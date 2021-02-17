`timescale 1ns / 1ps
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

module hcu
#(
    // AXI Strem Data Width
    parameter S_AXIS_DATA_WIDTH=512,
    parameter M_AXIS_DATA_WIDTH=512
)
(
    // Global Ports
    input axi_aclk,
    input axi_resetn,

    // Control
    input [1:0] sha_type,  // msb is 0 if SHA224/256 and 1 if SHA384/512
    input en,   // 1 if the hashing engine has been enabled by the scheduler

    /*** Slave Steam Port ***/
    // Incomig words
    input [(S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
    input [(S_AXIS_DATA_WIDTH/8-1):0] s_axis_tkeep,
    input s_axis_tvalid,
    output reg s_axis_tready,
    input s_axis_tlast,

    // Message digest
    output [(M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output [(M_AXIS_DATA_WIDTH/8-1):0] m_axis_tkeep,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast

);
localparam BLOCK_DATA_WIDTH 512
localparam WORDS_DATA_WIDTH 64

wire [BLOCK_DATA_WIDTH-1:0] padded_axis_tdata;
wire padded_axis_tvalid, padded_axis_tready, padded_axis_tlast;
wire [WORDS_DATA_WIDTH-1:0] wt_axis_tdata;
wire wt_axis_tvalid, wt_axis_tready, wt_axis_tlast;
wire [BLOCK_DATA_WIDTH-1:0] hcu_axis_tdata;
wire hcu_axis_tvalid, hcu_axis_tready, hcu_axis_tlast;

padder Padder(
    // Global signals
    .axi_aclk(axi_aclk),
    .axi_resetn(axi_resetn),
    .sha_type(sha_type),
    .en(en),
    // Input message
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast)
    // Padded message and divided in blocks
    .m_axis_tdata(padded_axis_tdata),
    .m_axis_tvalid(padded_axis_tvalid),
    .m_axis_tready(padded_axis_tready),
    .m_axis_tlast(padded_axis_tlast)
);

wt_unit Wt(
    // Global signals
    .axi_aclk(axi_aclk),
    .axi_resetn(axi_resetn),
    .sha_type(sha_type),
    .en(en),
    // Input padded message blocks
    .s_axis_tdata(padded_axis_tdata),
    .s_axis_tvalid(padded_axis_tvalid),
    .s_axis_tready(padded_axis_tready),
    .s_axis_tlast(padded_axis_tlast),
    // Output words
    .m_axis_tdata(wt_axis_tdata),
    .m_axis_tvalid(wt_axis_tvalid),
    .m_axis_tready(wt_axis_tready),
    .m_axis_tlast(wt_axis_tlast)
);

hcu HashingComputationUnit(
    // Global signals
    .axi_aclk(axi_aclk),
    .axi_resetn(axi_resetn),
    .sha_type(sha_type),
    .en(en),
    // Input words
    .s_axis_tdata(wt_axis_tdata),
    .s_axis_tvalid(wt_axis_tvalid),
    .s_axis_tready(wt_axis_tready),
    .s_axis_tlast(wt_axis_tlast),
    // Output unparsed hash
    .m_axis_tdata(hcu_axis_tdata),
    .m_axis_tvalid(hcu_axis_tvalid),
    .m_axis_tready(hcu_axis_tready),
    .m_axis_tlast(hcu_axis_tlast)
);

digest Digest(
    // Global signals
    .axi_aclk(axi_aclk),
    .axi_resetn(axi_resetn),
    .sha_type(sha_type),
    .en(en),
    // Input unparsed hash
    .s_axis_tdata(wt_axis_tdata),
    .s_axis_tvalid(wt_axis_tvalid),
    .s_axis_tready(wt_axis_tready),
    .s_axis_tlast(wt_axis_tlast),
    // Output message digest
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast)
);

endmodule

