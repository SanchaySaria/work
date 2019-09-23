#!/bin/sh

while (inotifywait -q -e modify filename) >/dev/null; do
    echo "filename is changed"
done
