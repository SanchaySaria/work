#!/bin/csh

cd $1
source .init.sh
cd src
###### Vivado ######
echo "--------Vivado opt build start--------"
rm -f ../logs/opt.vivado
rdi make product=vivado > ../logs/opt.vivado
if ($? == 0) then
  set warningVal = `grep -c "warning:" ../logs/opt.vivado`
  echo "Vivado build completed with $warningVal warnings\n"
else
  echo "Vivado opt build failed\n"
  exit
endif

#set sandbox = `echo $PWD | sed -e 's/.*RDI/RDI/g' | sed -s 's/\/.*//g'`
#set isVivadoDebugRunning = `ps -ef | grep sanchayk | grep totalview | grep $sandbox | grep -v grep | wc -l`

if ($isVivadoDebugRunning != 0) then
  echo "\nVivado debug session running, ignoring debug build"
else
  echo "--------Vivado dbg build start--------"
  rm -f ../logs/dbg.vivado
  rdi make product=vivado debug=yes > ../logs/dbg.vivado
  if ($? == 0) then
    set warningVal = `grep -c "warning:" ../logs/dbg.vivado`
    echo "Vivado debug build completed with $warningVal warnings\n"
  else
    echo "Vivado debug build failed\n"
  endif
endif

rm -f ../logs/prepuse.vivado
rdi make prepuse > ../logs/prepuse.vivado
if ($? != 0) then
  echo "Vivado prepuse failed\n"
endif
