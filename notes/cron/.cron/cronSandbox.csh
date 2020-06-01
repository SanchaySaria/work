#!/bin/csh

set staff="/proj/xhdhdstaff3/sanchayk"
cd $staff/
source ~/.staff3.csh

echo "--------------------------------------------------------------------------------\n"
echo "Sandbox : $RDI_ROOT"
cd $RDI_ROOT
echo "--------------------------------------------------------------------------------\n"
####SYNC####
~/.cron/syncSandbox.csh $PWD
echo "--------------------------------------------------------------------------------\n"
####BUILD####
~/.cron/buildSandbox.csh $PWD
echo "--------------------------------------------------------------------------------\n"
####TAGS####
~/.cron/tagSandbox force
echo "--------------------------------------------------------------------------------\n"
