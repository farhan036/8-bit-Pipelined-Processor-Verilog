`timescale 1ns / 1ps

module tb_call_call;

    // =================================================
    // Signals
    // =================================================
    reg clk, rstn;
    reg [7:0] I_Port;
    reg int_sig;
    wire [7:0] O_Port;

    // =================================================
    // UUT
    // =================================================
    CPU_WrapperV3 uut (
        .clk(clk),
        .rstn(rstn),
        .I_Port(I_Port),
        .int_sig(int_sig),
        .O_Port(O_Port)
    );

    // =================================================
    // Spy signals
    // =================================================
    wire [7:0] PC = uut.PC.pc_current;
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] R3 = uut.regfile_inst.regs[3];

    // =================================================
    // Clock (10ns)
    // =================================================
    always #5 clk = ~clk;

    // =================================================
    // MAIN
    // =================================================
    integer i;
    initial begin
        clk = 0;
        // -------------------------------------------------
        // Clear stack/data only
        // -------------------------------------------------
        for (i = 8'd0; i < 256; i = i + 1)
            uut.mem_inst.mem[i] = 8'h00;
        // -------------------------------------------------
        // Reset vector → PC = 0x10
        // -------------------------------------------------
        uut.mem_inst.mem[8'h00] = 8'h10;
        rstn = 0;
        I_Port = 0;
        int_sig = 0;

        // -------------------------------------------------
        // Clear stack/data only
        // -------------------------------------------------
        for (i = 8'd128; i < 256; i = i + 1)
            uut.mem_inst.mem[i] = 8'h00;

        

        // -------------------------------------------------
        // MAIN PROGRAM @ 0x10
        // -------------------------------------------------
        uut.mem_inst.mem[8'h10] = 8'hC0; // LDM R0     20 at R0
        uut.mem_inst.mem[8'h11] = 8'h20; // addr sub1
        uut.mem_inst.mem[8'h12] = 8'hB4; // CALL R0

        uut.mem_inst.mem[8'h13] = 8'h21; // ADD R0,R1 (after both CALLs) R0 SAME 20
       

        // -------------------------------------------------
        // SUBROUTINE 1 @ 0x20
        // -------------------------------------------------
        uut.mem_inst.mem[8'h20] = 8'hC1; // LDM R1 1 AT R1
        uut.mem_inst.mem[8'h21] = 8'h01; // R1 = 1

        uut.mem_inst.mem[8'h22] = 8'hC0; // LDM R0 30 AT R0
        uut.mem_inst.mem[8'h23] = 8'h30; // addr sub2
        uut.mem_inst.mem[8'h24] = 8'h00; // Nop
        uut.mem_inst.mem[8'h25] = 8'hB4; // CALL R0
        uut.mem_inst.mem[8'h26] = 8'h00; // 

        uut.mem_inst.mem[8'h27] = 8'hB8; // RET

        // -------------------------------------------------
        // SUBROUTINE 2 @ 0x30
        // -------------------------------------------------
        uut.mem_inst.mem[8'h30] = 8'hC2; // LDM R2
        uut.mem_inst.mem[8'h31] = 8'h02; // R2 = 2
        uut.mem_inst.mem[8'h32] = 8'hB8; // RET

        // -------------------------------------------------
        // Initial registers
        // -------------------------------------------------
        uut.regfile_inst.regs[0] = 0;
        uut.regfile_inst.regs[1] = 0;
        uut.regfile_inst.regs[2] = 0;

        // -------------------------------------------------
        // Reset
        // -------------------------------------------------
        #10;
        rstn = 1;

        // -------------------------------------------------
        // Run
        // -------------------------------------------------
        #290;

        // -------------------------------------------------
        // CHECKS
        // -------------------------------------------------
        if (R1 !== 8'd1) begin
            $display("[FAIL] Subroutine 1 not executed");
            $stop;
        end

        if (R2 !== 8'd2) begin
            $display("[FAIL] Subroutine 2 not executed");
            $stop;
        end

        if (R0 !== 8'd49) begin
            $display("[FAIL] Return order incorrect (R0 != 3)");
            $stop;
        end

        $display("\n====================================");
        $display(" TWO CALLS TEST PASSED");
        $display("====================================");
        $display("R0=%0h R1=%0h R2=%0h R3=%h", R0, R1, R2, R3);

        $stop;
    end

    // =================================================
    // Monitor (optional)
    // =================================================
    always @(posedge clk) begin
        if (rstn)
            $display("PC:%02h | R0:%0d | R1:%0d | R2:%0d",
                      PC, R0, R1, R2);
    end

endmodule 
