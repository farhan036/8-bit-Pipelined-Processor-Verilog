`timescale 1ns / 1ps

module tb_ldd_ldd_add;


    // =============================================
    // Signals
    // =============================================
    reg clk, rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // =============================================
    // UUT
    // =============================================
    CPU_WrapperV3 uut (
        .clk(clk),
        .rstn(rstn),
        .I_Port(I_Port),
        .int_sig(int_sig),
        .O_Port(O_Port)
    );

    // =============================================
    // Spy Signals
    // =============================================
    wire [7:0] PC = uut.PC.pc_current;
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] R3 = uut.regfile_inst.regs[3]; // Stack Pointer

    // =============================================
    // Clock (10ns)
    // =============================================
    always #5 clk = ~clk;

    // =============================================
    // MAIN
    // =============================================
    integer i;
    initial 
    begin
        clk = 0;
        // -----------------------------------------
        // Clear memory
        // -----------------------------------------
        for (i = 1; i < 256; i = i + 1)
            uut.mem_inst.mem[i] = 8'h00;

        // -----------------------------------------
        // Reset vector -> PC = 0x10 (16)
        // -----------------------------------------
        uut.mem_inst.mem[8'h00] = 8'h10;
        rstn = 0;
        I_Port = 0;
        int_sig = 0;

        

      
        // -----------------------------------------
        // DATA SETUP (Arbitrary addresses 0x30, 0x31)
        // -----------------------------------------
        uut.mem_inst.mem[8'h30] = 8'd10; // Data for R1
        uut.mem_inst.mem[8'h31] = 8'd20; // Data for R2

        // -----------------------------------------
        // PROGRAM @ 0x10
        // -----------------------------------------
        
        // 1. LDD R1, [0x30]  (Load 10 into R1)
        // Opcode: C (12), ra:01 (LDD), rb:01 (R1) -> C5
        uut.mem_inst.mem[16] = 8'hC5; 
        uut.mem_inst.mem[17] = 8'h30; // Address 0x30

        // 2. LDD R2, [0x31]  (Load 20 into R2)
        // Opcode: C (12), ra:01 (LDD), rb:10 (R2) -> C6
        uut.mem_inst.mem[18] = 8'hC6; 
        uut.mem_inst.mem[19] = 8'h31; // Address 0x31

        // 3. ADD R1, R3      (R1 = R1 + R3)
        // Opcode: 2, ra:01 (Dest R1), rb:11 (Src R3) -> 27
        uut.mem_inst.mem[20] = 8'h27; 

        // -----------------------------------------
        // Initial Registers
        // -----------------------------------------
        #10;
        rstn = 1;

        // Force R3 (Stack Pointer) to a known value to verify addition
        // In real HW, this defaults to 255, but we set to 5 for easy math.
        uut.regfile_inst.regs[0] = 8'd0;
        uut.regfile_inst.regs[1] = 8'd0;  
        uut.regfile_inst.regs[2] = 8'd0;  
        uut.regfile_inst.regs[3] = 8'd5;  // R3 = 5

        // -----------------------------------------
        // Run Simulation
        // -----------------------------------------
        #300; 

        // -----------------------------------------
        // CHECKS
        // -----------------------------------------
        
        // Check 1: R2 should have loaded 20 from Memory[0x31]
        if (R2 !== 8'd20) begin
            $display("[FAIL] R2 LDD failed (Expected 20, Got %0d)", R2);
            $stop;
        end

        // Check 2: R1 should be (Value loaded 10) + (R3 Value 5) = 15
        if (R1 !== 8'd15) begin
            $display("[FAIL] R1 ADD failed (Expected 15, Got %0d)", R1);
            $stop;
        end

        // Check 3: R3 should remain 5
        if (R3 !== 8'd5) begin
            $display("[FAIL] R3 changed unexpectedly (Expected 5, Got %0d)", R3);
            $stop;
        end

        $display("\n====================================");
        $display(" LDD & ADD SEQUENCE PASSED");
        $display("====================================");
        $display("Final State:");
        $display("R1 (Result) = %0d (Expected 15)", R1);
        $display("R2 (Loaded) = %0d (Expected 20)", R2);
        $display("R3 (Source) = %0d (Expected 5)", R3);

        $stop;
    end

    // =============================================
    // Monitor
    // =============================================
    always @(posedge clk) begin
        if (rstn)
            $display("Time:%0t | PC:%02h | R1:%0d R2:%0d R3:%0d", 
                     $time, PC, R1, R2, R3);
    end

endmodule