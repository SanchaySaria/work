#!/bin/csh

if (! -e continue.csh) then
  echo "file does not exist"
else if (-e file.c) then
  ls file.c
endif
