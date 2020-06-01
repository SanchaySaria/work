#!/bin/csh

cd $1
source .init.sh
rm -f logs/sync.log
#p4 sync ... > logs/sync.log
rdi p4-sync > logs/sync.log
echo "Sync Completed..."
