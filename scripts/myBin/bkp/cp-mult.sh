#!/bin/bash
dir="$1"
copiesRequired="$2"
for name in $(seq -w 1 $copiesRequired); do
    echo cp $dir/ ${dir}_$name/ -Rf
    cp $dir/ ${dir}_$name/ -Rf
done
