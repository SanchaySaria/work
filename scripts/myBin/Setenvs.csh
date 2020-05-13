#!/bin/csh

set start = `date`

#/tools/baton/totalview/totalview/bin:
#/tools/batonroot/rodin/devkits/lnx32/lmx-6.0:
#/tools/baton/valgrind/3.12.0-gcc-6.20-rhel6-eval-128GB/bin:
#/devl/swtools
#/tools/xint/prod/bin
#/tools/xgs/perl/5.8.5/bin
#/usr/kerberos/bin
#/usr/X11R6/bin

setenv PATH ${PATH}:/home/rahulg/myBins

setenv LMXDIR /home/rahulg/
setenv SWTOOLS_PATH /devl/swtools
#source /group/xhdfarm/lsf/conf/cshrc.lsf

setenv VALGRIND_LIB /tools/baton/valgrind/3.12.0-gcc-6.20-rhel6-eval-128GB/lib/valgrind

setenv comparePRFlowGoldFiles 1

set end = `date`
#echo "$end - $start | .Setenvs.sh"
