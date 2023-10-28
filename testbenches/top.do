# Use this run.do file to run this example.
# Either bring up ModelSim and type the following at the "ModelSim>" prompt:
#     do run.do
# or, to run from a shell, type the following at the shell prompt:
#     vsim -do run.do -c
# (omit the "-c" to see the GUI while running from the shell)

onbreak {resume}

# create library
if [file exists work] {
    vdel -all
}
vlib work

# compile source files
vlog ../testbenches/tb_top.sv top.sv jtag_test_logic.sv 
vlog tap_controller.sv instruction_register.sv 
vlog bypass_register.sv bsr_cell.sv ../example_logic/full_adder.sv
vlog device_identification_register.sv

# start and run simulation
vsim +nowarn3829 -error 3015 -voptargs=+acc -l transcript.txt work.testbench

# view list
# view wave

-- display input and output signals as hexidecimal values
add wave -hex /testbench/dut/jtag/ir/instructions
add wave -hex /testbench/tck
add wave -hex /testbench/trst
add wave -hex /testbench/tms
add wave -hex /testbench/tdi
add wave -hex /testbench/tdo
add wave -hex /testbench/tdo_sample
add wave -hex /testbench/tdo_ref
add wave -hex /testbench/dut/jtag/bsr_tdo
add wave -hex /testbench/dut/jtag/tdo_en
add wave -hex /testbench/dut/jtag/select
add wave -hex /testbench/dut/jtag/tdo_ir
add wave -hex /testbench/dut/jtag/tdo_dr
add wave -hex /testbench/dut/bsr_update
add wave -hex /testbench/dut/bsr_clk
add wave -hex /testbench/dut/jtag/shiftDR

add wave -noupdate -divider -height 32 "TAP controller"
add wave -label state -hex /testbench/dut/jtag/fsm/state 
add wave -label tck -hex /testbench/dut/jtag/fsm/tck 
add wave -label trst -hex /testbench/dut/jtag/fsm/trst 
add wave -label tms -hex /testbench/dut/jtag/fsm/tms 
add wave -label reset -hex /testbench/dut/jtag/fsm/reset 
add wave -label tdo_en -hex /testbench/dut/jtag/fsm/tdo_en 
add wave -label shiftIR -hex /testbench/dut/jtag/fsm/shiftIR 
add wave -label captureIR -hex /testbench/dut/jtag/fsm/captureIR 
add wave -label clockIR -hex /testbench/dut/jtag/fsm/clockIR 
add wave -label updateIR -hex /testbench/dut/jtag/fsm/updateIR 
add wave -label shiftDR -hex /testbench/dut/jtag/fsm/shiftDR 
add wave -label captureDR -hex /testbench/dut/jtag/fsm/captureDR 
add wave -label clockDR -hex /testbench/dut/jtag/fsm/clockDR 
add wave -label updateDR -hex /testbench/dut/jtag/fsm/updateDR 
add wave -label updateDRstate -hex /testbench/dut/jtag/fsm/updateDRstate 
add wave -label select -hex /testbench/dut/jtag/fsm/select

add wave -noupdate -divider -height 32 "BSR"
add wave -label sequential_out[0] -hex {/testbench/dut/genblk1[0]/bsr_in/sequential_out}
add wave -label sequential_out[1] -hex {/testbench/dut/genblk1[1]/bsr_in/sequential_out}
add wave -label sequential_out[2] -hex {/testbench/dut/genblk1[2]/bsr_in/sequential_out}
add wave -label sequential_out[3] -hex {/testbench/dut/genblk2[3]/bsr_out/sequential_out}
add wave -label sequential_out[4] -hex {/testbench/dut/genblk2[4]/bsr_out/sequential_out}
add wave -label parallel_in[0] -hex {/testbench/dut/genblk1[0]/bsr_in/parallel_in}
add wave -label parallel_in[1] -hex {/testbench/dut/genblk1[1]/bsr_in/parallel_in}
add wave -label parallel_in[2] -hex {/testbench/dut/genblk1[2]/bsr_in/parallel_in}
add wave -label parallel_in[3] -hex {/testbench/dut/genblk2[3]/bsr_out/parallel_in}
add wave -label parallel_in[4] -hex {/testbench/dut/genblk2[4]/bsr_out/parallel_in}

add wave -noupdate -divider -height 32 "External I/O"
add wave -noupdate -radix hexadecimal -label a /testbench/a
add wave -noupdate -radix hexadecimal -label b /testbench/b
add wave -noupdate -radix hexadecimal -label c /testbench/c
add wave -noupdate -radix hexadecimal -label sum /testbench/sum
add wave -noupdate -radix hexadecimal -label carry /testbench/carry

add wave -noupdate -divider -height 32 "Example Logic (Internal)"
add wave -noupdate -radix hexadecimal -label a /testbench/dut/fa/a
add wave -noupdate -radix hexadecimal -label b /testbench/dut/fa/b
add wave -noupdate -radix hexadecimal -label carry_in /testbench/dut/fa/carry_in
add wave -noupdate -radix hexadecimal -label sum /testbench/dut/fa/sum
add wave -noupdate -radix hexadecimal -label carry_out /testbench/dut/fa/carry_out

add wave -noupdate -divider -height 32 "All Signals"
# Diplays All Signals recursively
add wave -hex -r /testbench/*
#add wave -noupdate -divider -height 32 "Title"


-- Set Wave Output Items 
TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ps} {200 ns}
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

-- Run the Simulation
run 10000000 ns