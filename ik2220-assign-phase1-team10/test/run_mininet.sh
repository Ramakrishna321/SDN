#!/bin/bash
#IK2220 SDN Phase 1 Mininet starter script

# Starts the Mininet and passes the arguments in case of 
# a test

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
SRCTOP=$(cd $DIR/.. && pwd)

cd $SRCTOP/topology && sudo python net.py $@
