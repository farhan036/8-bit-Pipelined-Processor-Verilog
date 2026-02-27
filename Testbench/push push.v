`timescale 1ns / 1ps

module tb_push_push;

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
    // Spy signals
    // =============================================
    wire [7:0] PC = uut.PC.pc_current;
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [7:0] R3 = uut.regfile_inst.regs[3];

    // =============================================
    // Clock (10ns)
    // =============================================
    always #5 clk = ~clk;

    // =============================================
    // MAIN
    // =============================================
    integer i;
    initial begin
        clk = 0;
         // -----------------------------------------
        // Reset vector → PC = 0x10
        // -----------------------------------------
        uut.mem_inst.mem[8'h00] = 8'h10;
        rstn = 0;
        I_Port = 0;
        int_sig = 0;

        // -----------------------------------------
        // Clear stack/data only
        // -----------------------------------------
        for (i = 8'd128; i < 256; i = i + 1)
            uut.mem_inst.mem[i] = 8'h00;

       

        // -----------------------------------------
        // PROGRAM @ 0x10
        // -----------------------------------------
        uut.mem_inst.mem[8'h10] = 8'h70; // PUSH R0
        uut.mem_inst.mem[8'h11] = 8'h71; // PUSH R1
        uut.mem_inst.mem[8'h12] = 8'h76; // POP  R2 0110
        uut.mem_inst.mem[8'h13] = 8'h77; // POP  R3 0111
        uut.mem_inst.mem[8'h14] = 8'h00; // NOP

        

        // -----------------------------------------
        // Reset
        // -----------------------------------------
        #10;
        rstn = 1;
        // -----------------------------------------
        // Initial registers
        // -----------------------------------------
        uut.regfile_inst.regs[0] = 8'd10;
        uut.regfile_inst.regs[1] = 8'd20;
        uut.regfile_inst.regs[2] = 8'd0;
        uut.regfile_inst.regs[3] = 8'd0;

        // -----------------------------------------
        // Run
        // -----------------------------------------
        #400;

        // -----------------------------------------
        // CHECKS
        // -----------------------------------------
        if (R2 !== 8'd20) begin
            $display("[FAIL] POP order incorrect (R2 != 20)");
            $stop;
        end

        if (R3 !== 8'd10) begin
            $display("[FAIL] POP order incorrect (R3 != 10)");
            $stop;
        end

        $display("\n====================================");
        $display(" PUSH PUSH POP POP TEST PASSED");
        $display("====================================");
        $display("R0=%0d R1=%0d R2=%0d R3=%0d PC=%h",
                 R0, R1, R2, R3, PC);

        $stop;
    end

    // =============================================
    // Monitor (optional)
    // =============================================
    always @(posedge clk) begin
        if (rstn)
            $display("PC:%02h | R0:%0d R1:%0d R2:%0d R3:%0d",
                      PC, R0, R1, R2, R3);
    end

endmodule