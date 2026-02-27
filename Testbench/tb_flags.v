`timescale 1ns / 1ps

module tb_OutputPort;

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
    // Accessing internal registers for verification
    wire [7:0] R0 = uut.regfile_inst.regs[0];
    wire [7:0] R1 = uut.regfile_inst.regs[1];
    wire [7:0] R2 = uut.regfile_inst.regs[2];
    wire [3:0] CCR = uut.ccr_inst.CCR; // CCR bits: [3]=V, [2]=C, [1]=N, [0]=Z

    // Helper wires for readability
    wire Z_flag = CCR[0];
    wire N_flag = CCR[1];
    wire C_flag = CCR[2];
    wire V_flag = CCR[3];

    // =========================================================
    // Clock
    // =========================================================
    always #5 clk = ~clk;

    // =========================================================
    // Tasks
    // =========================================================
    task reset_cpu;
    begin
    uut.mem_inst.mem[0]  = 8'h0A; // Reset Vector

        rstn = 0;
        I_Port = 0;
        int_sig = 0;
        #20;
        rstn = 1;
    end
    endtask

    task clear_mem;
        integer i;
    begin
        for (i = 0; i < 256; i = i + 1)
            uut.mem_inst.mem[i] = 8'h00;
    end
    endtask

    task run_cycles(input integer n);
        integer k;
    begin
        for (k = 0; k < n; k = k + 1)
            @(posedge clk);
    end
    endtask

    task fail(input [200*8:1] msg);
    begin
        $display("[FAIL] %s", msg);
        $display("       Current Flags: V=%b C=%b N=%b Z=%b", V_flag, C_flag, N_flag, Z_flag);
        $stop;
    end
    endtask

    // =========================================================
    // MAIN TEST
    // =========================================================
    initial begin
        clk = 0;

        // =====================================================
        // TEST 1: ZERO FLAG (Z)
        // Operation: SUB R0, R0 (Result = 0)
        // =====================================================
        reset_cpu(); clear_mem();
        // Program at 0x0A
        uut.mem_inst.mem[10] = 8'h30; // SUB R0, R0 (Op=3, ra=0, rb=0) -> 0011 00 00

        // Initial State
        uut.regfile_inst.regs[0] = 8'd55; // R0 = 55

        run_cycles(20);

        if (Z_flag !== 1'b1) 
            fail("Zero Flag did not set after SUB R0, R0");
        
        if (R0 !== 8'd0)
            fail("Result of SUB R0, R0 was not 0");

        // =====================================================
        // TEST 2: NEGATIVE FLAG (N)
        // Operation: SUB R0, R1 (10 - 20 = -10 / 0xF6)
        // =====================================================
        reset_cpu(); clear_mem();
        uut.mem_inst.mem[0]  = 8'h0A;

        // Program
        uut.mem_inst.mem[10] = 8'h31; // SUB R0, R1 (Op=3, ra=0, rb=1) -> 0011 00 01

        // Initial State
        uut.regfile_inst.regs[0] = 8'd10; 
        uut.regfile_inst.regs[1] = 8'd20;

        run_cycles(20);

        if (N_flag !== 1'b1) 
            fail("Negative Flag did not set after 10 - 20");

        if (Z_flag !== 1'b0)
            fail("Zero Flag incorrectly set for negative result");

        // =====================================================
        // TEST 3: CARRY FLAG (C)
        // Operation: ADD R0, R1 (255 + 1 = 0 with Carry)
        // =====================================================
        reset_cpu(); clear_mem();
        uut.mem_inst.mem[0]  = 8'h0A;

        // Program
        uut.mem_inst.mem[10] = 8'h21; // ADD R0, R1 (Op=2, ra=0, rb=1) -> 0010 00 01

        // Initial State
        uut.regfile_inst.regs[0] = 8'd255; // 0xFF
        uut.regfile_inst.regs[1] = 8'd1;   // 0x01

        run_cycles(20);

        if (C_flag !== 1'b1)
            fail("Carry Flag did not set after 255 + 1");
        
        if (Z_flag !== 1'b1)
            fail("Zero Flag did not set (Result should be 0)");

        // =====================================================
        // TEST 4: OVERFLOW FLAG (V)
        // Operation: ADD R0, R1 (127 + 1 = 128)
        // Signed: (+127) + (+1) = (-128) -> Overflow!
        // =====================================================
        reset_cpu(); clear_mem();
        uut.mem_inst.mem[0]  = 8'h0A;

        // Program
        uut.mem_inst.mem[10] = 8'h21; // ADD R0, R1

        // Initial State
        uut.regfile_inst.regs[0] = 8'd127; // 0x7F (Max positive)
        uut.regfile_inst.regs[1] = 8'd1;   // 0x01

        run_cycles(20);

        if (V_flag !== 1'b1)
            fail("Overflow Flag did not set after 127 + 1");

        if (N_flag !== 1'b1)
            fail("Negative Flag check failed (128 is -128 in 2's comp)");

        // =====================================================
        // TEST 5: ROTATE LEFT CARRY (RLC)
        // Operation: RLC R1 (Shift MSB into Carry)
        // =====================================================
        reset_cpu(); clear_mem();
        uut.mem_inst.mem[0]  = 8'h0A;

        // Program
        // RLC is Opcode 6, ra=0 (RLC), rb=1 (R1) -> 0110 00 01 -> 0x61
        uut.mem_inst.mem[10] = 8'h61; 

        // Initial State
        uut.regfile_inst.regs[1] = 8'b10000000; // MSB is 1

        run_cycles(20);

        if (C_flag !== 1'b1)
            fail("Carry Flag not set by RLC of MSB=1");

        if (R1 !== 8'b00000000) 
            fail("R1 did not shift correctly (Expected 0)");

        // =====================================================
        // TEST 6: SETC (Set Carry Instruction)
        // Operation: SETC (Force Carry = 1)
        // =====================================================
        reset_cpu(); clear_mem();
        uut.mem_inst.mem[0]  = 8'h0A;

        // Program
        // SETC is Opcode 6, ra=2, rb=X -> 0110 10 00 -> 0x68
        uut.mem_inst.mem[10] = 8'h68; 

        run_cycles(20);

        if (C_flag !== 1'b1)
            fail("SETC instruction failed to set Carry flag");


        // =====================================================
        $display("========================================");
        $display(" ALL FLAG TESTS PASSED");
        $display("========================================");
        $stop;
    end

    // =========================================================
    // Monitor
    // =========================================================
    always @(posedge clk) begin
        if (rstn) begin
            // Uncomment line below to see per-cycle updates
            // $display("PC:%02h | R0:%02h R1:%02h | Flags(VCNZ): %b%b%b%b", uut.PC.pc_current, R0, R1, V_flag, C_flag, N_flag, Z_flag);
        end
    end

endmodule