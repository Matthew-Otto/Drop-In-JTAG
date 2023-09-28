// Rule e) of 8.1.1 also implies that there is no memory in the instruction decoder, that the decoding of the instruction
// register is strictly static (combinatorial).

// this module controls the muxes that route TDI through/around the various registers
// information about which modes we support will need to be avialable for inclusion in a BSDL file

// some modes are required by IEEE 1149.1

// this module may not need to be configurable
// The system designer will *always* provide one extest (boundary scan) register

module instruction_decoder #(parameter WIDTH) (
    input        [WIDTH-1:0]   instruction_reg,
    output logic [2^WIDTH-1:0] instructions
);

localparam INSTRUCTION_COUNT = 2^WIDTH;

// encoded
localparam [WIDTH-1:0]
    // requried    
    E_BYPASS = {INSTRUCTION_COUNT{1'b1}}, // 8.4.1 (a)
    E_SAMPLE_PRELOAD = 6'b000010,
    E_EXTEST = 6'b000100,
    //recommended
    E_IDCODE = 6'b001000,
    E_CLAMP = 6'b010000,
    E_IC_RESET = 6'b100000;

// decoded
localparam [INSTRUCTION_COUNT-1:0]
    D_BYPASS = 1'b1,
    D_SAMPLE_PRELOAD = 2'b10,
    D_EXTEST = 3'b100,
    D_IDCODE = 4'b1000,
    D_CLAMP = 5'b10000,
    D_IC_RESET = 6'b100000;


always_comb begin
    unique case (instruction_reg)
        E_BYPASS         : instructions <= D_BYPASS;
        E_SAMPLE_PRELOAD : instructions <= D_SAMPLE_PRELOAD;
        E_EXTEST         : instructions <= D_EXTEST;
        E_IDCODE         : instructions <= D_IDCODE;
        E_CLAMP          : instructions <= D_CLAMP;
        E_IC_RESET       : instructions <= D_IC_RESET;
    endcase
end


endmodule // instruction_decoder