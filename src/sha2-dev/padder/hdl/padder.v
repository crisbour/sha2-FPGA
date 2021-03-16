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

`define HARD_WIRED
module padder
#(
    // AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=512,
    parameter C_S_AXIS_DATA_WIDTH=512,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128
)
(
// Global Ports
input axis_aclk,
input axis_resetn,

// Master Stream Port
output [(C_M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
output reg [(C_M_AXIS_TUSER_WIDTH-1):0] m_axis_tuser,
output m_axis_tvalid,
input m_axis_tready,
output reg m_axis_tlast,

// Slave Stream Port
input [(C_S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
// Bits 34 and 33 of tuser represent sha_type
// msb is 0 if SHA224/256 and 1 if SHA384/512
input [(C_S_AXIS_TUSER_WIDTH-1):0] s_axis_tuser,
input [((C_M_AXIS_DATA_WIDTH)/8-1):0] s_axis_tkeep,
input s_axis_tvalid,
output wire s_axis_tready,
input s_axis_tlast
);

localparam M_AXIS_TKEEP_WIDTH = C_M_AXIS_DATA_WIDTH/8;
localparam DATA_BLOCK_REG_WIDTH=512;

// ----- TUSER specs for identify sha_type ----
localparam TUESR_SLOT_OFFSET = 32;
localparam TUSER_SLOT_WIDTH = 16;
localparam HASH_TUSER_SLOT = 0;
localparam SHA_TUSER_OFFSET = 0;

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

// ---------- Internal Parameters ------------------
localparam C_S_AXIS_TKEEP_WIDTH = C_M_AXIS_DATA_WIDTH/8;
localparam NUM_BYTES_WIDTH = log2(C_S_AXIS_TKEEP_WIDTH);
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
assign sha_type = bom   ? s_axis_tuser[TUSER_SLOT_WIDTH*HASH_TUSER_SLOT+TUESR_SLOT_OFFSET+SHA_TUSER_OFFSET+1:
                                TUSER_SLOT_WIDTH*HASH_TUSER_SLOT+TUESR_SLOT_OFFSET+SHA_TUSER_OFFSET] 
                        : m_axis_tuser[TUSER_SLOT_WIDTH*HASH_TUSER_SLOT+TUESR_SLOT_OFFSET+SHA_TUSER_OFFSET+1:
                                TUSER_SLOT_WIDTH*HASH_TUSER_SLOT+TUESR_SLOT_OFFSET+SHA_TUSER_OFFSET];
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
/* verilator lint_off LATCH */
genvar by;
generate
    for(by=0;by<M_AXIS_TKEEP_WIDTH;by=by+1) begin
        always @(*) begin
            if(s_axis_tkeep == {{(M_AXIS_TKEEP_WIDTH-by-1){1'b0}},{(by+1){1'b1}}})
                last_valid_byte = by;
        end
    end
endgenerate
/* verilator lint_on LATCH */

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

