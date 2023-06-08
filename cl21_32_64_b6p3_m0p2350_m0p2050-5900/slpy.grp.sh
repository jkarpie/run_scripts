#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <task file>"
    exit 1
fi

TASKS=$1
QLIM=10

while [ `wc -l $TASKS | awk '{printf $1}'` -ne 0 ]; do
    if [ `qstat -u $USER | wc -l` -lt $QLIM ]; then

        dif=$(( $QLIM - `qstat -u $USER | wc -l` ))

        for k in `seq 1 1 $dif`; do
            `head -1 $TASKS`
            sed -i -e '1,1d' $TASKS
            sleep 5s
        done

    fi
    sleep 20m
done
