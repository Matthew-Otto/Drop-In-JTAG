// `timescale 1ns/1ps
module testbench();

localparam CYCLES = 57;

logic [CYCLES-1:0] tms_vector;
logic [CYCLES-1:0] tdi_vector;
integer handle3;
integer desc3;

integer i;

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

// fileout
initial begin
    handle3 = $fopen("fsm.out");	
    desc3 = handle3;
end

/*
always begin
    @(posedge tck) begin
        $fdisplay(desc3, "uclk: %b | %b | %b || val: %b | data: %b", uclk, reset, rx, data_val, data);
    end
end
*/



initial begin
    tms = 1'b1;
    trst = 1;
    tms = 1;
    #1 trst = 0;
    #1 trst = 1;

                 // tlr   rt/idle     shiftdr      shiftdr        idle
    //testvector = 43'b111_0000000_0100_00000000_110_0000000_11111_000000;
    tms_vector = 57'b111111111011000100001000011000100001000010000110001111111;

    for (i=CYCLES-1; i >= 0; i=i-1) begin
        
        @(negedge tck) begin

            tms <= tms_vector[i];
            
        end
    end

    $finish;
end

endmodule // testbench
