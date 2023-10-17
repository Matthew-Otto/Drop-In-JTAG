// `timescale 1ns/1ps
module testbench();

localparam CYCLES = 57;

integer i;
logic [CYCLES-1:0] tmsvector;
logic [CYCLES-1:0] tdivector;

logic tck, trst, tms, tdi, tdo;

logic a;
logic b;
logic c;
logic sum;
logic carry;


top dut (
    .tck(tck),
    .tdi(tdi),
    .tms(tms),
    .trst(trst),
    .tdo(tdo),
    .a(a),
    .b(b),
    .c(c),
    .sum(sum),
    .carry(carry)
);
    
// clock
initial begin
    tck = 1'b1;
    forever #5 tck = ~tck;
end



initial begin
    tms = 1'b1;
    trst = 1;
    tms = 1;
    #1 trst = 0;
    #1 trst = 1;

    tmsvector = 57'b11111101100_001_1100_00000000000000000000000000000000_1111111;
    tdivector = 57'b00000000000_100_0000000000000000000000000000000000000000000;

    for (i=CYCLES-1; i >= 0; i=i-1) begin
        
        @(negedge tck) begin

            tms <= tmsvector[i];
            tdi <= tdivector[i];
            
        end
    end

    //$finish;
    $stop;
end

endmodule // testbench
