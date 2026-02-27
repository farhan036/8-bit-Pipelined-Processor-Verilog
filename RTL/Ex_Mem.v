module EX_MEM_reg (
    input wire clk, rst,
    input wire [7:0] pc_plus1,
    input wire [7:0] Rd1,
    input wire [7:0] Rd2,
    input wire       IO_Write,
    input wire [1:0] RegDistidx,
    input wire [7:0] ALU_res,
    input wire [7:0] FW_value,
    input wire       MemWrite,
    input wire [1:0] MemToReg,
    input wire       RegWrite,
    input wire [7:0] IP,
    input wire       isCall,
    input wire       int_signal,
    input wire       isNotRet,

    output reg [7:0] pc_plus1_out,
    output reg [7:0] Rd1_out,
    output reg [7:0] Rd2_out,
    output reg IO_Write_out,
    output reg [1:0] RegDistidx_out,
    output reg [7:0] ALU_res_out,
    output reg [7:0] FW_value_out,
    output reg       MemWrite_out,
    output reg [1:0] MemToReg_out,
    output reg       RegWrite_out,
    output reg [7:0] IP_out,
    output reg       int_signal_out,
    output reg       isCall_out,
    output reg       isNotRet_out
);

    // Sequential logic: update on clock
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            pc_plus1_out <= 0;
            Rd1_out <= 0;
            Rd2_out <= 0;
            IO_Write_out <= 0;
            RegDistidx_out <= 0;
            ALU_res_out <= 0;
            FW_value_out <= 0;
            MemWrite_out <= 0;
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            IP_out <= 0;
            isCall_out <= 0;
            int_signal_out<=0;
            isNotRet_out <= 0;
        end
        else begin
            pc_plus1_out <= pc_plus1;
            Rd1_out <= Rd1;
            Rd2_out <= Rd2;
            IO_Write_out <= IO_Write;
            RegDistidx_out <= RegDistidx;
            ALU_res_out <= ALU_res;
            FW_value_out <= FW_value;
            MemWrite_out <= MemWrite;
            MemToReg_out <= MemToReg;
            RegWrite_out <= RegWrite;
            IP_out <= IP;
            isCall_out <= isCall;
            int_signal_out<=int_signal;
            isNotRet_out <= isNotRet;
        end
    end

endmodule
