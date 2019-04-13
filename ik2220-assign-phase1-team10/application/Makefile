SRCTOP = $(shell (cd ..; pwd))
POXDIR = ${HOME}/pox
PYTHONPATH = "${SRCTOP}/:"

export PYTHONPATH

.PHONY: clean app

clean:
	@echo "Nothing to clean up..."

app:
	@echo "-------------------------"
	@echo "Starting POX Controller  "
	@echo "-------------------------"
	@cd ${POXDIR}; python pox.py application
