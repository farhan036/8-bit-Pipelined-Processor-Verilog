module MEM_WB_Reg(
    input clk, rst,
    input [7:0] pc_plus1,
    input [1:0] RegDistidx,
    input [7:0] Rd2,
    input [7:0] ALU_res,
    input [7:0] data_B,
    input [1:0] MemToReg,
    input       RegWrite,
    input [7:0] IP,
    input       IO_Write,
    input [7:0] FW_val,

    output reg [7:0] pc_plus1_out,
    output reg [1:0] RegDistidx_out,
    output reg [7:0] Rd2_out,
    output reg [7:0] ALU_res_out,
    output reg [7:0] data_B_out,
    output reg [1:0] MemToReg_out,
    output reg       RegWrite_out,
    output reg [7:0] IP_out,
    output reg       IO_Write_out,
    output reg [7:0] FW_val_out
);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
     pc_plus1_out <= 0;
     RegDistidx_out <= 0;
     Rd2_out <= 0;
     ALU_res_out <= 0;
     data_B_out <= 0;
     MemToReg_out <= 0;
     RegWrite_out <= 0;
     IP_out        <= 0;
     IO_Write_out <= 0;
     FW_val_out <= 0;
    end

    else begin
        pc_plus1_out <= pc_plus1;
        RegDistidx_out <= RegDistidx;
        Rd2_out <= Rd2;
        ALU_res_out <= ALU_res;
        data_B_out <= data_B;
        MemToReg_out <= MemToReg;
        RegWrite_out <= RegWrite;
        IP_out <= IP;
        IO_Write_out <= IO_Write;
        FW_val_out <= FW_val;
    end
end
    
endmodule