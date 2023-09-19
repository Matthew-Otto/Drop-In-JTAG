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
    input tck, tdi, trst, enable,
    output tdo,
    output [WIDTH-1:0] mode
);

logic [WIDTH:0] link;

assign link[0] = tdi;
assign tdo = link[WIDTH];
assign mode = link[WIDTH:1];

genvar i;
for (i = 0; i < WIDTH; i = i + 1) begin
    always @(posedge tck or negedge trst) begin
        if (~trst)
            link[i+1] <= 0;
        else if (enable)
            link[i+1] <= link[i];
    end
end

endmodule // instruction_register