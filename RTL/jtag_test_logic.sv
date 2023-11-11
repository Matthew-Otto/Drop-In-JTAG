module jtag_test_logic (
    `include "defines.sv"

    input  tck, tms, tdi, trst,
    output tdo,

    output bsr_tdi, bsr_clk, bsr_update,
    output bsr_shift, bsr_mode,
    input bsr_tdo
);

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
logic clk_dr;
logic updateDRstate;
logic select;

// instruction signals
logic [`INST_COUNT-1:0] instructions;
logic idcode;
logic sample_preload;
logic extest;
logic intest;
logic clamp;

// intermediate wires
logic tdi_ir, tdi_dr;
logic tdo_ir, tdo_dr;
logic tdo_br;
logic tdo_id;


tap_controller fsm (
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
    .clockDR(clk_dr),
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
    .tck_ir(ir_clk), 
    .tdi(tdi_ir),
    .tl_reset(reset),
    .captureIR(captureIR),
    .updateIR(updateIR),
    .tdo(tdo_ir),
    .instructions(instructions)
);


// synth tool should recognize these as one-hot signals
assign idcode         = (instructions == `D_IDCODE);
assign sample_preload = (instructions == `D_SAMPLE_PRELOAD);
assign extest         = (instructions == `D_EXTEST);
assign intest         = (instructions == `D_INTEST);
assign clamp          = (instructions == `D_CLAMP);


// Data Registers

bypass_register br (
    .clockDR(clk_dr),
    .tdi(tdi_dr),
    .shiftDR(shiftDR), // 10.1.1 (b)
    .tdo(tdo_br)
);


device_identification_register didr (
    .tdi(tdi_dr),
    .tdo(tdo_id),
    .clockDR(clk_dr || ~idcode),
    .captureDR(captureDR)
);


// BSR mux
logic bsr_enable;
assign bsr_enable = (sample_preload || extest || intest || clamp);

assign bsr_mode = (extest || intest || clamp);  // selects parallel output latches for BSR output

assign bsr_tdi = bsr_enable ? tdi_dr : 1'bx;
assign bsr_clk = clk_dr || ~bsr_enable;  // clock high when idle
assign bsr_update = updateDR || clk_dr && captureDR;  // 8.7.1 (f)
assign bsr_shift = shiftDR;


// DR demux
always_comb begin
    unique0 case (instructions)
        `D_BYPASS          : tdo_dr <= tdo_br;
        `D_IDCODE          : tdo_dr <= tdo_id;
        `D_SAMPLE_PRELOAD,
        `D_EXTEST,
        `D_INTEST,
        `D_CLAMP           : tdo_dr <= bsr_tdo;
        default            : tdo_dr <= 1'bx;
    endcase
end


endmodule