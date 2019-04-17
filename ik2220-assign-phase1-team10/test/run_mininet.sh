#!/bin/bash

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
SRCTOP=$(cd $DIR/.. && pwd)

SCRIPT=$1

cd $SRCTOP/topology && sudo python net.py $SCRIPT
