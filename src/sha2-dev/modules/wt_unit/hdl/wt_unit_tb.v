`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2020 10:10:17
// Design Name: 
// Module Name: wt_unit_tb
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


module wt_unit_tb #(
	parameter C_S_AXIS_DATA_WIDTH = 512,
	parameter C_AXIS_TUSER_WIDTH = 128
)
(
	input 	axis_aclk,
    input	axis_resetn,

    // Master Stream Port
    input [(C_S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
	input [(C_AXIS_TUSER_WIDTH-1):0] s_axis_tuser,
    input s_axis_tvalid,
    output s_axis_tready,
    input s_axis_tlast,

    // Slave Stream Port
    output [63:0] m_axis_tdata,
	output [(C_AXIS_TUSER_WIDTH-1):0] m_axis_tuser,
    output m_axis_tvalid,
    input m_axis_tready,
    output m_axis_tlast	
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

wire [(C_S_AXIS_DATA_WIDTH-1):0] wt_axis_tdata;
wire [C_AXIS_TUSER_WIDTH-1:0] wt_axis_tuser;
wire wt_axis_tvalid;
wire wt_axis_tready;
wire wt_axis_tlast;


bridge #(
	.C_AXIS_DATA_WIDTH(512),
	.C_AXIS_TUSER_WIDTH(128)
) big_endian(
	.clk	(axis_aclk),
	.reset	(~axis_resetn),

	// Little endian input stream
	.s_axis_tdata	(s_axis_tdata),
	.s_axis_tkeep	(),
	.s_axis_tuser	(s_axis_tuser),
    .s_axis_tvalid	(s_axis_tvalid),
    .s_axis_tready	(s_axis_tready),
    .s_axis_tlast	(s_axis_tlast),

	// Big endian output stream
	.m_axis_tdata	(wt_axis_tdata),
	.m_axis_tkeep	(),
	.m_axis_tuser	(wt_axis_tuser),
    .m_axis_tvalid	(wt_axis_tvalid),
    .m_axis_tready	(wt_axis_tready),
    .m_axis_tlast	(wt_axis_tlast)
);



wt_unit #(
	.C_M_AXIS_DATA_WIDTH(64),
	.C_AXIS_TUSER_WIDTH(128)
) wt_ut(
	.axis_aclk		(axis_aclk),
    .axis_resetn	(axis_resetn),

    // Master Stream Port
    .s_axis_tdata	(wt_axis_tdata),
	.s_axis_tuser	(wt_axis_tuser),
    .s_axis_tvalid	(wt_axis_tvalid),
    .s_axis_tready	(wt_axis_tready),
    .s_axis_tlast	(wt_axis_tlast),

    // Slave Stream Port
    .m_axis_tdata	(m_axis_tdata),
	.m_axis_tuser	(m_axis_tuser),
    .m_axis_tvalid	(m_axis_tvalid),
    .m_axis_tready	(m_axis_tready),
    .m_axis_tlast	(m_axis_tlast)
	);


endmodule
