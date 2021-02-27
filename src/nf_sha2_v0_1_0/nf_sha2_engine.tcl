
# Vivado Launch Script
#### Change design settings here #######
set design nf_sha2_engine
set top hash_engine
set device $::env(DEVICE)
set proj_dir ./ip_proj
set ip_version 0.10
set lib_name NetFPGA

#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property source_mgmt_mode All [current_project]  
set_property top ${top} [current_fileset]

# local IP repo
if { [info exists ::env(NFPLUS_FOLDER)] } {
    puts "Setting ip_rep to NFPLUS_FOLDER"
   set_property ip_repo_paths $::env(NFPLUS_FOLDER)  [current_fileset] 
} else {
    puts "Setting ip_repo to current directory"
    set_property ip_repo_paths [pwd]  [current_fileset]
}
update_ip_catalog

puts "nf_sha2_engine build"
# Project Constraints
#####################################
# Project Structure & IP Build
#####################################

read_verilog "./hdl/Choose.v"
read_verilog "./hdl/Majority.v"
read_verilog "./hdl/Sigma.v"
read_verilog "./hdl/big_endian.v"
read_verilog "./hdl/digest.v"
read_verilog "./hdl/hash_engine.v"
read_verilog "./hdl/hash_update.sv"
read_verilog "./hdl/hcu.sv"
read_verilog "./hdl/hcu_define.v"
read_verilog "./hdl/madd_32_64.v"
read_verilog "./hdl/madd_Kt.v"
read_verilog "./hdl/padder.v"
read_verilog "./hdl/wt_sigma_define.v"
read_verilog "./hdl/wt_unit.v"  
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Package IP
ipx::package_project

set_property name ${design} [ipx::current_core]
set_property library ${lib_name} [ipx::current_core]
set_property vendor_display_name {NetFPGA} [ipx::current_core]
set_property company_url {http://www.netfpga.org} [ipx::current_core]
set_property vendor {NetFPGA} [ipx::current_core]
set_property supported_families {{virtexuplus} {Production} {virtexuplushbm} {Production}} [ipx::current_core]
set_property taxonomy {{/NetFPGA/Generic}} [ipx::current_core]
set_property version ${ip_version} [ipx::current_core]
set_property display_name ${design} [ipx::current_core]
set_property description ${design} [ipx::current_core]


ipx::add_user_parameter {C_M_AXIS_DATA_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameters C_M_AXIS_DATA_WIDTH]
set_property display_name {C_M_AXIS_DATA_WIDTH} [ipx::get_user_parameters C_M_AXIS_DATA_WIDTH]
set_property value {512} [ipx::get_user_parameters C_M_AXIS_DATA_WIDTH]
set_property value_format {long} [ipx::get_user_parameters C_M_AXIS_DATA_WIDTH]

ipx::add_user_parameter {C_S_AXIS_DATA_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameters C_S_AXIS_DATA_WIDTH]
set_property display_name {C_S_AXIS_DATA_WIDTH} [ipx::get_user_parameters C_S_AXIS_DATA_WIDTH]
set_property value {512} [ipx::get_user_parameters C_S_AXIS_DATA_WIDTH]
set_property value_format {long} [ipx::get_user_parameters C_S_AXIS_DATA_WIDTH]
  
ipx::add_user_parameter {C_M_AXIS_TUSER_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameters C_M_AXIS_TUSER_WIDTH]
set_property display_name {C_M_AXIS_TUSER_WIDTH} [ipx::get_user_parameters C_M_AXIS_TUSER_WIDTH]
set_property value {128} [ipx::get_user_parameters C_M_AXIS_TUSER_WIDTH]
set_property value_format {long} [ipx::get_user_parameters C_M_AXIS_TUSER_WIDTH]

ipx::add_user_parameter {C_S_AXIS_TUSER_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameters C_S_AXIS_TUSER_WIDTH]
set_property display_name {C_S_AXIS_TUSER_WIDTH} [ipx::get_user_parameters C_S_AXIS_TUSER_WIDTH]
set_property value {128} [ipx::get_user_parameters C_S_AXIS_TUSER_WIDTH]
set_property value_format {long} [ipx::get_user_parameters C_S_AXIS_TUSER_WIDTH]

update_ip_catalog -rebuild 
ipx::infer_user_parameters [ipx::current_core]

ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
update_ip_catalog
close_project

file delete -force ${proj_dir} 