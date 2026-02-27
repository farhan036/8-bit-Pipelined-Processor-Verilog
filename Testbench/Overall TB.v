`timescale 1ns / 1ps

module Over_all_tb;

    // =========================================================
    // Signals
    // =========================================================
    reg clk;
    reg rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // =========================================================
    // UUT
    // =========================================================
    CPU_WrapperV3 uut (
        .clk(clk),
        .rstn(rstn),
        .I_Port(I_Port),
        .int_sig(int_sig),
        .O_Port(O_Port)
    );

    // =========================================================
    // Spy Signals
    // =========================================================
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] R3 = uut.regfile_inst.regs[3];
    wire [3:0] CCR = uut.ccr_inst.CCR;   // [0]=Z [1]=N [2]=C [3]=V

    // =========================================================
    // Clock (10 ns period)
    // =========================================================
    always #5 clk = ~clk;

    // =========================================================
    // Utility Tasks
    // =========================================================
    task run_cycles(input integer n);
        integer i;
    begin
        for (i = 0; i < n; i = i + 1)
            @(posedge clk);
    end
    endtask

    task fail(input [200*8:1] msg);
    begin
        $display("\n[FAIL] %s", msg);
        $stop;
    end
    endtask

    // =========================================================
    // MAIN TEST
    // =========================================================
    integer i;
    initial begin
        
        clk = 0;
        I_Port = 0;
        int_sig = 0;
        uut.mem_inst.mem[0]  = 8'h0A;   // PC = 10
        uut.mem_inst.mem[85]  = 8'h00;   // PC = 10
        // =====================================================
        // RESET (ONCE ONLY)
        // =====================================================
        rstn = 0;
        #20;
        rstn = 1;

        // =====================================================
        // CLEAR DATA + STACK ONLY (128–255)
        // =====================================================
        for (i = 8'd128; i < 256; i = i + 1)
            uut.mem_inst.mem[i] = 8'h00;

        // =====================================================
        // LOAD PROGRAM (INSTRUCTION MEMORY 0–127)
        // =====================================================

        // Reset Vector
        

        // ---------- GROUP 1: ALU + FORWARDING ---------- 5 3 32 2
        uut.mem_inst.mem[10] = 8'h21;   // ADD R0,R1 8
        uut.mem_inst.mem[11] = 8'h28;   // ADD R2,R0 40
        uut.mem_inst.mem[12] = 8'h2E;   // ADD R3,R2 42
        uut.mem_inst.mem[13] = 8'h27;   // ADD R1,R3 45
        uut.mem_inst.mem[14] = 8'h21;   // ADD R0,R1 45

        // ---------- GROUP 2: FLAGS ----------
        uut.mem_inst.mem[15] = 8'h30;   // SUB R0,R0 → Z=1
        uut.mem_inst.mem[16] = 8'h31;   // SUB R0,R1 → N=1

        /////////////////// Done ///////////////////

        // ---------- GROUP 3: LDM ----------
        uut.mem_inst.mem[17] = 8'hC2;   // LDM R2
        uut.mem_inst.mem[18] = 8'h55;

        // ---------- GROUP 4: LDD + LOAD-USE ----------
        uut.mem_inst.mem[19] = 8'hC5;   // LDD R1
        uut.mem_inst.mem[20] = 8'h80;
        uut.mem_inst.mem[21] = 8'h21;   // ADD R0,R1
        /////////////////// Done ///////////////////
        // ---------- GROUP 5: STD ----------
        uut.mem_inst.mem[22] = 8'hCA;   // STD
        uut.mem_inst.mem[23] = 8'h90;
        /////////////////// Done ///////////////////
        // ---------- GROUP 6: LDI + LOAD-USE ----------
        uut.mem_inst.mem[24] = 8'hD9;   // LDI R1,[R2] // R1 = 0
        uut.mem_inst.mem[25] = 8'h27;   // ADD R1,R3  //  R1 = 42
        /////////////////// Done ///////////////////

        // ---------- GROUP 7: STI ----------
        uut.mem_inst.mem[26] = 8'hE6;   // STI [R1],R2
        /////////////////// Done ///////////////////

        // ---------- NOPs ----------
        uut.mem_inst.mem[27] = 8'h00;
        uut.mem_inst.mem[28] = 8'h00;
        // ---------- GROUP 8: LOOP ----------
        // We will loop 2 times on the instruction at 0x21 (decimal 33)
        // 0x21 is the address of the LOOP instruction itself (Delay Loop)
        uut.mem_inst.mem[29] = 8'hC1;   // LDM R1 (Counter)
        uut.mem_inst.mem[30] = 8'h02;
        uut.mem_inst.mem[31] = 8'hC2;   // LDM R2 (Target Address)
        uut.mem_inst.mem[32] = 8'd33;   // 0x21 = Decimal 33 (The address of the LOOP op)
        uut.mem_inst.mem[33] = 8'hA6;   // LOOP R1,R2 (Dec R1, if !=0 Jump to 0x21)
        /////////////////// Done ///////////////////

        // ---------- GROUP 9: CALL / RET ----------
        // Target 0x46 (Decimal 70) for Subroutine
        uut.mem_inst.mem[34] = 8'hC2;   // LDM R2 (Subroutine Address)
        uut.mem_inst.mem[35] = 8'h46;   // 0x46 = Decimal 70
        uut.mem_inst.mem[36] = 8'h00;   // NOP
        uut.mem_inst.mem[37] = 8'hB6;   // CALL R2 (Pushes Return Addr, Jumps to 70)
        /////////////////// Done ///////////////////

        // ---------- GROUP 10: JZ (Jump Zero) ----------
        // We return here from Subroutine. 
        // We need to set Zero flag first.
        uut.mem_inst.mem[38] = 8'h30;   // SUB R0,R0 (Set Z=1)
        uut.mem_inst.mem[39] = 8'hC2;   // LDM R2 (Jump Target)
        uut.mem_inst.mem[40] = 8'h50;   // 0x50 = Decimal 80
        uut.mem_inst.mem[41] = 8'h92;   // JZ R2 (If Z=1, Jump to 80)
        /////////////////// Done ///////////////////

        // =====================================================
        // SUBROUTINE @ 0x46 (Decimal 70)
        // =====================================================
        uut.mem_inst.mem[70] = 8'hC0;   // LDM R0 (Marker)
        uut.mem_inst.mem[71] = 8'hAA;   // R0 = 0xAA indicates inside Sub
        uut.mem_inst.mem[72] = 8'hB8;   // RET (Pop PC, return to 37)
        /////////////////// Done ///////////////////
        // =====================================================
        // END POINT @ 0x50 (Decimal 80)
        // =====================================================
        uut.mem_inst.mem[80] = 8'hC0;   // LDM R0 (Success Marker)
        uut.mem_inst.mem[81] = 8'hFF;   // R0 = 0xFF indicates Finish
        /////////////////// Done ///////////////////
        // =====================================================
        // INITIAL REGISTER VALUES
        // =====================================================
        uut.regfile_inst.regs[0] = 5;
        uut.regfile_inst.regs[1] = 3;
        uut.regfile_inst.regs[2] = 8'h20;
        uut.regfile_inst.regs[3] = 2;

        // =====================================================
        // RUN FULL PROGRAM
        // =====================================================
        run_cycles(150);

        // =====================================================
        // FINAL SELF-CHECKING
        // =====================================================
        // Expected final values after FULL dependency chain:
        // R0 = 10
        // R1 = 8
        // R2 = 85
        // R3 = 11
        // M[0x90] = 10

        if (R0 !== 8'hff) fail("R0 incorrect");
        if (R1 !== 8'h00)  fail("R1 incorrect");
        if (R2 !== 8'h50)  fail("R2 incorrect");
        if (R3 !== 8'h2a)  fail("R3 incorrect");

        if (uut.mem_inst.mem[8'd42] !== 8'd38) //PC+1 from Call
            fail("STI result incorrect");
        
        if (CCR[0] !== 1'b1) fail("Z flag incorrect");
        if (CCR[1] !== 1'b0) fail("N flag incorrect");
        
        

        $display("\n========================================");
        $display(" ALL TESTS PASSED (ONE RESET, FULL DEPENDENCY)");
        $display("========================================\n");

        $stop;
    end

endmodule