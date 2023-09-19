// IEEE 1149.1 section 7
// 7.1: "The instruction shifted into the register is latched during the Update-IR TAPcontroller state."

// "The instruction shifted into the instruction register shall be latched such that changes in the effect of an
//      instruction occur only in the Update-IR and Test-Logic-Reset TAP controller states (see 7.2)."

// "The two least significant instruction register cells (i.e., those nearest the serial output) shall load a fixed
//      binary “01” pattern (the 1 into the least significant bit location) in the Capture-IR TAP controller state (see 7.2)""

// 7.2.1 e
// "After entry into the Test-Logic-Reset controller state as a result of the clocked operation of the TAP
//      controller, the IDCODE instruction (or, if there is no device identification register, the BYPASS instruction)
//      shall be latched onto the instruction register output on the falling edge of TCK"

module instruction_register #(parameter WIDTH) (
    input tck, tdi, tl_reset, ShiftIR, UpdateIR,
    output tdo,
    output logic [2^WIDTH-1:0] instructions
);

logic [WIDTH:0]     shift_reg;
logic [2^WIDTH-1:0] decoded;

assign shift_reg[0] = tdi;
assign tdo = shift_reg[WIDTH];


// Shift register
genvar i;
for (i = 0; i < WIDTH; i = i + 1) begin
    always @(posedge tck) begin
        shift_reg[i+1] <= shift_reg[i];
    end
end


// Instruction decoder
instruction_decoder #(.WIDTH(WIDTH)) irde (.instruction_reg(shift_reg[WIDTH:1]),
                                           .instructions(decoded));


// Instruction latch
always @(posedge UpdateIR or posedge tl_reset) begin
    if (tl_reset)
        // IEEE 1149.1 - 7.2.1.e: first instruction (BYPASS or IDCODE) is set to "on"
        instructions <= {{2^WIDTH-1{1'b0}},{1'b1}}; 
    else
        instructions <= decoded;
end


endmodule // instruction_register