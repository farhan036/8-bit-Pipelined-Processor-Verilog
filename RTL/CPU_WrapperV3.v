module CPU_WrapperV3 (
    input clk,
    input rstn,
    input [7 : 0] I_Port,
    input int_sig,  // Interrupt Signal
    output [7 : 0] O_Port
);

// RF outputs
    wire [7 : 0]    ra_data_out,
                    rb_data_out,
                    rf_wd_mux_out;

// Memory wires
    wire [7 : 0]    mem_data_b_out;
    wire [7 : 0]    IR;
    wire [7 : 0]    interrupt_mux_out; //input port of addr_a
    wire int_sig_regout; //interrupt delayed control unit
    wire    cu_mem_read,
            cu_mem_write,
            cu_isCall;
    wire cu_isNotRet;

// Branch Unit Wires
    wire            bu_bt;

// ALU and CCR Wires
    wire [7 : 0]    alu_a,
                    alu_b,
                    alu_out;

    wire            alu_z,
                    alu_n,
                    alu_c,
                    alu_v;

    wire [3 : 0]    alu_flag_mask,
                    ccr_reg_out;
    wire [7 : 0]    alu_b_mux_out;

// IDEX Output Wires
    wire [2:0] idex_BType;       // output [2:0]
    wire [1:0] idex_MemToReg;    // output [1:0]
    wire [1:0] ID_EX_Rs_Addr;    // output [1:0]
    wire [1:0] ID_EX_Rt_Addr;    // output [1:0]
    wire       idex_RegWrite;    // output [0:0]
    wire       idex_MemWrite;    // output [0:0]
    wire       idex_MemRead;     // output [0:0]
    wire       idex_UpdateFlags; // output [0:0]
    wire [1:0] idex_RegDistidx;  // output [1:0]
    wire [1:0] idex_ALU_src;     // output [0:0]
    wire [3:0] idex_ALU_op;      // output [3:0]
    wire       idex_IO_Write;    // output [0:0]
    wire       idex_isCall;

    wire [7:0] idex_ra_val;     // output [7:0]
    wire [7:0] idex_rb_val;     // output [7:0]
    wire [1:0] idex_ra;         // output [1:0]
    wire [1:0] idex_rb;         // output [1:0]

    wire [7:0] idex_pc_plus1;   // output [7:0]
    wire [7:0] idex_IP;         // output [7:0]
    wire [7:0] idex_imm;        // output [7:0]
    wire       idex_loop_sel;
    wire       idex_ret_sel;
    wire       idex_int_signal;
    wire       idex_rti_sel;
    wire       idex_isNotRet;



// Ex-mem output wires
    wire [7:0]      exmem_pc_plus1;    // output [7:0]
    wire [7:0]      exmem_Rd1;         // output [7:0]
    wire [7:0]      exmem_Rd2;         // output [7:0]
    wire            exmem_IO_Write;    // output [0:0]
    wire [1:0]      exmem_RegDistidx;  // output [1:0]
    wire [7:0]      exmem_ALU_res;     // output [7:0]
    wire [7:0]      exmem_FW_value;    // output [7:0]
    wire            exmem_MemWrite;    // output [0:0]
    wire [1:0]      exmem_MemToReg;    // output [1:0]
    wire            exmem_RegWrite;    // output [0:0]
    wire [7:0]      exmem_IP;          // output [7:0]
    wire            exmem_isCall;      // output [0:0]
    wire            exmem_int_signal;
    wire            exmem_isNotRet;

    wire [7 : 0]    exmem_IP_mux_out;

    wire [7 : 0]    ret_mux_out;

// Mem-WB Output Wires
    wire [7:0] memwb_pc_plus1;    // output [7:0]
    wire [1:0] memwb_RegDistidx;  // output [1:0]
    wire [7:0] memwb_Rd2;         // output [7:0]
    wire [7:0] memwb_ALU_res;     // output [7:0]
    wire [7:0] memwb_data_B;      // output [7:0]
    wire [1:0] memwb_MemToReg;    // output [1:0]
    wire       memwb_RegWrite;    // output [0:0]
    wire [7:0] memwb_IP;          // output [7:0]
    wire       memwb_IO_Write;
    wire [7:0] memwb_FW_val;

// FU Outputs
    wire [1 : 0]    fu_FWA,
                    fu_FWB;
    wire    fu_FWDA,
            fu_FWDB;


/*** Program Counter *****************************************************************************/
    wire [7 : 0]    pc_next,
                    pc_current,
                    pc_plus1;
    wire            pc_write; 
    wire [1 : 0]    pc_src;
    
    Pc PC(
        .clk(clk),
        .rst(rstn),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    assign pc_plus1 = pc_current + 1;

    mux4to1pc PC_MUX (
        .d0(pc_plus1),
        .d1(alu_b_mux_out), 
        .d2(mem_data_b_out),
        .d3(IR), //M[0] , M[1]
        .sel(pc_src),
        .int_sig(int_sig),
        .rst(rstn),
        .out(pc_next)
    );
/*** MUX FOR INTERRUPT *****************************************************************************/
   mux4to1 u_interruptmux
   (
    .d0(8'd0),
    .d1(pc_current),
    .d2(8'd0), 
    .d3(8'd1),
    .sel({int_sig,rstn}),
    .out(interrupt_mux_out)
   );

   interrupt_reg u_interrupt_reg
   (
    .clk(clk),
    .rst(rstn),
    .int_sig(int_sig),
    .int_sig_reg(int_sig_regout)
   );
   

/*** Memory *****************************************************************************/
    

    wire [7 : 0]    Write_b_interrupt; //before interrupt
    wire [7 : 0]    Write_data_a_interrupt; //after interrupt
    mux2to1 #(.WIDTH(8)) mem_writeD_b_mux (
        .d0     (exmem_FW_value),
        .d1     (exmem_pc_plus1),
        .sel    (exmem_isCall),
        .out    (Write_b_interrupt)
    );
    mux2to1 #(.WIDTH(8)) mem_writeD_b_mux2to1 (
        .d0     (Write_b_interrupt),
        .d1     (exmem_pc_plus1-1'b1),
        .sel    (exmem_int_signal),
        .out    (Write_data_a_interrupt)
    );


    memory mem_inst (
        .clk            (clk),
        .rst            (rstn),
        .addr_a         (interrupt_mux_out),
        .data_out_a     (IR),
        .addr_b         (ret_mux_out), 
        .data_out_b     (mem_data_b_out), 
        .we_b           (exmem_MemWrite), 
        .write_data_b   (Write_data_a_interrupt)  
    );

/*** IF_ID_Reg *****************************************************************************/
    wire [7 : 0]    ifid_pc_plus1,
                    ifid_IR,
                    ifid_immby,
                    ifid_IP;
    // HU Wires
    wire            hu_flush;

    IF_ID_Reg if_id_reg_inst (
        .clk            (clk), // 1 bit, input
        .rst            (rstn), // 1 bit, input

        // CONTROL INPUTS
        .IF_ID_EN       (if_id_en), // 1 bit, input (Active Low Enable)
        .Flush          (hu_flush), // 1 bit, input (Active High Reset)

        // DATA INPUTS
        .PC_Plus_1_In   (pc_plus1), // 8 bits, input
        .Instruction_In (IR), // 8 bits, input
        .immby          (IR), // 8 bits, input
        .IP             (I_Port), // 8 bits, input

        // DATA OUTPUTS
        .PC_Plus_1_Out  (ifid_pc_plus1), // 8 bits, output
        .Instruction_Out(ifid_IR), // 8 bits, output
        .immbyout       (ifid_immby), // 8 bits, output
        .IP_out         (ifid_IP)  // 8 bits, output
    );
/*** Interrupt muxes before Control Unit ********************************************************/
wire [3:0] opcode_interrupt;
mux2to1 #(.WIDTH(4))u_interrupt_opcode_mux
(
    .d0(ifid_IR[7:4]),
    .d1(4'b0111),
    .sel(int_sig_regout),
    .out(opcode_interrupt)
);
wire [1:0] ra_interrupt;
mux2to1 #(.WIDTH(2))u_interrupt_ra_mux
(
    .d0(ifid_IR[3:2]),
    .d1(2'b00),
    .sel(int_sig_regout),
    .out(ra_interrupt)
);

/*** Control Unit *****************************************************************************/
    
    // Fetch Wires
    wire    cu_pc_write_en,
            cu_if_id_write_en,
            cu_inject_bubble,
            cu_inject_int;

    // Decode Wires
    wire    cu_sp_en,
            cu_sp_op,
            cu_reg_write,
            cu_sp_sel,
            cu_reg_dist;
    wire    cu_ret_sel;
    wire cu_rti_sel;        // Karim added this

    // Execute Wires
    wire [1 : 0]   cu_alu_src;
    wire [3 : 0]    cu_alu_op;
    wire cu_flag_en;
    wire [2 : 0]    cu_btype;

    // Memory Wires
    wire [1 : 0]    cu_memtoreg;

    // Write-Back Control
    wire cu_io_write;
    wire cu_loop_sel;
    

    Control_unit ctrl_inst (
        .clk            (clk),
        .rst            (rstn),
        .INTR           (int_sig_regout),
        .opcode         (opcode_interrupt), // modify due to interrupt mux
        .ra             (ra_interrupt),     // modify due to interrupt mux
        // Fetch Control
        .PC_Write_En    (cu_pc_write_en),
        .IF_ID_Write_En (cu_if_id_write_en),
        .Inject_Bubble  (cu_inject_bubble),
        .Inject_Int     (cu_inject_int),
        // Decode Control
        .RegWrite       (cu_reg_write),
        .RegDist        (cu_reg_dist),
        .SP_SEL         (cu_sp_sel), // SP = Stack Pointer
        .SP_EN          (cu_sp_en),
        .SP_OP          (cu_sp_op),
        // Execute Control
        .Alu_Op         (cu_alu_op), // 4 Bits
        .BTYPE          (cu_btype), // 3 Bits
        .Alu_src        (cu_alu_src),
        .UpdateFlags    (cu_flag_en),
        .loop_sel       (cu_loop_sel),
        // Memory Control
        .IS_CALL        (cu_isCall),
        .ISNOT_RET      (cu_isNotRet),
        .MemToReg       (cu_memtoreg), // 2 Bits
        .MemWrite       (cu_mem_write),
        .MemRead        (cu_mem_read),
        .Ret_sel        (cu_ret_sel),
        .Rti_sel        (cu_rti_sel),       // karim
        // Write-Back Control
        .IO_Write       (cu_io_write)
    );

    wire [1:0]  reg_dist;
    mux2to1 #(.WIDTH(2)) reg_dist_mux (
        .d0     (ifid_IR[3:2]),
        .d1     (ifid_IR[1:0]),
        .sel    (cu_reg_dist),
        .out    (reg_dist)
    );

/*** Hazard Unit *****************************************************************************/

    wire    hu_pc_write_en,
            hu_if_id_write_en;
    wire    hu_bubble;

    HU hu_inst (
        // ID Stage inputs
        .opcode        (ifid_IR[7:4]),
        .if_id_ra      (ifid_IR[3:2]),  // 2 Bits
        .if_id_rb      (ifid_IR[1:0]),  // 2 Bits

        // EX Stage inputs
        .id_ex_rd      (idex_RegDistidx),  // 2 Bits
        .id_ex_mem_read(idex_MemRead),

        // Inputs from Logic
        .BT            (bu_bt),

        .pc_en         (hu_pc_write_en),
        .if_id_en      (hu_if_id_write_en),
        .flush         (hu_flush),
        .control_zero  (hu_bubble)
    );

/*** LOGIC Gates *****************************************************************************/
    wire    bubble_wire;

    assign pc_write = cu_pc_write_en & hu_pc_write_en;
    assign if_id_en = cu_if_id_write_en & hu_if_id_write_en;

    assign bubble_wire = hu_bubble | cu_inject_bubble;

/*** Register File *****************************************************************************/
  
    mux4to1 rf_wd_mux (
        .d0(memwb_ALU_res),
        .d1(memwb_data_B), 
        .d2(memwb_IP),
        .d3(8'b0),
        .sel(memwb_MemToReg),
        .out(rf_wd_mux_out)
    );

    wire [3 : 2]    ra_mux_out;
    mux2to1 #(.WIDTH(2)) ra_mux (
        .d0     (ifid_IR[3:2]),
        .d1     (2'b11),
        .sel    (cu_sp_sel),
        .out    (ra_mux_out)
    );                 

    Register_file regfile_inst (
        .clk        (clk),
        .rst        (rstn),
        .wenabel    (memwb_RegWrite),
        .SP_EN      (cu_sp_en),
        .SP_OP      (cu_sp_op),
        .ra         (ra_mux_out),
        .rb         (ifid_IR[1:0]),
        .rd         (memwb_RegDistidx), 
        .write_data (rf_wd_mux_out),
        .ra_date    (ra_data_out),
        .rb_date    (rb_data_out)
    );


    wire [7 : 0]    rf_ra_fwd_mux_out;
    mux2to1 #(.WIDTH(8)) rf_ra_fwd_mux (
        .d0     (ra_data_out),
        .d1     (rf_wd_mux_out),
        .sel    (fu_FWDA),
        .out    (rf_ra_fwd_mux_out)
    );  

    wire [7 : 0]    rf_rb_fwd_mux_out;
    mux2to1 #(.WIDTH(8)) rf_rb_fwd_mux (
        .d0     (rb_data_out),
        .d1     (rf_wd_mux_out),
        .sel    (fu_FWDB),
        .out    (rf_rb_fwd_mux_out)
    );  

/*** ID_EX Reg *****************************************************************************/
// Inside Decode Stage (Combinational Logic)

    // 1. Detect if this is an instruction that implicitly reads SP (R3)
    // Adjust these opcode checks to match your specific definitions
    wire Is_RET_RTI  = (ifid_IR[7:4] == 4'd11) && (ifid_IR[3:2] >= 2'b10); // RET(2) or RTI(3)
    wire Is_POP      = (ifid_IR[7:4] == 4'd7)  && (ifid_IR[3:2] == 2'b01); // POP(1)
    wire Stack_Read_Op = Is_RET_RTI || Is_POP  ;

    // 2. The Logic Fix: Override the Register Address
    // If it is a Stack Op, tell the pipeline we are reading R3 (11).
    // Otherwise, read the normal bits from the instruction.
    
    // For ALU Input A (Rs):
    assign ID_EX_Rs_Addr = (Stack_Read_Op) ? 2'b11 : ifid_IR[3:2];

    // For ALU Input B (Rt) - OPTIONAL depending on where you wire SP
   // assign ID_EX_Rt_Addr = (Stack_Read_Op) ? 2'b11 : ifid_IR[1:0];

    id_ex_reg id_ex_reg_inst (
        .clk            (clk), // 1 bit, input
        .rst            (rstn), // 1 bit, input
        .flush          (hu_flush || cu_inject_bubble), // 1 bit, input //todo Might Need to remove
        .inject_bubble  (bubble_wire), // 1 bit, input

        // ---------- Data inputs ----------
        .pc_plus1       (ifid_pc_plus1), // 8 bits, input
        .IP             (ifid_IP), // 8 bits, input
        .imm            (ifid_immby), // 8 bits, input

        // ---------- Control inputs from ID stage ----------
        .BType          (cu_btype), // 3 bits, input
        .MemToReg       (cu_memtoreg), // 2 bits, input
        .RegWrite       (cu_reg_write), // 1 bit, input
        .MemWrite       (cu_mem_write), // 1 bit, input
        .MemRead        (cu_mem_read), // 1 bit, input
        .UpdateFlags    (cu_flag_en), // 1 bit, input
        .RegDistidx     (reg_dist), // 2 bits, input
        .ALU_src        (cu_alu_src), // 1 bit, input
        .ALU_op         (cu_alu_op), // 4 bits, input
        .IO_Write       (cu_io_write), // 1 bit, input
        .isCall         (cu_isCall),
        .isNotRet       (cu_isNotRet),
        .loop_sel       (cu_loop_sel),
        .Ret_sel        (cu_ret_sel),
        .Rti_sel        (cu_rti_sel),
        .int_signal     (int_sig_regout),

        // ---------- Data inputs from ID stage ----------
        .ra_val_in      (rf_ra_fwd_mux_out), // 8 bits, input
        .rb_val_in      (rf_rb_fwd_mux_out), // 8 bits, input
        .ra             (ID_EX_Rs_Addr), // 2 bits, input // i will modify
        .rb             (ifid_IR[1:0]), // 2 bits, input

        // ---------- Control outputs to EX stage ----------
        .BType_out       (idex_BType),       // 3 bits, output
        .MemToReg_out    (idex_MemToReg),    // 2 bits, output
        .RegWrite_out    (idex_RegWrite),    // 1 bit, output
        .MemWrite_out    (idex_MemWrite),    // 1 bit, output
        .MemRead_out     (idex_MemRead),     // 1 bit, output
        .UpdateFlags_out (idex_UpdateFlags), // 1 bit, output
        .RegDistidx_out  (idex_RegDistidx),  // 2 bits, output
        .ALU_src_out     (idex_ALU_src),     // 1 bit, output
        .ALU_op_out      (idex_ALU_op),      // 4 bits, output
        .IO_Write_out    (idex_IO_Write),     // 1 bit, output
        .isCall_out      (idex_isCall),
        .loop_sel_out    (idex_loop_sel),
        .Ret_sel_out     (idex_ret_sel),
        .Rti_sel_out     (idex_rti_sel),
        .int_signal_out  (idex_int_signal),
        .isNotRet_out    (idex_isNotRet),

        // ---------- Data outputs to EX stage ----------
        .ra_val_out   (idex_ra_val),   // 8 bits, output
        .rb_val_out   (idex_rb_val),   // 8 bits, output
        .ra_out       (idex_ra),       // 2 bits, output
        .rb_out       (idex_rb),       // 2 bits, output

        // ---------- PC_plus1 out, IP_out, immediate ----------
        .pc_plus1_out (idex_pc_plus1), // 8 bits, output
        .IP_out       (idex_IP),       // 8 bits, output
        .imm_out      (idex_imm)       // 8 bits, output
    );

/*** Forwarding Unit *****************************************************************************************/

    FU fu_inst (
        // ---------------- Control Signals ----------------
        .RegWrite_Ex_MEM (exmem_RegWrite),   // 1 bit, input
        .RegWrite_Mem_WB (memwb_RegWrite),   // 1 bit, Input

        // ---------------- Register Addresses ----------------
        .Rs_EX           (idex_ra), // 2 bits, input   idex
        .Rt_EX           (idex_rb), // 2 bits, input   idex
        .Rd_MEM          (exmem_RegDistidx), // 2 bits, input 
        .Rd_WB           (memwb_RegDistidx), // 2 bits, input
        .Rs_ID           (ifid_IR[3:2]),
        .Rt_ID           (ifid_IR[1:0]),

        // ---------------- Outputs to EX Stage ----------------
        .ForwardA        (fu_FWA), // 2 bits, output
        .ForwardB        (fu_FWB),  // 2 bits, output
        .Forward_ID_A    (fu_FWDA),
        .Forward_ID_B    (fu_FWDB)
    );

/*** ALU ****************************************************************************************/

    mux4to1 alu_a_mux (
        .d0(idex_ra_val),
        .d1(rf_wd_mux_out),  //? Make sure its Correct
        .d2(exmem_IP_mux_out),  //? Make sure its Correct
        .d3(8'b0),  
        .sel(fu_FWA),
        .out(alu_a)
    );

    mux4to1 alu_b_mux4to1 (
        .d0(idex_rb_val),
        .d1(rf_wd_mux_out),  //? Make sure its Correct
        .d2(exmem_IP_mux_out),  //? Make sure its Correct
        .d3(8'b0),  
        .sel(fu_FWB),
        .out(alu_b_mux_out)
    );

    // assign alu_a = ra_data_out; // Temporarily untill Fwd is done
    //! Old Arch MUX
    // mux2to1 #(.WIDTH(8)) alu_b_mux2to1 (
    //     .d0     (alu_b_mux_out),
    //     .d1     (idex_imm),
    //     .sel    (idex_ALU_src),
    //     .out    (alu_b)
    // );

    mux4to1 alu_b_src_mux (
        .d0(alu_b_mux_out),
        .d1(idex_imm), 
        .d2(alu_a),
        .d3(8'b00000000),
        .sel(idex_ALU_src),
        .out(alu_b)
    );

    ALU alu_inst (
        .A         (alu_a),
        .B         (alu_b),
        .sel       (idex_ALU_op),
        .cin       (ccr_reg_out[2]),
        .out       (alu_out),
        .Z         (alu_z),
        .N         (alu_n),
        .C         (alu_c),
        .V         (alu_v),
        .flag_mask (alu_flag_mask)  // 4 Bits
    );

    CCR ccr_inst (
        .clk       (clk),
        .rst       (rstn),
        .Z         (alu_z),
        .N         (alu_n),
        .C         (alu_c),
        .V         (alu_v),
        .intr      (idex_int_signal),
        .rti       (idex_rti_sel),
        .flag_en   (idex_UpdateFlags),
        .flag_mask (alu_flag_mask), // 4 bits
        .CCR   (ccr_reg_out)  // 4 bits
    );

/*** Branch Unit ****************************************************************************************/
    
    wire [3 : 0]    loop_sel_mux_out;
    mux2to1 #(.WIDTH(4)) loop_sel_mux (
        .d0     (ccr_reg_out),
        .d1     ({alu_v,alu_c,alu_n,alu_z}),
        .sel    (idex_loop_sel),
        .out    (loop_sel_mux_out)
    );   


    Branch_Unit branch_inst (
        .flag_mask (loop_sel_mux_out), // 4 bits
        .BTYPE     (idex_BType), // 3 bits
        .B_TAKE    (bu_bt), // 2 bits
        .PC_SRC    (pc_src)  // 2 bits
    );

/*** EX-MEM Register ****************************************************************************************/

    EX_MEM_reg ex_mem_reg_inst (
        // ---------------- Inputs ----------------
        .clk        (clk), // 1 bit, input
        .rst        (rstn), // 1 bit, input
        .pc_plus1   (idex_pc_plus1), // 8 bits, input
        .Rd1        (idex_ra_val), // 8 bits, input 
        .Rd2        (idex_rb_val), // 8 bits, input 
        .IO_Write   (idex_IO_Write), // 1 bit, input
        .RegDistidx (idex_RegDistidx), // 2 bits, input
        .ALU_res    (alu_out), // 8 bits, input
        .FW_value   (alu_b_mux_out), // 8 bits, input
        .MemWrite   (idex_MemWrite), // 1 bit, input
        .MemToReg   (idex_MemToReg), // 2 bits, input
        .RegWrite   (idex_RegWrite), // 1 bit, input
        .IP         (idex_IP), // 8 bits, input
        .isCall     (idex_isCall), // 1 bit, input
        .int_signal (idex_int_signal),
        .isNotRet   (idex_isNotRet),

        // ---------------- Outputs ----------------
        .pc_plus1_out   (exmem_pc_plus1),    // 8 bits, output
        .Rd1_out        (exmem_Rd1),         // 8 bits, output
        .Rd2_out        (exmem_Rd2),         // 8 bits, output
        .IO_Write_out   (exmem_IO_Write),    // 1 bit, output
        .RegDistidx_out (exmem_RegDistidx),  // 2 bits, output
        .ALU_res_out    (exmem_ALU_res),     // 8 bits, output
        .FW_value_out   (exmem_FW_value),    // 8 bits, output
        .MemWrite_out   (exmem_MemWrite),    // 1 bit, output
        .MemToReg_out   (exmem_MemToReg),    // 2 bits, output
        .RegWrite_out   (exmem_RegWrite),    // 1 bit, output
        .IP_out         (exmem_IP),          // 8 bits, output
        .isCall_out     (exmem_isCall),       // 1 bit, output
        .int_signal_out (exmem_int_signal),
        .isNotRet_out   (exmem_isNotRet)
    );

    //! New to Architecture
    //** New Addition **// //forward when input instruction
    mux4to1 exmem_IP_mux (
        .d0(exmem_ALU_res),
        .d1(exmem_ALU_res),
        .d2(exmem_IP),
        .d3(exmem_ALU_res),  
        .sel(exmem_MemToReg),
        .out(exmem_IP_mux_out)
    );

    //todo for Farhan to edit
    // //! Call Mux
     wire [7 : 0]    call_mux_out;
     mux2to1 #(.WIDTH(8)) call_mux (
        .d0     (exmem_IP_mux_out),
        .d1     (exmem_Rd1),
        .sel    (exmem_isCall & exmem_isNotRet),
        .out    (call_mux_out)
     );      

    //! Return Logic
    mux2to1 #(.WIDTH(8)) ret_mux (
        .d0     (call_mux_out),
        .d1     (alu_out),
        .sel    (idex_ret_sel | idex_rti_sel),
        .out    (ret_mux_out)
    );  


/*** Mem-WB Register ****************************************************************************************/

    MEM_WB_Reg mem_wb_reg_inst (
        // ---------------- Inputs ----------------
        .clk        (clk), // 1 bit, input
        .rst        (rstn), // 1 bit, input
        .pc_plus1   (exmem_pc_plus1), // 8 bits, input
        .RegDistidx (exmem_RegDistidx), // 2 bits, input
        .Rd2        (exmem_Rd2), // 8 bits, input
        .ALU_res    (exmem_ALU_res), // 8 bits, input
        .data_B     (mem_data_b_out), // 8 bits, input
        .MemToReg   (exmem_MemToReg), // 2 bits, input
        .RegWrite   (exmem_RegWrite), // 1 bit, input
        .IP         (exmem_IP), // 8 bits, input
        .IO_Write   (exmem_IO_Write), // 1 Bit, Input
        .FW_val     (exmem_FW_value),

        // ---------------- Outputs ----------------
        .pc_plus1_out   (memwb_pc_plus1),   // 8 bits, output
        .RegDistidx_out (memwb_RegDistidx), // 2 bits, output
        .Rd2_out        (memwb_Rd2),        // 8 bits, output
        .ALU_res_out    (memwb_ALU_res),    // 8 bits, output
        .data_B_out     (memwb_data_B),     // 8 bits, output
        .MemToReg_out   (memwb_MemToReg),   // 2 bits, output
        .RegWrite_out   (memwb_RegWrite),   // 1 bit, output
        .IP_out         (memwb_IP),         // 8 bits, output
        .IO_Write_out   (memwb_IO_Write),    // 1 Bit, output
        .FW_val_out   (memwb_FW_val)
    );



/*** Output Port ****************************************************************************************/

    //? Old Arch
    // mux2to1 #(.WIDTH(8)) output_port_mux (
    //     .d0     (8'b00000000),
    //     .d1     (memwb_FW_val),
    //     .sel    (memwb_IO_Write),
    //     .out    (O_Port)
    // );

    OUT out_reg(
        .clk (clk),   // Input: Clock signal
        .rst (rstn),   // Input: Reset signal
        .en  (memwb_IO_Write),   // Input: Enable signal
        .in  (memwb_FW_val),   // Input [7:0]: 8-bit input data bus
        .out (O_Port)    // Output [7:0]: 8-bit output data bus
    );


endmodule