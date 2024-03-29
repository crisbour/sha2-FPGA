`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2020 10:10:17
// Design Name: 
// Module Name: hcu
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

`include "hcu_define.v"
`include "multiformats_codec.vh"
module hcu
#(
    // AXI Strem Data Width
    parameter C_S_AXIS_DATA_WIDTH=64,
    parameter C_M_AXIS_DATA_WIDTH=512,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128
)
(
    // Global Ports
    input axis_aclk,
    input axis_resetn,

    /*** Slave Steam Port ***/
    // Incomig words
    input [(C_S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
    input [(C_S_AXIS_TUSER_WIDTH-1):0] s_axis_tuser,
    input s_axis_tvalid,
    output reg s_axis_tready,
    input s_axis_tlast,

    // Message digest
    output [(C_M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output reg [(C_M_AXIS_TUSER_WIDTH-1):0] m_axis_tuser,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast

);

// ----- TUSER specs for identify sha_type ----
localparam TUESR_SLOT_OFFSET = 32;
localparam TUSER_SLOT_WIDTH = 16;
localparam HASH_TUSER_SLOT = 0;
localparam SHA_TUSER_OFFSET = 0;

localparam [63:0] Kt [0:79]= '{
        64'h428a2f98d728ae22, 64'h7137449123ef65cd, 64'hb5c0fbcfec4d3b2f, 64'he9b5dba58189dbbc,
        64'h3956c25bf348b538, 64'h59f111f1b605d019, 64'h923f82a4af194f9b, 64'hab1c5ed5da6d8118,
        64'hd807aa98a3030242, 64'h12835b0145706fbe, 64'h243185be4ee4b28c, 64'h550c7dc3d5ffb4e2,
        64'h72be5d74f27b896f, 64'h80deb1fe3b1696b1, 64'h9bdc06a725c71235, 64'hc19bf174cf692694,
        64'he49b69c19ef14ad2, 64'hefbe4786384f25e3, 64'h0fc19dc68b8cd5b5, 64'h240ca1cc77ac9c65,
        64'h2de92c6f592b0275, 64'h4a7484aa6ea6e483, 64'h5cb0a9dcbd41fbd4, 64'h76f988da831153b5,
        64'h983e5152ee66dfab, 64'ha831c66d2db43210, 64'hb00327c898fb213f, 64'hbf597fc7beef0ee4,
        64'hc6e00bf33da88fc2, 64'hd5a79147930aa725, 64'h06ca6351e003826f, 64'h142929670a0e6e70,
        64'h27b70a8546d22ffc, 64'h2e1b21385c26c926, 64'h4d2c6dfc5ac42aed, 64'h53380d139d95b3df,
        64'h650a73548baf63de, 64'h766a0abb3c77b2a8, 64'h81c2c92e47edaee6, 64'h92722c851482353b,
        64'ha2bfe8a14cf10364, 64'ha81a664bbc423001, 64'hc24b8b70d0f89791, 64'hc76c51a30654be30,
        64'hd192e819d6ef5218, 64'hd69906245565a910, 64'hf40e35855771202a, 64'h106aa07032bbd1b8,
        64'h19a4c116b8d2d0c8, 64'h1e376c085141ab53, 64'h2748774cdf8eeb99, 64'h34b0bcb5e19b48a8,
        64'h391c0cb3c5c95a63, 64'h4ed8aa4ae3418acb, 64'h5b9cca4f7763e373, 64'h682e6ff3d6b2b8a3,
        64'h748f82ee5defb2fc, 64'h78a5636f43172f60, 64'h84c87814a1f0ab72, 64'h8cc702081a6439ec,
        64'h90befffa23631e28, 64'ha4506cebde82bde9, 64'hbef9a3f7b2c67915, 64'hc67178f2e372532b,
        64'hca273eceea26619c, 64'hd186b8c721c0c207, 64'heada7dd6cde0eb1e, 64'hf57d4f7fee6ed178,
        64'h06f067aa72176fba, 64'h0a637dc5a2c898a6, 64'h113f9804bef90dae, 64'h1b710b35131c471b,
        64'h28db77f523047d84, 64'h32caab7b40c72493, 64'h3c9ebe0a15c9bebc, 64'h431d67c49c100d4c,
        64'h4cc5d4becb3e42b6, 64'h597f299cfc657e2a, 64'h5fcb6fab3ad6faec, 64'h6c44198c4a475817
};

// Internal parameters
localparam REG_LENGTH = 64;


// ------- Feedback loop --------
// Registers and wires
reg [REG_LENGTH-1 : 0] Reg [0:7];
wire [REG_LENGTH-1 : 0] A_new, E_new, T1, T2, sig_ch_sum, wt_kt_sum, wt_kt_h_sum;

// Status registers and wires
reg [6:0] word_count;
wire reset;
assign reset = ~axis_resetn;

//FSM registers
reg [2:0] state, state_next;
reg s_axis_tready_next, m_axis_tvalid_next;
localparam RESET = 0;
localparam UPDATE_REG = 1;
localparam FEED = 2;
localparam UPDATE_HASH = 3;
localparam DIGEST = 4;

wire [1:0] sha_type;
wire [15:0] codec;

// ---------- Hash identification -----------------
function [15:0] extract_codec;
    input [C_M_AXIS_TUSER_WIDTH-1:0] tuser;
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
assign codec = (s_axis_tvalid & state==RESET) ? extract_codec(s_axis_tuser) : extract_codec(m_axis_tuser);
assign sha_type = codec2sha_type(codec);

// Computation blocks
wire [REG_LENGTH-1 : 0] sigma0, sigma0_32, sigma0_64;
wire [REG_LENGTH-1 : 0] sigma1, sigma1_32, sigma1_64;
wire [REG_LENGTH-1 : 0] maj, ch;
assign sigma0 = sha_type[1] ? sigma0_64 : sigma0_32;
assign sigma1 = sha_type[1] ? sigma1_64 : sigma1_32;

// Auxiliary variables
integer i;

// Update Hash
wire [63:0] H [0:7];
wire reset_hash, update_hash;
reg finish;

assign m_axis_tdata = {H[0],H[1],H[2],H[3],H[4],H[5],H[6],H[7]}; //{Reg[0],Reg[1],Reg[2],Reg[3],Reg[4],Reg[5],Reg[6],Reg[7]};  
/* sha_type_reg[1] ?
            {H[0],H[1],H[2],H[3],H[4],H[5],H[6],H[7]} : 
            {H[0][63:32],H[1][63:32],H[2][63:32],H[3][63:32],
            H[4][63:32],H[5][63:32],H[6][63:32],H[7][63:32],
            256'b0};
            */
assign reset_hash = (state == RESET);
assign update_hash = (state == UPDATE_HASH);


initial begin
    m_axis_tvalid = 0;
    s_axis_tready = 0;
end

// ---------- Reset State: Task -------
task reset_task();
begin

    m_axis_tlast <= 0;

    finish <= 0;
    word_count <= 0;

end
endtask

// ---------- FSM --------------

// FSM transitions
always @(*) begin 
    state_next = state;
    s_axis_tready_next = s_axis_tready;
    m_axis_tvalid_next = m_axis_tvalid;
    case(state)
        RESET: begin
            m_axis_tvalid_next = 0;
            if(s_axis_tvalid)
                state_next = UPDATE_REG;
        end
        UPDATE_REG: begin
            state_next = FEED;
            s_axis_tready_next = 1;
        end
        FEED: begin
            if(s_axis_tvalid) begin
                if((sha_type[1] && word_count==`BLOCK1024_WORDS-1) ||
                    (!sha_type[1] && word_count==`BLOCK512_WORDS-1)) begin
                        state_next = UPDATE_HASH;
                        s_axis_tready_next = 0;
                    end
            end
        end
        UPDATE_HASH: begin
            if (finish) begin
               state_next = DIGEST;
               m_axis_tvalid_next = 1;
            end
            else
                state_next = UPDATE_REG;
        end
        DIGEST: begin
            if(m_axis_tready) begin
                m_axis_tvalid_next = 0;
                state_next = RESET;
            end
        end
    endcase
end

//----------Seq Logic------------------
always @(posedge axis_aclk)
begin
    if(reset) begin
        state <= RESET;
        m_axis_tvalid <= 0;
        s_axis_tready <= 0;
        reset_task();
    end else begin
        state <= state_next;
        s_axis_tready <= s_axis_tready_next;
        m_axis_tvalid <= m_axis_tvalid_next;
        m_axis_tlast <= m_axis_tvalid_next;
    end
end

always @(posedge axis_aclk) begin
    if(~reset) begin
        case(state)
            RESET: begin
                reset_task();
                m_axis_tuser <= s_axis_tuser;
            end

            UPDATE_REG: begin
                for(i=0;i<8;i=i+1)
                    Reg[i] <= H[i];
            end

            FEED: begin
                if(s_axis_tvalid)begin
                    Reg[0] <= A_new;
                    Reg[1] <= Reg[0];
                    Reg[2] <= Reg[1];
                    Reg[3] <= Reg[2];
                    Reg[4] <= E_new;
                    Reg[5] <= Reg[4];
                    Reg[6] <= Reg[5];
                    Reg[7] <= Reg[6];

                    word_count <= word_count + 1;
                    if(s_axis_tlast)
                        finish <= 1;
                end
            end

            UPDATE_HASH: begin
                word_count <= 0;
            end

            DIGEST : begin
            end
        endcase // state
    end
end

// ------- Modules ------------
//Computation modules
// Ks =[2,13,22], [28,34,39]
Sigma #(.p1(2), .p2(13), .p3(22))
Sigma0_32 (
    .data_width_flag(sha_type[1]),
    .data_value(Reg[0]),
    .sigma_value(sigma0_32)
);
// Gs = [6,11,25], [14,18,41]
Sigma #(.p1(6), .p2(11), .p3(25))
Sigma1_32 (
    .data_width_flag(sha_type[1]),
    .data_value(Reg[4]),
    .sigma_value(sigma1_32)
);

// Ks =[2,13,22], [28,34,39]
Sigma #(.p1(28), .p2(34), .p3(39))
Sigma0_64 (
    .data_width_flag(sha_type[1]),
    .data_value(Reg[0]),
    .sigma_value(sigma0_64)
);
// Gs = [6,11,25], [14,18,41]
Sigma #(.p1(14), .p2(18), .p3(41))
Sigma1_64 (
    .data_width_flag(sha_type[1]),
    .data_value(Reg[4]),
    .sigma_value(sigma1_64)
);

Majority Maj(
    .x_val(Reg[0]),
    .y_val(Reg[1]),
    .z_val(Reg[2]),
    .maj_value(maj)
);

Choose Ch(
    .x_val(Reg[4]),
    .y_val(Reg[5]),
    .z_val(Reg[6]),
    .ch_value(ch)
);

// Update Hash Words content
hash_update per_block(
    .clk(axis_aclk),
    .reset(reset_hash),

    .sha_type(sha_type),
    .update(update_hash),

    .AH(Reg),
    .H(H)
);

// -------- Modulo 32/64 adders -------
madd_Kt wt_kt(
    .a(s_axis_tdata),
    .kt(Kt[word_count]),
    .s(wt_kt_sum),
    .mode64(sha_type[1])
);

madd_32_64 wt_kt_h(
    .a(wt_kt_sum),
    .b(Reg[7]),
    .s(wt_kt_h_sum),
    .mode64(sha_type[1])
);
madd_32_64 Sig_Ch(
    .a(sigma1),
    .b(ch),
    .s(sig_ch_sum),
    .mode64(sha_type[1])
);
madd_32_64 T1_sum(
    .a(sig_ch_sum),
    .b(wt_kt_h_sum),
    .s(T1),
    .mode64(sha_type[1])
);
madd_32_64 Sig_Maj(
    .a(sigma0),
    .b(maj),
    .s(T2),
    .mode64(sha_type[1])
);
madd_32_64 A_sum(
    .a(T1),
    .b(T2),
    .s(A_new),
    .mode64(sha_type[1])
);
madd_32_64 E_sum(
    .a(Reg[3]),
    .b(T1),
    .s(E_new),
    .mode64(sha_type[1])
);


endmodule

