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
module hcu
#(
    // AXI Strem Data Width
    parameter WORD_AXIS_DATA_WIDTH=64,
    parameter S_AXIS_DATA_WIDTH=64,
    parameter M_AXIS_DATA_WIDTH=512
)
(
    // Global Ports
    input axi_aclk,
    input axi_resetn,

    // Control
    input [1:0] sha_type,  // msb is 0 if SHA224/256 and 1 if SHA384/512
    input en,   // 1 if the hashing engine has been enabled by the scheduler

    /*** Slave Steam Port ***/
    // Incomig words
    input [(S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
    input s_axis_tvalid,
    output reg s_axis_tready,
    input s_axis_tlast,

    // Message digest
    output [(M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast

);

// Internal parameters
localparam REG_LENGTH = 64;
localparam ELEM_REG_LENGTH = 32;


// ------- Feedback loop --------
// Registers and wires
reg [REG_LENGTH-1 : 0] Reg [7:0];
wire [REG_LENGTH-1 : 0] A_new, E_new, T1, T2, sig_ch_sum, sig_maj_sum, wt_kt_sum, wt_kt_h_sum;

// Status registers
reg [6:0] word_count;

// Computation blocks
wire [REG_LENGTH-1 : 0] sigma0, sigma1;
wire [REG_LENGTH-1 : 0] maj, ch;

// Auxiliary variables
integer i;

// Update Hash
wire [63:0] H [0:7];
wire reset_hash;
reg digest_count;
assign m_axis_tdata = sha_type_reg ?
        (digest_count ?
            {H[0],H[1],H[2],H[3]} : 
            {H[4],H[5],H[6],H[7]}
        ) : {H[0][63:32],H[1][63:32],H[2][63:32],H[3][63:32],
            H[4][63:32],H[5][63:32],H[6][63:32],H[7][63:32]};
assign reset_hash = (state == RESET);



// ---------- Reset State: Task -------
task reset_task();
begin

    m_axis_tlast = 0;
    m_axis_tvalid = 0;
    s_axis_tready = 0;

    digest_count = 0;
    word_count = 0;

end
endtask

// ---------- FSM --------------
//FSM registers
reg [2:0] state, state_next;
reg s_axis_tready_next, m_axis_tvalid_next;
localparam RESET = 0;
localparam UPDATE_REG = 1;
localparam FEED = 2;
localparam UPDATE_HASH = 3;
localparam DIGEST = 4;

// FSM transitions
always @(*) begin 
    state_next = state;
    s_axis_tready_next = s_axis_tready;
    m_axis_tvalid_next = m_axis_tvalid;
    case(state)
        RESET: begin
            m_axis_tvalid_next = 0;
            if(en)
                state_next = UPDATE_REG;
        end
        UPDATE_REG: begin
            state_next = FEED;
            s_axis_tready_next = 1;
        end
        FEED: begin
            if (sha_type_reg != sha_type)begin
                state_next = RESET;
            end
            else if(s_axis_tvalid) begin
                if((sha_type_reg[1] && word_count==BLOCK1024_WORDS-1) ||
                    (!sha_type_reg[1] && word_count==BLOCK512_WORDS-1)) begin
                        sate_next = UPDATE_HASH;
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
            
        end
    endcase
end

//----------Seq Logic------------------
always @(posedge axi_aclk)
begin
    if(reset) begin
        state <= RESET;
        reset_task();
    end else begin
        state <= state_next;
        s_axis_tready <= s_axis_tready_next;
        m_axis_tvalid <= m_axis_tvalid_next;
    end
end

always @(posedge axi_aclk) begin
    if(~reset) begin
        case(state)
            RESET: begin
                reset_task();
                if(en)
                    sha_type_reg <= sha_type;
            end

            UPDATE_REG: begin
                for(i=0;i<8;i=i+1)
                    Reg[i] <= hash_value[i];
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
// Computation modules
Sigma #(p1=2, p2=13, p3=22) Sigma0 (
    .data_width_flag(sha_type[1]),
    .data_value(A),
    .sigma_value(sigma0)
);

Sigma #(p1=6, p2=11, p3=25) Sigma1 (
    .data_width_flag(sha_type[1]),
    .data_value(E),
    .sigma_value(sigma1)
);

Majority Maj(
    .x_val(B),
    .y_val(C),
    .z_val(D),
    .maj_value(maj)
);

Choose Ch(
    .x_val(E),
    .y_val(F),
    .z_val(G),
    .ch_value(ch)
);

// Update Hash Words content
hash_update per_block(
    .clk(axi_aclk),
    .reset(reset_hash),

    .mode64(sha_type[1]),
    .update(update),

    .AH(Reg),
    .H(hash_value),
);

// -------- Modulo 32/64 adders -------
madd_32_64 wt_kt(
    .a(s_axis_tdata),
    .b(Kt[word_count]),
    .s(wt_kt_sum),
    .mode(sha_type_reg[1])
);

madd_32_64 wt_kt_h(
    .a(wt_kt_sum),
    .b(Reg[7]),
    .s(wt_kt_h_sum),
    .mode(sha_type_reg[1])
);
madd_32_64 Sig_Ch(
    .a(sigma1),
    .b(ch),
    .s(sig_ch_sum),
    .mode(sha_type_reg[1])
);
madd_32_64 Sig_Ch(
    .a(sig_ch_sum),
    .b(wt_kt_h_sum),
    .s(T1),
    .mode(sha_type_reg[1])
);
madd_32_64 Sig_Ch(
    .a(sigma1),
    .b(ch),
    .s(sig_ch_sum),
    .mode(sha_type_reg[1])
);
madd_32_64 Sig_Ch(
    .a(sigma0),
    .b(maj),
    .s(T2),
    .mode(sha_type_reg[1])
);
madd_32_64 Sig_Ch(
    .a(T1),
    .b(T2),
    .s(A_new),
    .mode(sha_type_reg[1])
);
madd_32_64 Sig_Ch(
    .a(Reg[3]),
    .b(T1),
    .s(E_new),
    .mode(sha_type_reg[1])
);


endmodule

