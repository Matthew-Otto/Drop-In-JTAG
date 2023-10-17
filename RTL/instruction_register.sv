// IEEE 1149.1 section 7
// 7.1: "The instruction shifted into the register is latched during the Update-IR TAPcontroller state."

// "The instruction shifted into the instruction register shall be latched such that changes in the effect of an
//      instruction occur only in the Update-IR and Test-Logic-Reset TAP controller states (see 7.2)."

// "The two least significant instruction register cells (i.e., those nearest the serial output) shall load a fixed
//      binary “01” pattern (the 1 into the least significant bit location) in the Capture-IR TAP controller state (see 7.2)""

// 7.2.1
// @Capture-IR Load 01 into bits closest to TDO and, optionally, design-specific
// data or fixed values into other bits closer to TDI

// 7.2.1 e
// "After entry into the Test-Logic-Reset controller state as a result of the clocked operation of the TAP
//      controller, the IDCODE instruction (or, if there is no device identification register, the BYPASS instruction)
//      shall be latched onto the instruction register output on the falling edge of TCK"

// 8.1.1 e
// All test logic responses to an active instruction shall terminate when a different instruction is transferred to
// the parallel output of the instruction register (i.e., in the Update-IR or Test-Logic-Reset controller states)
// unless the new instruction supports the same test logic response.


module instruction_register (
    `include "defines.sv"

    input                          tck_ir,
    input                          tdi,
    input                          tl_reset, 
    input                          captureIR,
    input                          shiftIR,
    input                          updateIR,
    output                         tdo,
    output logic [`INST_COUNT-1:0] instructions
);

logic [`INST_REG_WIDTH:0]  shift_reg;
logic [`INST_COUNT-1:0]    decoded;

assign shift_reg[0] = tdi;
assign tdo = shift_reg[`INST_REG_WIDTH];


// Shift register
genvar i;
for (i = 0; i < `INST_REG_WIDTH; i = i + 1) begin
    always @(posedge tck_ir) begin
        shift_reg[i+1] <= shift_reg[i];
    end
end


// Instruction decoder\

//Rule e) of 8.1.1 also implies that there is no memory in the instruction decoder, that the decoding of the instruction
// register is strictly static (combinatorial).
always_comb begin
    unique case (shift_reg[`INST_REG_WIDTH:1])
        `E_BYPASS         : decoded <= `D_BYPASS;
        `E_SAMPLE_PRELOAD : decoded <= `D_SAMPLE_PRELOAD;
        `E_EXTEST         : decoded <= `D_EXTEST;
        `E_IDCODE         : decoded <= `D_IDCODE;
        `E_CLAMP          : decoded <= `D_CLAMP;
        `E_IC_RESET       : decoded <= `D_IC_RESET;
    endcase
end



// Instruction latch
always @(negedge tck_ir or posedge tl_reset) begin
    if (tl_reset)
        // IEEE 1149.1 - 7.2.1.e: first instruction (BYPASS or IDCODE) is set to "on"
        instructions <= `D_IDCODE; 
    else if (updateIR)
        instructions <= decoded;
end


endmodule // instruction_register