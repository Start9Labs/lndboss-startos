#!/bin/bash

DURATION=$(</dev/stdin)
if (($DURATION <= 5000)); then
    exit 60
else
    curl --silent --fail lndboss.embassy:8055 &>/dev/null
    RES=$?
    if [ $RES != 0 ] ; then
        echo "LNDBoss UI is unreachable" >&2
        exit 1
    fi
fi