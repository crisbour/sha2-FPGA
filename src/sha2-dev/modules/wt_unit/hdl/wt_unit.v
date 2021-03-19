`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Oxford
// Engineer: Cristian Bourceanu
// 
// Create Date: 20.11.2020 09:34:34
// Design Name: W(t) chunks generator
// Module Name: wt_unit
// Project Name: SHA2_FPGA
// Target Devices: Alveo U280
// Tool Versions: icarus 11.2
// Description: 
// 
// Dependencies: padder.v
// 
// Revision:
// Revision 0.2.1 - Fixing Sigma Function
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "wt_sigma_define.v"

module wt_unit
#(
    // AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=64,
    parameter C_S_AXIS_DATA_WIDTH=512,
    parameter DATA_BLOCK_REG_WIDTH=512,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128
)
(
    // Global Ports
    input axis_aclk,
    input axis_resetn,

    // Master Stream Port
    output [(C_M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output reg [(C_M_AXIS_TUSER_WIDTH-1):0] m_axis_tuser,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast,

    // Slave Stream Port
    input [(C_S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
    input [(C_S_AXIS_TUSER_WIDTH-1):0] s_axis_tuser,
    input s_axis_tvalid,
    output reg s_axis_tready,
    input s_axis_tlast
);
// ----- TUSER specs for identify sha_type ----
localparam TUESR_SLOT_OFFSET = 32;
localparam TUSER_SLOT_WIDTH = 16;
localparam HASH_TUSER_SLOT = 0;
localparam SHA_TUSER_OFFSET = 0;

// Internal Parameters
localparam REG_WT_R_LENGTH = 32;
localparam REG_WT_LR_LENGTH = 64;
localparam L_REG_WT_LENGTH = 32;
localparam R_REG_WT_LENGTH = 32;
localparam WT_LENGTH = 16;

// Registers and wries for W(t)
reg [REG_WT_LR_LENGTH-1 : 0] Reg [WT_LENGTH-1 : 0];
wire [REG_WT_LR_LENGTH-1 : 0] W0_Reg; //Register to inspect value of Reg[0] in simulation
assign W0_Reg = Reg[0];
assign m_axis_tdata = Reg[0];

// Wires and registers for assessing states
wire reset;
wire load_reg;
wire hcu_read;
reg finish;
wire [1:0] sha_type;
reg [6:0] loopbacks;

// ---------- Hash identification -----------------
function [15:0] extract_codec;
    input [C_AXIS_TUSER_WIDTH-1:0] tuser;
    begin
        if(tuser[`CODEC_POS + 7: `CODEC_POS] >= 8'h80) 
            extract_codec = {tuser[`CODEC_POS+7: `CODEC_POS],tuser[`CODEC_POS+15: `CODEC_POS+8]};
        else
            extract_codec = tuser[`CODEC_POS + 15: `CODEC_POS];
    end

endfunction

// Bit 0 signifies if the codec is supported
// Bit 1 signifies whether it is a 512 or 1024 block based sha hash. Supports sha1 and sha2
function [1:0] codec2sha_type;
    input [15:0] codec;
    begin
        case(codec)
            `CODEC_SHA2_224:    codec2sha_type = 2'b00;
            `CODEC_SHA2_256:    codec2sha_type = 2'b01;
            `CODEC_SHA2_384:    codec2sha_type = 2'b10;
            `CODEC_SHA2_512:    codec2sha_type = 2'b11;
            default:            codec2sha_type = 2'b00;
        endcase
    end
endfunction


// Logic
assign codec = (s_axis_tvalid & state==IDLE) ? extract_codec(s_axis_tuser) : extract_codec(m_axis_tuser);

assign sha_type = codec2sha_type(codec);

assign hcu_read = m_axis_tready & m_axis_tvalid;
assign load_reg = s_axis_tready & s_axis_tvalid;
assign reset = ~axis_resetn;

// Auxiliary variables
integer i;
integer b;

initial begin
    s_axis_tready = 0;
    m_axis_tvalid = 0;
    m_axis_tuser = 0;
end

// ---------- Function Sigma ----------
function [REG_WT_LR_LENGTH-1 : 0] sigma;
    input [REG_WT_LR_LENGTH-1 : 0] tempReg;
    input [1:0] sha_type;
    input operation;
    integer s1, s2, s3;
    reg [REG_WT_LR_LENGTH-1 : 0] op1, op2, op3;
    
    begin
        case(sha_type)
            `SHA224_type:
                if(operation) begin
                    s1 = `SHA224_S1_1; s2 = `SHA224_S1_2; s3 = `SHA224_S1_3;
                end else begin
                    s1 = `SHA224_S0_1; s2 = `SHA224_S0_2; s3 = `SHA224_S0_3;
                end
            `SHA256_type:
                if(operation) begin
                    s1 = `SHA256_S1_1; s2 = `SHA256_S1_2; s3 = `SHA256_S1_3;
                end else begin
                    s1 = `SHA256_S0_1; s2 = `SHA256_S0_2; s3 = `SHA256_S0_3;
                end
            `SHA384_type:
                if(operation) begin
                    s1 = `SHA384_S1_1; s2 = `SHA384_S1_2; s3 = `SHA384_S1_3;
                end else begin
                    s1 = `SHA384_S0_1; s2 = `SHA384_S0_2; s3 = `SHA384_S0_3;
                end
            `SHA512_type:
                if(operation) begin
                    s1 = `SHA512_S1_1; s2 = `SHA512_S1_2; s3 = `SHA512_S1_3;
                end else begin
                    s1 = `SHA512_S0_1; s2 = `SHA512_S0_2; s3 = `SHA512_S0_3;
                end
        endcase // sha_type
        op1 = tempReg >> s1;
        if(sha_type[1]) begin
            op2 = tempReg >> s2 | tempReg << (REG_WT_LR_LENGTH-s2);
            op3 = tempReg >> s3 | tempReg << (REG_WT_LR_LENGTH-s3);
        end else begin
            op2 = tempReg >> s2 | tempReg << (REG_WT_R_LENGTH-s2);
            op3 = tempReg >> s3 | tempReg << (REG_WT_R_LENGTH-s3);
        end        
        sigma = op1 ^ op2 ^ op3;
    end
endfunction

// ---------- FSM --------------
//FSM registers
reg [2:0] state, state_next;
reg s_axis_tready_next, m_axis_tvalid_next, m_axis_tlast_next;
localparam IDLE = 0;
localparam BLOCK512 = 1;
localparam BLOCK1024_L = 2;
localparam BLOCK1024_R = 3;
localparam TRANSF512 = 4;
localparam TRANSF1024 = 5;

// FSM transitions
always @(*) begin 
    state_next = state;
    s_axis_tready_next = s_axis_tready;
    m_axis_tvalid_next = m_axis_tvalid;
    m_axis_tlast_next = 0;
    case(state)
        IDLE: begin
            m_axis_tvalid_next = 0;
            if(s_axis_tvalid) begin
                s_axis_tready_next = 1;
                if(sha_type[1]) state_next = BLOCK1024_L;
                else state_next = BLOCK512;
            end
        end
        BLOCK512: begin
            if(s_axis_tvalid) begin
                s_axis_tready_next = 0; 
                m_axis_tvalid_next = 1;
                state_next = TRANSF512;
            end
        end
        TRANSF512: begin
            if(loopbacks == `BLOCK512_STEPS-1 & hcu_read) begin
                m_axis_tvalid_next = 0;
                if(finish) state_next = IDLE;
                else begin
                    s_axis_tready_next = 1;
                    state_next = BLOCK512;
                end
            end
        end
        BLOCK1024_L: begin
            if (s_axis_tvalid) begin
               state_next = BLOCK1024_R;
            end
        end
        BLOCK1024_R: begin
            if (s_axis_tvalid) begin
                s_axis_tready_next = 0;
                m_axis_tvalid_next = 1;
                state_next = TRANSF1024;
            end
        end
        TRANSF1024: begin
            if(loopbacks == `BLOCK1024_STEPS-1 & hcu_read) begin
                m_axis_tvalid_next = 0;
                if(finish)  state_next = IDLE;
                else begin
                    s_axis_tready_next = 1;
                    state_next = BLOCK1024_L;
                end
            end
        end
    endcase
end

//----------Seq Logic----------------------
always @(posedge axis_aclk)
begin: FSM_SEQ
    if(reset) begin
        // reset_task();
    end else begin
        state <= state_next;
        s_axis_tready <= s_axis_tready_next;
        m_axis_tvalid <= m_axis_tvalid_next;
    end
end

always @(posedge axis_aclk) begin
    if(reset) begin
        state <= IDLE;

        m_axis_tlast <= 0;
        m_axis_tvalid <= 0;
        s_axis_tready <= 0;
        m_axis_tuser <= 0;

        finish <= 0;
        loopbacks <= 0;

        for(i=0;i<16;i=i+1) begin // Clear the registers
                        Reg[i] <= 0;
        end
    end 
    else begin
        case(state)
            IDLE: begin
                m_axis_tlast <= 0;
                m_axis_tuser <= s_axis_tuser;

                finish <= 0;
                loopbacks <= 0;

                for(i=0;i<16;i=i+1) begin // Clear the registers
                                Reg[i] <= 0;
                end
            end

            BLOCK512: begin
                if(load_reg & ~finish) begin
                    if(s_axis_tlast)    finish <= 1;    // End of message
                end
            end

            TRANSF512: begin
                if(hcu_read & loopbacks == `BLOCK512_STEPS-1)
                begin
                    loopbacks <= 0;
                    m_axis_tlast <= 0; 
                end
                if(hcu_read && loopbacks<`BLOCK512_STEPS-1) begin
                    if(loopbacks == `BLOCK512_STEPS-2 & finish) 
                         m_axis_tlast <= 1; //Next available tdata is the last chunck "Wt" for this Message
                    loopbacks <= loopbacks + 1; // Count number of iterations

                    for(i=0;i<15;i=i+1) begin
                        Reg[i] <= Reg[i+1];
                    end
                    // This modulo addition should be replaced with two CSAs and one CPA with widths matched
                    /* verilator lint_off WIDTH */
                    Reg[15][REG_WT_LR_LENGTH-1:0] <= 32'hFFFFFFFF &
                            (  Reg[0][REG_WT_R_LENGTH-1:0]
                             + sigma(Reg[1][REG_WT_R_LENGTH-1:0],sha_type,0)
                             + Reg[9][REG_WT_R_LENGTH-1:0]
                             + sigma(Reg[14][REG_WT_R_LENGTH-1:0],sha_type,1));
                    /* verilator lint_on WIDTH */  
                end
            end

            // BLOCK1024_L: begin
            //     if(load_reg & ~finish) begin
            //         for(i=0;i<8;i=i+1) begin
            //             b = 64 * i;
            //             // Change order of bytes such that msb in Message is msb in Reg
            //             Reg[i][63:56]   <= 8'hff & (s_axis_tdata>>b);
            //             Reg[i][55:48]   <= 8'hff & (s_axis_tdata>>(b+8));
            //             Reg[i][47:40]   <= 8'hff & (s_axis_tdata>>(b+16));
            //             Reg[i][39:32]   <= 8'hff & (s_axis_tdata>>(b+24));
            //             Reg[i][31:24]   <= 8'hff & (s_axis_tdata>>(b+32));
            //             Reg[i][23:16]   <= 8'hff & (s_axis_tdata>>(b+40));
            //             Reg[i][15:8]    <= 8'hff & (s_axis_tdata>>(b+48));
            //             Reg[i][7:0]     <= 8'hff & (s_axis_tdata>>(b+56));
            //         end
            //     end
            // end

            BLOCK1024_R: begin
                if(load_reg & ~finish) begin
                    // for(i=0;i<8;i=i+1) begin
                    //     b = 64 * i;
                    //     // Change order of bytes such that msb in Message is msb in Reg
                    //     Reg[i+8][63:56]   <= 8'hff & (s_axis_tdata>>b);
                    //     Reg[i+8][55:48]   <= 8'hff & (s_axis_tdata>>(b+8));
                    //     Reg[i+8][47:40]   <= 8'hff & (s_axis_tdata>>(b+16));
                    //     Reg[i+8][39:32]   <= 8'hff & (s_axis_tdata>>(b+24));
                    //     Reg[i+8][31:24]   <= 8'hff & (s_axis_tdata>>(b+32));
                    //     Reg[i+8][23:16]   <= 8'hff & (s_axis_tdata>>(b+40));
                    //     Reg[i+8][15:8]    <= 8'hff & (s_axis_tdata>>(b+48));
                    //     Reg[i+8][7:0]     <= 8'hff & (s_axis_tdata>>(b+56));
                    // end
                    if(s_axis_tlast)    finish <= 1;    // End of message
                end
            end

            TRANSF1024 : begin
                if(hcu_read & loopbacks == `BLOCK1024_STEPS-1) begin
                    loopbacks <= 0;
                    m_axis_tlast <= 0;
                end
                if(hcu_read && loopbacks<`BLOCK1024_STEPS-1) begin
                    if(loopbacks == `BLOCK1024_STEPS-2 & finish) 
                         m_axis_tlast <= 1; //Next available tdata is the last chunck "Wt" for this Message
                    loopbacks <= loopbacks + 1; // Count number of iterations

                    for(i=0;i<15;i=i+1) begin
                        Reg[i] <= Reg[i+1];
                    end
                    // This modulo addition should be replaced with two CSAs and one CPA with widths matched
                    Reg[15] <= Reg[0]
                             + sigma(Reg[1],sha_type,0)
                             + Reg[9]
                             + sigma(Reg[14],sha_type,1);  
                end
            end
        endcase // state
    end
end

// Little endian to big-endian
//TODO: Make this functionality under a module and clock Reg[_] in the previous always block
// such that 
genvar indx,by;
generate
    for(by=0;by<4;by=by+1)
        for(indx=0;indx<16;indx=indx+1)
            always @(posedge axis_aclk) begin
                if(state==BLOCK512 & ~reset & load_reg & ~finish) begin
                    // Change order of bytes such that msb in Message is msb in Reg
                    Reg[indx][8*by+7:8*by]     <= s_axis_tdata[32*indx+(31-8*by):32*indx+(24-8*by)];
                end
            end
endgenerate

generate
    for(by=0;by<8;by=by+1)
        for(indx=0;indx<8;indx=indx+1)
            always @(posedge axis_aclk)begin
                if(state==BLOCK1024_L & ~reset & load_reg & ~finish)begin
                    // Change order of bytes such that msb in Message is msb in Reg
                    Reg[indx][8*by+7:8*by]   <= s_axis_tdata[64*indx+(63-8*by):64*indx+(56-8*by)];
                end
                if(state==BLOCK1024_R & ~reset & load_reg & ~finish)begin
                    // Change order of bytes such that msb in Message is msb in Reg
                    Reg[indx+8][8*by+7:8*by]   <= s_axis_tdata[64*indx+(63-8*by):64*indx+(56-8*by)];
                end
            end
endgenerate

`ifdef COCOTB_SIM
`ifndef VERILATOR // traced differently
initial begin
  $dumpfile ("dump.vcd");
  $dumpvars (0,wt_unit);
  #1;
end
`endif
`endif

endmodule
