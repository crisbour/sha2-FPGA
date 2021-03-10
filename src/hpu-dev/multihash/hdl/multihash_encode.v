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
module multihash_encode
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

wire read, transmit;
assign read = s_axis_tready & s_axis_tvalid;
assign transmit = m_axis_tready & m_axis_tvalid;

reg [1:0] msgs_queued;
reg [6:0]   valid_bytes;

reg [13:0]  len;
reg [13:0]  next_len;
reg [15:0]  len_varint;
reg [15:0]  codec_varint;
reg [1:0]   codec_bytes;
reg [1:0]   len_bytes;

reg [DATA_BYTES*8-1:0]  buffer_sync;
reg [DATA_BYTES*8-1:0]  buffer;
reg [2:0]  buffer_bytes_sync;
reg [2:0]  buffer_bytes;
reg [8:0]  empty_bytes;


wire read_queue = fifo_rd_en & ~fifo_empty & msgs_queued>0;

reg [6:0]   fifo_valid_bytes;


wire                             fifo_nearly_full;
wire                             fifo_empty;
reg                              fifo_rd_en;
wire [C_AXIS_TUSER_WIDTH-1:0]  fifo_out_tuser;
wire [C_AXIS_DATA_WIDTH-1:0]   fifo_out_tdata;
wire [C_AXIS_DATA_WIDTH/8-1:0] fifo_out_tkeep;
wire                             fifo_out_tlast;
wire                             fifo_tvalid;
wire                             fifo_tlast;

fallthrough_small_fifo
#(
    .WIDTH(C_AXIS_DATA_WIDTH+C_AXIS_TUSER_WIDTH+C_AXIS_DATA_WIDTH/8+1),
    .MAX_DEPTH_BITS(3)
)
input_fifo
(   // Outputs
    .dout                         ({fifo_out_tlast, fifo_out_tuser, fifo_out_tkeep, fifo_out_tdata}),
    .full                         (),
    .nearly_full                  (fifo_nearly_full),
    .prog_full                    (),
    .empty                        (fifo_empty),
    // Inputs
    .din                          ({s_axis_tlast, s_axis_tuser, s_axis_tkeep, s_axis_tdata}),
    .wr_en                        (s_axis_tvalid & s_axis_tready),
    .rd_en                        (fifo_rd_en),
    .reset                        (~axis_resetn),
    .clk                          (axis_aclk)
);

assign s_axis_tready = ~fifo_nearly_full && msgs_queued < 2;

// ***********************************
// FIFO reading
// ***********************************

always @(*) begin
    m_axis_tvalid = !fifo_empty;
end

// ---------- Decode FIFO TKEEP ------
genvar by_f;
generate
    for(by_f=1;by_f<=AXIS_TKEEP_WIDTH;by_f=by_f+1) begin
        always @(*) begin
            if(fifo_out_tkeep == {{by_f{1'b1}},{(AXIS_TKEEP_WIDTH-by_f){1'b0}}} && read_queue)
                fifo_valid_bytes = by_f;
        end
    end
    always @(*) begin
        if(~read_queue)
            fifo_valid_bytes = 0; 
    end
endgenerate

// *******************************************
// MultiHash Encapsulation
// *******************************************

// -------- Varint Lenght -------
// Assume that len<=16383
integer  s,i;
always @(*) begin
    s=0;
    len_varint = 0;
    len_bytes = 1;
    for(i=0;i<1;i=i+1)  // Number of iteration = max_bytes_len - 1
        if( (len >> s) >= 8'h80 )begin
            len_varint = (len_varint << 8) | (8'h80 | ((len>>s) & 8'h7F));
            len_bytes = len_bytes + 1;
            s = s+7;
        end
    len_varint = (len_varint << 8) | ((len>>s) & 8'h7F);
end

// --------- Varint Codec -----------
always @(*) begin
    if(read_queue)  begin
        codec_varint = fifo_out_tuser[TUESR_SLOT_OFFSET+TUSER_SLOT_WIDTH*(HASH_TUSER_SLOT+1)-1:TUESR_SLOT_OFFSET+TUSER_SLOT_WIDTH*HASH_TUSER_SLOT];
        if(codec_varint[7]) begin
            codec_bytes = 2;
            codec_varint = {codec_varint[7:0], codec_varint[15:8]};
        end else begin
            codec_bytes = 1;
        end
    end
end

reg [1:0]   state, state_next;
localparam  ENCAPS  =   0;
localparam  SHIFT   =   1;
localparam  SHIFT_LAST = 2;

always @(*) begin
    m_axis_tvalid = 0;
    fifo_rd_en = 0;
    state_next = state;
    case(state)
        ENCAPS: begin
            // Modify tuser codec identifier
            m_axis_tuser[31:0] = fifo_out_tuser[31:0];
            m_axis_tuser[127:32] = {80'h0,`CODEC_MULTIHASH};

            // Create header for the stream
            buffer = { {codec_varint,16'h0} << (8*(2-codec_bytes))
                | ({16'h0,len_varint} << (8*(4-codec_bytes-len_bytes)))
                , {(C_AXIS_DATA_WIDTH-32){1'b0}} };
            buffer_bytes = len_bytes + codec_bytes;

            m_axis_tvalid = ~fifo_empty & msgs_queued>0;

            // Add header to the stream
            m_axis_tdata = buffer | (fifo_out_tdata >> (8*buffer_bytes));

            if(DATA_BYTES <= fifo_valid_bytes + buffer_bytes) begin
                empty_bytes = 0;
                m_axis_tlast = 0;
            end
            else begin
                empty_bytes = (DATA_BYTES - fifo_valid_bytes - buffer_bytes);
                m_axis_tlast = 1;
            end
            m_axis_tkeep = ~((1 << empty_bytes) - 1);

            if(m_axis_tready & m_axis_tvalid) begin
                fifo_rd_en = 1;
                if(~m_axis_tlast)
                    if(~fifo_out_tlast)
                        state_next = SHIFT;
                    else
                        state_next = SHIFT_LAST;
            end
        end
        SHIFT: begin
            // Update buffer from shifted transaction
            buffer = buffer_sync;
            buffer_bytes = buffer_bytes_sync;

            m_axis_tvalid = ~fifo_empty;

            // Add overflow stream to next stream
            m_axis_tdata = buffer | (fifo_out_tdata >> (8*buffer_bytes));

            if(DATA_BYTES <= fifo_valid_bytes + buffer_bytes) begin
                empty_bytes = 0;
                m_axis_tlast = 0;
            end
            else begin
                empty_bytes = (DATA_BYTES - fifo_valid_bytes - buffer_bytes);
                m_axis_tlast = 1;
            end
            m_axis_tkeep = ~((1 << (empty_bytes)) - 1);

            if(m_axis_tready & m_axis_tvalid) begin
                fifo_rd_en = 1;
                if(m_axis_tlast)
                    state_next = ENCAPS;
                else if(fifo_out_tlast)
                    state_next = SHIFT_LAST;
            end
        end
        SHIFT_LAST: begin
            // Update buffer from shifted transaction
            buffer = buffer_sync;
            buffer_bytes = buffer_bytes_sync;

            m_axis_tvalid = 1;
            m_axis_tlast = 1;

            // Add overflow stream to the next stream
            m_axis_tdata = buffer;

            m_axis_tkeep = ~((1 << (DATA_BYTES - buffer_bytes)) - 1);

            if(m_axis_tready & m_axis_tvalid & m_axis_tlast)
                state_next = ENCAPS;
        end
    endcase
end

always @(posedge axis_aclk) begin
    if(reset) begin
        state <= ENCAPS;
    end
    else begin
        state <= state_next;
        if(transmit) begin
            buffer_sync <= fifo_out_tdata << (8*(DATA_BYTES - buffer_bytes));
            buffer_bytes_sync <= fifo_valid_bytes + buffer_bytes - DATA_BYTES;
        end
    end
end


// *********************************
// Measure frame length and feed FIFO
// *********************************

// ---------- Decode Input Stream TKEEP ------
genvar by_i;
generate
    for(by_i=1;by_i<=AXIS_TKEEP_WIDTH;by_i=by_i+1) begin
        always @(*) begin
            if(s_axis_tkeep == {{by_i{1'b1}},{(AXIS_TKEEP_WIDTH-by_i){1'b0}}})
                valid_bytes = by_i;
        end
    end
endgenerate

// Feed fifo from input stream
always @(posedge axis_aclk) begin
    if(reset) begin
        msgs_queued <= 0;
        next_len <= 0;
    end
    else begin
        if(read & s_axis_tlast & transmit & m_axis_tlast) begin
            len <= next_len + valid_bytes;
            next_len <= 0;
        end
        else if(read)begin
            if(s_axis_tlast && msgs_queued == 0 ) begin
                len <= next_len + valid_bytes;
                next_len <= 0;
            end
            else
                next_len <= next_len + valid_bytes;
            
        end
        else if((m_axis_tlast&transmit) && msgs_queued == 2) begin
            len <= next_len;
            next_len <= 0;
        end

        // Keep count of messeges queued
        if((read & s_axis_tlast) & ~(transmit & m_axis_tlast))
            msgs_queued <= msgs_queued + 1;
        else if(~(read & s_axis_tlast) & (transmit & m_axis_tlast))
            msgs_queued <= msgs_queued - 1;
             
    end
end

`ifdef COCOTB_SIM
`ifndef VERILATOR // traced differently
initial begin
  $dumpfile ("dump.vcd");
  $dumpvars (0,multihash_encode);
  #1;
end
`endif
`endif

endmodule

