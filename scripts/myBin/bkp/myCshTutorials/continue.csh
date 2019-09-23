#!/bin/csh
foreach number (one two three exit four)
  if ($number == exit) then
    echo reached an exit
    continue
  endif
  echo $number
end
