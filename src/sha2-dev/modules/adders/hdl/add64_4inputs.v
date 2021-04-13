`timescale 1ns/100ps

module add64_4inputs(
    input mode64,
    input [63:0] AIN,
    input [63:0] BIN,
    input [63:0] CIN,
    input [63:0] DIN,
    output [63:0] SUM_OUT,
    input rst,
    input clk
);

wire [63:0] sum_42, carry_42;

compressor42 compress_4inputs(
    .mode64(mode64),
    .AIN(AIN), .BIN(BIN),
    .CIN(CIN), .DIN(DIN),
    .SUM_OUT(sum_42),
    .COUT(carry_42)
);

dsp_add64_modulo dsp_adder(
    .mode64(mode64),
    .AIN(sum_42),
    .BIN(carry_42),
    .SUM_OUT(SUM_OUT),
    .clk(clk),
    .rst(rst)
);

endmodule
