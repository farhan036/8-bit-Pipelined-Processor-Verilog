module Pc (
    input wire       clk,
    input wire       rst,
    input wire       pc_write,
    input wire [7:0] pc_next,
    output reg [7:0] pc_current
);

always @(posedge clk ) 
begin
    if(!rst)
    begin
        pc_current <= pc_next; 
    end
    else if(pc_write)
    begin
        pc_current<=pc_next;
    end
end
    
endmodule