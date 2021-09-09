SRCTOP = $(shell pwd)
POXDIR = ${HOME}/pox
CFG = ${SRCTOP}/topology/config.py
APP = ${SRCTOP}/application/sdn
POXAPP = ${POXDIR}/ext/application
PYTHONPATH = "${SRCTOP}/application:"
CLICK_SCRIPT_DIR = ${SRCTOP}/application/nfv

export PYTHONPATH
export CLICK_SCRIPT_DIR
export SRCTOP


# Main make targets
.PHONY: all topo app clean test

clean:
	@echo "-------------------------"
	@echo "Clean up Mininet         "
	@echo "-------------------------"
# this last line is just here because mn returns
# with non-zero exitcode and it trips up make...
	sudo mn -c; \
	echo -n
	@echo "-------------------------"
	@echo "Clean up POX             "
	@echo "-------------------------"
	sudo killall python 2>/dev/null; \
    echo -n ""
	@echo "-------------------------"
	@echo "Clean up Click           "
	@echo "-------------------------"
	sudo killall click 2>/dev/null; \
	echo -n ""
	@echo "-----------------------------"
	@echo "Clean up runtime artifacts   "
	@echo "-----------------------------"
	find ${SRCTOP}/ -name "*.pyc" -delete
	rm -f ${POXAPP} 2>/dev/null

topo:
	@echo "-------------------------"
	@echo "Starting Mininet         "
	@echo "-------------------------"
	test/run_mininet.sh

app:
	@echo "-------------------------"
	@echo "Starting POX Controller  "
	@echo "-------------------------"
	chmod +x ${CLICK_SCRIPT_DIR}/*.sh
	test/run_pox.sh

test: clean
	@echo ""
	@echo "-------------------------"
	@echo "Starting Tests           "
	@echo "-------------------------"
	chmod +x ${SRCTOP}/test/*.sh
	bash ${SRCTOP}/test/runall.sh
	@echo ""
	${MAKE} clean

# Set up shell with smae env-vars for debugging
shell:
	/bin/bash

pkg:
	cd ${SRCTOP}/../; \
	tar czf ik2220-assign-${PHASE}-team10.tar.gz -C ${SRCTOP} .
