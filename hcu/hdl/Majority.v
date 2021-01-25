`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Oxford
// Engineer: Cristian Bourceanu
// 
// Create Date: 05.01.2020 19:26:24
// Design Name: Majority bitwise value
// Module Name: Maj
// Project Name: SHA2_FPGA
// Target Devices: Alveo U280
// Tool Versions: icarus 11.2
// Description: 
// 
// Dependencies: Maj.v
// 
// Revision:
// Revision 0.1
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

parameter DATA_WIDTH = 64;
parameter SMALL_DATA_WIDTH = 32;

module Majority
(
    // Inputs
    input [DATA_WIDTH-1 : 0] x_val,
    input [DATA_WIDTH-1 : 0] y_val,
    input [DATA_WIDTH-1 : 0] z_val,

    // Output
    output [DATA_WIDTH-1 : 0] maj_value
);

wire [DATA_WIDTH-1 : 0] maj_value;

assign maj_value = (x_val&y_val)^(x_val&z_val)^(y_val&z_val);

endmodule