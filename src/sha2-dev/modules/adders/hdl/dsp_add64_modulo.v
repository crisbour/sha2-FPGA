`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2021 15:46:12
// Design Name: 
// Module Name: dsp_add64_modulo
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


module dsp_add64_modulo(
    input [63:0] AIN,
    input [63:0] BIN,
    output [63:0] SUM_OUT,
    input mode64,
    input clk,
    input rst
    );
    
    wire carry;
    wire [95:0] full_sum;

    assign SUM_OUT = mode64 ? full_sum[63:0] : {32'b0, full_sum[31:0]};

    DSP48E2 #(
      // Feature Control Attributes: Data Path Selection
      .AMULTSEL("A"),                    // Selects A input to multiplier (A, AD)
      .A_INPUT("DIRECT"),                // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .BMULTSEL("B"),                    // Selects B input to multiplier (AD, B)
      .B_INPUT("DIRECT"),                // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .PREADDINSEL("A"),                 // Selects input to pre-adder (A, B)
      .RND(48'h000000000000),            // Rounding Constant
      .USE_MULT("NONE"),             // Select multiplier usage (DYNAMIC, MULTIPLY, NONE)
      .USE_SIMD("ONE48"),                // SIMD selection (FOUR12, ONE48, TWO24)
      .USE_WIDEXOR("FALSE"),             // Use the Wide XOR function (FALSE, TRUE)
      .XORSIMD("XOR24_48_96"),           // Mode of operation for the Wide XOR (XOR12, XOR24_48_96)
      // Pattern Detector Attributes: Pattern Detection Configuration
      .AUTORESET_PATDET("NO_RESET"),     // NO_RESET, RESET_MATCH, RESET_NOT_MATCH
      .AUTORESET_PRIORITY("RESET"),      // Priority of AUTORESET vs. CEP (CEP, RESET).
      .MASK(48'h3fffffffffff),           // 48-bit mask value for pattern detect (1=ignore)
      .PATTERN(48'h000000000000),        // 48-bit pattern match for pattern detect
      .SEL_MASK("MASK"),                 // C, MASK, ROUNDING_MODE1, ROUNDING_MODE2
      .SEL_PATTERN("PATTERN"),           // Select pattern value (C, PATTERN)
      .USE_PATTERN_DETECT("NO_PATDET"),  // Enable pattern detect (NO_PATDET, PATDET)
      // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
      .IS_ALUMODE_INVERTED(4'b0000),     // Optional inversion for ALUMODE
      .IS_CARRYIN_INVERTED(1'b0),        // Optional inversion for CARRYIN
      .IS_CLK_INVERTED(1'b0),            // Optional inversion for CLK
      .IS_INMODE_INVERTED(5'b00000),     // Optional inversion for INMODE
      .IS_OPMODE_INVERTED(9'b000000000), // Optional inversion for OPMODE
      .IS_RSTALLCARRYIN_INVERTED(1'b0),  // Optional inversion for RSTALLCARRYIN
      .IS_RSTALUMODE_INVERTED(1'b0),     // Optional inversion for RSTALUMODE
      .IS_RSTA_INVERTED(1'b0),           // Optional inversion for RSTA
      .IS_RSTB_INVERTED(1'b0),           // Optional inversion for RSTB
      .IS_RSTCTRL_INVERTED(1'b0),        // Optional inversion for RSTCTRL
      .IS_RSTC_INVERTED(1'b0),           // Optional inversion for RSTC
      .IS_RSTD_INVERTED(1'b0),           // Optional inversion for RSTD
      .IS_RSTINMODE_INVERTED(1'b0),      // Optional inversion for RSTINMODE
      .IS_RSTM_INVERTED(1'b0),           // Optional inversion for RSTM
      .IS_RSTP_INVERTED(1'b0),           // Optional inversion for RSTP
      // Register Control Attributes: Pipeline Register Configuration
      .ACASCREG(0),                      // Number of pipeline stages between A/ACIN and ACOUT (0-2)
      .ADREG(0),                         // Pipeline stages for pre-adder (0-1)
      .ALUMODEREG(0),                    // Pipeline stages for ALUMODE (0-1)
      .AREG(0),                          // Pipeline stages for A (0-2)
      .BCASCREG(0),                      // Number of pipeline stages between B/BCIN and BCOUT (0-2)
      .BREG(0),                          // Pipeline stages for B (0-2)
      .CARRYINREG(0),                    // Pipeline stages for CARRYIN (0-1)
      .CARRYINSELREG(0),                 // Pipeline stages for CARRYINSEL (0-1)
      .CREG(0),                          // Pipeline stages for C (0-1)
      .DREG(0),                          // Pipeline stages for D (0-1)
      .INMODEREG(0),                     // Pipeline stages for INMODE (0-1)
      .MREG(0),                          // Multiplier pipeline stages (0-1)
      .OPMODEREG(0),                     // Pipeline stages for OPMODE (0-1)
      .PREG(0)                           // Number of pipeline stages for P (0-1)
   )
   DSP48E2_1 (
      // Cascade outputs: Cascade Ports
      .ACOUT(),                   // 30-bit output: A port cascade
      .BCOUT(),                   // 18-bit output: B cascade
      .CARRYCASCOUT(carry),     // 1-bit output: Cascade carry
      .MULTSIGNOUT(),       // 1-bit output: Multiplier sign cascade
      .PCOUT(),                   // 48-bit output: Cascade output
      // Control outputs: Control Inputs/Status Bits
      .OVERFLOW(),             // 1-bit output: Overflow in add/acc
      .PATTERNBDETECT(), // 1-bit output: Pattern bar detect
      .PATTERNDETECT(),   // 1-bit output: Pattern detect
      .UNDERFLOW(),           // 1-bit output: Underflow in add/acc
      // Data outputs: Data Ports
      .CARRYOUT(),             // 4-bit output: Carry
      .P(full_sum[47:0]),                           // 48-bit output: Primary data
      .XOROUT(),                 // 8-bit output: XOR data
      // Cascade inputs: Cascade Ports
      .ACIN(30'b0),                     // 30-bit input: A cascade data
      .BCIN(18'b0),                     // 18-bit input: B cascade
      .CARRYCASCIN(1'b0),       // 1-bit input: Cascade carry
      .MULTSIGNIN(1'b0),         // 1-bit input: Multiplier sign cascade
      .PCIN(48'b0),                     // 48-bit input: P cascade
      // Control inputs: Control Inputs/Status Bits
      .ALUMODE(4'b0000),               // 4-bit input: ALU control; 4'b0000=ADD
      .CARRYINSEL(3'b0),         // 3-bit input: Carry select
      .CLK(clk),                       // 1-bit input: Clock
      .INMODE(5'b00000),                 // 5-bit input: INMODE control
      .OPMODE({2'b00,3'b011,2'b00,2'b11}),                 // 9-bit input: Operation mode
      // Data inputs: Data Ports
      .A(AIN[47:18]),                           // 30-bit input: A data
      .B(AIN[17:0]),                           // 18-bit input: B data
      .C(BIN[47:0]),                           // 48-bit input: C data
      .CARRYIN(1'b0),               // 1-bit input: Carry-in
      .D(27'b0),                           // 27-bit input: D data
      // Reset/Clock Enable inputs: Reset/Clock Enable Inputs
      .CEA1(1'b0),                     // 1-bit input: Clock enable for 1st stage AREG
      .CEA2(1'b0),                     // 1-bit input: Clock enable for 2nd stage AREG
      .CEAD(1'b0),                     // 1-bit input: Clock enable for ADREG
      .CEALUMODE(1'b0),           // 1-bit input: Clock enable for ALUMODE
      .CEB1(1'b0),                     // 1-bit input: Clock enable for 1st stage BREG
      .CEB2(1'b0),                     // 1-bit input: Clock enable for 2nd stage BREG
      .CEC(1'b0),                       // 1-bit input: Clock enable for CREG
      .CECARRYIN(1'b0),           // 1-bit input: Clock enable for CARRYINREG
      .CECTRL(1'b0),                 // 1-bit input: Clock enable for OPMODEREG and CARRYINSELREG
      .CED(1'b0),                       // 1-bit input: Clock enable for DREG
      .CEINMODE(1'b0),             // 1-bit input: Clock enable for INMODEREG
      .CEM(0),                       // 1-bit input: Clock enable for MREG
      .CEP(1'b0),                       // 1-bit input: Clock enable for PREG
      .RSTA(rst),                     // 1-bit input: Reset for AREG
      .RSTALLCARRYIN(rst),   // 1-bit input: Reset for CARRYINREG
      .RSTALUMODE(rst),         // 1-bit input: Reset for ALUMODEREG
      .RSTB(rst),                     // 1-bit input: Reset for BREG
      .RSTC(rst),                     // 1-bit input: Reset for CREG
      .RSTCTRL(rst),               // 1-bit input: Reset for OPMODEREG and CARRYINSELREG
      .RSTD(rst),                     // 1-bit input: Reset for DREG and ADREG
      .RSTINMODE(rst),           // 1-bit input: Reset for INMODEREG
      .RSTM(rst),                     // 1-bit input: Reset for MREG
      .RSTP(rst)                      // 1-bit input: Reset for PREG
   );
   
   DSP48E2 #(
      // Feature Control Attributes: Data Path Selection
      .AMULTSEL("A"),                    // Selects A input to multiplier (A, AD)
      .A_INPUT("DIRECT"),                // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .BMULTSEL("B"),                    // Selects B input to multiplier (AD, B)
      .B_INPUT("DIRECT"),                // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .PREADDINSEL("A"),                 // Selects input to pre-adder (A, B)
      .RND(48'h000000000000),            // Rounding Constant
      .USE_MULT("NONE"),             // Select multiplier usage (DYNAMIC, MULTIPLY, NONE)
      .USE_SIMD("ONE48"),                // SIMD selection (FOUR12, ONE48, TWO24)
      .USE_WIDEXOR("FALSE"),             // Use the Wide XOR function (FALSE, TRUE)
      .XORSIMD("XOR24_48_96"),           // Mode of operation for the Wide XOR (XOR12, XOR24_48_96)
      // Pattern Detector Attributes: Pattern Detection Configuration
      .AUTORESET_PATDET("NO_RESET"),     // NO_RESET, RESET_MATCH, RESET_NOT_MATCH
      .AUTORESET_PRIORITY("RESET"),      // Priority of AUTORESET vs. CEP (CEP, RESET).
      .MASK(48'h3fffffffffff),           // 48-bit mask value for pattern detect (1=ignore)
      .PATTERN(48'h000000000000),        // 48-bit pattern match for pattern detect
      .SEL_MASK("MASK"),                 // C, MASK, ROUNDING_MODE1, ROUNDING_MODE2
      .SEL_PATTERN("PATTERN"),           // Select pattern value (C, PATTERN)
      .USE_PATTERN_DETECT("NO_PATDET"),  // Enable pattern detect (NO_PATDET, PATDET)
      // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
      .IS_ALUMODE_INVERTED(4'b0000),     // Optional inversion for ALUMODE
      .IS_CARRYIN_INVERTED(1'b0),        // Optional inversion for CARRYIN
      .IS_CLK_INVERTED(1'b0),            // Optional inversion for CLK
      .IS_INMODE_INVERTED(5'b00000),     // Optional inversion for INMODE
      .IS_OPMODE_INVERTED(9'b000000000), // Optional inversion for OPMODE
      .IS_RSTALLCARRYIN_INVERTED(1'b0),  // Optional inversion for RSTALLCARRYIN
      .IS_RSTALUMODE_INVERTED(1'b0),     // Optional inversion for RSTALUMODE
      .IS_RSTA_INVERTED(1'b0),           // Optional inversion for RSTA
      .IS_RSTB_INVERTED(1'b0),           // Optional inversion for RSTB
      .IS_RSTCTRL_INVERTED(1'b0),        // Optional inversion for RSTCTRL
      .IS_RSTC_INVERTED(1'b0),           // Optional inversion for RSTC
      .IS_RSTD_INVERTED(1'b0),           // Optional inversion for RSTD
      .IS_RSTINMODE_INVERTED(1'b0),      // Optional inversion for RSTINMODE
      .IS_RSTM_INVERTED(1'b0),           // Optional inversion for RSTM
      .IS_RSTP_INVERTED(1'b0),           // Optional inversion for RSTP
      // Register Control Attributes: Pipeline Register Configuration
      .ACASCREG(0),                      // Number of pipeline stages between A/ACIN and ACOUT (0-2)
      .ADREG(0),                         // Pipeline stages for pre-adder (0-1)
      .ALUMODEREG(0),                    // Pipeline stages for ALUMODE (0-1)
      .AREG(0),                          // Pipeline stages for A (0-2)
      .BCASCREG(0),                      // Number of pipeline stages between B/BCIN and BCOUT (0-2)
      .BREG(0),                          // Pipeline stages for B (0-2)
      .CARRYINREG(0),                    // Pipeline stages for CARRYIN (0-1)
      .CARRYINSELREG(0),                 // Pipeline stages for CARRYINSEL (0-1)
      .CREG(0),                          // Pipeline stages for C (0-1)
      .DREG(0),                          // Pipeline stages for D (0-1)
      .INMODEREG(0),                     // Pipeline stages for INMODE (0-1)
      .MREG(0),                          // Multiplier pipeline stages (0-1)
      .OPMODEREG(0),                     // Pipeline stages for OPMODE (0-1)
      .PREG(0)                           // Number of pipeline stages for P (0-1)
   )
   DSP48E2_2 (
      // Cascade outputs: Cascade Ports
      .ACOUT(),                   // 30-bit output: A port cascade
      .BCOUT(),                   // 18-bit output: B cascade
      .CARRYCASCOUT(),     // 1-bit output: Cascade carry
      .MULTSIGNOUT(),       // 1-bit output: Multiplier sign cascade
      .PCOUT(),                   // 48-bit output: Cascade output
      // Control outputs: Control Inputs/Status Bits
      .OVERFLOW(),             // 1-bit output: Overflow in add/acc
      .PATTERNBDETECT(), // 1-bit output: Pattern bar detect
      .PATTERNDETECT(),   // 1-bit output: Pattern detect
      .UNDERFLOW(),           // 1-bit output: Underflow in add/acc
      // Data outputs: Data Ports
      .CARRYOUT(),             // 4-bit output: Carry
      .P(full_sum[95:48]),                           // 48-bit output: Primary data
      .XOROUT(),                 // 8-bit output: XOR data
      // Cascade inputs: Cascade Ports
      .ACIN(30'b0),                     // 30-bit input: A cascade data
      .BCIN(18'b0),                     // 18-bit input: B cascade
      .CARRYCASCIN(carry),       // 1-bit input: Cascade carry
      .MULTSIGNIN(1'b0),         // 1-bit input: Multiplier sign cascade
      .PCIN(48'b0),                     // 48-bit input: P cascade
      // Control inputs: Control Inputs/Status Bits
      .ALUMODE(4'b0000),               // 4-bit input: ALU control; 4'b0000=ADD
      .CARRYINSEL(3'b010),         // 3-bit input: Carry select
      .CLK(clk),                       // 1-bit input: Clock
      .INMODE(5'b00000),                 // 5-bit input: INMODE control
      .OPMODE({2'b00,3'b011,2'b00,2'b11}),                 // 9-bit input: Operation mode
      // Data inputs: Data Ports
      .A(30'b0),                           // 30-bit input: A data
      .B({2'b0, AIN[63:48]}),                           // 18-bit input: B data
      .C({32'b0, BIN[63:48]}),                           // 48-bit input: C data
      .CARRYIN(1'b0),               // 1-bit input: Carry-in
      .D(27'b0),                           // 27-bit input: D data
      // Reset/Clock Enable inputs: Reset/Clock Enable Inputs
      .CEA1(1'b0),                     // 1-bit input: Clock enable for 1st stage AREG
      .CEA2(1'b0),                     // 1-bit input: Clock enable for 2nd stage AREG
      .CEAD(1'b0),                     // 1-bit input: Clock enable for ADREG
      .CEALUMODE(1'b0),           // 1-bit input: Clock enable for ALUMODE
      .CEB1(1'b0),                     // 1-bit input: Clock enable for 1st stage BREG
      .CEB2(1'b0),                     // 1-bit input: Clock enable for 2nd stage BREG
      .CEC(1'b0),                       // 1-bit input: Clock enable for CREG
      .CECARRYIN(1'b0),           // 1-bit input: Clock enable for CARRYINREG
      .CECTRL(1'b0),                 // 1-bit input: Clock enable for OPMODEREG and CARRYINSELREG
      .CED(1'b0),                       // 1-bit input: Clock enable for DREG
      .CEINMODE(1'b0),             // 1-bit input: Clock enable for INMODEREG
      .CEM(0),                       // 1-bit input: Clock enable for MREG
      .CEP(1'b0),                       // 1-bit input: Clock enable for PREG
      .RSTA(rst),                     // 1-bit input: Reset for AREG
      .RSTALLCARRYIN(rst),   // 1-bit input: Reset for CARRYINREG
      .RSTALUMODE(rst),         // 1-bit input: Reset for ALUMODEREG
      .RSTB(rst),                     // 1-bit input: Reset for BREG
      .RSTC(rst),                     // 1-bit input: Reset for CREG
      .RSTCTRL(rst),               // 1-bit input: Reset for OPMODEREG and CARRYINSELREG
      .RSTD(rst),                     // 1-bit input: Reset for DREG and ADREG
      .RSTINMODE(rst),           // 1-bit input: Reset for INMODEREG
      .RSTM(rst),                     // 1-bit input: Reset for MREG
      .RSTP(rst)                      // 1-bit input: Reset for PREG
   );
   
endmodule
				