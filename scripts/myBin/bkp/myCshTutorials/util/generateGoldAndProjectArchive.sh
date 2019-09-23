#!/bin/csh
#***************************************************
# This script will 
# 1. first modify run.tcl of level 2 regression and then launch level 2 regressions with keep-workarea
# 2.  then checks all generated gold files and existing goldfiles for any mismatch
# 3.    if mismatch is found, it will pack new gold files in gold_scripts.zip
# 4. it then modified run.tcl of level 3-5 and launches level3-5 regressions with keep-workarea
# 5.  then checks all generated gold files and existing goldfiles for any mismatch
# 6.    if mismatch is found, it will pack new gold files in gold_scripts.zip
#***************************************************

if (! $?ENVROOT) then
  echo "Please set ENVROOT and then launch again, Also make sure SW_TESTS is set"
  exit -1
endif
if (! $?SW_TESTS) then
  echo "Please set SW_TESTS and then launch again"
  exit -1
endif

source $ENVROOT/g_cshrc

unalias cp
unalias cd

set pr_flow_dir = $SW_TESTS/features/project/test/pr_flow
set util_dir = $pr_flow_dir/util
set out_dir = $util_dir/tmp

rm -rf $out_dir
mkdir -p $out_dir

############################################
set printLog = 1
set runRegre = 0
set keepDiff = 1
set exclusiv = 0
set inputFile= $out_dir/reg_to_process

if ($# == 0 || $# > 4) then
  echo "To generate gold files, read below help text on how to launch this script\n"
  echo "This script takes four argument\n"
  echo "1st arg:if 0, Only error would be shown on screen(User can check $out_dir/pre_regression_status file for which archive could not be generated)"
  echo "       :if 1, Prints all the traces(Recommended)\n"
  echo "2nd arg:if 0, Only gold files archive will be updated"
  echo "       :if 1, Gold files will be updated and all affected regressions would be run."
  echo "              Also, user will be shown which regression are failing after gold file updated\n"
  echo "3rd arg:if 0, difference of gold files would not be maintained"
  echo "       :if 1, old and new gold files will be maintained in old_gold_scripts and new_gold_scripts directories inside regression directory"
  echo "4th arg:User will need to give a file containing regressions need to be worked on"
  echo "              File shall specify regression as below i.e. relative path in pr_flow directory"
  echo "              adv/user_config_l6"
  echo "              adv/grey_box_l6"
  echo "              newbie/persist_l6"
  echo "./createProjectArchive.csh 1 0 0 ./all_regression_to_be_worked_on means print all logs and process only what file has"
  exit
endif
############################################

if ($exclusiv == 1) then
  if(-e $inputFile) then
    cp $inputFile $out_dir/reg_to_process
  else
    echo "$inputFile does not exist"
    exit
  endif
else
  find $pr_flow_dir -name "test.info" -type f | grep -v TEST_WORK_ | xargs grep "LEVEL.*[1-5]" > $out_dir/reg_to_process
  sed -i 's/\/test.info//g' $out_dir/reg_to_process
endif

sed -i 's/.*pr_flow\///g' $out_dir/reg_to_process

cd $pr_flow_dir
foreach regression ( "`cat $out_dir/reg_to_process`" )

  set error = 0

  if (! -e $regression) then
    set error = 1
    echo "$regression does not exist"
  else if (! -e $regression/run.tcl) then
    set error = 1
    echo "$regression/run.tcl does not exist"
  endif

  if ($error == 1) then
    echo "Make sure all regression paths specified by user does exist and paths are relative to $pr_flow_dir directory"
    exit
  endif

end

foreach regression ( "`cat $out_dir/reg_to_process`" )

  cd $pr_flow_dir/$regression

  if($printLog == 1) then
    echo "-->Modifying $regression/run.tcl"
  endif

  cp -f run.tcl run.bkp
  sed -i 's/exec unzip.*gold_scripts\.zip/#exec unzip -o gold_scripts\.zip/g' run.tcl
  sed -i 's/#*exec cp /exec cp /g' run.tcl
  sed -i 's/.*compareSteps /#compareSteps /g' run.tcl

end

cd $pr_flow_dir
rdi regression --file=$out_dir/reg_to_process --level=\[1-5\] --keep-workarea > reg.log
cut -d, -f1,3,4 lnx64.csv > $out_dir/pre_regression_status

foreach regression ( "`cat $out_dir/reg_to_process`" )

  cd $pr_flow_dir/$regression
  if ($printLog == 1) then
    echo "->Working on $regression"
  endif

  set isComparisonPresent = `grep "compareSteps" run.tcl | grep -v "#.*compareSteps" | wc -l`
  if ( $isComparisonPresent == 0 ) then
    echo "->compareSteps not found in $regression/run.tcl. No need to generate gold_scripts.zip"
    continue;
  endif

  set regex = `echo $regression | sed -s 's/.*\///g'`
  set isPass = `grep -w "$regex" $out_dir/pre_regression_status | grep -c "^PASS"`
  if ($isPass == 0) then
    echo "->$regex failed in regression, gold files can not be generated. Manual action recommended."
    continue;
  endif

  if (! -d TEST_WORK_lnx64) then
    echo "->TEST_WORK_lnx64 not found. $regression did not run. Skipping."
    continue;
  endif

  cd TEST_WORK_lnx64

  set goldFileCount = `find my_pr_project/ -name "gold*.tcl" -type f | wc -l`
  if ( $goldFileCount == 0 ) then
    echo "No gold file generated for $regression, skipping"
    continue;
  endif

  if (-e gold_scripts.zip && ! -e gold_scripts_l6.zip) then
    set goldFile = "gold_scripts.zip"
  else if (-e gold_scripts_l6.zip && ! -e gold_scripts.zip) then
    set goldFile = "gold_scripts_l6.zip"
  else if (-e gold_scripts.zip && -e gold_scripts_l6.zip) then
    echo "In $regression, both gold_scripts_l6.zip and gold_scripts.zip present. Ambiguity hence skipping"
    continue;
  else
    set goldFile = "gold_scripts.zip"
    echo "gold_scripts zip could not be located in $regression. Creating new with name as $goldFile"
  endif

  if ($printLog == 1) then
    echo "->Creating new_gold_scripts.zip for $regression"
  endif
  rm -f $out_dir/tmp_gold.log
  zip new_gold_scripts.zip `find my_pr_project/ -name "gold*.tcl" -type f` > $out_dir/tmp_gold.log
  rm -f $out_dir/tmp_gold.log

  if ($printLog == 1) then
    echo "------>checking if gold files have any change in $regression"
  endif
  rm -rf $out_dir/new_gold_scripts
  rm -rf $out_dir/old_gold_scripts
  mkdir -p $out_dir/new_gold_scripts
  mkdir -p $out_dir/old_gold_scripts
  unzip -o $goldFile -d $out_dir/old_gold_scripts/
  unzip -o new_gold_scripts.zip -d $out_dir/new_gold_scripts/

  set isDiff = `diff -qrb $out_dir/new_gold_scripts $out_dir/old_gold_scripts | wc -l`
  if ($isDiff == 0) then
    echo "No change is gold files for $regression. Skipping."
    continue;
  endif

  if ($keepDiff == 1) then
    rm -rf $pr_flow_dir/$regression/new_gold_scripts
    rm -rf $pr_flow_dir/$regression/old_gold_scripts
    cp -r $out_dir/new_gold_scripts $pr_flow_dir/$regression/
    cp -r $out_dir/old_gold_scripts $pr_flow_dir/$regression/
  endif

  if($printLog == 1) then
    echo "------->$isDiff Gold scripts have changed"
    echo "------->Creating $goldFile in $regression"
  endif

# p4 edit $regression/gold_scripts.zip
  rm -f $pr_flow_dir/$regression/$goldFile
  cp -f new_gold_scripts.zip $pr_flow_dir/$regression/$goldFile

  cd $pr_flow_dir/$regression
  rm -f tqlQueries.out
  rm -rf TEST_WORK_lnx64*
  rm -f lnx64*

  if ($printLog == 1) then
    echo "->Recovering run.tcl to its earlier state"
  endif
  cp -f run.bkp run.tcl
  rm -f run.bkp

end

if ($runRegre == 1) then
  rm -f $out_dir/reg.log
  rdi regression --file=$out_dir/reg_to_process --level=\[1-5\] > $out_dir/reg.log
endif
rm -f $out_dir/reg.log

echo "Finished"
