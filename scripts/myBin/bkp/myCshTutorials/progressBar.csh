#!/bin/sh

while ( 1 ) do
  x=grep -c "Building [a-z] ..." $1
  echo -ne '#####                     ($x%)\r'
  sleep 3
done

#sleep 3
#echo -ne '#############             (66%)\r'
#sleep 3
#echo -ne '#######################   (100%)\r'
