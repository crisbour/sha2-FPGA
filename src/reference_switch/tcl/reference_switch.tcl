#
# Copyright (c) 2021 University of Cambridge
# All rights reserved.
#
# This software was developed by Stanford University and the University of Cambridge Computer Laboratory 
# under National Science Foundation under Grant No. CNS-0855268,
# the University of Cambridge Computer Laboratory under EPSRC INTERNET Project EP/H040536/1 and
# by the University of Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249 ("MRC2"), 
# as part of the DARPA MRC research programme.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  NetFPGA licenses this
# file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#

#### Change design settings here #######
set design $::env(NF_PROJECT_NAME) 
set top top
set device $::env(DEVICE)
set board  $::env(BOARD)
set board_name  $::env(BOARD_NAME)

set proj_dir ./project
set public_repo_dir $::env(NFPLUS_FOLDER)/hw/lib
set repo_dir ./ip_repo
set project_constraints "${public_repo_dir}/common/constraints/${board_name}_general.xdc"

set start_time [exec date +%s]
set_param general.maxThreads 8
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter max_loop_limit 200000"
#####################################
# Design Parameters on NF_DATAPATH
#####################################
set datapath_width_bit    512
set tuser_width_bit       128
set datapath_freq_mhz     250
set opl_bcam_size         16

set opl_cam_depth_bits    [expr int(log(${opl_bcam_size})/log(2))]
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device}
set_property board_part ${board} [current_project]
set_property source_mgmt_mode DisplayOnly [current_project]
set_property top ${top} [current_fileset]
if {[string match $board_name "au280"]} {
	set_property verilog_define { {BOARD_AU280} {au280} } [current_fileset]
	set board_param "AU280"
} elseif {[string match $board_name "au250"]} {
	set_property verilog_define { {BOARD_AU250} } [current_fileset]
	set board_param "AU250"
} elseif {[string match $board_name "au200"]} {
	set_property verilog_define { {BOARD_AU200} } [current_fileset]
	set board_param "AU200"
} elseif {[string match $board_name "vcu1525"]} {
	set_property verilog_define { {BOARD_VCU1525} } [current_fileset]
	set board_param "VCU1525"
}
set_property generic "C_NF_DATA_WIDTH=${datapath_width_bit} BOARD=\"${board_param}\"" [current_fileset]

puts "Creating User Datapath reference project"
#####################################
# set IP paths
#####################################
create_fileset -constrset -quiet constraints
file copy ${public_repo_dir}/ ${repo_dir}
set_property ip_repo_paths ${repo_dir} [current_fileset]
#####################################
# Project Constraints
#####################################
add_files -fileset constraints -norecurse ${project_constraints}
if {[string match $board_name "au280"]} {
	add_files -fileset constraints -norecurse ${public_repo_dir}/common/constraints/au280_timing.tcl
} else {
	add_files -fileset constraints -norecurse ${public_repo_dir}/common/constraints/au250_timing.tcl
}
set_property is_enabled true [get_files ${project_constraints}]
set_property constrset constraints [get_runs synth_1]
set_property constrset constraints [get_runs impl_1]
 
#####################################
# Project 
#####################################
update_ip_catalog
# SHA2
create_ip -name nf_sha2_engine -vendor NetFPGA -library NetFPGA -module_name nf_sha2_engine_ip
set_property CONFIG.C_M_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips nf_sha2_engine_ip]
set_property CONFIG.C_S_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips nf_sha2_engine_ip]
set_property generate_synth_checkpoint false [get_files nf_sha2_engine_ip.xci]
reset_target all [get_ips nf_sha2_engine_ip]
generate_target all [get_ips nf_sha2_engine_ip]
# OPL
create_ip -name switch_output_port_lookup -vendor NetFPGA -library NetFPGA -module_name switch_output_port_lookup_ip
set_property CONFIG.C_CAM_LUT_DEPTH_BITS ${opl_cam_depth_bits} [get_ips switch_output_port_lookup_ip]
set_property CONFIG.C_M_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips switch_output_port_lookup_ip]
set_property CONFIG.C_S_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips switch_output_port_lookup_ip]
set_property generate_synth_checkpoint false [get_files switch_output_port_lookup_ip.xci]
reset_target all [get_ips switch_output_port_lookup_ip]
generate_target all [get_ips switch_output_port_lookup_ip]
# input_arbiter
create_ip -name input_arbiter -vendor NetFPGA -library NetFPGA -module_name input_arbiter_ip
set_property CONFIG.C_M_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips input_arbiter_ip]
set_property CONFIG.C_S_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips input_arbiter_ip]
set_property generate_synth_checkpoint false [get_files input_arbiter_ip.xci]
reset_target all [get_ips input_arbiter_ip]
generate_target all [get_ips input_arbiter_ip]
# output_queues
create_ip -name output_queues -vendor NetFPGA -library NetFPGA -module_name output_queues_ip
set_property CONFIG.C_M_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips output_queues_ip]
set_property CONFIG.C_S_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips output_queues_ip]
set_property generate_synth_checkpoint false [get_files output_queues_ip.xci]
reset_target all [get_ips output_queues_ip]
generate_target all [get_ips output_queues_ip]

create_ip -name xilinx_shell -vendor xilinx -library xilinx -module_name xilinx_shell_ip
set_property CONFIG.MAX_PKT_LEN 1514 [get_ips xilinx_shell_ip]
set_property CONFIG.NUM_Q 2048 [get_ips xilinx_shell_ip]
set_property CONFIG.NUM_FUNC 2 [get_ips xilinx_shell_ip]
set_property CONFIG.NUM_CMAC 2 [get_ips xilinx_shell_ip]
set_property generate_synth_checkpoint false [get_files xilinx_shell_ip.xci]
reset_target all [get_ips xilinx_shell_ip]
generate_target all [get_ips xilinx_shell_ip]

create_ip -name nf_axis_converter -vendor NetFPGA -library NetFPGA -module_name nf_axis_converter_s_ip
set_property CONFIG.C_M_AXIS_DATA_WIDTH 512 [get_ips nf_axis_converter_s_ip]
set_property CONFIG.C_S_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips nf_axis_converter_s_ip]
set_property generate_synth_checkpoint false [get_files nf_axis_converter_s_ip.xci]
reset_target all [get_ips nf_axis_converter_s_ip]
generate_target all [get_ips nf_axis_converter_s_ip]

create_ip -name nf_axis_converter -vendor NetFPGA -library NetFPGA -module_name nf_axis_converter_m_ip
set_property CONFIG.C_M_AXIS_DATA_WIDTH ${datapath_width_bit} [get_ips nf_axis_converter_m_ip]
set_property CONFIG.C_S_AXIS_DATA_WIDTH 512 [get_ips nf_axis_converter_m_ip]
set_property generate_synth_checkpoint false [get_files nf_axis_converter_m_ip.xci]
reset_target all [get_ips nf_axis_converter_m_ip]
generate_target all [get_ips nf_axis_converter_m_ip]

create_ip -name axi_crossbar -vendor xilinx.com -library ip -module_name axi_crossbar_0
set_property -dict [list \
CONFIG.NUM_MI {3}                            \
CONFIG.PROTOCOL {AXI4LITE}                   \
CONFIG.CONNECTIVITY_MODE {SASD}              \
CONFIG.R_REGISTER {1}                        \
CONFIG.S00_WRITE_ACCEPTANCE {1}              \
CONFIG.S01_WRITE_ACCEPTANCE {1}              \
CONFIG.S02_WRITE_ACCEPTANCE {1}              \
CONFIG.S03_WRITE_ACCEPTANCE {1}              \
CONFIG.S04_WRITE_ACCEPTANCE {1}              \
CONFIG.S05_WRITE_ACCEPTANCE {1}              \
CONFIG.S06_WRITE_ACCEPTANCE {1}              \
CONFIG.S07_WRITE_ACCEPTANCE {1}              \
CONFIG.S08_WRITE_ACCEPTANCE {1}              \
CONFIG.S09_WRITE_ACCEPTANCE {1}              \
CONFIG.S10_WRITE_ACCEPTANCE {1}              \
CONFIG.S11_WRITE_ACCEPTANCE {1}              \
CONFIG.S12_WRITE_ACCEPTANCE {1}              \
CONFIG.S13_WRITE_ACCEPTANCE {1}              \
CONFIG.S14_WRITE_ACCEPTANCE {1}              \
CONFIG.S15_WRITE_ACCEPTANCE {1}              \
CONFIG.S00_READ_ACCEPTANCE {1}               \
CONFIG.S01_READ_ACCEPTANCE {1}               \
CONFIG.S02_READ_ACCEPTANCE {1}               \
CONFIG.S03_READ_ACCEPTANCE {1}               \
CONFIG.S04_READ_ACCEPTANCE {1}               \
CONFIG.S05_READ_ACCEPTANCE {1}               \
CONFIG.S06_READ_ACCEPTANCE {1}               \
CONFIG.S07_READ_ACCEPTANCE {1}               \
CONFIG.S08_READ_ACCEPTANCE {1}               \
CONFIG.S09_READ_ACCEPTANCE {1}               \
CONFIG.S10_READ_ACCEPTANCE {1}               \
CONFIG.S11_READ_ACCEPTANCE {1}               \
CONFIG.S12_READ_ACCEPTANCE {1}               \
CONFIG.S13_READ_ACCEPTANCE {1}               \
CONFIG.S14_READ_ACCEPTANCE {1}               \
CONFIG.S15_READ_ACCEPTANCE {1}               \
CONFIG.M00_WRITE_ISSUING {1}                 \
CONFIG.M01_WRITE_ISSUING {1}                 \
CONFIG.M02_WRITE_ISSUING {1}                 \
CONFIG.M03_WRITE_ISSUING {1}                 \
CONFIG.M04_WRITE_ISSUING {1}                 \
CONFIG.M05_WRITE_ISSUING {1}                 \
CONFIG.M06_WRITE_ISSUING {1}                 \
CONFIG.M07_WRITE_ISSUING {1}                 \
CONFIG.M08_WRITE_ISSUING {1}                 \
CONFIG.M09_WRITE_ISSUING {1}                 \
CONFIG.M10_WRITE_ISSUING {1}                 \
CONFIG.M11_WRITE_ISSUING {1}                 \
CONFIG.M12_WRITE_ISSUING {1}                 \
CONFIG.M13_WRITE_ISSUING {1}                 \
CONFIG.M14_WRITE_ISSUING {1}                 \
CONFIG.M15_WRITE_ISSUING {1}                 \
CONFIG.M00_READ_ISSUING {1}                  \
CONFIG.M01_READ_ISSUING {1}                  \
CONFIG.M02_READ_ISSUING {1}                  \
CONFIG.M03_READ_ISSUING {1}                  \
CONFIG.M04_READ_ISSUING {1}                  \
CONFIG.M05_READ_ISSUING {1}                  \
CONFIG.M06_READ_ISSUING {1}                  \
CONFIG.M07_READ_ISSUING {1}                  \
CONFIG.M08_READ_ISSUING {1}                  \
CONFIG.M09_READ_ISSUING {1}                  \
CONFIG.M10_READ_ISSUING {1}                  \
CONFIG.M11_READ_ISSUING {1}                  \
CONFIG.M12_READ_ISSUING {1}                  \
CONFIG.M13_READ_ISSUING {1}                  \
CONFIG.M14_READ_ISSUING {1}                  \
CONFIG.M15_READ_ISSUING {1}                  \
CONFIG.S00_SINGLE_THREAD {1}                 \
CONFIG.M00_A00_ADDR_WIDTH {16}               \
CONFIG.M01_A00_ADDR_WIDTH {16}               \
CONFIG.M02_A00_ADDR_WIDTH {16}               \
CONFIG.M00_A00_BASE_ADDR {0x0000000000000000}\
CONFIG.M01_A00_BASE_ADDR {0x0000000000010000}\
CONFIG.M02_A00_BASE_ADDR {0x0000000000020000}] [get_ips axi_crossbar_0]
set_property generate_synth_checkpoint false [get_files axi_crossbar_0.xci]
reset_target all [get_ips axi_crossbar_0]
generate_target all [get_ips axi_crossbar_0]

#Add a clock wizard
create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_1
if {[string match "${datapath_freq_mhz}" "200"]} {
#200MHz clock
	set_property -dict [list \
		CONFIG.PRIM_IN_FREQ {250.000} \
		CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
		CONFIG.CLKIN1_JITTER_PS {40.0} \
		CONFIG.MMCM_DIVCLK_DIVIDE {5} \
		CONFIG.MMCM_CLKFBOUT_MULT_F {24.000} \
		CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
		CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
		CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} \
		CONFIG.CLKOUT1_JITTER {119.392} \
		CONFIG.CLKOUT1_PHASE_ERROR {154.678}] [get_ips clk_wiz_1]
} elseif {[string match "${datapath_freq_mhz}" "250"]} {
#250MHz clock
	set_property -dict [list \
		CONFIG.PRIM_IN_FREQ {250.000} \
		CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {250.000} \
		CONFIG.CLKIN1_JITTER_PS {40.0} \
		CONFIG.MMCM_DIVCLK_DIVIDE {1} \
		CONFIG.MMCM_CLKFBOUT_MULT_F {4.750} \
		CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
		CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
		CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.750} \
		CONFIG.CLKOUT1_JITTER {85.152} \
		CONFIG.CLKOUT1_PHASE_ERROR {78.266}] [get_ips clk_wiz_1]
} elseif {[string match "${datapath_freq_mhz}" "260"]} {
#260MHz clock
	set_property -dict [list \
		CONFIG.PRIM_IN_FREQ {250.000} \
		CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {260.000} \
		CONFIG.CLKIN1_JITTER_PS {40.0} \
		CONFIG.MMCM_DIVCLK_DIVIDE {25} \
		CONFIG.MMCM_CLKFBOUT_MULT_F {120.250} \
		CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
		CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
		CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.625} \
		CONFIG.CLKOUT1_JITTER {182.359} \
		CONFIG.CLKOUT1_PHASE_ERROR {351.991}] [get_ips clk_wiz_10]
} elseif {[string match "${datapath_freq_mhz}" "280"]} {
#280MHz clock
	set_property -dict [list \
		CONFIG.PRIM_IN_FREQ {250.000} \
		CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {280.000} \
		CONFIG.CLKIN1_JITTER_PS {40.0} \
		CONFIG.MMCM_DIVCLK_DIVIDE {25} \
		CONFIG.MMCM_CLKFBOUT_MULT_F {119.000} \
		CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
		CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
		CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.250} \
		CONFIG.CLKOUT1_JITTER {183.720} \
		CONFIG.CLKOUT1_PHASE_ERROR {357.524}] [get_ips clk_wiz_1]
} elseif {[string match "${datapath_freq_mhz}" "300"]} {
#300MHz clock
	set_property -dict [list \
		CONFIG.PRIM_IN_FREQ {250.000} \
		CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {300.000} \
		CONFIG.CLKIN1_JITTER_PS {40.0} \
		CONFIG.MMCM_DIVCLK_DIVIDE {5} \
		CONFIG.MMCM_CLKFBOUT_MULT_F {24.000} \
		CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
		CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
		CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.000} \
		CONFIG.CLKOUT1_JITTER {111.430} \
		CONFIG.CLKOUT1_PHASE_ERROR {154.678}] [get_ips clk_wiz_1]
} elseif {[string match "${datapath_freq_mhz}" "320"]} {
#320MHz clock
	set_property -dict [list \
		CONFIG.PRIM_IN_FREQ {250.000} \
		CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {320.000} \
		CONFIG.CLKIN1_JITTER_PS {40.0} \
		CONFIG.MMCM_DIVCLK_DIVIDE {5} \
		CONFIG.MMCM_CLKFBOUT_MULT_F {24.000} \
		CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
		CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
		CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.750} \
		CONFIG.CLKOUT1_JITTER {110.215} \
		CONFIG.CLKOUT1_PHASE_ERROR {154.678}] [get_ips clk_wiz_1]
} else {
	puts "Error: the specified clock is error"
	exit -1
}
#340MHz clock
#set_property -dict [list \
#	CONFIG.PRIM_IN_FREQ {250.000} \
#	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {340.000} \
#	CONFIG.CLKIN1_JITTER_PS {40.0} \
#	CONFIG.MMCM_DIVCLK_DIVIDE {25} \
#	CONFIG.MMCM_CLKFBOUT_MULT_F {119.000} \
#	CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
#	CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
#	CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.500} \
#	CONFIG.CLKOUT1_JITTER {179.007} \
#	CONFIG.CLKOUT1_PHASE_ERROR {357.524}] [get_ips clk_wiz_1]
#360MHz clock
#set_property -dict [list \
#	CONFIG.PRIM_IN_FREQ {250.000} \
#	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {360.000} \
#	CONFIG.CLKIN1_JITTER_PS {40.0} \
#	CONFIG.MMCM_DIVCLK_DIVIDE {25} \
#	CONFIG.MMCM_CLKFBOUT_MULT_F {121.500} \
#	CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
#	CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
#	CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.375} \
#	CONFIG.CLKOUT1_JITTER {171.636} \
#	CONFIG.CLKOUT1_PHASE_ERROR {346.603}] [get_ips clk_wiz_1]
#380MHz clock
#set_property -dict [list \
#	CONFIG.PRIM_IN_FREQ {250.000} \
#	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {380.000} \
#	CONFIG.CLKIN1_JITTER_PS {40.0} \
#	CONFIG.MMCM_DIVCLK_DIVIDE {1} \
#	CONFIG.MMCM_CLKFBOUT_MULT_F {4.750} \
#	CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
#	CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
#	CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.125} \
#	CONFIG.CLKOUT1_JITTER {78.466} \
#	CONFIG.CLKOUT1_PHASE_ERROR {78.266}] [get_ips clk_wiz_1]
#400MHz clock
#set_property -dict [list \
#	CONFIG.PRIM_IN_FREQ {250.000} \
#	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {400.000} \
#	CONFIG.CLKIN1_JITTER_PS {40.0} \
#	CONFIG.MMCM_DIVCLK_DIVIDE {5} \
#	CONFIG.MMCM_CLKFBOUT_MULT_F {24.000} \
#	CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
#	CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
#	CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.000} \
#	CONFIG.CLKOUT1_JITTER {106.119} \
#	CONFIG.CLKOUT1_PHASE_ERROR {154.678}] [get_ips clk_wiz_1]
set_property generate_synth_checkpoint false [get_files clk_wiz_1.xci]
reset_target all [get_ips clk_wiz_1]
generate_target all [get_ips clk_wiz_1]

#set ip_name ila_0
#set proj  project
#create_ip -name ila -vendor xilinx.com -library ip -module_name $ip_name -dir $proj
#set_property -dict [list \
#	CONFIG.C_PROBE0_WIDTH  {512} \
#	CONFIG.C_PROBE1_WIDTH  {64} \
#	CONFIG.C_PROBE2_WIDTH  {128} \
#	CONFIG.C_PROBE3_WIDTH  {1} \
#	CONFIG.C_PROBE4_WIDTH  {1} \
#	CONFIG.C_PROBE5_WIDTH  {1} \
#	CONFIG.C_PROBE6_WIDTH  {512} \
#	CONFIG.C_PROBE7_WIDTH  {64} \
#	CONFIG.C_PROBE8_WIDTH  {128} \
#	CONFIG.C_PROBE9_WIDTH  {1} \
#	CONFIG.C_PROBE10_WIDTH {1} \
#	CONFIG.C_NUM_OF_PROBES {11}] [get_ips $ip_name]
#generate_target all [get_files  $ip_name.xci]

read_verilog -sv "${public_repo_dir}/xilinx/cmac_sub_v1_0_0/hdl/axi_stream_packet_fifo.sv"
read_verilog -sv "${public_repo_dir}/xilinx/cmac_sub_v1_0_0/hdl/axi_stream_register_slice.sv"
read_verilog     "./hdl/nf_datapath.v"
read_verilog -sv "${public_repo_dir}/common/hdl/xilinx_wrapper.sv"
read_verilog     "${public_repo_dir}/common/hdl/top.v"

#Setting Synthesis options
create_run -flow {Vivado Synthesis 2019} synth
set_property write_incremental_synth_checkpoint true [get_runs synth_1]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs synth_1]
#Setting Implementation options
create_run impl -parent_run synth -flow {Vivado Implementation 2019} 
set_property strategy Performance_Explore [get_runs impl_1]
set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
#set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
#set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
#set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AlternateFlowWithRetiming [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE ExploreWithHoldFix [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.is_enabled true [get_runs impl_1]

set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
# The following implementation options will increase runtime, but get the best timing results
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
launch_runs synth
wait_on_run synth
launch_runs impl_1
wait_on_run impl_1
open_checkpoint project/${design}.runs/impl_1/top_postroute_physopt.dcp

if {![file exists "../bitfiles"]} {
	file mkdir "../bitfiles"
}
write_bitstream -force ../bitfiles/${design}_${board_name}.bit
#write_debug_probes -file ../bitfiles/${design}_${board_name}.ltx -force

# -- For Report --
set end_time [exec date +%s]
set elapsed_time [expr ${end_time} - ${start_time}]
if {[catch {exec grep -A 4 "VIOLAT" project/${design}.runs/impl_1/top_timing_summary_postroute_physopted.rpt} timing_report_data]} {
	set timing_report "Met"
	set timing_report_data ""
} else {
	set timing_report "VIOLATED"
}
puts " --- Report : ${design} for ${board_name} --- "
puts "    Synth time    : ${elapsed_time}"
puts "    Timing Closure: ${timing_report}"
puts "${timing_report_data}"

exit

