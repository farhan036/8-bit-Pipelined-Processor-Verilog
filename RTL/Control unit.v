module Control_unit (
    input wire       clk,
    input wire       rst,
    input wire       INTR ,               // Interrupt
    input wire [3:0] opcode,
    input wire [1:0] ra,
    
    // Fetch Control
    output reg       PC_Write_En,
    output reg       IF_ID_Write_En,
    output reg       Inject_Bubble,
    output reg       Inject_Int, // to PC MUX
    // Decode 
    output reg       RegWrite,
    output reg       RegDist,             // 0 select ra and 1 select rb
    output reg       SP_SEL,
    output reg       SP_EN,
    output reg       SP_OP,
    // Execute
    output reg [3:0] Alu_Op,
    output reg [2:0] BTYPE,
    output reg [1:0] Alu_src,
    output reg       IS_CALL,
    output reg       ISNOT_RET,
    output reg       UpdateFlags,
    // Memory
    output reg [1:0] MemToReg,            // 00=ALU, 01=Mem, 10=Input Port.
    output reg       MemWrite,
    output reg       MemRead,
    output reg       Ret_sel,
    output reg       Rti_sel,

    output reg loop_sel,    // loop selction 
    //Write Back
    output reg       IO_Write  
);
    // ========================================================================
    // Status
    // ========================================================================
    localparam Reset     =2'b00;
    localparam FETCH     =2'b01;
    localparam FETCH_IMM =2'b10;
    // ========================================================================
    // ALU OPERATION CODES 
    // ========================================================================
    localparam OP_NOP    = 4'b0000;
    localparam OP_MOV    = 4'b0001;
    localparam OP_ADD    = 4'b0010;
    localparam OP_SUB    = 4'b0011;
    localparam OP_AND    = 4'b0100;
    localparam OP_OR     = 4'b0101;
    localparam OP_RLC    = 4'b0110;
    localparam OP_RRC    = 4'b0111;
    localparam OP_NOT    = 4'b1000;
    localparam OP_NEG    = 4'b1001;
    localparam OP_INC    = 4'b1010;
    localparam OP_DEC    = 4'b1011;
    localparam OP_SETC   = 4'b1100;
    localparam OP_CLRC   = 4'b1101;
    localparam OP_PASS_A = 4'b1110; // Pass A (Used for PUSH address)
    localparam OP_POP    = 4'b1111; // A + 1  (Used for POP address)

    // ========================================================================
    // BRANCH TYPES
    // ========================================================================
    localparam BR_NONE = 3'b000;
    localparam BR_JZ   = 3'b001;
    localparam BR_JN   = 3'b010;
    localparam BR_JC   = 3'b011;
    localparam BR_JV   = 3'b100;
    localparam BR_LOOP = 3'b101;
    localparam BR_JMP  = 3'b110; // Used for JMP, CALL
    localparam BR_RET = 3'b111; // THIS (New Type for RET/RTI)

    reg [1:0] current_state, next_state;



    always @(posedge clk or negedge rst) begin
        if (!rst) 
            current_state <= Reset;
        else 
            current_state <= next_state;
    end


    always @(*) 
    begin
            PC_Write_En    = 'd1;
            IF_ID_Write_En = 'd1;
            Inject_Bubble  = 'd0;
            Inject_Int     = 'd0;
            next_state     = FETCH;

            
        case (current_state)
        Reset:
        begin
            PC_Write_En    = 'd1;
            IF_ID_Write_En = 'd1;
            Inject_Bubble  = 'd1;
            Inject_Int     = 'd0;
            next_state     = FETCH;
        end
        FETCH: 
        begin
            if(opcode=='d12)
            begin
                IF_ID_Write_En ='d0;
                Inject_Bubble  = 1;  // No Execute
                next_state     = FETCH_IMM;
            end
            else
            next_state     = FETCH;
        end
        FETCH_IMM:
        begin
                next_state     = FETCH;    
        end 
        default: next_state     = FETCH;
        endcase    
    end
    // Decoder Logic
    always @(*) 
    begin
        RegWrite       = 'd0;
        RegDist        = 'd0;
        SP_SEL         = 'd0;
        SP_EN          = 'd0;
        SP_OP          = 'd0;
        Alu_Op         = OP_NOP;
        BTYPE          = BR_NONE;
        Alu_src        = 'd0;
        IS_CALL        = 'd0;
        UpdateFlags    = 'd0;
        MemToReg       = 'd0;
        MemRead        = 'd0;
        MemWrite       = 'd0;
        loop_sel       = 'd0;
        IO_Write       = 'd0;
        Ret_sel        = 'd0;
        Rti_sel        = 'd0;
        ISNOT_RET      = 'd1;
        case (opcode)
        4'b0000: //NOP
        begin
        end 
        4'b0001:
        begin
            Alu_Op      = OP_MOV;
            RegWrite    = 'd1;
            RegDist     = 'd0;
        end
        4'b0010:
        begin
            Alu_Op      = OP_ADD;
            RegWrite    = 'd1;
            RegDist     = 'd0;
            UpdateFlags = 'd1;
        end 
        4'b0011:
        begin
            Alu_Op      = OP_SUB;
            RegWrite    = 'd1;
            RegDist     = 'd0;
            UpdateFlags = 'd1;
        end 
        4'b0100:
        begin
            Alu_Op      = OP_AND;
            RegWrite    = 'd1;
            RegDist     = 'd0;
            UpdateFlags = 'd1;
        end 
        4'b0101:
        begin
            Alu_Op      = OP_OR;
            RegWrite    = 'd1;
            RegDist     = 'd0;
            UpdateFlags = 'd1;
        end 
        4'b0110:
        begin
            case (ra)
            2'b00: // RLC
            begin
            Alu_Op      = OP_RLC;
            RegWrite    = 'd1;
            RegDist     = 'd1;
            UpdateFlags = 'd1;    
            end 
            2'b01: //RRC
            begin
            Alu_Op      = OP_RRC;
            RegWrite    = 'd1;
            RegDist     = 'd1;
            UpdateFlags = 'd1;    
            end 
            2'b10: //SETC
            begin
            Alu_Op      = OP_SETC;
            RegWrite    = 'd0;
            RegDist     = 'd0;
            UpdateFlags = 'd1;    
            end
            2'b11: //CLRC
            begin
            Alu_Op      = OP_CLRC;
            RegWrite    = 'd0;
            RegDist     = 'd0;
            UpdateFlags = 'd1;    
            end 
             
            endcase
        end 
        4'b0111:
        begin
            case (ra)
            2'b00: // PUSH
            begin
            Alu_Op      = OP_PASS_A;
            SP_EN       = 'd1;
            SP_OP       = 'd0;
            SP_SEL      = 'd1;
            MemWrite    = 'd1;
            if(INTR) //interrupt
            begin
               IS_CALL  = 'd1; 
            end
            else
                IS_CALL  = 'd0;
            end 
            2'b01: //POP
            begin
            Alu_Op      = OP_POP;
            SP_EN       = 'd1;
            SP_OP       = 'd1;
            SP_SEL      = 'd1;
            MemRead     = 'd1;
            MemToReg    = 'd1;
            RegWrite    = 'd1;
            RegDist     = 'd1;  
            end 
            2'b10: //OUT
            begin
            IO_Write    = 'd1;
            Alu_Op      = 'b0001;
            end
            2'b11: //IN
            begin
            RegWrite    = 'd1;
            RegDist     = 'd1;
            MemToReg    = 'd10;    
            end 
             
            endcase
        end  
        4'b1000:
        begin
        RegWrite    = 'd1;
        RegDist     = 'd1;
        UpdateFlags = 'd1;
            case(ra)
            2'b00: Alu_Op = OP_NOT;
            2'b01: Alu_Op = OP_NEG;
            2'b10: Alu_Op = OP_INC;
            2'b11: Alu_Op = OP_DEC;
            
            
            endcase
        end 
        4'b1001:
        begin
            case(ra)
            2'b00: 
            begin 
                BTYPE = BR_JZ;
            end
            2'b01: BTYPE = BR_JN;
            2'b10: BTYPE = BR_JC;
            2'b11: BTYPE = BR_JV;
            endcase
        end 
        4'b1010:
        begin
            BTYPE       = BR_LOOP;
            RegWrite    = 'd1;
            RegDist     = 'd0;
            UpdateFlags = 'd1;
            Alu_Op      = OP_DEC;
            Alu_src     = 'd2;
            loop_sel    = 'd1;
        end
        4'b1011:
        begin
            case(ra)
            2'b00: BTYPE = BR_JMP; //jmp
            2'b01: //  call
            begin
                   BTYPE    = BR_JMP ;
                   Alu_Op   = OP_PASS_A;
                   SP_EN    = 'd1;
                   SP_OP    = 'd0;
                   SP_SEL   = 'd1;
                   IS_CALL  = 'd1;
                   MemWrite = 'd1;
            end 
            2'b10: //RET
            begin
                   BTYPE    = BR_RET ;
                   Alu_Op   = OP_POP;
                   SP_EN    = 'd1;
                   SP_OP    = 'd1;
                   SP_SEL   = 'd1;
                   MemRead  = 'd1;
                   Ret_sel  = 'd1;
                   ISNOT_RET= 'd0;
            end
            2'b11: //RTI
            begin
                   BTYPE    = BR_RET ;
                   Alu_Op   = OP_POP;
                   SP_EN    = 'd1;
                   SP_OP    = 'd1;
                   SP_SEL   = 'd1;
                   MemRead  = 'd1;
                   Rti_sel  = 'd1;
                   ISNOT_RET= 'd0;
            end
            endcase
        end 
        4'b1100:
        begin
        case (ra)
            2'b00: // LDM
            begin
            Alu_Op   = OP_MOV;
            Alu_src  = 'd1;
            RegWrite = 'd1;
            RegDist  = 'd1;
            end 
            2'b01: //LDD
            begin
            Alu_Op   = OP_MOV;
            Alu_src  = 'd1;
            RegWrite = 'd1;
            RegDist  = 'd1;
            MemToReg = 'd1;
            MemRead  = 'd1;
            end 
            2'b10: //STD
            begin
            Alu_Op   = OP_MOV;
            Alu_src  = 'd1;

            MemWrite  = 'd1;
            end  
            endcase        
        end 
        4'b1101:
        begin
            Alu_Op   = OP_PASS_A;
            MemRead  = 'd1;
            MemToReg = 'd1;
            RegWrite = 'd1;
            RegDist  = 'd1;   
        end
        4'b1110: 
        begin
            Alu_Op   = OP_PASS_A;
            MemWrite = 'd1;
        end
         
        endcase
    end

endmodule

