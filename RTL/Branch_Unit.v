module Branch_Unit(
    input   wire [3:0]      flag_mask,     // [Z,N,C,V]
    input   wire [2:0]      BTYPE,
	output  reg [1:0]    	PC_SRC,
	output	reg				B_TAKE
    );


    localparam BR_NONE = 3'b000;
    localparam BR_JZ   = 3'b001;
    localparam BR_JN   = 3'b010;
    localparam BR_JC   = 3'b011;
    localparam BR_JV   = 3'b100;
    localparam BR_LOOP = 3'b101;
    localparam BR_JMP  = 3'b110; // Used for JMP, CALL
    localparam BR_RET  = 3'b111; // THIS (New Type for RET/RTI)

    localparam FW     = 2'b01;
    localparam DataB  = 2'b10;
    localparam NORM   = 2'b00;

	always @* begin
        
        case(BTYPE)
					BR_NONE:begin
						B_TAKE = 1'b0; 
						PC_SRC= NORM;
					end
            	
					BR_JZ:begin
						B_TAKE = (flag_mask[0] == 1'b1) ? 1'b1: 1'b0; 
						PC_SRC=  (B_TAKE == 1'b1) ? FW: NORM;
					end
					
					BR_JN:begin
						B_TAKE = (flag_mask[1] == 1'b1) ? 1'b1: 1'b0; 
						PC_SRC=  (B_TAKE == 1'b1) ? FW: NORM;
					end
					
					BR_JC:begin
						B_TAKE = (flag_mask[2] == 1'b1) ? 1'b1: 1'b0; 
						PC_SRC=  (B_TAKE == 1'b1) ? FW: NORM;
					end
				
					BR_JV:begin
						B_TAKE = (flag_mask[3] == 1'b1) ? 1'b1: 1'b0; 
						PC_SRC=  (B_TAKE == 1'b1) ? FW: NORM;
					end
					
					BR_LOOP:begin 
						B_TAKE = (flag_mask[0] == 1'b0) ? 1'b1: 1'b0; 
						PC_SRC=  (B_TAKE == 1'b1) ? FW: NORM;
					end
					
					BR_JMP:begin
						B_TAKE = 1'b1; 
						PC_SRC=  (B_TAKE == 1'b1) ? FW: NORM;
					end
					
					BR_RET:begin
						B_TAKE = 1'b1;
					    PC_SRC= DataB;
					end
                  
				    default :begin 
						B_TAKE = 1'b0;
						PC_SRC= NORM;
					end
                        
        endcase
    end

endmodule

