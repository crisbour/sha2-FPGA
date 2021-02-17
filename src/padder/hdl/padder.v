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
    parameter P_M_AXIS_DATA_WIDTH=512,
    parameter P_S_AXIS_DATA_WIDTH=512,
    parameter DATA_BLOCK_REG_WIDTH=512
)
(
// Global Ports
input axi_aclk,
input axi_resetn,

// Control
input [1:0] sha_type,  // msf bit is 0 if SHA224/256 and 1 if SHA384/512
input en,   // 1 if the hashing engine has been enabled by the scheduler

// Master Stream Port
output [(P_M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
output m_axis_tvalid,
input m_axis_tready,
output reg m_axis_tlast,

// Slave Stream Port
input [(P_S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
input [((P_M_AXIS_DATA_WIDTH)/8-1):0] s_axis_tkeep,
input s_axis_tvalid,
output wire s_axis_tready,
input s_axis_tlast
);
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
localparam P_S_AXIS_TKEEP_WIDTH=P_M_AXIS_DATA_WIDTH/8;
localparam NUM_BYTES_WIDTH = log2(P_S_AXIS_TKEEP_WIDTH);
localparam LEN_FIELD_BYTES = 8;
localparam LEN_FIELD_WIDTH = 8 * LEN_FIELD_BYTES;

// --------- Registers and wires --------------
// If 32 bytes blocks are needed (SHA256), then use only the R_reg,
// otherwise use both of them
reg [DATA_BLOCK_REG_WIDTH-1:0] R_reg;
reg [DATA_BLOCK_REG_WIDTH-1:0] L_reg;
reg [DATA_BLOCK_REG_WIDTH-1:0] pad;
reg [1:0] reg_status;
reg [NUM_BYTES_WIDTH-1:0] shift_inc;
reg [NUM_BYTES_WIDTH-1:0] shift_measure;
reg [NUM_BYTES_WIDTH-1:0] last_valid_byte;
reg [NUM_BYTES_WIDTH-1:0] next_byte;
reg [31:0] length_low;
reg [31:0] length_high;
reg reg_count;
wire reset;

// Initial values
initial begin
    state = IDLE;
    m_axis_tlast = 0;
    s_axis_tready_fsm = 0;
    s_axis_tready_next = 0;
    reg_status = 2'b00;
    length_low = 0;
    length_high = 0;
    reg_count = 0;
    next_byte = 0;
end


// ----------- Logic -----------
// Transmitting padded message block
assign m_axis_tvalid = sha_type ? reg_status[1] : reg_status[0];
assign m_axis_tdata = sha_type ? L_reg : R_reg;
assign s_axis_tready = (m_axis_tvalid & m_axis_tready | ~reg_status[0] | (sha_type & ~reg_status[1])) & s_axis_tready_fsm;
assign reset = ~axi_resetn;

// FSM dependent wires
// free_reg, empty_reg and complete and indicators for what will be the state at the next clock cycle
assign free_reg = m_axis_tvalid & m_axis_tready | ~reg_status[0] | (sha_type & ~reg_status[1]);
assign empty_reg = m_axis_tvalid & m_axis_tready & (sha_type ? reg_status == 2'b10 : reg_status[0]);
assign last_received = s_axis_tlast & s_axis_tready & s_axis_tvalid;

// Complete when there are available 
// 9 bytes (8bytes len and 1 byte = x80) for SHA256 or 17 bytes for SHA384/512
assign complete = free_reg & (reg_count | ~sha_type[1]) & (next_byte < 56 - 2*sha_type[1]);



// ---------- FSM --------------
//FSM registers
reg [2:0] state, state_next;
reg s_axis_tready_next, s_axis_tready_fsm;
reg m_axis_tlast_next;
localparam IDLE = 0;
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
        IDLE: begin
            s_axis_tready_next = 0;
            if(free_reg) begin
                state_next = FEED;
                s_axis_tready_next = 1;
            end
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
            if(free_reg) begin
                if(complete) begin 
                    state_next = WAIT;
                    m_axis_tlast_next = 1;
                end else begin
                    state_next = EXTRA_PAD;
                end
            end
        end
        EXTRA_PAD: begin
            s_axis_tready_next = 0;
            if(complete) begin
                m_axis_tlast_next = 1;
                state_next = WAIT;
            end
        end
        WAIT: begin
            s_axis_tready_next = 0;
            if(empty_reg) begin
                state_next = IDLE;
                m_axis_tlast_next = 0;
            end
        end
    endcase
end

//----------Seq Logic----------------------
always @(posedge axi_aclk)
begin: FSM_SEQ
    if(reset) begin
        state <=IDLE;
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
always @(posedge axi_aclk) begin
    if(sha_type[1] & ~reg_status[1]) begin
        L_reg <= R_reg;
        reg_status[1] <= reg_status[0];
    end
end

task count_message;
    input [31:0] length_inc;
    begin
        length_low = length_low + length_inc;
        if(length_low == 0)begin
            length_high = length_high + 1;
        end
    end
endtask : count_message
// Feed R_reg
always @(posedge axi_aclk) begin
    if(reset) begin
        R_reg <= #1 0;
        L_reg <= #1 0;
    end
    else begin
        case(state)
            IDLE: begin
                reg_status <= 2'b00;
                length_low <= 0;
                length_high <= 0;
                reg_count <= 0;
            end

            FEED: begin
                if(free_reg) begin
                    if(s_axis_tvalid) begin

                        if(s_axis_tlast)begin
                            // Find the last valid byte in tdata with binary search
                            last_valid_byte = 0;
                            shift_inc = P_S_AXIS_TKEEP_WIDTH >> 1;
                            shift_measure = P_S_AXIS_TKEEP_WIDTH >> 1;
                            while(shift_inc) begin
                                shift_inc = shift_inc >> 1;
                                if(s_axis_tkeep >> shift_measure)begin
                                    last_valid_byte = shift_measure;
                                    shift_measure = shift_measure + shift_inc;
                                end else begin
                                    shift_measure = shift_measure - shift_inc;
                                end
                            end
                            // Write tdata to R_reg
                            R_reg <= s_axis_tdata;
                            next_byte = last_valid_byte + 1;
                            count_message((last_valid_byte + 1) * 8);
                            if(next_byte == 0) begin    // If there weren't any null bytes in the last frame
                                reg_status[0] <= 1;
                                reg_count <= ~reg_count;
                            end else begin
                                reg_status[0] <= 0;
                            end
                        end
                        else begin  // Write tdata to R_reg and raise the flag for a new register
                            R_reg <= s_axis_tdata;
                            reg_status[0] <= 1;
                            reg_count <= ~reg_count;
                            count_message(DATA_BLOCK_REG_WIDTH);
                        end
                    end
                    else begin  // No message block has been received
                        reg_status[0] <= 0;
                    end
                end
            end

            PAD: begin
                if(free_reg)begin   // If R_reg is not completed or if it will be propagated at the next clock edge, then we can carry on with padding
                    pad = 8'h80 << (8 * next_byte);
                    if(complete) begin // If the length doesn't fit in the padding, just pad with 0s the rest and go to next block
                        // If the length fits, then pad with 0s all but the length bytes and assert tlast
                        // Length is written in big-endian format
                        if(sha_type) begin
                            pad = pad | {big_endian({length_high,length_low}),{16'h00}} << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH * 2);
                        end else begin
                            pad = pad | big_endian({length_high,length_low}) << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH);
                        end

                    end
                    R_reg <= (R_reg & ((1<<(8 * next_byte)) - 1)) | pad;
                    reg_status[0] <= 1;
                    next_byte = 0;
                    reg_count <= ~reg_count;
                end
            end
            EXTRA_PAD: begin
                if(free_reg) begin
                    if(~reg_count & sha_type) begin // In the case of SHA384/512 verify that an even number of 512b blocks has been created
                        R_reg[DATA_BLOCK_REG_WIDTH-1:0] <= 0;
                        reg_status[0] <= 1;
                    end else begin // Then pad with 0's and append the length value
                        // Length is written in big-endian format
                        // I assumed the length will never surprass 2^64-1, which is a reasonable assumption
                        if(sha_type) begin
                            R_reg <= {big_endian({length_high,length_low}),{16'h00}} << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH * 2);
                        end else begin
                            R_reg <= big_endian({length_high,length_low}) << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH);
                        end
                        reg_status[0] <= 1;
                        reg_count <= ~reg_count;
                    end
                end
            end
            WAIT: begin
                if(free_reg)begin
                    reg_status[0] <= 0;
                end
            end
        endcase // state
    end
end


`ifdef COCOTB_SIM
`ifndef VERILATOR // traced differently
initial begin
  $dumpfile ("waveform.vcd");
  $dumpvars (0,padder);
  #1;
end
`endif
`endif

endmodule

