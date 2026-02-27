module interrupt_reg (
    input wire clk,
    input wire rst,
    input wire int_sig,
    output reg int_sig_reg
);
    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
        begin
            int_sig_reg <= 0;
        end
        else
            int_sig_reg <= int_sig;
    end
endmodule