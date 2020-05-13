#!/bin/csh

cd $1

#set waitTime=0
#while ( ! -e logs/dbg.vivado)
#  @ waitTime=10 + $waitTime
#  sleep 600
#end
#echo "Waited $waitTime minutes for opt vivado build to finish"

if ( ! -e logs/dbg.vivado) then
  echo "code not compilable. Exiting."
  exit
endif

source .init.sh
cd regression

rm -rf `find . -name "tp" -type d`
rm -f $1/logs/regressionResult.txt
rm -f $1/logs/reg.log
mv -f $1/logs/result.txt $1/logs/prevResult.txt

rdi regression --path=./src/dbgflows/vivado --level='[1-5]' --failure-rate=100 > $1/logs/reg.log

cut -d, -f1,3 lnx64.csv | grep -w FAIL | cut -d, -f2 > $1/logs/result.txt

echo "__________________________________________\n"
echo "New failures"
diff $1/logs/prevResult.txt $1/logs/result.txt | grep "^>"
echo "__________________________________________\n"
echo "New fixes"
diff $1/logs/prevResult.txt $1/logs/result.txt | grep "^<"
echo "__________________________________________\n"

set failCount = `cut -d, -f1 lnx64.csv | grep -v "^PASS" | grep -v "^STATUS" | wc -l`
echo "$failCount non passing regressions"

rm -f $1/logs/tmp
cut -d, -f1,3,4 lnx64.csv | grep "^FAIL" > $1/logs/tmp

set FS=","
echo "======    FAILED     ======"                              >  $1/logs/regressionResult.txt
awk -F $FS '{print $1 "\t" $3 "\t" $2}' $1/logs/tmp | sort -k2 >>  $1/logs/regressionResult.txt

rm -f $1/logs/tmp
cut -d, -f1,3,4 lnx64.csv | grep "^TIME" > $1/logs/tmp

echo "======   TIMED-OUT   ======"                             >> $1/logs/regressionResult.txt
awk -F $FS '{print $1 "\t" $3 "\t" $2}' $1/logs/tmp | sort -k2 >> $1/logs/regressionResult.txt


cat $1/logs/regressionResult.txt
rm -f $1/logs/tmp

