#!/bin/bash
#IK2220 SDN Phase 1 Test runner script

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
TOPDIR=$(cd $DIR/.. && pwd)
FLOWS=$DIR/flows.log

source $DIR/logger.sh

# Kill child processes on user interrupt.
user_abort () {
    INFO "Aborting due to user interrupt..."
    sudo killall python &>/dev/null
    exit 0
}
trap user_abort SIGINT

# Makefile are not meant to run stuff in the background,
# so start everything from here...
INFO "Starting POX..."
$DIR/run_pox.sh &> $DIR/pox.log &
sleep 5

INFO "Starting Mininet..."
$DIR/run_mininet.sh $DIR/*.cmd 2>&1 | tee $DIR/mininet.log &
sleep 5

# Dump the flow tables while Mininet is up and running.
rm -f $FLOWS
INFO "Starting flow-dump..."
while true; do
    if [ -z "$(ps aux | grep run_mininet.sh | grep -v grep)" ]; then
        break
    fi
    echo "FLOW DUMP FIREWALL 1 `date --rfc-3339=seconds`" >> $FLOWS
    sudo ovs-ofctl dump-flows fw1 >> $FLOWS
    echo "----------------------------------------------------------------------" >> $FLOWS
    echo "FLOW DUMP FIREWALL 2 `date --rfc-3339=seconds`" >> $FLOWS
    sudo ovs-ofctl dump-flows fw2 >> $FLOWS
    echo "----------------------------------------------------------------------" >> $FLOWS
    sleep 2
done
