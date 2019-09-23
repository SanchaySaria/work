#!/bin/csh

set pr_flow = $RDI_ROOT/regression/features/project/test/pr_flow
set pr_flow_bkp = $RDI_ROOT/regression/features/project/test/pr_flow_bkp
cd $pr_flow

rm -f try.files
find $PWD -name "test.info" | grep -v -e "_l6" -e "TEST_WO" > try.files
sed -i 's/\/test.info//g' try.files

rm -f log.1
rdi regression --level=\[1-5\] --keep-workarea --file=try.files > log.1

rm -f all2recreate
grep "^PASS" lnx64.csv | cut -d, -f3 > all2recreate
echo "Failed in original regressions"
grep "^FAIL" lnx64.csv | cut -d, -f3
echo ""
echo ""
echo ""

#sed -i 's/$/\/TEST_WORK_lnx64/g' all2recreate

foreach this ("`cat all2recreate`")

  cd $this/TEST_WORK_lnx64

  rm -rf test

  cp -f $pr_flow/util/try.tcl .
  rm -f log
  /wrk/xhdhdnobkup2/rahulg/RDI_rahulg_prime/Rodin/HEAD/prep/rdi/vivado/bin/vivado -source try.tcl -mode batch > log
  
# cp -f $this/run.tcl $this/run.bkp
# cp -f $this/test.info $this/test.bkp

  cp -f $pr_flow/util/run.tcl $this/TEST_WORK_lnx64/test

  cp -f $this/test.info $this/TEST_WORK_lnx64/test/
  sed -i 's/LEVEL.*/LEVEL       : 8/g' $this/TEST_WORK_lnx64/test/test.info
# cp -f test.info $this
# cp -r test $this
  cp -f test/recreate.tcl $this

  echo "$this done"
  cd $pr_flow

end

cd $pr_flow/..
rm -rf pr_flow_bkp
cp -r pr_flow pr_flow_bkp
cd $pr_flow_bkp
sed -i 's/pr_flow/pr_flow_bkp/g' all2recreate

rm -f log.2
rdi regression --level=\[8\] --keep-workarea --file=all2recreate > log.2

cat all.summary
rm -f try.output
touch try.output

exit

foreach this ("`cat all2recreate`")
  cp -f $this/run.bkp $this/run.tcl
  cp -f $this/test.bkp $this/test.info

  set count = `find $this/TEST_WORK_lnx64 -name "*.dcp" | wc -l`
  if ( $count > 0 ) then
    echo ">>>>dcps generated $this" >> $try.output
  else
    echo "<<<<dcps not generated $this" >> $try.output
  endif
end
