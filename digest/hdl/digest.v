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

`define HARD_WIRED
module digest
#(
    // AXI Strem Data Width
    parameter S_AXIS_DATA_WIDTH=512,
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
    output reg s_axis_tready

    // Message digest
    output reg [(M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output reg [(M_AXIS_DATA_WIDTH/8-1):0]m_axis_tkeep,
    output reg m_axis_tvalid,
    input m_axis_tready

);

localparam AXIS_DATA_BYTES = M_AXIS_DATA_WIDTH/8;
localparam hash_word_width = 32;
localparam SHA224 = 2b'00;
localparam SHA256 = 2b'01;
localparam SHA384 = 2b'10;
localparam SHA512 = 2b'11;

reg [M_AXIS_DATA_WIDTH - 1 : 0] buffer;

// Function to change endianess of hash value
function [M_AXIS_DATA_WIDTH:0] big_endian;
input [M_AXIS_DATA_WIDTH:0] input_value;
integer byte;
for(byte=0;byte<AXIS_DATA_BYTES;byte=byte+1)begin
    big_endian[(AXIS_DATA_BYTES-byte)*8-1:(AXIS_DATA_BYTES-byte-1)*8] = 
        input_value[AXIS_DATA_BYTES*(byte+1)-1:AXIS_DATA_BYTES*byte];
end
endfunction //big_endian

// ---------- Reset State: Task -------
task reset_task();
begin

    m_axis_tlast = 0;
    m_axis_tvalid = 0;
    s_axis_tready = 1;
    busy_tdata = 0;

end
endtask


always @(posedge axi_aclk) begin
    if(reset) begin
        reset_task();
    end 
    else begin
        if(s_axis_tvalid) begin
            if(~m_axis_tvalid) begin
                sha_type_reg = sha_type;
                m_axis_tvalid <= 1;
                s_axis_tready <= 0;
                if(~sha_type_reg[1]) begin    // sha224/256 needs only 512 bit for hash
                    for(i=0;i<8;i++)
                        buffer[hash_word_width*(i+1) - 1:hash_word_width*i] =
                            s_axis_tdata[8-i][63:32];
                    m_axis_tdata <= big_endian({(M_AXIS_DATA_WIDTH/2){1b'0},buffer}); 
                end
                else
                    m_axis_tdata <= big_endian(s_axis_tdata);
            end

            case (sha_type_reg):
                SHA224:
                    m_axis_tkeep <= {288{1b'0},224{1b'1}};
                SHA256:
                    m_axis_tkeep <= {256{1b'0},256{1b'1}};
                SHA384:
                    m_axis_tkeep <= {128{1b'1},384{1b'1}};
                SHA512:
                    m_axis_tkeep <= {512{1b'1}}; 
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

