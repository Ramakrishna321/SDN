#!/bin/bash

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
SRCTOP=$(cd $DIR/.. && pwd)

#SCRIPT=$1 $2 $3
#
cd $SRCTOP/topology && sudo python net.py $1 $2 $3 $4 $5 $6 $7 $8 $9 
