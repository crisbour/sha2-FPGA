`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2020 10:10:17
// Design Name: 
// Module Name: madd_
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

module madd_Kt
(
    // Control
    input mode64,

    // Inputs
    input [63:0] a,
    input [63:0] kt,

    // Output
    output [63:0] s

);

wire [63:0] b;
assign b = mode64 ? kt : {32'h00000000, kt[63:32]};

madd_32_64 sum(
    .a(a),
    .b(b),
    .s(s),
    .mode64(mode64)
);

endmodule
