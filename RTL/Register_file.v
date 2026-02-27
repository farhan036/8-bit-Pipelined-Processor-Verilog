module Register_file (
    input wire clk,              // Clock signal
    input wire rst,              // Active-low reset
    input wire wenabel,          // Write enable signal
    input wire SP_EN,
    input wire SP_OP,

    input wire [1:0] ra,         // Read address A  (selects R0..R3)
    input wire [1:0] rb,         // Read address B  (selects R0..R3)
    input wire [1:0] rd,         // Destination register index (for write)

    input wire [7:0] write_data, // Data to be written into R[rd]

    output wire [7:0] ra_date,   // Output data from register R[ra]
    output wire [7:0] rb_date    // Output data from register R[rb]
);

    
    reg [7:0] regs [0:3];
    
    always @(posedge clk or negedge rst) 
    begin
        if (!rst) begin
            // Reset all general-purpose registers
            regs[0] <= 8'd0;      // R0 = 0
            regs[1] <= 8'd0;      // R1 = 0
            regs[2] <= 8'd0;      // R2 = 0
            
            // Initialize SP (R3) to 255 according to project ISA
            regs[3] <= 8'd255;    // SP = 255
        end
        else begin
            if (wenabel) begin
            // Write operation: write_data → R[rd]
            regs[rd] <= write_data;
        end
            if(SP_EN) begin
            regs[3] <= (SP_OP == 1'b1)? regs[3] + 1 : regs[3] - 1;
        end
        end

        
    end

    // Note: Read is asynchronous → updates instantly with ra/rb changes.
    assign ra_date = regs[ra];
    assign rb_date = regs[rb];

endmodule
