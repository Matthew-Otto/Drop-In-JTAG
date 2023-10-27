// systemverilog module that implements our module jtag test logic
//  alongside example system logic and boundary scan register


module top (    
    // jtag logic
    (* mark_debug = "true" *) input tck,tdi,tms,trst,
    output tdo,

    // dut logic
    input a,b,c,
    output sum,carry
);

logic bsr_tdi, bsr_clk, bsr_update, bsr_shift, bsr_enable, bsr_mode, bsr_tdo;

logic [4:0] system_io;
logic [4:0] logic_io; // TODO update name to match spec
logic [5:0] bsr;

assign bsr[0] = bsr_tdi;
assign bsr_tdo = bsr[5];

// test logic ////////////////////////////////////////////////////

jtag_test_logic jtag (
    .tck(tck),
    .tms(tms),
    .tdi(tdi),
    .trst(trst),
    .tdo(tdo),
    .bsr_tdi(bsr_tdi),
    .bsr_clk(bsr_clk),
    .bsr_update(bsr_update),
    .bsr_shift(bsr_shift),
    .bsr_mode(bsr_mode),
    .bsr_tdo(bsr_tdo)
);

// boundary scan /////////////////////////////////////////////////

assign system_io[0] = a;
assign system_io[1] = b;
assign system_io[2] = c;
assign sum = system_io[3];
assign carry = system_io[4];

genvar i;
for (i=0; i<3; i=i+1) begin
    bsr_cell bsr_in (.clk(bsr_clk),
                     .update_dr(bsr_update),
                     .shift_dr(bsr_shift),
                     .mode(bsr_mode),
                     .parallel_in(system_io[i]),
                     .parallel_out(logic_io[i]),
                     .sequential_in(bsr[i]),
                     .sequential_out(bsr[i+1]));
end

for (i=3; i<5; i=i+1) begin
    bsr_cell bsr_out (.clk(bsr_clk),
                      .update_dr(bsr_update),
                      .shift_dr(bsr_shift),
                      .mode(bsr_mode),
                      .parallel_in(logic_io[i]),
                      .parallel_out(system_io[i]),
                      .sequential_in(bsr[i]),
                      .sequential_out(bsr[i+1]));
end

// dut logic /////////////////////////////////////////////////////

full_adder fa (.a(logic_io[0]),
               .b(logic_io[1]),
               .carry_in(logic_io[2]),
               .sum(logic_io[3]),
               .carry_out(logic_io[4]));

endmodule // top