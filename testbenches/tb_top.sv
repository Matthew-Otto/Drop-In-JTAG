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
logic [31:0] PCF;
logic [31:0] InstrF;
logic MemWriteM;
logic [31:0] DataAdrM;
logic [31:0] WriteDataM;
logic [31:0] ReadDataM;


top dut (
    .tck(tck),
    .tdi(tdi),
    .tms(tms),
    .trst(trst),
    .tdo(tdo),
    .sysclk(clk),
    .reset(reset),
    .PCF(PCF),
    .InstrF(InstrF),
    .MemWriteM(MemWriteM),
    .ALUResultM(DataAdrM),
    .WriteDataM(WriteDataM),
    .ReadDataM(ReadDataM)
);

imem imem (PCF, InstrF);
dmem dmem (clk, MemWriteM, DataAdrM, WriteDataM, ReadDataM);


initial begin
    string memfilename;
    memfilename = {"../RISCV_pipe/riscvtest/riscvtest.memfile"};
    $readmemh(memfilename, imem.RAM);
end


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
    if (MemWriteM) begin
        if(DataAdrM === 100 & WriteDataM === 25) begin
            $display("Simulation succeeded");
            $stop;
        end else if (DataAdrM !== 96) begin
            $display("Simulation failed");
            $stop;
        end
    end
end

endmodule // testbench
