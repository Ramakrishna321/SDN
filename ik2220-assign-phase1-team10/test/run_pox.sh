#!/bin/bash
#IK2220 SDN Phase 1 POX starter script

# Starts the POX controller

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
SRCTOP=$(cd $DIR/.. && pwd)

POXDIR=${HOME}/pox
CFG=${SRCTOP}/topology/config.py
APP=${SRCTOP}/application/sdn
POXAPP=${POXDIR}/ext/application

# creates symlink to the topology/config
rm -f ${APP}/config.py
ln -s ${CFG} ${APP}/config.py

# creates symlink to the pox/ext/ directory
rm -f ${POXAPP}
ln -s ${APP} ${POXAPP}

cd ${POXDIR} && python pox.py application
