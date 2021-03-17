`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Oxford
// Engineer: Cristian Bourceanu
//
// Create Date: 17.11.2020 10:54:31
// Design Name: Padder
// Module Name: padder
// Project Name: Hashing Engine
// Target Devices: Alveo U280
// Tool Versions: v1_0
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "multiformats_codec.vh"
`define HARD_WIRED
module padder
#(
    // AXI Stream Data Width
    parameter C_AXIS_DATA_WIDTH=512,
    parameter C_AXIS_TUSER_WIDTH=128
)
(
// Global Ports
input axis_aclk,
input axis_resetn,

// Master Stream Port
output [(C_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
output reg [(C_AXIS_TUSER_WIDTH-1):0] m_axis_tuser,
output m_axis_tvalid,
input m_axis_tready,
output reg m_axis_tlast,

// Slave Stream Port
input [(C_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
// Bits 34 and 33 of tuser represent sha_type
// msb is 0 if SHA224/256 and 1 if SHA384/512
input [(C_AXIS_TUSER_WIDTH-1):0] s_axis_tuser,
input [((C_AXIS_DATA_WIDTH)/8-1):0] s_axis_tkeep,
input s_axis_tvalid,
output wire s_axis_tready,
input s_axis_tlast
);

// ----- TUSER specs for identify sha_type ----
localparam TUESR_SLOT_OFFSET = 32;
localparam TUSER_SLOT_WIDTH = 16;

function integer log2;
    input integer number;
    begin
        log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
    end
endfunction // log2

// Function to change endianess of length value
function [63:0] big_endian;
input [63:0] length_value;
`ifdef HARD_WIRED
begin
    big_endian[63:56] = length_value[7:0];
    big_endian[55:48] = length_value[15:8];
    big_endian[47:40] = length_value[23:16];
    big_endian[39:32] = length_value[31:24];
    big_endian[31:24] = length_value[39:32];
    big_endian[23:16] = length_value[47:40];
    big_endian[15: 8] = length_value[55:48];
    big_endian[7 : 0] = length_value[63:56];
end
`else
integer byte;
for(byte=0;byte<8;byte=byte+1)begin
    big_endian[(8-byte)*8-1:(7-byte)*8] = length_value[8*(byte+1)-1:8*byte];
end
`endif
endfunction //big_endian

// ---------- Sha identification -----------------
// Bit 0 signifies if the codec is supported
// Bit 1 signifies whether it is a 512 or 1024 block based sha hash. Supports sha1 and sha2
function [1:0] sha_id;
    input [C_AXIS_TUSER_WIDTH-1:0] tuser;
    reg [15:0] codec;
    begin
        if(tuser[`CODEC_POS + 7: `CODEC_POS] >= 8'h80) 
            codec = {tuser[`CODEC_POS+7: `CODEC_POS],tuser[`CODEC_POS+15: `CODEC_POS+8]};
        else
            codec = tuser[`CODEC_POS + 15: `CODEC_POS];
        case(codec)
            `CODEC_SHA1:        sha_id = 2'b01;
            `CODEC_MD5:         sha_id = 2'b01;
            `CODEC_MD4:         sha_id = 2'b01;
            `CODEC_RIPEMD_128:  sha_id = 2'b01;
            `CODEC_RIPEMD_160:  sha_id = 2'b01;
            `CODEC_RIPEMD_256:  sha_id = 2'b01;
            `CODEC_RIPEMD_320:  sha_id = 2'b01;
            `CODEC_SHA2_224:    sha_id = 2'b01;
            `CODEC_SHA2_256:    sha_id = 2'b01;
            `CODEC_SHA2_384:    sha_id = 2'b11;
            `CODEC_SHA2_512:    sha_id = 2'b11;
            default:            sha_id = 2'b00;
        endcase
    end

endfunction

// ---------- Internal Parameters ------------------
localparam AXIS_TKEEP_WIDTH = C_AXIS_DATA_WIDTH/8;
localparam DATA_BLOCK_REG_WIDTH=512;
localparam NUM_BYTES_WIDTH = log2(AXIS_TKEEP_WIDTH);
localparam LEN_FIELD_BYTES = 8;
localparam LEN_FIELD_WIDTH = 8 * LEN_FIELD_BYTES;

// --------- Registers and wires --------------
// If 32 bytes blocks are needed (SHA256), then use only the R_reg,
// otherwise use both of them
reg [DATA_BLOCK_REG_WIDTH-1:0] R_reg;
reg [DATA_BLOCK_REG_WIDTH-1:0] L_reg;
reg [DATA_BLOCK_REG_WIDTH-1:0] pad;
reg [1:0] reg_status;
wire [1:0] reg_status_actual;

reg [NUM_BYTES_WIDTH-1:0] shift_inc;
reg [NUM_BYTES_WIDTH-1:0] shift_measure;
reg [NUM_BYTES_WIDTH-1:0] last_valid_byte;
reg [NUM_BYTES_WIDTH-1:0] next_byte;

reg [63:0] length_low;
reg [63:0] length_high;   // Theoretically used only for SHA384/512, practically never
reg reg_count;
wire reset;
wire [1:0] sha_type;

reg bom;        // Begining of message

wire shift_reg, m_transmit, empty_regs, last_received, complete;

// Initial values
initial begin
    state = RESET;
    m_axis_tlast = 0;
    s_axis_tready_fsm = 0;
    s_axis_tready_next = 0;
    reg_status = 2'b00;
    length_low = 0;
    length_high = 0;
    reg_count = 0;
    next_byte = 0;
    m_axis_tuser = 0;
end


// ----------- Logic -----------
// Identify sha_type
assign sha_type = bom   ? sha_id(s_axis_tuser) : sha_id(m_axis_tuser);
// Transmitting padded message block
assign m_axis_tvalid = sha_type[1] ? reg_status[1] : reg_status[0];
assign m_axis_tdata = sha_type[1] ? L_reg : R_reg;
assign m_transmit = m_axis_tvalid & m_axis_tready;
assign s_axis_tready = (m_transmit 
                    | ~reg_status[0] 
                    | (sha_type[1] & ~reg_status[1])) 
                    & s_axis_tready_fsm;
assign reset = ~axis_resetn;

// FSM dependent wires
// free_reg, empty_reg and complete and indicators for what would be the state at the next clock cycle
// in the absence of feeding
// If transmission on m_axis or (SHA384/512 and free L_reg), shift reg status
assign shift_reg = m_transmit | (sha_type[1] & ~reg_status[1]);
assign reg_status_actual = shift_reg ? (reg_status << 1) : reg_status;

assign empty_regs = sha_type[1] ? reg_status_actual == 2'b00 : ~reg_status_actual[0];
assign last_received = s_axis_tlast & s_axis_tready & s_axis_tvalid;

// Complete when there are available 
// 9 bytes (8bytes len and 1 byte = x80) for SHA256 or 17 bytes for SHA384/512
assign complete = ~reg_status_actual[0] & (reg_count | ~sha_type[1]) 
                & (next_byte < 56 - 8*sha_type[1]);



// ---------- Decode TKEEP ------
genvar by;
generate
    integer local_last_valid_byte;
    for(by=0;by<AXIS_TKEEP_WIDTH;by=by+1) begin
        always_latch begin
            if(s_axis_tkeep == {{(AXIS_TKEEP_WIDTH-by-1){1'b0}},{(by+1){1'b1}}})
                local_last_valid_byte = by;
                
        end
    end
    always @(*) last_valid_byte = local_last_valid_byte[5:0];
endgenerate
// always @(*) begin
//     // encode FIFO IN (8b->4b)
//           case (s_axis_tkeep)
//               64'h1                : last_valid_byte = 6'h0;
//               64'h3                : last_valid_byte = 6'h1;
//               64'h7                : last_valid_byte = 6'h2;
//               64'hF                : last_valid_byte = 6'h3;
//               64'h1F               : last_valid_byte = 6'h4;
//               64'h3F               : last_valid_byte = 6'h5;
//               64'h7F               : last_valid_byte = 6'h6;
//               64'hFF               : last_valid_byte = 6'h7;
//               64'h1FF              : last_valid_byte = 6'h8;
//               64'h3FF              : last_valid_byte = 6'h9;
//               64'h7FF              : last_valid_byte = 6'ha;
//               64'hFFF              : last_valid_byte = 6'hb;
//               64'h1FFF             : last_valid_byte = 6'hc;
//               64'h3FFF             : last_valid_byte = 6'hd;
//               64'h7FFF             : last_valid_byte = 6'he;
//               64'hFFFF             : last_valid_byte = 6'hf;
//               64'h1FFFF            : last_valid_byte = 6'h10;
//               64'h3FFFF            : last_valid_byte = 6'h11;
//               64'h7FFFF            : last_valid_byte = 6'h12;
//               64'hFFFFF            : last_valid_byte = 6'h13;
//               64'h1FFFFF           : last_valid_byte = 6'h14;
//               64'h3FFFFF           : last_valid_byte = 6'h15;
//               64'h7FFFFF           : last_valid_byte = 6'h16;
//               64'hFFFFFF           : last_valid_byte = 6'h17;
//               64'h1FFFFFF          : last_valid_byte = 6'h18;
//               64'h3FFFFFF          : last_valid_byte = 6'h19;
//               64'h7FFFFFF          : last_valid_byte = 6'h1a;
//               64'hFFFFFFF          : last_valid_byte = 6'h1b;
//               64'h1FFFFFFF         : last_valid_byte = 6'h1c;
//               64'h3FFFFFFF         : last_valid_byte = 6'h1d;
//               64'h7FFFFFFF         : last_valid_byte = 6'h1e;
//               64'hFFFFFFFF         : last_valid_byte = 6'h1f;
//               64'h1_FFFFFFFF       : last_valid_byte = 6'h20;
//               64'h3_FFFFFFFF       : last_valid_byte = 6'h21;
//               64'h7_FFFFFFFF       : last_valid_byte = 6'h22;
//               64'hF_FFFFFFFF       : last_valid_byte = 6'h23;
//               64'h1F_FFFFFFFF      : last_valid_byte = 6'h24;
//               64'h3F_FFFFFFFF      : last_valid_byte = 6'h25;
//               64'h7F_FFFFFFFF      : last_valid_byte = 6'h26;
//               64'hFF_FFFFFFFF      : last_valid_byte = 6'h27;
//               64'h1FF_FFFFFFFF     : last_valid_byte = 6'h28;
//               64'h3FF_FFFFFFFF     : last_valid_byte = 6'h29;
//               64'h7FF_FFFFFFFF     : last_valid_byte = 6'h2a;
//               64'hFFF_FFFFFFFF     : last_valid_byte = 6'h2b;
//               64'h1FFF_FFFFFFFF    : last_valid_byte = 6'h2c;
//               64'h3FFF_FFFFFFFF    : last_valid_byte = 6'h2d;
//               64'h7FFF_FFFFFFFF    : last_valid_byte = 6'h2e;
//               64'hFFFF_FFFFFFFF    : last_valid_byte = 6'h2f;
//               64'h1FFFF_FFFFFFFF   : last_valid_byte = 6'h30;
//               64'h3FFFF_FFFFFFFF   : last_valid_byte = 6'h31;
//               64'h7FFFF_FFFFFFFF   : last_valid_byte = 6'h32;
//               64'hFFFFF_FFFFFFFF   : last_valid_byte = 6'h33;
//               64'h1FFFFF_FFFFFFFF  : last_valid_byte = 6'h34;
//               64'h3FFFFF_FFFFFFFF  : last_valid_byte = 6'h35;
//               64'h7FFFFF_FFFFFFFF  : last_valid_byte = 6'h36;
//               64'hFFFFFF_FFFFFFFF  : last_valid_byte = 6'h37;
//               64'h1FFFFFF_FFFFFFFF : last_valid_byte = 6'h38;
//               64'h3FFFFFF_FFFFFFFF : last_valid_byte = 6'h39;
//               64'h7FFFFFF_FFFFFFFF : last_valid_byte = 6'h3a;
//               64'hFFFFFFF_FFFFFFFF : last_valid_byte = 6'h3b;
//               64'h1FFFFFFF_FFFFFFFF: last_valid_byte = 6'h3c;
//               64'h3FFFFFFF_FFFFFFFF: last_valid_byte = 6'h3d;
//               64'h7FFFFFFF_FFFFFFFF: last_valid_byte = 6'h3e;
//               64'hFFFFFFFF_FFFFFFFF: last_valid_byte = 6'h3f;
//               default:  last_valid_byte = 6'h00;
//           endcase
// end

// ---------- FSM --------------
//FSM registers
reg [2:0] state, state_next;
reg s_axis_tready_next, s_axis_tready_fsm;
reg m_axis_tlast_next;
localparam RESET = 0;
localparam FEED = 1;
localparam PAD = 2;
localparam EXTRA_PAD = 3;
localparam WAIT = 4;

// FSM transitions
always @(*) begin
    state_next = state;
    s_axis_tready_next = s_axis_tready;
    m_axis_tlast_next = m_axis_tlast;
    case(state)
        RESET: begin
            s_axis_tready_next = 0;
            state_next = FEED;
            s_axis_tready_next = 1;
        end
        FEED: begin
            s_axis_tready_next = 1;
            if(last_received) begin
                s_axis_tready_next = 0;
                state_next = PAD;
            end
        end
        PAD: begin
            s_axis_tready_next = 0;
            if(~reg_status_actual[0]) begin
                if(complete) begin 
                    state_next = WAIT;
                    if(~sha_type[1]) // In contrast SHA384/512may wait for one extra block
                        m_axis_tlast_next = 1;
                end else begin
                    state_next = EXTRA_PAD;
                end
            end
        end
        EXTRA_PAD: begin
            s_axis_tready_next = 0;
            if(complete) begin
                state_next = WAIT;
                if(~sha_type[1]) // In contrast SHA384/512may wait for one extra block
                    m_axis_tlast_next = 1;
            end
        end
        WAIT: begin
            s_axis_tready_next = 0;
            if(~reg_status_actual[0])   // SHA384/512 Check outstanding blocks
                m_axis_tlast_next = 1;
            if(empty_regs) begin
                state_next = RESET;
                m_axis_tlast_next = 0;
            end
        end
    endcase
end

//----------Seq Logic----------------------
always @(posedge axis_aclk)
begin: FSM_SEQ
    if(reset) begin
        state <= RESET;
        m_axis_tlast <= 0;
        s_axis_tready_fsm <= 0;

    end
    else begin
        state <= state_next;
        s_axis_tready_fsm <= s_axis_tready_next;
        m_axis_tlast <= m_axis_tlast_next;
    end
end

/*
******** Feed Data In Logic *******
*/

// Propagate data from R_reg to L_reg if needed
always @(posedge axis_aclk) begin
    if(shift_reg & ~reset)
        L_reg <= R_reg;
end

// Count length of padded message
task count_message;
    input [63:0] length_inc;
    begin
        length_low = length_low + length_inc;
        if(length_low == 0)begin
            length_high = length_high + 1;
        end
    end
endtask : count_message

// Feed R_reg
always @(posedge axis_aclk) begin
    if(reset) begin
        R_reg <= 0;
        L_reg <= 0;
    end
    else begin
        case(state)
            RESET: begin
                bom <= 1;
                reg_status <= 2'b00;
                length_low = 0;
                length_high = 0;
                reg_count <= 0;
            end

            FEED: begin
                if(~reg_status_actual[0]) begin
                    if(s_axis_tvalid) begin
                        // Store tuser at the begining of message transmission
                        if(bom)
                            m_axis_tuser <= s_axis_tuser;
                        bom <= 0;

                        if(s_axis_tlast)begin
                            // Write tdata to R_reg
                            R_reg <= s_axis_tdata;
                            next_byte <= last_valid_byte + 1;
                            count_message(({58'b0,last_valid_byte} + 1) * 8);
                            if(last_valid_byte + 1 == 64) begin    // If there weren't any null bytes in the last frame
                                reg_status <= reg_status_actual | 2'b01;
                                reg_count <= ~reg_count;
                            end else begin
                                reg_status <= reg_status_actual;
                            end
                        end
                        else begin  // Write tdata to R_reg and raise the flag for a new register
                            R_reg <= s_axis_tdata;
                            reg_status <= reg_status_actual | 2'b01;
                            reg_count <= ~reg_count;
                            count_message(DATA_BLOCK_REG_WIDTH);
                        end
                    end
                    else begin  // No message block has been received
                        reg_status <= reg_status_actual;
                    end
                end
            end

            PAD: begin
                if(~reg_status_actual[0])begin   // If R_reg is not completed or if it will be propagated at the next clock edge, then we can carry on with padding
                    pad = 512'h80 << (8 * next_byte);
                    if(complete) begin // If the length fits, then pad with 0s all but the length bytes and assert tlast
                        // If the length doesn't fit in the padding, just pad with 0s the rest and go to next block
                        // Length is written in big-endian format
                        if(sha_type[1]) begin
                            pad = pad | {{384{1'b0}},big_endian(length_low),big_endian(length_high)} 
                                            << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH * 2);
                        end else begin
                            pad = pad | {{448{1'b0}},big_endian(length_low)} << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH);
                        end

                    end
                    R_reg <= (R_reg & ((1<<(8 * next_byte)) - 1)) | pad;
                    reg_status <= reg_status_actual | 2'b01;
                    next_byte <= 0;
                    reg_count <= ~reg_count;
                end
            end
            EXTRA_PAD: begin
                if(~reg_status_actual[0]) begin
                    if(~reg_count & sha_type[1]) begin // In the case of SHA384/512 verify that an even number of 512b blocks has been created
                        R_reg[DATA_BLOCK_REG_WIDTH-1:0] <= 0;
                        reg_count <= ~reg_count;
                    end else begin // Then pad with 0's and append the length value
                        // Length is written in big-endian format
                        // I assumed the length will never surprass 2^64-1, which is a reasonable assumption
                        if(sha_type[1]) begin
                            R_reg <= {{384{1'b0}},big_endian(length_low),big_endian(length_high)}  
                                            << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH * 2);
                        end else begin
                            R_reg <= {{448{1'b0}},big_endian(length_low)} << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH);
                        end
                        reg_count <= ~reg_count;
                    end
                    reg_status <= reg_status_actual | 2'b01;
                end
            end
            WAIT: begin
                reg_status <= reg_status_actual;
            end
        endcase // state
    end
end


`ifdef COCOTB_SIM
`ifndef VERILATOR // traced differently
initial begin
  $dumpfile ("dump.vcd");
  $dumpvars (0,padder);
  #1;
end
`endif
`endif

endmodule

