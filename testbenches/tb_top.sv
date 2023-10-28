// `timescale 1ns/1ps
module testbench();

localparam CYCLES = 70;

integer i, cc, errors;
logic [CYCLES-1:0] tmsvector;
logic [CYCLES-1:0] tdivector;
logic [CYCLES-1:0] c_vec;
logic [CYCLES-1:0] tdovector;

logic tck, trst, tms, tdi, tdo;

logic a;
logic b;
logic c;
logic sum;
logic carry;
logic tdo_ref, tdo_sample;


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
    cc = 0;
    errors = 0;

    tms = 1'b1;
    trst = 1;
    tms = 1;

    a = 1;
    b = 1;
    //c = 0;

    #1 trst = 0;
    #1 trst = 1;

                //        SAMPLE / PRELOAD                  EXTEST         EXTEST
    tmsvector = 'b1101100_001_1100_00001_011100_00001_11100_001_1100_00001_1100_00001_1100_00001_11111;
    c_vec =     'b0000000_000_0000_01111_110001_10000_00000_000_0000_00000_1111_11111_1111_11111_11111;
    tdivector = 'b0000000_010_0000_00000_000000_01010_00000_110_0000_00111_0000_00010_0000_00000_00000;
    tdovector = 'b0000000_100_0000_10011_000000_11111_00000_100_0000_01011_0000_11111_0000_01111_00000;
    
    for (i=CYCLES-1; i >= 0; i=i-1) begin
        //cc <= cc + 1;
        
        @(negedge tck) begin
            tms <= tmsvector[i];
            tdi <= tdivector[i];
            c <= c_vec[i];

            if (tdo_sample != tdo_ref) begin
                $display("Error: incorrect value at TDO on cycle %d", cc);
                errors <= errors + 1;
            end
        end

        @(posedge tck) begin
            tdo_sample <= tdo;
            tdo_ref <= tdovector[i];
        end
    end

    $display("%d cycles completed with %d errors.", CYCLES, errors);

    //$finish;
    $stop;
end

endmodule // testbench
