module instruction_decoder #(parameter WIDTH) (
    input [WIDTH-1:0] instruction_reg,
    output [2^WIDTH-1:0] instructions
);

// this module controls the muxes that route TDI through/around the various registers
// information about which modes we support will need to be avialable for inclusion in a BSDL file

// some modes are required by IEEE 1149.1

// this module may not need to be configurable
// The system designer will *always* provide one extest (boundary scan) register

localparam [5:0]
    // requried    
    BYPASS = 6'b000001,
    SAMPLE_PRELOAD = 6'b000010,
    EXTEST = 6'b000100,
    //recommended
    IDCODE = 6'b001000,
    CLAMP = 6'b010000,
    IC_RESET = 6'b100000;


always @* begin
    case (instruction_reg)
        BYPASS : begin
        end
        SAMPLE_PRELOAD : begin
        end
        EXTEST : begin
        end
        IDCODE : begin
        end
        CLAMP : begin
        end
        IC_RESET : begin
        end
    endcase
end


endmodule // instruction_decode