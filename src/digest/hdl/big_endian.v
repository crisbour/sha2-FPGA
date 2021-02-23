`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: big_endian
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
module big_endian
#(
    // AXI Strem Data Width
    parameter DATA_WIDTH=512
)
(
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out

);
localparam DATA_BYTES = DATA_WIDTH / 8;

genvar byte_i;
generate
for(byte_i=0;byte_i<DATA_BYTES;byte_i=byte_i+1)begin
    assign data_out[8*(DATA_BYTES-byte_i)-1:8*(DATA_BYTES-byte_i-1)] = 
        data_in[8*(byte_i+1)-1:8*byte_i];
end
endgenerate

endmodule

