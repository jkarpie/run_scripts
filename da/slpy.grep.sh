#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <task file> "
    exit 1
fi

TASKS=$1
QUEUE=ju-stand
QLIM=100

while [ `wc -l $TASKS | awk '{printf $1}'` -ne 0 ]; do
    #sleep 2m
    if [ `squeue -u $USER | grep $QUEUE | wc -l` -lt $QLIM ]; then

        dif=$(( $QLIM - `squeue -u $USER | grep $QUEUE | wc -l` ))

        for k in `seq 1 1 $dif`; do
            `head -1 $TASKS`
            sed -i -e '1,1d' $TASKS
        done

    fi
    sleep 20m
done
