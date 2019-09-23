#/bin/sh

#set uName = `whoami`
ps -ef | grep rahulg | grep -v grep | awk '{print $2}' | tee killed
sed -i 's/^/kill -9 /g' killed
chmod +x ./killed
./killed

