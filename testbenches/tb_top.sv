// `timescale 1ns/1ps
module testbench();

integer i, cc, errors;
logic [100:0] tmsvector;
logic [100:0] tdivector;
logic [100:0] c_vec;
logic [100:0] tdovector;

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
    
    tms = 1'b1;
    trst = 1;
    tms = 1;
    
    a = 1;
    b = 1;
    //c = 0;



    //// IDCODE ////////////////////////////////////////////////////////////////////////////

    cc = 0;
    errors = 0;
    tmsvector = 'b1101100_0001_1100_0000000000000000_0000000000000001_11111;
    c_vec =     'b0000000_0000_0000_0000000000000000_0000000000000000_00000;
    tdivector = 'b0000000_1000_0000_0000000000000000_0000000000000000_00000;
    tdovector = 'b0000000_1000_0000_1111011101111101_1011010101111011_00000;
    
    #1 trst = 0;
    #1 trst = 1;

    $display("Start SAMPLE/PRELOAD test");
    for (i=51; i >= 0; i=i-1) begin
        cc <= cc + 1;
        
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
    $display("IDCODE test completed %d cycles with %d errors.", cc+1, errors);


    //// SAMPLE/PRELOAD ////////////////////////////////////////////////////////////////////////////

    cc = 0;
    errors = 0;
    tmsvector = 'b1101100_0001_1100_00001_011100_00001;
    c_vec =     'b0000000_0000_0000_01111_110001_10000;
    tdivector = 'b0000000_0100_0000_00000_000000_01010;
    tdovector = 'b0000000_1000_0000_10011_000000_11111;
    
    #1 trst = 0;
    #1 trst = 1;

    $display("Start SAMPLE/PRELOAD test");
    for (i=29; i >= 0; i=i-1) begin
        cc <= cc + 1;
        
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
    $display("SAMPLE/PRELOAD test completed %d cycles with %d errors.", cc+1, errors);


    //// PRELOAD -> EXTEST ////////////////////////////////////////////////////////////////////

    cc = 0;
    errors = 0;
    tmsvector = 'b1101100_0001_1100_00001__11100_0001_1100_00001_1100_00001_1100_00001_11111;
    c_vec =     'b0000000_0000_0001_00000__00000_0000_0000_00000_1111_11111_1111_11111_11111;
    tdivector = 'b0000000_0100_0000_01010__00000_1100_0000_00111_0000_00010_0000_00000_00000;
    tdovector = 'b0000000_1000_0000_11111__00000_1000_0000_01011_0000_11111_0000_01111_00000;

    #1 trst = 0;
    #1 trst = 1;

    $display("Start EXTEST test");
    for (i=58; i >= 0; i=i-1) begin
        cc <= cc + 1;
        
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
    $display("EXTEST test completed %d cycles with %d errors.", cc+1, errors);

    //$finish;
    $stop;
end

endmodule // testbench
