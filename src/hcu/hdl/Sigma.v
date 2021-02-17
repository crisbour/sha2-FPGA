`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Oxford
// Engineer: Cristian Bourceanu
// 
// Create Date: 05.01.2020 16:32:56
// Design Name: Sigma_0_1
// Module Name: Sgima
// Project Name: SHA2_FPGA
// Target Devices: Alveo U280
// Tool Versions: icarus 11.2
// Description: 
// 
// Dependencies: Sigma.v
// 
// Revision:
// Revision 0.1
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Sigma
#(
    // 
    parameter p1=2,
    parameter p2=13,
    parameter p3=22
)
(


    // Control
    input data_width_flag,    // 0 if 32-bit and 1 for 64-bit

    // Input
    input [63 : 0] data_value,

    // Output
    output [63 : 0] sigma_value
);
localparam DATA_WIDTH = 64;
localparam SMALL_DATA_WIDTH = 32;

reg [DATA_WIDTH-1 : 0] data1;
reg [DATA_WIDTH-1 : 0] data2;
reg [DATA_WIDTH-1 : 0] data3;

always @(*) 
begin: SigmaOp
if(data_width_flag) begin
    data1 = (data_value >> p1)|(data_value <<(DATA_WIDTH-p1));
    data2 = (data_value >> p2)|(data_value <<(DATA_WIDTH-p2));
    data3 = (data_value >> p3)|(data_value <<(DATA_WIDTH-p3));
end
else begin
    data1 = (data_value >> p1)|(data_value <<(SMALL_DATA_WIDTH-p1));
    data2 = (data_value >> p2)|(data_value <<(SMALL_DATA_WIDTH-p2));
    data3 = (data_value >> p3)|(data_value <<(SMALL_DATA_WIDTH-p3));
end
end: SigmaOp

assign sigma_value = data1 ^ data2 ^ data3;

`ifndef VERILATOR
initial begin
  $dumpfile ("waveform.vcd");
  $dumpvars (0, Sigma);
  #1;
end
`endif

endmodule