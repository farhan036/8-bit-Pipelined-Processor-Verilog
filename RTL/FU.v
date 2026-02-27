module FU (
    // ==========================================================
    // Inputs from Pipeline Registers (Control Signals)
    // ==========================================================
    input wire RegWrite_Ex_MEM,    // Write Enable of instruction in MEM
    input wire RegWrite_Mem_WB,    // Write Enable of instruction in WB

    // ==========================================================
    // Inputs from Pipeline Registers (Register Addresses)
    // ==========================================================
    // EX Stage Inputs (For ALU Forwarding)
    input wire [1:0] Rs_EX,          // Source Register 1 address from ID/EX
    input wire [1:0] Rt_EX,          // Source Register 2 address from ID/EX
    
    // NEW: ID Stage Inputs (For Decode Forwarding)
    input wire [1:0] Rs_ID,          // Source Register 1 address currently in IF/ID
    input wire [1:0] Rt_ID,          // Source Register 2 address currently in IF/ID

    // Hazard Sources
    input wire [1:0] Rd_MEM,         // Destination Register address from EX/MEM
    input wire [1:0] Rd_WB,          // Destination Register address from MEM/WB
    
    // ==========================================================
    // Outputs
    // ==========================================================
    // To EX Stage ALU MUXes (ForwardA/B are 2-bit select lines)
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB,

    // NEW: To ID Stage MUXes (1-bit select is usually enough here)
    // 0 = Read from Register File
    // 1 = Forward from Write Back data
    output reg Forward_ID_A,
    output reg Forward_ID_B
);

    always @(*) begin
        
        // ==========================================================
        // 1. ORIGINAL EX STAGE FORWARDING (ALU HAZARDS)
        // ==========================================================
        
        // Default: No forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // ALU Input A (Rs_EX)
        if (RegWrite_Ex_MEM && (Rd_MEM == Rs_EX)) begin
            ForwardA = 2'b10; // Forward from EX/MEM
        end
        else if (RegWrite_Mem_WB && (Rd_WB == Rs_EX)) begin
            ForwardA = 2'b01; // Forward from MEM/WB
        end

        // ALU Input B (Rt_EX)
        if (RegWrite_Ex_MEM && (Rd_MEM == Rt_EX)) begin
            ForwardB = 2'b10; // Forward from EX/MEM
        end
        else if (RegWrite_Mem_WB && (Rd_WB == Rt_EX)) begin
            ForwardB = 2'b01; // Forward from MEM/WB
        end


        // ==========================================================
        // 2. NEW ID STAGE FORWARDING (WB HAZARD CORRECTION)
        // ==========================================================
        
        // Default: Read from Register File
        Forward_ID_A = 1'b0;
        Forward_ID_B = 1'b0;

        // Check Source A in Decode Stage
        // If the instruction in WB is writing to the register we are trying to decode
        if (RegWrite_Mem_WB && (Rd_WB == Rs_ID)) begin
            Forward_ID_A = 1'b1; // Trigger ID-stage MUX to take WB data
        end

        // Check Source B in Decode Stage
        if (RegWrite_Mem_WB && (Rd_WB == Rt_ID)) begin
            Forward_ID_B = 1'b1; // Trigger ID-stage MUX to take WB data
        end

    end

endmodule