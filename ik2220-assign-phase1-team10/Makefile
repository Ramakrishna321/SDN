SRCTOP = $(shell pwd)
POXDIR = ${HOME}/pox
CFG = ${SRCTOP}/topology/config.py
APP = ${SRCTOP}/application
POXAPP = ${POXDIR}/ext/application
PYTHONPATH = "${SRCTOP}/:"

export PYTHONPATH


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
	@echo "-----------------------------"
	@echo "Clean up runtime artifacts   "
	@echo "-----------------------------"
	find ${SRCTOP}/ -name "*.pyc" -delete
	rm -f ${POXAPP} 2>/dev/null

topo:
	@echo "-------------------------"
	@echo "Starting Mininet         "
	@echo "-------------------------"
	@bash test/run_mininet.sh

app:
	@echo "-------------------------"
	@echo "Starting POX Controller  "
	@echo "-------------------------"
	@bash test/run_pox.sh

test: clean
	@echo ""
	@echo "-------------------------"
	@echo "Starting Tests           "
	@echo "-------------------------"
	chmod +x ${SRCTOP}/test/*.sh
	bash ${SRCTOP}/test/runall.sh
	@echo ""
	${MAKE} clean
