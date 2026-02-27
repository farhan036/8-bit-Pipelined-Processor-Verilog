module HU(
    input [1:0] if_id_ra,
    input [1:0] if_id_rb,
    input [1:0] id_ex_rd,
    input       id_ex_mem_read,
    input [3:0] opcode,
    input       BT,
    
    output reg  pc_en,
    output reg  if_id_en,
    output reg  flush,
    output reg  control_zero // <--- YOU NEED THIS
);

    always @(*) begin
        // 1. Set Defaults
        pc_en        = 1;
        if_id_en     = 1;
        flush        = 0;
        control_zero = 0; // Default: let control signals pass

        // 2. Load-Use Hazard Detection
        if(opcode=='d12 )
        begin
            if (id_ex_mem_read && (id_ex_rd == if_id_rb)) begin
            pc_en        = 0;   // Freeze PC
            if_id_en     = 0;   // Freeze IF/ID (Keep instr in Decode)
            control_zero = 1;   // <--- INSERT BUBBLE into ID/EX
            flush        = 0;   // Do NOT flush IF/ID (we need to save the instr)
        end
        end
        else 
        begin
        if (id_ex_mem_read && (id_ex_rd == if_id_ra || id_ex_rd == if_id_rb) && opcode!='d7) begin
            pc_en        = 0;   // Freeze PC
            if_id_en     = 0;   // Freeze IF/ID (Keep instr in Decode)
            control_zero = 1;   // <--- INSERT BUBBLE into ID/EX
            flush        = 0;   // Do NOT flush IF/ID (we need to save the instr)
        end
        end

        // 3. Control Hazard (Branching)
        if (BT) begin
            flush = 1;          // Kill the instruction in Fetch/Decode
            // No need to stall, just kill.
        end
    end

endmodule