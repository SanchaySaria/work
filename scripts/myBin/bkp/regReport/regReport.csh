#/bin/sh

cd $1
source .init.sh

cd regression/features/project/test/pr_flow

rdi regression --ignore-timeout true --level='[1-8]' --failure-rate 100.0
#cat all.summary | mutt -a lnx64.csv -s "PR Flow Regression Report" rahulg@xilinx.com
/home/fisusr/bin/rdi_report.pl -sds-src $PWD -mail "rahulg" -suite "PR Flows Regression" -out ~/myBins/regReport/

