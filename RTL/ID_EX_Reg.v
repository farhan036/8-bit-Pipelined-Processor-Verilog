module id_ex_reg(
    input wire clk, rst,
    input wire flush,
    input wire inject_bubble,
    input wire [7:0] pc_plus1,
    input wire [7:0] IP,
    input wire [7:0] imm,

    // ---------- Control inputs from ID stage ----------
    input wire      [2:0] BType,
    input wire      [1:0] MemToReg,
    input wire            RegWrite,
    input wire            MemWrite,
    input wire            MemRead,
    input wire            UpdateFlags,
    input wire      [1:0] RegDistidx,
    input wire      [1:0] ALU_src,
    input wire      [3:0] ALU_op,
    input wire            IO_Write,
    input wire            isCall,    
    input wire            loop_sel,
    input wire            Ret_sel,
    input wire            Rti_sel,
    input wire            int_signal, //interrupt signal
    input wire            isNotRet, 

    // ---------- Data inputs from ID stage ----------
    input wire  [7:0] ra_val_in,    // value of R[ra]
    input wire  [7:0] rb_val_in,    // value of R[rb]
    input wire  [1:0] ra,           // address of ra
    input wire  [1:0] rb,            // address of rb

    // ---------- Control outputs to EX stage ----------
    output reg      [2:0] BType_out,
    output reg      [1:0] MemToReg_out,
    output reg             RegWrite_out,
    output reg             MemWrite_out,
    output reg             MemRead_out,
    output reg             UpdateFlags_out,
    output reg       [1:0] RegDistidx_out,
    output reg       [1:0] ALU_src_out,
    output reg       [3:0] ALU_op_out,
    output reg             IO_Write_out,
    output reg             isCall_out,  
    output reg             loop_sel_out,
    output reg             Ret_sel_out,
    output reg             Rti_sel_out,
    output reg             int_signal_out,
    output reg             isNotRet_out,

    // ---------- Data outputs to EX stage ----------
    output reg  [7:0] ra_val_out,
    output reg  [7:0] rb_val_out,
    output reg  [1:0] ra_out,
    output reg  [1:0] rb_out,

    //  -------- PC_plus1 out, IP_out, immediate -----------
    output reg [7:0] pc_plus1_out,
    output reg [7:0] IP_out,
    output reg [7:0] imm_out
);

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            BType_out <= 0;
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            MemRead_out <= 0;
            UpdateFlags_out <= 0;
            RegDistidx_out <= 0;
            ALU_src_out <= 0;
            ALU_op_out <= 0;
            IO_Write_out <= 0;
            ra_val_out <= 0;
            rb_val_out <= 0;
            ra_out <= 0;
            rb_out <= 0;
            IP_out <= 0;
            imm_out <= 0;
            pc_plus1_out <= 0;
            isCall_out <= 0;
            loop_sel_out <= 0;
            Ret_sel_out <= 0;
            int_signal_out<=0;
            Rti_sel_out <= 0;
            isNotRet_out    <= 0;
        end
        else if (flush) begin
            BType_out <= 0;
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            MemRead_out <= 0;
            UpdateFlags_out <= 0;
            RegDistidx_out <= 0;
            ALU_src_out <= 0;
            ALU_op_out <= 0;
            IO_Write_out <= 0;
            ra_val_out <= 0;
            rb_val_out <= 0;
            ra_out <= 0;
            rb_out <= 0;
            IP_out <= 0;
            imm_out <= 0;
            pc_plus1_out <= 0;
            isCall_out <= 0;
            loop_sel_out <= 0;
            Ret_sel_out <= 0;
            int_signal_out<=0;
            Rti_sel_out <= 0;
            isNotRet_out <= 0;
        end
        else if(inject_bubble) begin
            BType_out <= 0;
            MemToReg_out <= 0;
            RegWrite_out <= 0;
            MemWrite_out <= 0;
            MemRead_out <= 0;
            UpdateFlags_out <= 0;
            RegDistidx_out <= 0;
            ALU_src_out <= 0;
            ALU_op_out <= 0;
            IO_Write_out <= 0;
            ra_val_out <= 0;
            rb_val_out <= 0;
            ra_out <= 0;
            rb_out <= 0;
            IP_out <= 0;
            imm_out <= 0;
            pc_plus1_out <= 0;
            isCall_out <= 0;
            loop_sel_out <= 0;
            Ret_sel_out <= 0;
            int_signal_out<=0;
            Rti_sel_out <= 0;
            isNotRet_out <= 0;
        end
        else begin
            BType_out <= BType;
            MemToReg_out <= MemToReg;
            RegWrite_out <= RegWrite;
            MemWrite_out <= MemWrite;
            MemRead_out <= MemRead;
            UpdateFlags_out <= UpdateFlags;
            RegDistidx_out <= RegDistidx;
            ALU_src_out <= ALU_src;
            ALU_op_out <= ALU_op;
            IO_Write_out <= IO_Write;
            ra_val_out <= ra_val_in;
            rb_val_out <= rb_val_in;
            ra_out <= ra;
            rb_out <= rb;
            pc_plus1_out <= pc_plus1;    
            IP_out <= IP;   
            imm_out <= imm;     
            isCall_out <= isCall;
            loop_sel_out <= loop_sel;
            Ret_sel_out <= Ret_sel;
            int_signal_out<=int_signal;
            Rti_sel_out <= Rti_sel;
            isNotRet_out    <= isNotRet;
        end
    end

endmodule
