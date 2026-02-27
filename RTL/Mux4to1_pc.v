module mux4to1pc (
    input  wire [7:0] d0, d1, d2, d3, // 8-bit data inputs
    input  wire [1:0] sel,             // 2-bit select input
    input  wire  int_sig,             //  interrupt
    input  wire  rst,             
    output reg  [7:0] out                 // 8-bit output
);

    always @(*) begin
    if(int_sig| !rst)
    begin
        out = d3;    
    end
    else
    begin
        case (sel)
            2'b00: out = d0;
            2'b01: out = d1; 
            2'b10: out = d2; 
            2'b11: out = d3;
            default: out = 8'b00000000; // safetout default
        endcase    
    end
        
    end

endmodule