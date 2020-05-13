#!/bin/csh
######################################################
# This script updates my_pr_project.zip files in     #
# all the regressions. When script finished, please  #
# check below files for details as mentioned         #
# 1. all_archive_files -> all regressions which      #
#                         script tried to update     #
# 2. post_archive -> regressions failing after       #
#                    generating my_pr_project.zip    #
######################################################

if (! $?ENVROOT) then
  echo "Please set ENVROOT and then launch again"
  exit -1
endif

if ($# == 0 || $# > 3) then
  echo "To generate project archive, read below help text on how to launch it\n"
  echo "This script takes three argument\n"
  echo "1st arg:if 0, Only error would be shown on screen(User can check tmp/pre_archive file for which archive could not be generated)"
  echo "       :if 1, Prints all the traces(Recommended)\n"
  echo "2nd arg:if 0, Only project archive will be generated"
  echo "       :if 1, Project archive will be generated and all affected regressions would be run."
  echo "              Also, user will be shown which regression are failing after project archive creation\n"
  echo "3rd arg:User will need to give a file containing regressions need to be worked on"
  echo "              File shall specify regression as below i.e. relative path in pr_flow directory"
  echo "              adv/user_config_l6"
  echo "              adv/grey_box_l6"
  echo "              newbie/persist_l6"
  echo "./createProjectArchive.csh 1 0 0 means print all logs"
  exit
endif

set print = 1
set regre = 0
set exclu = 0
set eFile = tmp

switch ($#)
  case 3:
    set exclu = 1
    if ( -e $3 ) then
      set eFile = $3
    else
      echo "3rd argument incorrect"
      exit
    endif
  case 2:
    if ($2 == 0 || $2 == 1) then
      set regre = $2
    else
      echo "2nd argument incorrect"
      exit
    endif
  case 1:
    if ($1 == 0 || $1 == 1) then
      set print = $1
    else
      echo "1st argument incorrect"
      exit
    endif
    breaksw
  default:
    breaksw
endsw

#####################################################
alias cadman 'eval `/tools/xint/prod/bin/cad.pl \!*`'
cadman add -t xilinx -v 2016.3_daily_latest -p ta
#####################################################

unalias cp
unalias cd
source $ENVROOT/g_cshrc

set pr_flow_dir = $SW_TESTS/features/project/test/pr_flow/
set util_dir = $pr_flow_dir/util
set out_dir = $util_dir/tmp

rm -rf $out_dir
mkdir -p $out_dir

if ($exclu == 1) then
  cp -f $eFile $out_dir/all_archive_files
  sed -i 's/_l6//g' $out_dir/all_archive_files
else
  find $PWD -name "my_pr_project.zip" | grep -v TEST_WORK_lnx64 > $out_dir/all_archive_files
endif

sed -i 's/_l6\/my_pr_project\.zip//g' $out_dir/all_archive_files
sed -i 's/.*pr_flow\///g' $out_dir/all_archive_files

if ($print == 1) then
  echo "Running regressions\n\n"
endif

cd $pr_flow_dir

rm -f reg.log
rdi regression --file=$out_dir/all_archive_files --level=\[1-2\] --keep-workarea > reg.log
cut -d, -f1,3,4 lnx64.csv | grep -v PASS > $out_dir/pre_archive

foreach regression ("`cat $out_dir/all_archive_files`")

  cd $pr_flow_dir
  if ($print == 1) then
    echo "\nWorking on $regression"
  endif

  set current_reg = `echo $regression | sed -s 's/.*\///g'`

  if ( -d $regression/TEST_WORK_lnx64 ) then
    cd $regression/TEST_WORK_lnx64

    set isPass = `grep -w $current_reg $pr_flow_dir/lnx64.csv | grep -c "^PASS"`

    if ( $isPass == 1 ) then
      rm -f logg
      rm -f `find my_pr_project -name "gold*.tcl" -type f`

      vivado -source $util_dir/createProjectArchive.tcl -mode batch > logg
      rm -f logg

      if ( -e ./my_pr_project.zip ) then
        set l6_reg_dir = "${regression}_l6"
        if ($print == 1) then
          echo "-->Generated my_pr_project.zip. Moving from $regression to $l6_reg_dir"
        endif

        rm -f $pr_flow_dir/$l6_reg_dir/my_pr_project.zip
        cp -f $pr_flow_dir/$regression/TEST_WORK_lnx64/my_pr_project.zip $pr_flow_dir/$l6_reg_dir
      else
        echo "-->my_pr_project.zip not found in $regression/TEST_WORK_lnx64"
      endif
    else
      echo "-->$current_reg failed"
    endif
  else
    echo "-->$current_reg did not run"
  endif

end

cd $pr_flow_dir
rm -rf `find $pr_flow_dir -name "TEST_WORK*"`
rm -f `find $pr_flow_dir -name "lnx64*"`

if ($regre == 1) then
  if ($print == 1) then
   echo "\nRunning regressions after generating new my_pr_project.zip"
  endif
  sed -i 's/$/_l6/g' $out_dir/all_archive_files
  rm -f reg.log
  rdi regression --file=$out_dir/all_archive_files --level=\[3-5\] > reg.log
  cut -d, -f1,3,4 lnx64.csv | grep -v STATUS | grep -v PASS > $out_dir/post_archive

  set num = `wc -l $out_dir/post_archive`
  if ($num > 0) then
    echo "Follwoing regression failed after creation of project archive\n"
	cat $out_dir/post_archive
  endif
endif
rm -f reg.log

echo "Finished"
