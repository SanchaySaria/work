#!/bin/sh
x="foo"
if [ $x == "fo" ]
then
  echo "equal"
elif [ $x == "foo" ]
then
  echo "not equal"
fi
