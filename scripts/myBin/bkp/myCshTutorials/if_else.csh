#!/bin/csh

set goldFile = ""
if (-e gold_scripts.zip && -e gold_scripts_l6.zip) then
  echo "Big error"
  exit
else if (-e gold_scripts.zip) then
  set goldFile = "gold_scripts.zip"
else if (-e gold_scripts_l6.zip) then
  set goldFile = "gold_scripts_l6.zip"
else
  echo "Error"
  exit
endif
echo "$goldFile"
