`timescale 1ns/100ps

module  CSA64(
    input mode64,
    input [63:0] AIN,
    input [63:0] BIN,
    input [63:0] CIN,
    output [63:0]   SUM_OUT,
    output [63:0]   COUT
);

wire [63:0] full_carry;
assign full_carry = ((AIN & BIN) | (BIN & CIN) | (CIN & AIN)) << 1;

assign SUM_OUT = AIN ^ BIN ^ CIN;
assign COUT = mode64 ? full_carry : {32'b0, full_carry[31:0]};

endmodule
