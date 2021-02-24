
set project_name [lindex $argv 0]

set sources_file scripts/${project_name}.tcl

if {![file exists $sources_file]} {
    puts "Invalid project name!"
    exit
}

create_project -force ${project_name} ${project_name} -part xc7z020clg400-1
set_property board_part www.digilentinc.com:pynq-z1:part0:1.0 [current_project]

source $sources_file

# Add lib file
add_files -norecurse ../lib/EECS151.v

# Add constraint file
add_files -fileset constrs_1 -norecurse constr/z1top.xdc

update_compile_order -fileset sources_1

check_syntax

update_compile_order -fileset sources_1
