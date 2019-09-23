source /wrk/xhdhdnobkup2/rahulg/RDI_rahulg_prime/Rodin/HEAD/data/XilinxTclStore/tclapp/xilinx/projutils/write_project_tcl.tcl

open_project my_pr_project/my_pr_project.xpr
exec rm -rf test
exec mkdir test
write_project_tcl -force test/recreate.tcl
close_project

cd test
source recreate.tcl
close_project
cd ..
