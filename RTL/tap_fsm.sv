module tap_fsm (
    input clk,reset,tdi
);

logic [3:0] state, nextstate;

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

always @(posedge clk, posedge reset)
begin
    if(reset)
        state <= tl_reset;
    else begin
        state <= nextstate;
    end
end

always @(tdi) begin
    case (state)
        tl_reset:
            if (tdi)
                nextstate <= tl_reset;
            else
                nextstate <= runtest_idle;

        runtest_idle:
            if (tdi)
                nextstate <= select_dr;
            else
                nextstate <= runtest_idle;

        select_dr:
            if (tdi)
                nextstate <= select_ir;
            else
                nextstate <= capture_dr;
        
        capture_dr:
            if (tdi)
                nextstate <= exit1_dr;
            else
                nextstate <= shift_dr;

        shift_dr:
            if (tdi)
                nextstate <= exit1_dr;
            else
                nextstate <= shift_dr;

        exit1_dr:
            if (tdi)
                nextstate <= update_dr;
            else
                nextstate <= pause_dr;

        pause_dr:
            if (tdi)
                nextstate <= exit2_dr;
            else
                nextstate <= pause_dr;

        exit2_dr:
            if (tdi)
                nextstate <= update_dr;
            else
                nextstate <= shift_dr;

        update_dr:
            if (tdi)
                nextstate <= select_dr;
            else
                nextstate <= runtest_idle;

        select_ir:
            if (tdi)
                nextstate <= tl_reset;
            else
                nextstate <= capture_ir;

        capture_ir:
            if (tdi)
                nextstate <= exit1_ir;
            else
                nextstate <= shift_ir;

        shift_ir:
            if (tdi)
                nextstate <= exit1_ir;
            else
                nextstate <= shift_ir;

        exit1_ir:
            if (tdi)
                nextstate <= update_ir;
            else
                nextstate <= pause_ir;

        pause_ir:
            if (tdi)
                nextstate <= exit2_ir;
            else
                nextstate <= pause_ir;

        exit2_ir:
            if (tdi)
                nextstate <= update_ir;
            else
                nextstate <= shift_ir;

        update_ir:
            if (tdi)
                nextstate <= select_dr;
            else
                nextstate <= runtest_idle;
    endcase
end

endmodule // tap_fsm