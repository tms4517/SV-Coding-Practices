
set REPORT 1
set CHECKPOINT 1
set NETLIST 1

# AC701 (Artix-7)
#set part "xc7a200tfbg676-2"

# KC705 (Kintex-7)
#set part "xc7k325tffg900-2"

# KCU1500 (Kintex UltraScale)
#set part "xcku115-flvb2104-2-e"

# KCU116 (Kintex UltraScale+)
#set part "xcku5p-ffvb676-2-e"

# VC707 (Virtex-7)
#set part "xc7vx485tffg1157-1"
set part "xc7vx485tffg1761-2"

# VCU108 (Virtex UltraScale)
#set part "xcvu095-ffva2104-2-e"

# VCU118 (Virtex UltraScale+)
#set part "xcvu9p-flga2104-2L-e"

# ZC702 (Zynq)
#set part "xc7z020clg484-1"

# ZCU102 (Zynq UltraScale+)
#set part "xczu9eg-ffvb1156-2-i"

set projname "correlator"
set dirHdl "../../hdl"
set dirBuild "build"
set dirRpt "${dirBuild}/rpt"

file mkdir ${dirBuild}
file mkdir ${dirRpt}


# Untracked (non version-controlled) config should be in here.
if [ file exists untracked.tcl ] {
    source untracked.tcl
}

# Header files.
add_files \
  ${dirHdl}/asrt.svh \
  ${dirHdl}/dff.svh \
  ${dirHdl}/misc.svh \
  ${dirHdl}/usbSpec.svh
set_property is_global_include true [get_files -regexp .*\.svh]

# Generic HDL, used by other projects.
add_files \
  ${dirHdl}/fpgaReset.sv \
  ${dirHdl}/usbfsPktRx.sv \
  ${dirHdl}/usbfsPktTx.sv \
  ${dirHdl}/usbfsTxn.sv \
  ${dirHdl}/usbfsEndpRx.sv \
  ${dirHdl}/usbfsEndpTx.sv \
  ${dirHdl}/usbfsEndpCtrlSerial.sv \
  ${dirHdl}/usbfsSerial.sv \
  ${dirHdl}/fifo.sv \
  ${dirHdl}/fxcs.sv \
  ${dirHdl}/logdropWindow.sv \
  ${dirHdl}/mssbIdx.sv \
  ${dirHdl}/onehotIdx.sv \
  ${dirHdl}/prngXoshiro128p.sv \
  ${dirHdl}/strobe.sv \
  ${dirHdl}/pwm.sv \
  ${dirHdl}/dividerFsm.sv \
  ${dirHdl}/corrCountRect.sv \
  ${dirHdl}/corrCountLogdrop.sv

# Project-specific HDL.
add_files \
  pll48.sv \
  correlator.sv \
  bpReg.sv \
  top.sv

set_property file_type "Verilog Header" [get_files -regexp .*\.svh]
check_syntax

# Read in constraints.
read_xdc vc707.xdc

# Synthesize design.
synth_design -part ${part} -top top -include_dirs ${dirHdl}
if $CHECKPOINT {
  write_checkpoint -force ${dirBuild}/synth.dcp
}
if $REPORT {
  report_timing_summary   -file ${dirRpt}/synth_timing_summary.rpt
  report_power            -file ${dirRpt}/synth_power.rpt
}

# Optimize, place design.
opt_design
place_design
phys_opt_design
if $CHECKPOINT {
  write_checkpoint -force ${dirBuild}/place.dcp
}

# Route design.
route_design
if $CHECKPOINT {
  write_checkpoint -force ${dirBuild}/route.dcp
}
if $REPORT {
  report_timing -sort_by group -max_paths 100 -path_type summary \
                              -file ${dirRpt}/route_timing.rpt
  report_timing_summary       -file ${dirRpt}/route_timing_summary.rpt
  report_clock_utilization    -file ${dirRpt}/route_clock_utilization.rpt
  report_utilization          -file ${dirRpt}/route_utilization.rpt
  report_power                -file ${dirRpt}/route_power.rpt
  report_drc                  -file ${dirRpt}/route_drc.rpt
}

# Write out netlist and constraints.
if $NETLIST {
  write_verilog -force ${dirBuild}/netlist.v
  write_xdc -no_fixed_only -force ${dirBuild}/impl.v
}

# Write out a bitstream.
write_bitstream -force ${dirBuild}/${projname}.bit

