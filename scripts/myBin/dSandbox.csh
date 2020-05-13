#!/bin/csh

set start = `date`

cd $1
source .init.sh
set root = ${PWD}
cd src

rm -f $root/logs/openFiles.txt
if ($# == 2) then
  cd $root/src/shared; rdi p4-status --check-modified > $root/logs/openFiles.txt;
  cd $root/src/components; rdi p4-status --check-modified >> $root/logs/openFiles.txt;
  cd $root/src/products/planAhead/tcltasks; rdi p4-status --check-modified >> $root/logs/openFiles.txt;
  cd $root/src/products/planAhead/ui; rdi p4-status --check-modified >> $root/logs/openFiles.txt;
  cd $2
else
  rdi p4-status --check-modified > $root/logs/openFiles.txt
endif

set modifiedFilesCount = `cat $root/logs/openFiles.txt | grep -c "\/\/Rodin"` 

if ( $modifiedFilesCount > 0) then
  echo "\nBelow files have been modified, include in workspace changes"
  cat $root/logs/openFiles.txt | grep "\/\/Rodin"
else
  echo "\nNo modified file found in workspace"
endif

set newFilesCount = `cat $root/logs/openFiles.txt | grep RDI_rahulg_ | grep -v "Scanning" | grep -v -e tags -e "cscope" -e "\.nfs" -e "vivado.*.txt" -e "hsi.*.txt" | wc -l` 
if ( $newFilesCount > 0 ) then
  echo "\nBelow files have been added, add them in workspace"
  cat $root/logs/openFiles.txt | grep RDI_rahulg_ | grep -v "Scanning" | grep -v -e tags -e "cscope" -e "\.nfs" -e "vivado.*.txt" -e "hsi.*.txt"
else
  echo "\nNo new file added in workspace"
  if ( $modifiedFilesCount == 0) then
    set end = `date`
    echo "\n$start\n$end"
    exit
  endif
endif

#make ready p4 edit commands for modified files
sed -i 's/#.*//g' $root/logs/openFiles.txt
sed -i 's/^ *//g' $root/logs/openFiles.txt

rm -f $root/logs/p4.*

cat $root/logs/openFiles.txt | grep "^\/[pw][r].*xhd.*RDI_rahulg_" | grep -v -e "tag" -e "cscope" -e "\.nfs" -e "vivado.txt" > $root/logs/p4.adds
cat $root/logs/openFiles.txt | grep "\/\/Rodin\/HEAD\/src\/" > $root/logs/p4.edits

set modifiedFileCount = `cat $root/logs/p4.edits | wc -l`
if ( $modifiedFileCount > 0 ) then
  sed -i 's/\/\/Rodin\/HEAD\/src\//p4 edit \/\/Rodin\/HEAD\/src\//g' $root/logs/p4.edits
  chmod +x $root/logs/p4.edits
  echo "sourcing p4.edits"
  source $root/logs/p4.edits
endif

set end = `date`
echo "\n$start\n$end"
