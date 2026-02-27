module mux2to1 #(
    parameter WIDTH = 8   // Default width is 8 bits
)(
    input  wire [WIDTH-1:0] d0, d1, // Data inputs
    input  wire             sel,    // Select input
    output reg  [WIDTH-1:0] out       // Output
);

    always @(*) begin
        case (sel)
            1'b0: out = d0;
            1'b1: out = d1;
            default: out = {WIDTH{1'b0}}; // safetout default (all zeros)
        endcase
    end

endmodule