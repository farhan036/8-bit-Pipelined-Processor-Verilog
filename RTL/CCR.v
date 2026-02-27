module CCR(
    input clk, rst,
    input Z, N, C, V,           // Flag inputs from ALU
    input flag_en,              // Enable flag updates
    input intr,                 // interrupt signal
    input rti,                  // rti instr
    input [3:0] flag_mask,
    output [3:0] CCR
);
    
    reg [7:0] ccr_reg;
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            ccr_reg <= 8'b00000000;
        end
        else if(intr) begin
            ccr_reg <= {ccr_reg[3:0], 4'b0000};
        end
        else if(rti) begin
            ccr_reg <= {4'b0000, ccr_reg[7:4]};
        end
        else begin
            if(flag_en) begin
                if(flag_mask[0]) begin
                    ccr_reg[0] <= Z;
                end 
                if(flag_mask[1]) begin 
                    ccr_reg[1] <= N;  
                end
                if(flag_mask[2]) begin
                    ccr_reg[2] <= C;  
                end
                if(flag_mask[3]) begin
                    ccr_reg[3] <= V;  
                end
        end
    end
    end

    assign CCR = ccr_reg[3:0];
endmodule
