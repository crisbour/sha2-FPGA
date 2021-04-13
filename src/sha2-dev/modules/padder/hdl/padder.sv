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
genvar byte;
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
reg [DATA_BLOCK_REG_WIDTH-1:0] pad_init;
reg [DATA_BLOCK_REG_WIDTH-1:0] reg_mask;
reg [DATA_BLOCK_REG_WIDTH-1:0] extra_pad;
reg [1:0] reg_status;
wire [1:0] reg_status_actual;

reg [NUM_BYTES_WIDTH-1:0] shift_inc;
reg [NUM_BYTES_WIDTH-1:0] shift_measure;
reg [NUM_BYTES_WIDTH:0] valid_bytes;
reg [NUM_BYTES_WIDTH-1:0] next_byte;

reg [63:0] length_low;
reg [63:0] length_high;   // Theoretically used only for SHA384/512, practically never
reg [63:0] new_length_low;
reg [63:0] new_length_high;   // Theoretically used only for SHA384/512, practically never
reg reg_count;
wire reset;
wire [1:0] sha_type;

reg bom;        // Begining of message

wire shift_reg, m_transmit, empty_regs, last_received, complete;


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
assign complete = sha_type[1]? ~reg_status_actual[0] & (reg_count | ~sha_type[1]) && next_byte < 48 :
                    ~reg_status_actual[0] & (reg_count | ~sha_type[1]) && next_byte < 56;


//FSM registers
reg [2:0] state, state_next;
reg s_axis_tready_next, s_axis_tready_fsm;
reg m_axis_tlast_next;
localparam RESET = 0;
localparam FEED = 1;
localparam PAD = 2;
localparam EXTRA_PAD = 3;
localparam WAIT = 4;

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

// ---------- Decode TKEEP ------
// genvar by;
// always_latch begin
//     for(by=0;by<AXIS_TKEEP_WIDTH;by=by+1) begin
//         if(s_axis_tkeep == {{(AXIS_TKEEP_WIDTH-by-1){1'b0}},{(by+1){1'b1}}})
//             valid_bytes = by[5:0];
            
//     end
// end
always @(*) begin
    // encode FIFO IN (8b->4b)
          case (s_axis_tkeep)
              64'h1                : valid_bytes = 7'h1;
              64'h3                : valid_bytes = 7'h2;
              64'h7                : valid_bytes = 7'h3;
              64'hF                : valid_bytes = 7'h4;
              64'h1F               : valid_bytes = 7'h5;
              64'h3F               : valid_bytes = 7'h6;
              64'h7F               : valid_bytes = 7'h7;
              64'hFF               : valid_bytes = 7'h8;
              64'h1FF              : valid_bytes = 7'h9;
              64'h3FF              : valid_bytes = 7'ha;
              64'h7FF              : valid_bytes = 7'hb;
              64'hFFF              : valid_bytes = 7'hc;
              64'h1FFF             : valid_bytes = 7'hd;
              64'h3FFF             : valid_bytes = 7'he;
              64'h7FFF             : valid_bytes = 7'hf;
              64'hFFFF             : valid_bytes = 7'h10;
              64'h1FFFF            : valid_bytes = 7'h11;
              64'h3FFFF            : valid_bytes = 7'h12;
              64'h7FFFF            : valid_bytes = 7'h13;
              64'hFFFFF            : valid_bytes = 7'h14;
              64'h1FFFFF           : valid_bytes = 7'h15;
              64'h3FFFFF           : valid_bytes = 7'h16;
              64'h7FFFFF           : valid_bytes = 7'h17;
              64'hFFFFFF           : valid_bytes = 7'h18;
              64'h1FFFFFF          : valid_bytes = 7'h19;
              64'h3FFFFFF          : valid_bytes = 7'h1a;
              64'h7FFFFFF          : valid_bytes = 7'h1b;
              64'hFFFFFFF          : valid_bytes = 7'h1c;
              64'h1FFFFFFF         : valid_bytes = 7'h1d;
              64'h3FFFFFFF         : valid_bytes = 7'h1e;
              64'h7FFFFFFF         : valid_bytes = 7'h1f;
              64'hFFFFFFFF         : valid_bytes = 7'h20;
              64'h1_FFFFFFFF       : valid_bytes = 7'h21;
              64'h3_FFFFFFFF       : valid_bytes = 7'h22;
              64'h7_FFFFFFFF       : valid_bytes = 7'h23;
              64'hF_FFFFFFFF       : valid_bytes = 7'h24;
              64'h1F_FFFFFFFF      : valid_bytes = 7'h25;
              64'h3F_FFFFFFFF      : valid_bytes = 7'h26;
              64'h7F_FFFFFFFF      : valid_bytes = 7'h27;
              64'hFF_FFFFFFFF      : valid_bytes = 7'h28;
              64'h1FF_FFFFFFFF     : valid_bytes = 7'h29;
              64'h3FF_FFFFFFFF     : valid_bytes = 7'h2a;
              64'h7FF_FFFFFFFF     : valid_bytes = 7'h2b;
              64'hFFF_FFFFFFFF     : valid_bytes = 7'h2c;
              64'h1FFF_FFFFFFFF    : valid_bytes = 7'h2d;
              64'h3FFF_FFFFFFFF    : valid_bytes = 7'h2e;
              64'h7FFF_FFFFFFFF    : valid_bytes = 7'h2f;
              64'hFFFF_FFFFFFFF    : valid_bytes = 7'h30;
              64'h1FFFF_FFFFFFFF   : valid_bytes = 7'h31;
              64'h3FFFF_FFFFFFFF   : valid_bytes = 7'h32;
              64'h7FFFF_FFFFFFFF   : valid_bytes = 7'h33;
              64'hFFFFF_FFFFFFFF   : valid_bytes = 7'h34;
              64'h1FFFFF_FFFFFFFF  : valid_bytes = 7'h35;
              64'h3FFFFF_FFFFFFFF  : valid_bytes = 7'h36;
              64'h7FFFFF_FFFFFFFF  : valid_bytes = 7'h37;
              64'hFFFFFF_FFFFFFFF  : valid_bytes = 7'h38;
              64'h1FFFFFF_FFFFFFFF : valid_bytes = 7'h39;
              64'h3FFFFFF_FFFFFFFF : valid_bytes = 7'h3a;
              64'h7FFFFFF_FFFFFFFF : valid_bytes = 7'h3b;
              64'hFFFFFFF_FFFFFFFF : valid_bytes = 7'h3c;
              64'h1FFFFFFF_FFFFFFFF: valid_bytes = 7'h3d;
              64'h3FFFFFFF_FFFFFFFF: valid_bytes = 7'h3e;
              64'h7FFFFFFF_FFFFFFFF: valid_bytes = 7'h3f;
              64'hFFFFFFFF_FFFFFFFF: valid_bytes = 7'h40;
              default:  valid_bytes = 7'h40;
          endcase
end


// ---------- FSM --------------

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



// Count length of padded message
always @(*) begin
    if(s_axis_tlast)begin
        new_length_low = length_low + ({57'b0,valid_bytes} << 3);
    end
    else begin  // Write tdata to R_reg and raise the flag for a new register
        new_length_low = length_low + DATA_BLOCK_REG_WIDTH;
    end
    if(new_length_low == 0)begin
        new_length_low = 0;
        new_length_high = length_high + 1;
    end
    else
        new_length_high = length_high;
end

task update_length;
    begin
        length_low  <= new_length_low;
        length_high <= new_length_high;
    end
endtask : update_length

always @(*) begin
    case(next_byte)
        0:  begin reg_mask = {{64{8'h0}}, {0{8'hff}}};     pad_init = {{63{8'h0}}, 8'h80,  {0{8'h0}}}; end
        1:  begin reg_mask = {{63{8'h0}}, {1{8'hff}}};     pad_init = {{62{8'h0}}, 8'h80,  {1{8'h0}}}; end
        2:  begin reg_mask = {{62{8'h0}}, {2{8'hff}}};     pad_init = {{61{8'h0}}, 8'h80,  {2{8'h0}}}; end
        3:  begin reg_mask = {{61{8'h0}}, {3{8'hff}}};     pad_init = {{60{8'h0}}, 8'h80,  {3{8'h0}}}; end
        4:  begin reg_mask = {{60{8'h0}}, {4{8'hff}}};     pad_init = {{59{8'h0}}, 8'h80,  {4{8'h0}}}; end
        5:  begin reg_mask = {{59{8'h0}}, {5{8'hff}}};     pad_init = {{58{8'h0}}, 8'h80,  {5{8'h0}}}; end
        6:  begin reg_mask = {{58{8'h0}}, {6{8'hff}}};     pad_init = {{57{8'h0}}, 8'h80,  {6{8'h0}}}; end
        7:  begin reg_mask = {{57{8'h0}}, {7{8'hff}}};     pad_init = {{56{8'h0}}, 8'h80,  {7{8'h0}}}; end
        8:  begin reg_mask = {{56{8'h0}}, {8{8'hff}}};     pad_init = {{55{8'h0}}, 8'h80,  {8{8'h0}}}; end
        9:  begin reg_mask = {{55{8'h0}}, {9{8'hff}}};     pad_init = {{54{8'h0}}, 8'h80,  {9{8'h0}}}; end
        10: begin reg_mask = {{54{8'h0}}, {10{8'hff}}};    pad_init = {{53{8'h0}}, 8'h80,  {10{8'h0}}}; end
        11: begin reg_mask = {{53{8'h0}}, {11{8'hff}}};    pad_init = {{52{8'h0}}, 8'h80,  {11{8'h0}}}; end
        12: begin reg_mask = {{52{8'h0}}, {12{8'hff}}};    pad_init = {{51{8'h0}}, 8'h80,  {12{8'h0}}}; end
        13: begin reg_mask = {{51{8'h0}}, {13{8'hff}}};    pad_init = {{50{8'h0}}, 8'h80,  {13{8'h0}}}; end
        14: begin reg_mask = {{50{8'h0}}, {14{8'hff}}};    pad_init = {{49{8'h0}}, 8'h80,  {14{8'h0}}}; end
        15: begin reg_mask = {{49{8'h0}}, {15{8'hff}}};    pad_init = {{48{8'h0}}, 8'h80,  {15{8'h0}}}; end
        16: begin reg_mask = {{48{8'h0}}, {16{8'hff}}};    pad_init = {{47{8'h0}}, 8'h80,  {16{8'h0}}}; end
        17: begin reg_mask = {{47{8'h0}}, {17{8'hff}}};    pad_init = {{46{8'h0}}, 8'h80,  {17{8'h0}}}; end
        18: begin reg_mask = {{46{8'h0}}, {18{8'hff}}};    pad_init = {{45{8'h0}}, 8'h80,  {18{8'h0}}}; end
        19: begin reg_mask = {{45{8'h0}}, {19{8'hff}}};    pad_init = {{44{8'h0}}, 8'h80,  {19{8'h0}}}; end
        20: begin reg_mask = {{44{8'h0}}, {20{8'hff}}};    pad_init = {{43{8'h0}}, 8'h80,  {20{8'h0}}}; end
        21: begin reg_mask = {{43{8'h0}}, {21{8'hff}}};    pad_init = {{42{8'h0}}, 8'h80,  {21{8'h0}}}; end
        22: begin reg_mask = {{42{8'h0}}, {22{8'hff}}};    pad_init = {{41{8'h0}}, 8'h80,  {22{8'h0}}}; end
        23: begin reg_mask = {{41{8'h0}}, {23{8'hff}}};    pad_init = {{40{8'h0}}, 8'h80,  {23{8'h0}}}; end
        24: begin reg_mask = {{40{8'h0}}, {24{8'hff}}};    pad_init = {{39{8'h0}}, 8'h80,  {24{8'h0}}}; end
        25: begin reg_mask = {{39{8'h0}}, {25{8'hff}}};    pad_init = {{38{8'h0}}, 8'h80,  {25{8'h0}}}; end
        26: begin reg_mask = {{38{8'h0}}, {26{8'hff}}};    pad_init = {{37{8'h0}}, 8'h80,  {26{8'h0}}}; end
        27: begin reg_mask = {{37{8'h0}}, {27{8'hff}}};    pad_init = {{36{8'h0}}, 8'h80,  {27{8'h0}}}; end
        28: begin reg_mask = {{36{8'h0}}, {28{8'hff}}};    pad_init = {{35{8'h0}}, 8'h80,  {28{8'h0}}}; end
        29: begin reg_mask = {{35{8'h0}}, {29{8'hff}}};    pad_init = {{34{8'h0}}, 8'h80,  {29{8'h0}}}; end
        30: begin reg_mask = {{34{8'h0}}, {30{8'hff}}};    pad_init = {{33{8'h0}}, 8'h80,  {30{8'h0}}}; end
        31: begin reg_mask = {{33{8'h0}}, {31{8'hff}}};    pad_init = {{32{8'h0}}, 8'h80,  {31{8'h0}}}; end
        32: begin reg_mask = {{32{8'h0}}, {32{8'hff}}};    pad_init = {{31{8'h0}}, 8'h80,  {32{8'h0}}}; end
        33: begin reg_mask = {{31{8'h0}}, {33{8'hff}}};    pad_init = {{30{8'h0}}, 8'h80,  {33{8'h0}}}; end
        34: begin reg_mask = {{30{8'h0}}, {34{8'hff}}};    pad_init = {{29{8'h0}}, 8'h80,  {34{8'h0}}}; end
        35: begin reg_mask = {{29{8'h0}}, {35{8'hff}}};    pad_init = {{28{8'h0}}, 8'h80,  {35{8'h0}}}; end
        36: begin reg_mask = {{28{8'h0}}, {36{8'hff}}};    pad_init = {{27{8'h0}}, 8'h80,  {36{8'h0}}}; end
        37: begin reg_mask = {{27{8'h0}}, {37{8'hff}}};    pad_init = {{26{8'h0}}, 8'h80,  {37{8'h0}}}; end
        38: begin reg_mask = {{26{8'h0}}, {38{8'hff}}};    pad_init = {{25{8'h0}}, 8'h80,  {38{8'h0}}}; end
        39: begin reg_mask = {{25{8'h0}}, {39{8'hff}}};    pad_init = {{24{8'h0}}, 8'h80,  {39{8'h0}}}; end
        40: begin reg_mask = {{24{8'h0}}, {40{8'hff}}};    pad_init = {{23{8'h0}}, 8'h80,  {40{8'h0}}}; end
        41: begin reg_mask = {{23{8'h0}}, {41{8'hff}}};    pad_init = {{22{8'h0}}, 8'h80,  {41{8'h0}}}; end
        42: begin reg_mask = {{22{8'h0}}, {42{8'hff}}};    pad_init = {{21{8'h0}}, 8'h80,  {42{8'h0}}}; end
        43: begin reg_mask = {{21{8'h0}}, {43{8'hff}}};    pad_init = {{20{8'h0}}, 8'h80,  {43{8'h0}}}; end
        44: begin reg_mask = {{20{8'h0}}, {44{8'hff}}};    pad_init = {{19{8'h0}}, 8'h80,  {44{8'h0}}}; end
        45: begin reg_mask = {{19{8'h0}}, {45{8'hff}}};    pad_init = {{18{8'h0}}, 8'h80,  {45{8'h0}}}; end
        46: begin reg_mask = {{18{8'h0}}, {46{8'hff}}};    pad_init = {{17{8'h0}}, 8'h80,  {46{8'h0}}}; end
        47: begin reg_mask = {{17{8'h0}}, {47{8'hff}}};    pad_init = {{16{8'h0}}, 8'h80,  {47{8'h0}}}; end
        48: begin reg_mask = {{16{8'h0}}, {48{8'hff}}};    pad_init = {{15{8'h0}}, 8'h80,  {48{8'h0}}}; end
        49: begin reg_mask = {{15{8'h0}}, {49{8'hff}}};    pad_init = {{14{8'h0}}, 8'h80,  {49{8'h0}}}; end
        50: begin reg_mask = {{14{8'h0}}, {50{8'hff}}};    pad_init = {{13{8'h0}}, 8'h80,  {50{8'h0}}}; end
        51: begin reg_mask = {{13{8'h0}}, {51{8'hff}}};    pad_init = {{12{8'h0}}, 8'h80,  {51{8'h0}}}; end
        52: begin reg_mask = {{12{8'h0}}, {52{8'hff}}};    pad_init = {{11{8'h0}}, 8'h80,  {52{8'h0}}}; end
        53: begin reg_mask = {{11{8'h0}}, {53{8'hff}}};    pad_init = {{10{8'h0}}, 8'h80,  {53{8'h0}}}; end
        54: begin reg_mask = {{10{8'h0}}, {54{8'hff}}};    pad_init = {{9{8'h0}},  8'h80,  {54{8'h0}}}; end
        55: begin reg_mask = {{9{8'h0}},  {55{8'hff}}};    pad_init = {{8{8'h0}},  8'h80,  {55{8'h0}}}; end
        56: begin reg_mask = {{8{8'h0}},  {56{8'hff}}};    pad_init = {{7{8'h0}},  8'h80,  {56{8'h0}}}; end
        57: begin reg_mask = {{7{8'h0}},  {57{8'hff}}};    pad_init = {{6{8'h0}},  8'h80,  {57{8'h0}}}; end
        58: begin reg_mask = {{6{8'h0}},  {58{8'hff}}};    pad_init = {{5{8'h0}},  8'h80,  {58{8'h0}}}; end
        59: begin reg_mask = {{5{8'h0}},  {59{8'hff}}};    pad_init = {{4{8'h0}},  8'h80,  {59{8'h0}}}; end
        60: begin reg_mask = {{4{8'h0}},  {60{8'hff}}};    pad_init = {{3{8'h0}},  8'h80,  {60{8'h0}}}; end
        61: begin reg_mask = {{3{8'h0}},  {61{8'hff}}};    pad_init = {{2{8'h0}},  8'h80,  {61{8'h0}}}; end
        62: begin reg_mask = {{2{8'h0}},  {62{8'hff}}};    pad_init = {{1{8'h0}},  8'h80,  {62{8'h0}}}; end
        63: begin reg_mask = {{1{8'h0}},  {63{8'hff}}};    pad_init = {{0{8'h0}},  8'h80,  {63{8'h0}}}; end
    endcase
    if(complete) begin // If the length fits, then pad with 0s all but the length bytes and assert tlast
        // If the length doesn't fit in the padding, just pad with 0s the rest and go to next block
        // Length is written in big-endian format
        if(sha_type[1]) begin
            pad = (R_reg & reg_mask) | pad_init | {big_endian(length_low),big_endian(length_high),{384{1'b0}}};
        end else begin
            pad = (R_reg & reg_mask) | pad_init | {big_endian(length_low),{448{1'b0}}};
        end
    end
    else
        pad = (R_reg & reg_mask) | pad_init;
end

// Extra padding
always @(*) begin
    if(sha_type[1]) begin
        extra_pad = {big_endian(length_low),big_endian(length_high),{384{1'b0}}};
    end else begin
        extra_pad = {big_endian(length_low),{448{1'b0}}};
    end
end



// Feed R_reg
always @(posedge axis_aclk) begin
    if(reset) begin
        L_reg <= 0;
	    R_reg <= 0;
    end
    else begin
        if(shift_reg)
            L_reg <= R_reg;

        case(state)
            RESET: begin
                bom <= 1;
                reg_status <= 2'b00;
                length_low <= 0;
                length_high <= 0;
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
                            next_byte <= valid_bytes[NUM_BYTES_WIDTH-1:0];
                            update_length();
                            if(valid_bytes == 64) begin    // If there weren't any null bytes in the last frame
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
                            update_length();
                        end
                    end
                    else begin  // No message block has been received
                        reg_status <= reg_status_actual;
                    end
                end
            end

            PAD: begin
                if(~reg_status_actual[0])begin   // If R_reg is not completed or if it will be propagated at the next clock edge, then we can carry on with padding
                    R_reg <= pad;
                    reg_status <= reg_status_actual | 2'b01;
                    next_byte <= 0;
                    reg_count <= ~reg_count;
                end
            end
            EXTRA_PAD: begin
                if(~reg_status_actual[0]) begin
                    if(~reg_count & sha_type[1]) begin // In the case of SHA384/512 verify that an even number of 512b blocks has been created
                        R_reg <= 0;
                        reg_count <= ~reg_count;
                    end else begin // Then pad with 0's and append the length value
                        // Length is written in big-endian format
                        // I assumed the length will never surprass 2^64-1, which is a reasonable assumption
                        R_reg <= extra_pad;
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

