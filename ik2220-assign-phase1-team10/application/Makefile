SRCTOP = $(shell (cd ..; pwd))
POXDIR = ${HOME}/pox
CFG = ${SRCTOP}/topology/config.py
PYTHONPATH = "${SRCTOP}/:"

export PYTHONPATH

.PHONY: app

app:
	@echo "-------------------------"
	@echo "Starting POX Controller  "
	@echo "-------------------------"
	@if [ ! -e ${SRCTOP}/application/config.py ]; then \
		ln -s ${CFG} ${SRCTOP}/application/config.py; \
	fi
	@cd ${POXDIR}; python pox.py application
