// `timescale 1ns/1ps
module testbench();

localparam CYCLES = 39;

integer i;
logic [CYCLES-1:0] tmsvector;
logic [CYCLES-1:0] tdivector;
logic [CYCLES-1:0] c_vec;

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

    a = 1;
    b = 1;
    //c = 0;

    #1 trst = 0;
    #1 trst = 1;

    tmsvector = 39'b1101100_001_1100_00001_011100_00001_111111111;
    tdivector = 39'b0000000_010_0000_00000_000000_00000_000000000;
    c_vec =     39'b0000000_000_0000_01111_110001_10000_000000000;

    for (i=CYCLES-1; i >= 0; i=i-1) begin
        
        @(negedge tck) begin

            tms <= tmsvector[i];
            tdi <= tdivector[i];
            c <= c_vec[i];
            
        end
    end

    //$finish;
    $stop;
end

endmodule // testbench
