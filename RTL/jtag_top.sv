module jtag_top #(parameter WIDTH=2) (
    input tck, tms, tdi, trst,
    output tdo
);

logic [3:0] out;

// WIDTH (of instruction register) == log2(<number of instructions>) + 2

localparam [WIDTH-1:0]


tap_controller fsm (.tck(tck),
                    .trst(trst),
                    .tms(tms),
                    .out(out));

instruction_register ir (.tck(tck), 
                         .tdi(tdi),
                         .trst(trst),
                         .enable(out[0]));

instruction_decode id ();


// input mux
always @* begin
    case (sel) begin

    endcase
end

// output mux

endmodule