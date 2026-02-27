module IF_ID_Reg (
    input wire       clk,
    input wire       rst,
    
    // CONTROL INPUTS
    input wire       IF_ID_EN, // Active Low Enable (0 = IF_ID_EN)
    input wire       Flush,  // Active High Reset (1 = Clear)
    
    // DATA INPUTS
    input wire [7:0] PC_Plus_1_In,
    input wire [7:0] Instruction_In,
    input wire [7:0] immby,
    input wire [7:0] IP,
    
    // DATA OUTPUTS
    output reg [7:0] PC_Plus_1_Out,
    output reg [7:0] Instruction_Out,
    output reg [7:0] immbyout,
    output reg [7:0] IP_out
);

    always @(posedge clk or negedge rst) begin
        if (!rst) 
        begin
            // Asynchronous Reset
            Instruction_Out <= 8'b00000000; // NOP
            PC_Plus_1_Out   <= 8'b00000000;
            immbyout        <='b0;
            IP_out          <= 0;
        end 
        else if (Flush) begin
            // Synchronous Flush (Branch Taken)
            Instruction_Out <= 8'b00000000; // Force NOP
            // PC value doesn't matter during flush, but clearing is safe
            PC_Plus_1_Out   <= 8'b00000000; 
            immbyout        <='b0;
            IP_out          <= 0;
        end 
        else if (IF_ID_EN) 
        begin 
            // Normal Operation (IF_ID_EN=1 means Enable)
            // Note: If logic says IF_ID_EN=0 means Stall, change this condition.
            // Usually: if (Write_En) -> Update.
            
            Instruction_Out <= Instruction_In;
            PC_Plus_1_Out   <= PC_Plus_1_In;
            IP_out <= IP;
        end
        else
        immbyout        <=immby;
        
    end

endmodule