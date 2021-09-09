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
	sudo killall click &>/dev/null
    exit 0
}
trap user_abort SIGINT

# Makefile are not meant to run stuff in the background,
# so start everything from here...
INFO "Starting POX..."
$DIR/run_pox.sh &> $DIR/pox.log &
sleep 10

INFO "Starting Mininet..."
$DIR/run_mininet.sh $DIR/*.cmd 2>&1 | tee $DIR/mininet.log

mkdir -p $TOPDIR/results/logs
python3 $DIR/genreport.py $DIR/mininet.log $TOPDIR/results/phase_2_report.txt
for log in $(ls $DIR/*.log); do
    mv $log $TOPDIR/results/logs/$(basename $log)
done
