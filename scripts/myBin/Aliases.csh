#!/bin/csh

set start = `date`

alias ls '\ls'
alias lsTime '\ls -lrt --time-style=full-iso'
alias psRahul 'ps -ef | grep rahulg | grep \!:1 | grep -v grep'
#ls -lrt | grep txt | grep -v grep | tail -n1 | awk '{print $9}'
alias cs 'setenv EDITOR gvim ; /usr/bin/cscope -d -p6'
alias p4v 'p4v &'
alias free 'free -g'

set primary = "/proj/xhdhdstaff2/rahulg/RDI_rahulg_code/Rodin/HEAD/src"
set testing = "/wrk/xhdhdnobkup2/rahulg/RDI_rahulg_test/Rodin/HEAD/src"
set myTestArea = "/wrk/xhdhdnobkup2/rahulg/testArea"

alias primarySandBox "cd $primary/../; source ./.init.sh;"
alias testingSandBox "cd $testing/../; source ./.init.sh;"
alias p4diff 'dSandbox.csh $RDI_ROOT $RDI_ROOT/src'
alias cadman 'eval `/tools/xint/prod/bin/cad.pl \!*`'
alias cadTo 'set version=\!:1; cadman add -t xilinx -v ${version}_daily_latest -p ta; which vivado | grep $version --color '
alias cadCont 'set version=\!:1; cadman add -t xilinx -v ${version}_continuous_latest -p ta; which vivado | grep $version --color '
alias cadInt 'set version=\!:1; cadman add -t xilinx -v ${version}_INT_daily_latest -p ta; which vivado | grep $version --color '
alias cadSp 'set version=\!:1; cadman add -t xilinx -v ${version} -p ta; which vivado | grep $version --color '
alias rusers 'ps -ef | awk '\''{print $1}'\'' | sort | uniq | grep -v -e "[0-9]" -e UID -e dbus -e root -e rpc -e rtkit -e nslcd -e ntp -e postfix'
alias rState "grep -e 'Building [spc][hro]' -e 'Finished build'"
alias rState "grep -e 'emake -C [spc][hro]' -e 'Finished build'"
alias createReview "/tools/batonroot/rodin/devkits/lnx64/fecru/crucible.py CE-SAP-IDT-XHD -s https://fisheye.xilinx.com -u rahulg -r shared"
#alias rState "grep -e 'emake -C /' -e 'emake -C [escp][hxor]' -e 'Finished build: '"
alias listFileTypes 'find . -type f | sed -s '\''s/.*\.//g'\'' | sort | uniq'
#alias tagSandbox 'tagSandbox dummy'

# LMX
#alias glinmx '/tools/batonroot/rodin/devkits/lnx32/lmx-6.0/glinmx'

set end = `date`
#echo "$end - $start | .Aliases.sh"
