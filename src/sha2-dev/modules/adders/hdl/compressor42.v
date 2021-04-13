`timescale 1ns/100ps

module compressor42(
    input mode64,
    input [63:0] AIN,
    input [63:0] BIN,
    input [63:0] CIN,
    input [63:0] DIN,
    output [63:0] SUM_OUT,
    output [63:0] COUT
);

wire [63:0] sum0, carry0;
CSA64 node0(
    .mode64(mode64),
    .AIN(AIN),
    .BIN(BIN),
    .CIN(CIN),
    .SUM_OUT(sum0),
    .COUT(carry0)
);

CSA64 node1(
    .mode64(mode64),
    .AIN(sum0),
    .BIN(carry0),
    .CIN(DIN),
    .SUM_OUT(SUM_OUT),
    .COUT(COUT)
);

endmodule
