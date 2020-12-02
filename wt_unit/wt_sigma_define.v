// This file contains the constants definitions for SHA2
// SHA224, SHA256, SHA384, SHA512

// ----- SHA2 Types -----
`define SHA224_type 2'b00
`define SHA256_type 2'b01
`define SHA384_type 2'b10
`define SHA512_type 2'b11

// SHA2 Number of steps per block
`define BLOCK512_STEPS 64
`define BLOCK1024_STEPS 80

// -------- SHA224 -------
// Sigma0
`define SHA224_S0_1	3
`define SHA224_S0_2	18
`define SHA224_S0_3	7
// Sigma1
`define SHA224_S1_1	10
`define SHA224_S1_2	19
`define SHA224_S1_3	17

// -------- SHA256 -------
// Sigma0
`define SHA256_S0_1	3
`define SHA256_S0_2	18
`define SHA256_S0_3	7
// Sigma1
`define SHA256_S1_1	10
`define SHA256_S1_2	19
`define SHA256_S1_3	17

// -------- SHA384 -------
// Sigma0
`define SHA384_S0_1	7
`define SHA384_S0_2	8
`define SHA384_S0_3	1
// Sigma1
`define SHA384_S1_1	6
`define SHA384_S1_2	61
`define SHA384_S1_3	19

// -------- SHA512 -------
// Sigma0
`define SHA512_S0_1	7
`define SHA512_S0_2	8
`define SHA512_S0_3	1
// Sigma1
`define SHA512_S1_1	6
`define SHA512_S1_2	61
`define SHA512_S1_3	19