// IEEE 1149.1 - 8.5.1 example boundary scan register

module bsr_cell (
    input clk, update, shift_dr, mode,
    input parallel_in, sequential_in,
    output logic parallel_out, sequential_out
);

logic state_in, state_out;

assign state_in = shift_dr ? sequential_in : parallel_in;

always @(clk)
    sequential_out <= state_in;

always @(update)
    state_out <= sequential_out;

assign parallel_out = mode ? state_out : parallel_in;

endmodule // bsr_cell