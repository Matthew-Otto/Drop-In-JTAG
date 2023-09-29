module jtag_top #(parameter WIDTH=2) (
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

logic [2^WIDTH-1:0] instructions;


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


instruction_register #(.WIDTH(WIDTH)) ir (
    .tck_ir(ir_clk), 
    .tdi(tdi_ir),
    .tl_reset(trst),
    .shiftIR(shiftIR),
    .captureIR(captureIR),
    .updateIR(updateIR),
    .tdo(tdo_ir),
    .instructions(instructions)
);


// Data Registers

bypass_register br (
    .tck(clk_dr),
    .tdi(tdi_dr),
    .tdo(tdo_br),
    .enable(instructions[0]) // BYPASS
    );
    

// BSR mux
assign bsr_tdi = |instructions[2:1] ? tdo_dr : 1'bx; // @ EXTEST or SAMPLE_PRELOAD
assign bsr_clk = clk_dr && |instructions[2:1];
assign bsr_update = updateDR || clk_dr && captureDR;

// TODO: make these global defines
localparam [2^WIDTH-1:0]
    D_BYPASS = 1'b1,
    D_SAMPLE_PRELOAD = 2'b10,
    D_EXTEST = 3'b100,
    D_IDCODE = 4'b1000,
    D_CLAMP = 5'b10000,
    D_IC_RESET = 6'b100000;

// DR demux
always_comb begin
    unique case (instructions)
        D_BYPASS          : tdo_dr <= tdo_br;
        D_SAMPLE_PRELOAD,
        D_EXTEST          : tdo_dr <= bsr_tdo;
        //D_IDCODE          : tdo_dr <= 
        //D_CLAMP           : tdo_dr <= 
        //D_IC_RESET        : tdo_dr <= 
    endcase
end


endmodule