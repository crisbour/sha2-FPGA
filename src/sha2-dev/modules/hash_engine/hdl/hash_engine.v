`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2020 10:10:17
// Design Name: 
// Module Name: hash-engine
// Project Name: 
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

module hash_engine
#(
    // AXI Strem Data Width
    parameter S_AXIS_DATA_WIDTH=512,
    parameter M_AXIS_DATA_WIDTH=512,
    parameter M_AXIS_TUSER_WIDTH=128,
    parameter S_AXIS_TUSER_WIDTH=128
)
(
    // Global Ports
    input axis_aclk,
    input axis_resetn,

    /*** Slave Steam Port ***/
    // Incomig words
    input [(S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
    input [(S_AXIS_TUSER_WIDTH-1):0] s_axis_tuser,
    input [(S_AXIS_DATA_WIDTH/8-1):0] s_axis_tkeep,
    input       s_axis_tvalid,
    output      s_axis_tready,
    input       s_axis_tlast,

    // Message digest
    output [(M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output [(M_AXIS_TUSER_WIDTH-1):0] m_axis_tuser,
    output [(M_AXIS_DATA_WIDTH/8-1):0] m_axis_tkeep,
    output      m_axis_tvalid,
    input       m_axis_tready,
    output      m_axis_tlast

);
localparam BLOCK_DATA_WIDTH = 512;
localparam WORDS_DATA_WIDTH = 64;

wire [S_AXIS_DATA_WIDTH-1:0] padded_axis_tdata, padbig_axis_tdata;
wire padded_axis_tvalid, padded_axis_tready, padded_axis_tlast;
wire padbig_axis_tvalid, padbig_axis_tready, padbig_axis_tlast;
wire [WORDS_DATA_WIDTH-1:0] wt_axis_tdata;
wire wt_axis_tvalid, wt_axis_tready, wt_axis_tlast;
wire [BLOCK_DATA_WIDTH-1:0] hcu_axis_tdata;
wire hcu_axis_tvalid, hcu_axis_tready, hcu_axis_tlast;
wire [M_AXIS_TUSER_WIDTH-1:0] padded_axis_tuser, padbig_axis_tuser, wt_axis_tuser, hcu_axis_tuser;

padder Padder(
    // Global signals
    .axis_aclk(axis_aclk),
    .axis_resetn(axis_resetn),
    // Input message
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tuser(s_axis_tuser),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    // Padded message and divided in blocks
    .m_axis_tdata(padded_axis_tdata),
    .m_axis_tuser(padded_axis_tuser),
    .m_axis_tvalid(padded_axis_tvalid),
    .m_axis_tready(padded_axis_tready),
    .m_axis_tlast(padded_axis_tlast)
);

bridge big_endian(
    .clk    (axis_aclk),
    .reset  (~axis_resetn),
    // Input message
    .s_axis_tdata(padded_axis_tdata),
    .s_axis_tkeep(),
    .s_axis_tuser(padded_axis_tuser),
    .s_axis_tvalid(padded_axis_tvalid),
    .s_axis_tready(padded_axis_tready),
    .s_axis_tlast(padded_axis_tlast),
    // Padded message and divided in blocks
    .m_axis_tdata(padbig_axis_tdata),
    .m_axis_tkeep(),
    .m_axis_tuser(padbig_axis_tuser),
    .m_axis_tvalid(padbig_axis_tvalid),
    .m_axis_tready(padbig_axis_tready),
    .m_axis_tlast(padbig_axis_tlast)
);

wt_unit Wt(
    // Global signals
    .axis_aclk(axis_aclk),
    .axis_resetn(axis_resetn),
    // Input padded message blocks
    .s_axis_tdata(padbig_axis_tdata),
    .s_axis_tuser(padbig_axis_tuser),
    .s_axis_tvalid(padbig_axis_tvalid),
    .s_axis_tready(padbig_axis_tready),
    .s_axis_tlast(padbig_axis_tlast),
    // Output words
    .m_axis_tdata(wt_axis_tdata),
    .m_axis_tuser(wt_axis_tuser),
    .m_axis_tvalid(wt_axis_tvalid),
    .m_axis_tready(wt_axis_tready),
    .m_axis_tlast(wt_axis_tlast)
);

hcu HashingComputationUnit(
    // Global signals
    .axis_aclk(axis_aclk),
    .axis_resetn(axis_resetn),
    // Input words
    .s_axis_tdata(wt_axis_tdata),
    .s_axis_tuser(wt_axis_tuser),
    .s_axis_tvalid(wt_axis_tvalid),
    .s_axis_tready(wt_axis_tready),
    .s_axis_tlast(wt_axis_tlast),
    // Output unparsed hash
    .m_axis_tdata(hcu_axis_tdata),
    .m_axis_tuser(hcu_axis_tuser),
    .m_axis_tvalid(hcu_axis_tvalid),
    .m_axis_tready(hcu_axis_tready),
    .m_axis_tlast(hcu_axis_tlast)
);

digest Digest(
    // Global signals
    .axis_aclk(axis_aclk),
    .axis_resetn(axis_resetn),
    // Input unparsed hash
    .s_axis_tdata(hcu_axis_tdata),
    .s_axis_tuser(hcu_axis_tuser),
    .s_axis_tvalid(hcu_axis_tvalid),
    .s_axis_tready(hcu_axis_tready),
    .s_axis_tlast(hcu_axis_tlast),
    // Output message digest
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tuser(m_axis_tuser),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast)
);

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

