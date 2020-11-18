`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Oxford
// Engineer: Cristian Bourceanu
//
// Create Date: 17.11.2020 10:54:31
// Design Name: Padder
// Module Name: padder
// Project Name: Hashing Engine
// Target Devices: Alveo U280
// Tool Versions: v1_0
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module padder
#(
    // AXI Stream Data Width
    parameter P_M_AXIS_DATA_WIDTH=512,
    parameter P_S_AXIS_DATA_WIDTH=512,
    parameter DATA_BLOCK_REG_WIDTH=512
)
(
    // Global Ports
    input axi_aclk,
    input axi_resetn,

    // Control
    input sha_type,  // 0 if SHA256 and 1 if SHA512 or SHA384
    input en,   // 1 if the hashing engine has been enabled by the scheduler

    // Master Stream Port
    output [(P_M_AXIS_DATA_WIDTH-1):0] m_axis_tdata,
    output m_axis_tvalid,
    input m_axis_tready,
    output reg m_axis_tlast,

    // Slave Stream Port
    input [(P_S_AXIS_DATA_WIDTH-1):0] s_axis_tdata,
    input [((P_M_AXIS_DATA_WIDTH)/8-1):0] s_axis_tkeep,
    input s_axis_tvalid,
    output reg s_axis_tready,
    input s_axis_tlast
);
    function integer log2;
        input integer number;
        begin
            log2=0;
             while(2**log2<number) begin
                log2=log2+1;
             end
        end
    endfunction // log2

    // ---------- Internal Parameters ------------------
    localparam P_S_AXIS_TKEEP_WIDTH=P_M_AXIS_DATA_WIDTH/8;
    localparam NUM_BYTES_WIDTH = log2(P_S_AXIS_TKEEP_WIDTH);
    localparam LEN_FIELD_BYTES = 8;
    localparam LEN_FIELD_WIDTH = 8 * LEN_FIELD_BYTES;

    // --------- Registers and wires --------------
    // If 32 bytes blocks are needed (SHA256), then use only the R_reg,
    // otherwise use both of them
    reg [DATA_BLOCK_REG_WIDTH-1:0] R_reg;
    reg [DATA_BLOCK_REG_WIDTH-1:0] L_reg;
    reg [DATA_BLOCK_REG_WIDTH-1:0] pad;
    reg [1:0] reg_status;
    reg [NUM_BYTES_WIDTH-1:0] shift_inc;
    reg [NUM_BYTES_WIDTH-1:0] shift_measure;
    reg [NUM_BYTES_WIDTH-1:0] last_valid_byte;
    reg [NUM_BYTES_WIDTH-1:0] next_byte;
    reg [31:0] length_low;
    reg [31:0] length_high;
    reg reg_count;
    wire reset;

    // ----------- Logic -----------
    // Transmitting padded message block
    assign m_axis_tvalid = sha_type ? reg_status[1] : reg_status[0];
    assign m_axis_tdata = sha_type ? L_reg : R_reg;
    assign reset = ~ resetn;

    // FSM dependent wires
    // free_reg, empty_reg and complete and indicators for what will be the state at the next clock cycle
    assign free_reg = m_axis_tvalid & m_axis_tready | ~reg_status[0] | (sha_type & ~reg_status[1]);
    assign empty_reg = m_axis_tvalid & m_axis_tready & (sha_type ? reg_status == 2'b10 : reg_status[0]);
    assign last_received = s_axis_tlast & s_axis_tready & s_axis_tvalid;
    assign complete = free_reg & (reg_count | ~sha_type) & (next_byte < 56 - 8*sha_type);



    // ---------- FSM --------------
    //FSM registers
    reg [2:0] receive_state, receive_state_next;
    reg s_axis_tready_next;
    localparam IDLE = 0;
    localparam FEED = 1;
    localparam PAD = 2;
    localparam EXTRA_PAD = 3;
    localparam WAIT = 4;
    localparam RESET = 5;

    initial begin
        s_axis_tready = 0;
        reg_status = 2'b00;
        length_low = 0;
        length_high = 0;
        reg_count = 0;
        next_byte = 0;
    end

    // RX FSM transitions
    always @(*) begin
        receive_state_next = receive_state;
        case(receive_state)
            IDLE: begin
                s_axis_tready_next = 0;
                if(free_reg) begin
                    receive_state_next = FEED;
                    s_axis_tready_next = 1;
                end
            end
            FEED: begin
                if(last_received) begin
                    s_axis_tready_next = 0;
                    receive_state_next = PAD;
                end
                if(~free_reg) begin
                    s_axis_tready_next = 0;
                    receive_state_next = IDLE;
                end
            end
            PAD: begin
                s_axis_tready_next = 0;
                if(free_reg) begin
                    if(complete) begin // 9 bytes (8bytes len and 1 byte = x80) for SHA256 or 17 bytes for SHA384/512
                        receive_state_next = WAIT;
                    end else begin
                        receive_state_next = EXTRA_PAD;
                    end
                end
            end
            EXTRA_PAD: begin
                s_axis_tready_next = 0;
                if(complete) begin
                    receive_state_next = WAIT;
                end
            end
            WAIT: begin
                s_axis_tready_next = 0;
                if(empty_reg) begin
                    receive_state_next = RESET;
                end
            end
            RESET: begin
                s_axis_tready_next = 0;
                receive_state_next = IDLE;
            end
        endcase
    end

    //----------Seq Logic----------------------
    always @(posedge axi_aclk)
    begin: FSM_SEQ
        if(reset) begin
            receive_state <=IDLE;

        end
        else begin
            receive_state <= receive_state_next;
            s_axis_tready <= s_axis_tready_next;
        end
    end

    /*
    ******** Feed Data In Logic *******
    */

    // Propagate data from R_reg to L_reg if needed
    always @(posedge axi_aclk) begin
        if(sha_type & ~reg_status[1]) begin
            L_reg <= R_reg;
            reg_status[1] <= reg_status[0];
        end
    end

    task count_message;
        input [31:0] length_inc;
        begin
            length_low = length_low + length_inc;
            if(length_low == 0)begin
                length_high = length_high + 1;
            end
        end
    endtask : count_message
    // Feed R_reg
    always @(posedge axi_aclk) begin
        if(reset) begin
            R_reg <= #1 0;
            L_reg <= #1 0;
        end
        else begin
            case(receive_state)
                IDLE: #1;

                FEED: begin
                    if(s_axis_tvalid) begin

                        if(s_axis_tlast)begin
                            // Find the last valid byte in tdata with binary search
                            last_valid_byte = 0;
                            shift_inc = P_S_AXIS_TKEEP_WIDTH >> 1;
                            shift_measure = P_S_AXIS_TKEEP_WIDTH >> 1;
                            while(shift_inc) begin
                                shift_inc = shift_inc >> 1;
                                if(s_axis_tlast >> shift_measure)begin
                                    last_valid_byte = shift_measure;
                                    shift_measure = shift_measure + shift_inc;
                                end else begin
                                    shift_measure = shift_measure - shift_inc;
                                end
                            end
                            // Write tdata to R_reg
                            R_reg <= s_axis_tdata;
                            next_byte = last_valid_byte + 1;
                            count_message(next_byte);
                            if(next_byte == 0) begin    // If there weren't any null bytes in the last frame
                                reg_status[0] <= 1;
                            end else begin
                                reg_status[0] <= 0;
                            end
                        end
                        else begin  // Write tdata to R_reg and raise the flag for a new register
                            R_reg <= s_axis_tdata;
                            reg_status[0] <= 1;
                            count_message(8);
                        end
                    end
                    else begin  // No message block has been received
                        reg_status[0] <= 0;
                    end
                end

                PAD: begin
                    if(free_reg)begin   // If R_reg is not completed or if it will be propagated at the next clock edge, then we can carry on with padding
                        pad = 8'h80 << (8 * next_byte);
                        count_message(8);
                        next_byte = next_byte + 1;
                        if(next_byte > 56 - 8 * sha_type) begin // If the length doesn't fit in the padding, just pad with 0s the rest and go to next block
                            count_message(DATA_BLOCK_REG_WIDTH - 8 * next_byte);
                        end else begin // If the length fits, then pad with 0s all, but the length bytes
                            count_message(DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH * (1 + sha_type) - 8 * next_byte);
                            // Length is written in big-endian format
                            if(sha_type) begin
                                pad = pad | {{16'h00},length_high,length_low} << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH * 2);
                            end else begin
                                pad = pad | {length_high,length_low} << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH);
                            end
                            
                        end
                        R_reg = R_reg & (1<<(next_byte+1) - 1) | pad;
                        reg_status[0] <= 1;
                        next_byte = 0;
                    end
                end
                EXTRA_PAD: begin
                    if(free_reg) begin
                        if(~reg_count & sha_type) begin // In the case of SHA384/512 verify that an even number of 512b blocks has been created
                            R_reg[DATA_BLOCK_REG_WIDTH-1:0] <= 0;
                            count_message(DATA_BLOCK_REG_WIDTH);
                            reg_status[0] <= 1;
                        end else begin // Then pad with 0's and append the length value
                            count_message(DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH * (1 + sha_type));
                            // Length is written in big-endian format
                            // I assumed the length will never surprass 2^64-1, which is a reasonable assumption
                            if(sha_type) begin
                                R_reg <= {{16'h00},length_high,length_low} << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH * 2);
                            end else begin
                                R_reg <= {length_high,length_low} << (DATA_BLOCK_REG_WIDTH - LEN_FIELD_WIDTH);
                            end
                            reg_status[0] <= 1;
                        end
                    end
                end
                WAIT: begin
                    if(free_reg)begin
                        reg_status[0] <= 0;
                    end
                end
                RESET: begin
                    reg_status = 2'b00;
                    length_low = 0;
                    length_high = 0;
                    reg_count = 0;
                end
            endcase // receive_state
        end
    end

endmodule

