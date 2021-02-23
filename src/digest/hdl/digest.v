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
    output reg s_axis_tready,

    // Message digest
    output reg [(M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output reg [(M_AXIS_DATA_WIDTH/8-1):0]m_axis_tkeep,
    output reg m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast

);

localparam AXIS_DATA_BYTES = M_AXIS_DATA_WIDTH/8;
localparam REG_WIDTH = 64;
localparam WORD_WIDTH = 32;

localparam SHA224 = 2'b00 ;
localparam SHA256 = 2'b01 ;
localparam SHA384 = 2'b10 ;
localparam SHA512 = 2'b11 ;

wire reset;
assign reset = ~axi_resetn;

wire [M_AXIS_DATA_WIDTH - 1 : 0] hash256;
wire [M_AXIS_DATA_WIDTH - 1 : 0] hash512;


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
assign hash256[M_AXIS_DATA_WIDTH-1:M_AXIS_DATA_WIDTH-8*WORD_WIDTH] = {256{1'b0}};

always @(posedge axi_aclk) begin
    if(reset) begin
        reset_task();
    end 
    else begin
        if(s_axis_tvalid) begin
            if(~m_axis_tvalid) begin
                m_axis_tvalid <= 1;
                m_axis_tlast <= 1;
                s_axis_tready <= 0;
                if(~sha_type[1])     // sha224/256 needs only 512 bit for hash
                    m_axis_tdata <= hash256;
                else
                    m_axis_tdata <= hash512;
            end

            case (sha_type)
                SHA224:
                    m_axis_tkeep <= {{36{1'b0}},{28{1'b1}}};
                SHA256:
                    m_axis_tkeep <= {{32{1'b0}},{32{1'b1}}};
                SHA384:
                    m_axis_tkeep <= {{16{1'b0}},{48{1'b1}}};
                SHA512:
                    m_axis_tkeep <= {64{1'b1}}; 
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

