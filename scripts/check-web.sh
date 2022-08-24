#!/bin/sh

check_web(){
    curl --silent --fail hello-world.embassy > /dev/null 2>&1
    echo $? > /root/health-web
}

while true ; do
    check_web
    sleep 60
done