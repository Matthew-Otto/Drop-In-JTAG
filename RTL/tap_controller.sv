module tap_controller (
    input tck, trst, tms,
    output [3:0] out
);

logic [3:0] state;

localparam [3:0]
    tl_reset     = 4'b0000,
    runtest_idle = 4'b0001,
    select_dr    = 4'b0010,
    capture_dr   = 4'b0011,
    shift_dr     = 4'b0100,
    exit1_dr     = 4'b0101,
    pause_dr     = 4'b0110,
    exit2_dr     = 4'b0111,
    update_dr    = 4'b1000,
    select_ir    = 4'b1001,
    capture_ir   = 4'b1010,
    shift_ir     = 4'b1011,
    exit1_ir     = 4'b1100,
    pause_ir     = 4'b1101,
    exit2_ir     = 4'b1110,
    update_ir    = 4'b1111;



always @(posedge tck, negedge trst) begin
    if (~trst)
        state <= tl_reset;
    else begin
        case (state)
            tl_reset:
                if (tms)
                    state <= tl_reset;
                else
                    state <= runtest_idle;

            runtest_idle:
                if (tms)
                    state <= select_dr;
                else
                    state <= runtest_idle;

            select_dr:
                if (tms)
                    state <= select_ir;
                else
                    state <= capture_dr;
            
            capture_dr:
                if (tms)
                    state <= exit1_dr;
                else
                    state <= shift_dr;

            shift_dr:
                if (tms)
                    state <= exit1_dr;
                else
                    state <= shift_dr;

            exit1_dr:
                if (tms)
                    state <= update_dr;
                else
                    state <= pause_dr;

            pause_dr:
                if (tms)
                    state <= exit2_dr;
                else
                    state <= pause_dr;

            exit2_dr:
                if (tms)
                    state <= update_dr;
                else
                    state <= shift_dr;

            update_dr:
                if (tms)
                    state <= select_dr;
                else
                    state <= runtest_idle;

            select_ir:
                if (tms)
                    state <= tl_reset;
                else
                    state <= capture_ir;

            capture_ir:
                if (tms)
                    state <= exit1_ir;
                else
                    state <= shift_ir;

            shift_ir:
                if (tms)
                    state <= exit1_ir;
                else
                    state <= shift_ir;

            exit1_ir:
                if (tms)
                    state <= update_ir;
                else
                    state <= pause_ir;

            pause_ir:
                if (tms)
                    state <= exit2_ir;
                else
                    state <= pause_ir;

            exit2_ir:
                if (tms)
                    state <= update_ir;
                else
                    state <= shift_ir;

            update_ir:
                if (tms)
                    state <= select_dr;
                else
                    state <= runtest_idle;
        endcase
    end // else
end

endmodule // tap_controller