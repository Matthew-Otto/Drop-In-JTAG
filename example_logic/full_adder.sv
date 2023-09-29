module full_adder (
    input a,b,carry_in,
    output sum, carry_out
);

assign {carry_out, sum} = a + b + carry_in;

endmodule // full_adder