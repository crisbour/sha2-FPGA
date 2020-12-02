set design "sha2_hcu_v1_0"
set top top
set device xcu280-fsvh2892-2L-e
set board xilinx.com:au280:part0:1.1
set proj_dir ./project
set repo_dri ./ip_repo
set project_constraints constraints.xdc

set test_name "test"


# Build project
create_project -name ${design} -force -dir "." -part ${device}
set_property board_part ${board} [current_project]
set_property top ${top} [current_fileset]
puts "Creating Project"

create_fileset -constrset -quiet constraints

read_verilog "./hdl/sha2_hcu.v"