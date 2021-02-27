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


module hash_update
(
    // Global Ports
    input clk,
    input reset,

    // Control
    input [1:0] sha_type,  // msb is 0 if SHA224/256 and 1 if SHA384/512
    input update,
    
    // Hash words in/out
    output reg [63:0] H [0:7],
    input [63:0] AH [0:7]

);

localparam [63:0] HASH_INIT [0:15] = '{
    64'h6a09e667f3bcc908, 64'hbb67ae8584caa73b, 64'h3c6ef372fe94f82b, 64'ha54ff53a5f1d36f1,
    64'h510e527fade682d1, 64'h9b05688c2b3e6c1f, 64'h1f83d9abfb41bd6b, 64'h5be0cd19137e2179,
    64'hcbbb9d5dc1059ed8, 64'h629a292a367cd507, 64'h9159015a3070dd17, 64'h152fecd8f70e5939,
    64'h67332667ffc00b31, 64'h8eb44a8768581511, 64'hdb0c2e0d64f98fa7, 64'h47b5481dbefa4fa4};

localparam [31:0] HASH_INIT_224 [0:7] = '{
    32'hc1059ed8, 32'h367cd507, 32'h3070dd17, 32'hf70e5939,
    32'hffc00b31, 32'h68581511, 32'h64f98fa7, 32'hbefa4fa4};

integer i;

//reg [63:0] H [0:7];
wire [63:0] Sums [0:7];

genvar j;
generate
    for(j=0;j<8;j++) begin : generate_block_identifier
        madd_32_64 sum(
            .mode64(sha_type[1]),
            .a(H[j]),
            .b(AH[j]),
            .s(Sums[j])
        );
    end
endgenerate

always @(posedge clk) begin
    if(reset) begin
        for(i=0;i<8;i=i+1)begin
            if(~sha_type[1])begin
                if(sha_type[0])
                    H[i][31:0] <= HASH_INIT[i][63:32];
                else
                    H[i][31:0] <= HASH_INIT_224[i];
                H[i][63:32] <= 32'b0;
            end else begin
                if(sha_type[0])
                    H[i] <= HASH_INIT[i];
                else
                    H[i] <= HASH_INIT[i+8];
            end
        end
    end
    else begin
        if(update)
            for(i=0; i<8; i=i+1) begin
                H[i] <= Sums[i];
            end
    end
end

// `ifndef VERILATOR
// `ifdef COCOTB_SIM
// initial begin
//   $dumpfile ("dump.vcd");
//   $dumpvars (0, hash_update);
//   for(i = 0; i<8; i=i+1) begin
//       $dumpvars(0, H[i]);
//   end
//   for(i = 0; i<8; i=i+1) begin
//       $dumpvars(0, AH[i]);
//   end
  
// end
// `endif
// `endif

endmodule
