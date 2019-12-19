# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
set_msg_config  -ruleid {4}  -id {Synth 8-614}  -new_severity {CRITICAL WARNING} 
set_msg_config  -ruleid {5}  -id {DRC CFGBVS-1}  -suppress 
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir D:/Data/VHDLProjecten/1digPong/1digPong.cache/wt [current_project]
set_property parent.project_path D:/Data/VHDLProjecten/1digPong/1digPong.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
set_property ip_output_repo d:/Data/VHDLProjecten/1digPong/1digPong.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  D:/Data/VHDLProjecten/1digPong/1digPong.srcs/sources_1/new/AI.vhd
  D:/Data/VHDLProjecten/1digPong/1digPong.srcs/sources_1/imports/new/BcdTo7Seg1Digitale.vhd
  D:/Data/VHDLProjecten/1digPong/1digPong.srcs/sources_1/new/Sound.vhd
  D:/Data/VHDLProjecten/1digPong/1digPong.srcs/sources_1/new/displayScore.vhd
  D:/Data/VHDLProjecten/1digPong/1digPong.srcs/sources_1/new/pongSpeler.vhd
  D:/Data/VHDLProjecten/1digPong/1digPong.srcs/sources_1/imports/new/schermHorizontaal.vhd
  D:/Data/VHDLProjecten/1digPong/1digPong.srcs/sources_1/imports/new/schermVerticaal.vhd
  D:/Data/VHDLProjecten/1digPong/1digPong.srcs/sources_1/new/pongScherm.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc D:/Data/VHDLProjecten/1digPong/1digPong.srcs/constrs_1/new/pongConstraint.xdc
set_property used_in_implementation false [get_files D:/Data/VHDLProjecten/1digPong/1digPong.srcs/constrs_1/new/pongConstraint.xdc]

set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top pongScherm -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef pongScherm.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file pongScherm_utilization_synth.rpt -pb pongScherm_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
