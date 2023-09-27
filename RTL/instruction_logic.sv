//BYPASS, SAMPLE, PRELOAD, EXTEST instruction implementation

//SOURCE - https://opencores.org/websvn/filedetails?repname=adv_debug_sys&path=%2Fadv_debug_sys%2Ftrunk%2FHardware%2Fjtag%2Ftap%2Frtl%2Fverilog%2Ftap_top.v

input   tck;      // JTAG test clock
input   trstn;     // JTAG test reset
input   tdi;      // JTAG test data input
input   bs_chain_tdo_i; // from Boundary Scan Chain
reg     test_logic_reset; //depends on state of FSM
reg     bypass_select;    //depends on current value in instruction register
reg     capture_dr;       //FSM state
reg     shift_dr;         //FSM state
reg     extest_select;              //flag to indicate extest instruction selected
reg     sample_preload_select;      //flag to indicate sample/preload instruction selected
reg     bypass_select;             //flag to indicate bypass instruction selected
output logic tdo;       //test data output

//SELECTING ACTIVE INSTRUCTION

always @ (latched_jtag_ir) //latched_jtag_ir from instruction reg
begin
    extest_select           = 1'b0;
    sample_preload_select   = 1'b0;
    bypass_select           = 1'b0;
 
    case(latched_jtag_ir)    /* synthesis parallel_case */ 
        `EXTEST:            extest_select           = 1'b1;    // External test
        `SAMPLE_PRELOAD:    sample_preload_select   = 1'b1;    // Sample preload
        `BYPASS:            bypass_select           = 1'b1;    // BYPASS
        default:            bypass_select           = 1'b1;    // BYPASS by default
    endcase
end

//BYPASS LOGIC

wire  bypassed_tdo;
reg   bypass_reg;  // This is a 1-bit register

always @ (posedge tck or negedge trstn)
begin
    if (trstn == 0) //if test reset pad from device is 0, bypass reg is 0
        bypass_reg <=  1'b0;
    else if (test_logic_reset == 1) //if test logic reset from FSM is 1, bypass reg is 0
        bypass_reg <=  1'b0;
    else if (bypass_select & capture_dr) //if bypass instruction is selected and capture_dr state is high, bypass reg is 0
        bypass_reg <= 1'b0;
    else if(bypass_select & shift_dr)//if bypass instruction is selected and FSM is in shift_dr state, bypass reg value becomes test data input from device
        bypass_reg <= tdi;
end

assign bypassed_tdo = bypass_reg;   // This is latched on a negative TCK edge after the output MUX

//END OF BYPASS LOGIC

//MUX TDO DATA OUTPUT

reg tdo_mux_o //acts as wire

always @ (shift_ir or instruction_tdo or latched_jtag_ir or bs_chain_tdo_i or bypassed_tdo) 
//if any of these values are high, mux tdo data out

begin
  if(shift_ir)
    tdo_mux_out = instruction_tdo; //from instruction reg
  else
    begin
      case(latched_jtag_ir)    // instruction selected
        `SAMPLE_PRELOAD:    tdo_mux_out = bs_chain_tdo_i;   // Sampling/Preloading boundary scan chain data output
        `EXTEST:            tdo_mux_out = bs_chain_tdo_i;   // External testing boundary scan chain data output
        default:            tdo_mux_out = bypassed_tdo;     // BYPASS instruction taking device input data directly
      endcase
    end
end

// TDO changes state at negative edge of Test clock
always @ (negedge tck)
begin
	tdo = tdo_mux_out;
end
