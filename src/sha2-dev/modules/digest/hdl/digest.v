`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: digest
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
`include "multiformats_codec.vh"
`define HARD_WIRED
module digest
#(
    // AXI Strem Data Width
    parameter C_S_AXIS_DATA_WIDTH=512,
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
    input s_axis_tlast,
    output reg s_axis_tready,

    // Message digest
    output reg [(C_M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output reg [(C_M_AXIS_TUSER_WIDTH-1):0] m_axis_tuser,
    output reg [(C_M_AXIS_DATA_WIDTH/8-1):0]m_axis_tkeep,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast

);
// ----- TUSER specs for identify sha_type ----
localparam TUESR_SLOT_OFFSET = 32;
localparam TUSER_SLOT_WIDTH = 16;
localparam HASH_TUSER_SLOT = 0;
localparam SHA_TUSER_OFFSET = 0;

// DATA
localparam AXIS_DATA_BYTES = C_M_AXIS_DATA_WIDTH/8;
localparam REG_WIDTH = 64;
localparam WORD_WIDTH = 32;


wire reset;
assign reset = ~axis_resetn;

wire [C_M_AXIS_DATA_WIDTH - 1 : 0] hash256;
wire [C_M_AXIS_DATA_WIDTH - 1 : 0] hash512;

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
assign codec = extract_codec(s_axis_tuser);
assign sha_type = codec2sha_type(codec);

// ---------- Reset State: Task -------
task reset_task();
begin

    m_axis_tlast <= 0;
    m_axis_tvalid <= 0;
    s_axis_tready <= 1;
    //busy_tdata = 0;

end
endtask

big_endian Digest512(
    .data_in(s_axis_tdata),
    .data_out(hash512)
);

genvar i;
generate
for(i=0;i<8;i=i+1)
   assign hash256[WORD_WIDTH*(i+1)-1 : WORD_WIDTH*i] = hash512[REG_WIDTH*(i+1)-1 : REG_WIDTH*(i+1)-WORD_WIDTH];
endgenerate
assign hash256[C_M_AXIS_DATA_WIDTH-1:C_M_AXIS_DATA_WIDTH-8*WORD_WIDTH] = {256{1'b0}};

always @(posedge axis_aclk) begin
    if(reset) begin
        reset_task();
    end 
    else begin
        if(s_axis_tvalid) begin
            if(~m_axis_tvalid) begin
                m_axis_tvalid <= 1;
                m_axis_tlast <= 1;
                s_axis_tready <= 0;
                
                m_axis_tuser <= s_axis_tuser;
                if(~sha_type[1])     // sha224/256 needs only 512 bit for hash
                    m_axis_tdata <= hash256;
                else
                    m_axis_tdata <= hash512;
            end

            case (codec)
                `CODEC_SHA2_224:
                    m_axis_tkeep <= {{36{1'b0}},{28{1'b1}}};
                `CODEC_SHA2_256:
                    m_axis_tkeep <= {{32{1'b0}},{32{1'b1}}};
                `CODEC_SHA2_384:
                    m_axis_tkeep <= {{16{1'b0}},{48{1'b1}}};
                `CODEC_SHA2_512:
                    m_axis_tkeep <= {64{1'b1}}; 
                default:
                    m_axis_tkeep <= 0;
            endcase
        end
        if(m_axis_tvalid & m_axis_tready)begin
            m_axis_tvalid <= 0;
            m_axis_tlast <= 0;
            s_axis_tready <= 1;
        end
    end
end

endmodule

