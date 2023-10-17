module jtag_test_logic (
    `include "defines.sv"

    input  tck, tms, tdi, trst,
    output tdo,

    output bsr_tdi, bsr_clk, bsr_update,
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
logic clk_dr;
logic updateDRstate;
logic select;

// intermediate wires
logic tdi_ir, tdi_dr;
logic tdo_ir, tdo_dr;
logic tdo_br;

logic [`INST_COUNT-1:0] instructions;


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
    .shiftIR(shiftIR),
    .captureIR(captureIR),
    .updateIR(updateIR),
    .tdo(tdo_ir),
    .instructions(instructions)
);


// Data Registers

bypass_register br (
    .clockDR(clk_dr),
    .tdi(tdi_dr),
    .shiftDR(shiftDR), // 10.1.1 (b)
    .tdo(tdo_br)
);


// TODO: move to intermediate wires section
logic tdi_id;
logic tdo_id;

device_identification_register didr (
    .tdi(tdi_dr),
    .tdo(tdo_id),
    .clockDR(clk_dr),
    .captureDR(captureDR)
);
    

// BSR mux
assign bsr_tdi = |instructions[2:1] ? tdo_dr : 1'bx; // @ EXTEST or SAMPLE_PRELOAD
assign bsr_clk = clk_dr && |instructions[2:1];
assign bsr_update = updateDR || clk_dr && captureDR;


// DR demux
always_comb begin
    unique0 case (instructions)
        `D_BYPASS          : tdo_dr <= tdo_br;
        `D_IDCODE          : tdo_dr <= tdo_id;
        `D_SAMPLE_PRELOAD,
        `D_EXTEST          : tdo_dr <= bsr_tdo;
        //D_CLAMP           : tdo_dr <= 
        //D_IC_RESET        : tdo_dr <= 
    endcase
end


endmodule