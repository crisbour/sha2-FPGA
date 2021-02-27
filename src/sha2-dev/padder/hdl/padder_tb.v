`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.11.2020 10:02:55
// Design Name: 
// Module Name: padder_tb
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


module padder_tb;

// Parameters
parameter CLK_PERIOD = 10;
parameter P_M_AXIS_DATA_WIDTH = 512;
parameter P_S_AXIS_DATA_WIDTH = 512;
parameter DATA_BLOCK_REG_WIDTH = 512;

function integer log2;
    input integer number;
    begin
        log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
    end
endfunction // log2

// Signals generated
reg clk, reset;
reg en;

// Receiving AXI4-Stream
reg [P_S_AXIS_DATA_WIDTH-1 : 0] r_tdata;
wire [DATA_BLOCK_REG_WIDTH/8 - 1 : 0] r_tkeep;
wire r_tvalid;
wire r_tready;
wire r_tlast;

// Transmitting AXI4-Stream
wire [P_M_AXIS_DATA_WIDTH-1 : 0] t_tdata;
wire t_tvalid;
reg t_tready;
wire t_tlast;

// Testing registers
reg [P_S_AXIS_DATA_WIDTH-1 : 0] modify;
reg [7:0] valid;
reg [7:0] last;
reg [63:0] keep;
reg finished;

// Clock generation
initial begin
	clk = 0;
	forever
		# (CLK_PERIOD/2) clk = ~clk;
end

initial begin
	// Set testing vectors
	modify = 512'b1;
	valid = 8'b11010011;
	last = 8'b10000000;
	keep = {16{1'b1}};
	
	finished = 0;
end

assign r_tvalid = valid[0];
assign r_tlast = last[0];
assign r_tkeep = r_tlast ? keep : {64{1'b1}};

initial begin
	r_tdata = 1;
	t_tready = 1;
	reset = 1;
	en = 1;
	#(CLK_PERIOD/2);
	reset = 0;
	forever begin
		#CLK_PERIOD
		if(r_tready) begin
		
			valid <= valid >> 1;
			last <= last >> 1;
			if(r_tvalid) begin
				modify <= modify << 64;
				r_tdata <= r_tdata | (modify << 64);
			end
			
			if(r_tlast) begin
			    finished <= 1;
			end
		end
	end

end

initial begin
    forever begin
    #CLK_PERIOD;
    if(finished) begin
    #(4*CLK_PERIOD)
        $display("**Test Finished! **\n");
        $finish;
    end
    end
end



padder padder_ut(
	.axis_aclk		(clk),
    .axis_resetn		(~reset),

    // Control
    .sha_type		(0),  // 0 if SHA256 and 1 if SHA512 or SHA384
    .en 			(1),   // 1 if the hashing engine has been enabled by the scheduler

    // Master Stream Port
    .m_axis_tdata	(t_tdata),
    .m_axis_tvalid	(t_tvalid),
    .m_axis_tready	(t_tready),
    .m_axis_tlast	(t_tlast),

    // Slave Stream Port
    .s_axis_tdata	(r_tdata),
    .s_axis_tkeep	(r_tkeep),
    .s_axis_tvalid	(r_tvalid),
    .s_axis_tready	(r_tready),
    .s_axis_tlast	(r_tlast)
	);


endmodule
