`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2021 14:58:56
// Design Name: 
// Module Name: dsp_add64_modulo_tb
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


module add64_4inputs_test;

parameter CLK_PERIOD = 10;

reg     clk, rst;
reg [63:0]  a, b, c, d;
wire [63:0] out;
reg [63:0] next_out;
reg [63:0] rx_out;
reg mode64;

add64_4inputs adder64_4(.AIN(a), .BIN(b), .CIN(c), .DIN(d), .SUM_OUT(out), .mode64(mode64));

initial begin
clk = 1'b0;
forever begin
  # (CLK_PERIOD/2) clk = ~clk;
end
end

initial begin
  rst = 1'b1;
  mode64 = 1'b1;
  a = 64'b0;
  b = 64'b0;
  c = 64'b0;
  d = 64'b0;
  next_out = a + b + c + d;
  #1 rst = 1'b0;
  $monitor("rst=%d, mode64=%d, a=%d, b=%d, c=%d, d=%d, out=%d", rst, mode64, a, b, c, d, out);
  forever begin
    #(CLK_PERIOD)

    a = (a << 4) + 4'hA;
    b = (b << 12) + 12'hFFF;
    c = (c << 5) + 5'h18;
    d = (d << 9) + 9'h1A1;

    next_out = a + b + c + d;

    if(~mode64) begin
      a = a & 32'hffffffff;
      b = b & 32'hffffffff;
      c = c & 32'hffffffff;
      d = d & 32'hffffffff;
      next_out = next_out & 32'hffffffff;
    end

  end
end

always @(posedge clk) begin
  rx_out <= out;
end

initial begin
  #(7*CLK_PERIOD)
  mode64 = ~mode64;
end

initial begin
  #(15*CLK_PERIOD)
  $finish;
end


initial begin
  $dumpfile ("dump.vcd");
  $dumpvars (0,add64_4inputs_test);
  #1;
end

initial 
$monitor ($time, "clk=%b", clk, " SUM_OUT = %h", out);


endmodule
