#!/bin/bash

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
TOPDIR=$(cd $DIR/.. && pwd)
FLOWS=$DIR/flows.log

source $DIR/logger.sh

# Makefile are not meant to run stuff in the background,
# so start everything from here...
INFO "starting POX"
$DIR/run_pox.sh &> $DIR/pox.log &
sleep 5
INFO "starting Mininet"
$DIR/run_mininet.sh $DIR/*.cmd & > $DIR/mininet.log &
sleep 5

rm -f $FLOWS
INFO "starting flow-dump"
for i in $(seq 1 150); do
    if [ -z "$(ps aux | grep run_mininet.sh | grep -v grep)" ]; then
	break
    fi

    echo "FLOW DUMP FW1 `date --rfc-3339=seconds`" >> $FLOWS
    sudo ovs-ofctl dump-flows fw1 >> $FLOWS
    echo "----------------------------------------------------------------------" >> $FLOWS
    echo "FLOW DUMP FW2 `date --rfc-3339=seconds`" >> $FLOWS
    sudo ovs-ofctl dump-flows fw2 >> $FLOWS
    echo "----------------------------------------------------------------------" >> $FLOWS
    sleep 2
done
