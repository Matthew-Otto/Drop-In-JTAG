module jtag_top #(parameter WIDTH=2) (
    input  tck, tms, tdi, trst,
    output tdo,

    output bsr_tdi,
    input bsr_tdo
    // maybe bsr clock??
);

logic [3:0] out;

// TAP controller logic
logic reset;
logic tdo_en;
logic shiftIR;
logic captureIR;
logic ir_clk;
logic updateIR;
logic shiftDR;
logic captureDR;
logic clockDR;
logic dr_clk;
logic updateDRstate;
logic select;

// intermediate wires
logic tdi_ir, tdi_dr;
logic tdo_ir, tdo_dr;
logic tdo_br;


spec_tap_controller fsm (
    .tck(tck),
    .trst(trst),
    .tms(tms),
    .reset(reset),
    .tdo_en(tdo_en),
    .shiftIR(shiftIR),
    .captureIR(captureIR),
    .clockIR(ir_clk),
    .updateIR(updateIR),
    .shiftDR(shiftDR),
    .captureDR(captureDR),
    .clockDR(dr_clk),
    .updateDR(updateDR),
    .updateDRstate(updateDRstate),
    .select(select)
);


// IR/DR input demux
assign {tdi_ir,tdi_dr} = select ? {tdi,1'bx} : {1'bx,tdi};
// IR/DR output mux
assign tdo = ~tdo_en ? 1'b0 : // TODO: check spec to see if this should be low or high when tdo_en is low
              select ? tdo_ir : tdo_dr;


instruction_register ir (
    .tck(ir_clk), 
    .tdi(tdi_ir),
    .tl_reset(trst),
    .tdo(tdo_ir)
);

// BSR mux
assign bsr_tdi = tdo_en ? tdo_dr : 1'bx; // TODO: change enable with the correct instruction signal

// Data Registers

bypass_register br (
    .tck(dr_tck),
    .tdi(tdi_dr),
    .tdo(tdo_br),
    .enable() // TODO
);



// DR demux
always_comb begin
    unique case (test)

    endcase
end


endmodule