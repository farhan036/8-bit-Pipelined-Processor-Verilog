module OUT (
    input wire       clk,
    input wire       rst,
    input wire       en,
    input wire [7:0] in,
    output reg [7:0] out
);

    always @(posedge clk or negedge rst ) 
    begin
        if(!rst)
        begin
            out <= 8'd0; 
        end
        else if(en)
        begin
            out <= in;
        end
    end
        
endmodule