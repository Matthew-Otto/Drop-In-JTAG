module tap_controller (
    input tck, trst, tms,
    output logic reset,
    output logic tdo_en,
    output logic shiftIR,
    output logic captureIR,
    output logic clockIR,
    output logic updateIR,
    output logic shiftDR,
    output logic captureDR,
    output logic clockDR,
    output logic updateDR,
    output logic updateDRstate,
    output logic select
);

logic [3:0] state;

localparam [3:0]
    exit2_dr     = 4'b0000,
    exit1_dr     = 4'b0001,
    shift_dr     = 4'b0010,
    pause_dr     = 4'b0011,
    select_ir    = 4'b0100,
    update_dr    = 4'b0101,
    capture_dr   = 4'b0110,
    select_dr    = 4'b0111,
    exit2_ir     = 4'b1000,
    exit1_ir     = 4'b1001,
    shift_ir     = 4'b1010,
    pause_ir     = 4'b1011,
    runtest_idle = 4'b1100,
    update_ir    = 4'b1101,
    capture_ir   = 4'b1110,
    tl_reset     = 4'b1111;



always @(posedge tck, negedge trst) begin
    if (~trst)
        state <= tl_reset;
    else begin
        case (state)
            tl_reset: begin
                reset <= 1'b1;
                select <= 1'b1;
                if (tms)
                    state <= tl_reset;
                else
                    state <= runtest_idle;
            end
            runtest_idle: begin
                reset <= 1'b0;
                if (tms)
                    state <= select_dr;
                else
                    state <= runtest_idle;
            end
            select_dr: begin
                select <= 1'b0;
                if (tms)
                    state <= select_ir;
                else
                    state <= capture_dr;
            end
            capture_dr: begin
                if (tms)
                    state <= exit1_dr;
                else
                    state <= shift_dr;
            end
            shift_dr: begin
                tdo_en <= 1'b1;
                if (tms)
                    state <= exit1_dr;
                else
                    state <= shift_dr;
            end
            exit1_dr: begin
                tdo_en <= 1'b0;
                if (tms)
                    state <= update_dr;
                else
                    state <= pause_dr;
            end
            pause_dr: begin
                if (tms)
                    state <= exit2_dr;
                else
                    state <= pause_dr;
            end
            exit2_dr: begin
                if (tms)
                    state <= update_dr;
                else
                    state <= shift_dr;
            end
            update_dr: begin
                if (tms)
                    state <= select_dr;
                else
                    state <= runtest_idle;
            end
            select_ir: begin
                if (tms)
                    state <= tl_reset;
                else
                    state <= capture_ir;
            end
            capture_ir: begin
                select <= 1'b1;
                if (tms)
                    state <= exit1_ir;
                else
                    state <= shift_ir;
            end
            shift_ir: begin
                tdo_en <= 1'b1;
                if (tms)
                    state <= exit1_ir;
                else
                    state <= shift_ir;
            end
            exit1_ir: begin
                tdo_en <= 1'b0;
                if (tms)
                    state <= update_ir;
                else
                    state <= pause_ir;
            end
            pause_ir: begin
                if (tms)
                    state <= exit2_ir;
                else
                    state <= pause_ir;
            end
            exit2_ir: begin
                if (tms)
                    state <= update_ir;
                else
                    state <= shift_ir;
            end
            update_ir: begin
                if (tms)
                    state <= select_dr;
                else
                    state <= runtest_idle;
            end
        endcase
    end // else
end

endmodule // tap_controller