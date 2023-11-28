// `timescale 1ns/1ps
module testbench();

integer i, cc, errors;
logic [100:0] tmsvector;
logic [100:0] tdivector;
logic [100:0] c_vec;
logic [100:0] tdovector;

logic tck, trst, tms, tdi, tdo;
logic tdo_ref, tdo_sample;
logic clk;
logic reset;


top dut (
    .tck(tck),
    .tdi(tdi),
    .tms(tms),
    .trst(trst),
    .tdo(tdo),
    .sysclk(clk),
    .reset(reset)
);


/*
initial begin
    string memfilename;
    memfilename = {"../RISCV_pipe/riscvtest/riscvtest.memfile"};
    $readmemh(memfilename, dut.imem.RAM);
end
*/


// clocks
initial begin
    clk = 1'b1;
    forever #1 clk = ~clk;
end

initial begin
    tck = 1'b1;
    forever #10 tck = ~tck;
end

// initialize test
initial begin
    reset <= 1; 
    trst <= 0;
    # 22;
    reset <= 0;
    trst <= 1;
end

// check results
always @(negedge clk) begin
    if (dut.MemWriteM) begin
        if(dut.DataAdrM === 100 & dut.WriteDataM === 25) begin
            $display("Simulation succeeded");
            $stop;
        end else if (dut.DataAdrM !== 96) begin
            $display("Simulation failed");
            $stop;
        end
    end
end

endmodule // testbench
