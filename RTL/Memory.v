module memory (
    input  wire        clk,
    input  wire        rst,            

    /**** Port A Instruction Fetch *****/
    input  wire [7:0]  addr_a,
    output wire  [7:0]  data_out_a,

    ///// Port B Data Memory /////
    input  wire [7:0]  addr_b,
    output wire  [7:0]  data_out_b,
    input  wire        we_b,             // write enable for port B
    input  wire [7:0]  write_data_b
);

    // memory 
    reg [7:0] mem [0:255];

   
    // initial begin
    //     $readmemh("program.hex", mem); // create program.hex for sim
    // end
integer i ;
    // Synchronous behavior: read/write on posedge clk
    always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
        begin
            for (i=128; i<=255;i=i+1)
                begin
                    mem[i] <= 'd0;
                end
        end
        else 
        begin
            if (we_b) 
            begin
                mem[addr_b] <= write_data_b;   // perform write
                // instruction fetch sees the new data if it's the same address
            end

        end
    end
assign data_out_b  = mem[addr_b];
assign data_out_a  = mem[addr_a];
endmodule
