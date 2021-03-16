`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Oxford
// Engineer: Cristian Bourceanu
// 
// Create Date: 28/02/2021
// Design Name: MultiHash
// Module Name: multihash
// Project Name: Hashing Processing Unit
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "multicodec_define.v"
module multihash_decode
#(
    // AXI Strem Data Width
    parameter C_AXIS_DATA_WIDTH=512,
    parameter C_AXIS_TUSER_WIDTH=128
)
(
    // Global Ports
    input axis_aclk,
    input axis_resetn,

    /*** Slave Steam Port ***/
    // Incomig words
    input [(C_AXIS_DATA_WIDTH-1):0]     s_axis_tdata,
    input [(C_AXIS_DATA_WIDTH/8-1):0]   s_axis_tkeep,
    input [(C_AXIS_TUSER_WIDTH-1):0]    s_axis_tuser,
    input   s_axis_tvalid,
    input   s_axis_tlast,
    output  s_axis_tready,

    // Message digest
    output reg [(C_AXIS_DATA_WIDTH-1):0]    m_axis_tdata,
    output reg [(C_AXIS_TUSER_WIDTH-1):0]   m_axis_tuser,
    output reg [(C_AXIS_DATA_WIDTH/8-1):0]  m_axis_tkeep,
    output reg  m_axis_tvalid,
    input       m_axis_tready,
    output reg  m_axis_tlast

);
// ----- TUSER specs for identify sha_type ----
localparam TUESR_SLOT_OFFSET = 32;
localparam TUSER_SLOT_WIDTH = 16;
localparam HASH_TUSER_SLOT = 0;

// DATA
localparam AXIS_TKEEP_WIDTH = C_AXIS_DATA_WIDTH/8;
localparam DATA_BYTES = AXIS_TKEEP_WIDTH;

localparam TKEEP_MASK = (1<<AXIS_TKEEP_WIDTH) - 1;

wire reset;
assign reset = ~axis_resetn;

reg [6:0]   valid_bytes;

reg [15:0]  len_varint;
reg [15:0]  codec;
reg [1:0]   codec_bytes;
reg [1:0]   len_bytes;

reg [DATA_BYTES*8-1:0]  buffer_sync;
reg [DATA_BYTES*8-1:0]  buffer;
reg [6:0]  buffer_bytes_sync;
reg [6:0]  buffer_bytes;

wire                             fifo_nearly_full;
wire                             fifo_empty;
reg                              fifo_wr_en;
reg [C_AXIS_TUSER_WIDTH-1:0]  fifo_in_tuser;
reg [C_AXIS_DATA_WIDTH-1:0]   fifo_in_tdata;
reg [C_AXIS_DATA_WIDTH/8-1:0] fifo_in_tkeep;
reg                             fifo_in_tlast;

fallthrough_small_fifo
#(
    .WIDTH(C_AXIS_DATA_WIDTH+C_AXIS_TUSER_WIDTH+C_AXIS_DATA_WIDTH/8+1),
    .MAX_DEPTH_BITS(3)
)
output_fifo
(   // Outputs
    .dout                         ({m_axis_tlast, m_axis_tuser, m_axis_tkeep, m_axis_tdata}),
    .full                         (),
    .nearly_full                  (fifo_nearly_full),
    .prog_full                    (),
    .empty                        (fifo_empty),
    // Inputs
    .din                          ({fifo_in_tlast, fifo_in_tuser, fifo_in_tkeep, fifo_in_tdata}),
    .wr_en                        (fifo_wr_en),
    .rd_en                        (m_axis_tready&m_axis_tvalid),
    .reset                        (~axis_resetn),
    .clk                          (axis_aclk)
);

assign s_axis_tready = !fifo_nearly_full;
// ***********************************
// FIFO writing
// ***********************************

always @(*) begin
    m_axis_tvalid = !fifo_empty;
end

// ---------- Decode Input Stream TKEEP ------
genvar by_i;
generate
    for(by_i=1;by_i<=AXIS_TKEEP_WIDTH;by_i=by_i+1) begin
        always @(*) begin
            if(s_axis_tkeep == { {(AXIS_TKEEP_WIDTH-by_i){1'b0}}, {by_i{1'b1}} })
                valid_bytes = by_i;
        end
    end
endgenerate

// *******************************************
// MultiHash Decapsulation
// *******************************************

// -------- Extract codec and len_varint -------
// Assume codec_bytes <= 2 and len_bytes <= 2
always @(*) begin
    buffer = s_axis_tdata;

    if(s_axis_tdata & 8'h80) begin
        codec_bytes = 2;
        codec = s_axis_tdata[15:0];
    end
    else begin
        codec_bytes = 1;
        codec = s_axis_tdata[7:0];
    end
    
    if( (s_axis_tdata>>(8*codec_bytes)) & 8'h80 ) begin
        len_bytes = 2;
        len_varint = (s_axis_tdata>>(8*codec_bytes)) & 16'hFFFF;
    end
    else begin
        len_bytes = 1;
        len_varint = (s_axis_tdata>>(8*codec_bytes)) & 8'hFF;
    end
end

// Transform varint into integer
function [15:0] varint2int;
    input [15:0] varint;
    reg [15:0] len;
    begin
        len = varint & 8'h7F;
        if(varint & 8'h80)
            len = len | ((varint & 16'h7F00) >> 1);
        
        varint2int = len;
    end
endfunction

reg [1:0]  state, state_next;
localparam  DECAPS  =   0;
localparam  SHIFT   =   1;
localparam SHIFT_LAST = 2;

always @(*) begin
    state_next = state;
    fifo_wr_en = 0;
    fifo_in_tlast = 0;
    case(state)
        DECAPS: begin
            // Modify tuser codec identifier
            fifo_in_tuser[31:16] = s_axis_tuser[31:16];
            fifo_in_tuser[15:0] = varint2int(len_varint);
            fifo_in_tuser[127:32] = codec;

            // Create header for the stream
            buffer = s_axis_tdata >> (8*(codec_bytes+len_bytes));
            buffer_bytes = DATA_BYTES - codec_bytes - len_bytes;

            fifo_in_tdata = buffer;
            fifo_in_tkeep = s_axis_tkeep >> (codec_bytes+len_bytes);

            if(s_axis_tvalid & ~fifo_nearly_full) begin
                if(s_axis_tlast) begin
                    fifo_wr_en = 1;
                    fifo_in_tlast = 1;
                    state_next = DECAPS;
                end
                else
                    state_next = SHIFT;
            end


        end
        SHIFT: begin
            // shift and append input stream to the buffer
            fifo_in_tdata  = (s_axis_tdata << (8*buffer_bytes_sync)) | buffer_sync;
            if(valid_bytes + buffer_bytes_sync >= DATA_BYTES)
                fifo_in_tkeep = {AXIS_TKEEP_WIDTH{1'b1}};
            else
                fifo_in_tkeep = (1<<(buffer_bytes_sync + valid_bytes)) - 1;

            buffer = s_axis_tdata >> (8*(DATA_BYTES - buffer_bytes_sync));
            buffer_bytes = valid_bytes + buffer_bytes_sync - DATA_BYTES;
            
            if(s_axis_tvalid & ~fifo_nearly_full) begin
                fifo_wr_en = 1;
                if(s_axis_tlast) begin
                    if(valid_bytes > DATA_BYTES - buffer_bytes_sync)
                        state_next = SHIFT_LAST;
                    else begin
                        fifo_in_tlast = 1;
                        state_next = DECAPS;
                    end
                        
                end
            end
        end
        SHIFT_LAST: begin
            // Update buffer from shifted transaction
            buffer = buffer_sync;
            buffer_bytes = buffer_bytes_sync;
            
            fifo_in_tdata  = buffer;
            fifo_in_tkeep = (1<<buffer_bytes) - 1;

            if(~fifo_nearly_full) begin
                fifo_in_tlast = 1;
                fifo_wr_en = 1;
                state_next = DECAPS;
            end
                
        end
    endcase
end

always @(posedge axis_aclk) begin
    if(reset) begin
        state <= DECAPS;
    end
    else begin
        state <= state_next;
        if(s_axis_tvalid & ~fifo_nearly_full) begin
            buffer_sync <= buffer;
            buffer_bytes_sync <= buffer_bytes;
        end
    end
end


`ifdef COCOTB_SIM
`ifndef VERILATOR // traced differently
initial begin
  $dumpfile ("dump.vcd");
  $dumpvars (0,multihash_decode);
  #1;
end
`endif
`endif

endmodule

