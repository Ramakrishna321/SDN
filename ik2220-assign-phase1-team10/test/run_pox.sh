#!/bin/bash

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
SRCTOP=$(cd $DIR/.. && pwd)

POXDIR=${HOME}/pox
CFG=${SRCTOP}/topology/config.py
APP=${SRCTOP}/application
POXAPP=${POXDIR}/ext/application

echo "SRCTOP = $SRCTOP"
echo "DIR = $DIR"

if [ ! -e ${SRCTOP}/application/config.py ]; then
	ln -s ${CFG} ${SRCTOP}/application/config.py
fi

if [ ! -e ${POXDIR}/ext/application ]; then
	ln -s ${APP} ${POXAPP}
fi

cd ${POXDIR} && python pox.py application
