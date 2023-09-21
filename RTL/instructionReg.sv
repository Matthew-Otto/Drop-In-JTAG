module jtag_instruction_register (
    input wire tap_control,          // Enable signal for capturing instruction
    input wire tdi,                  // JTAG Test Data Input
    output wire [1:0] instruction    // 2-bit instruction output
);

    reg [1:0] instruction_reg;  // 2-bit instruction register

    // Control the capture of instruction
    wire capture_instruction = tap_control;

    always_ff @(posedge capture_instruction or negedge tdi) begin
        if (capture_instruction) begin
            // Shift in the instruction data on the rising edge of tap_control
            instruction_reg <= {instruction_reg[0], tdi};
        end
    end

    localparam INSTRUCTION_BYPASS    = 2'b00; // Bypass instruction
    localparam INSTRUCTION_READ     = 2'b01; // Read data instruction
    localparam INSTRUCTION_WRITE    = 2'b10; // Write data instruction
    localparam INSTRUCTION_CUSTOM   = 2'b11; // Custom instruction

    // Decoder logic - determine 4 different instructions
    always_comb begin
        case (instruction_reg)
            INSTRUCTION_BYPASS: instruction = 2'b00;
            INSTRUCTION_READ: instruction = 2'b01;
            INSTRUCTION_WRITE: instruction = 2'b10; 
            INSTRUCTION_CUSTOM: instruction = 2'b11; 
            default: instruction = 2'bXX; // Undefined instruction
        endcase
    end

endmodule
