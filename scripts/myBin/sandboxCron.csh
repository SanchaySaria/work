#!/bin/csh

cd $1

####BUILD####
~/myBins/dSandbox.csh $PWD
####BUILD####

####SYNC####
~/myBins/syncSandbox.csh $PWD
####SYNC####

####BUILD####
~/myBins/buildSandbox.csh $PWD
####BUILD####

####TAGS####
~/myBins/tagSandbox force
####TAGS####
