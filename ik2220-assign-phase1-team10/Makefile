SRCTOP = $(shell pwd)
PYTHONPATH = "${SRCTOP}/:"

export PYTHONPATH


# Main make targets
.PHONY: all topo app clean test

clean:
	${MAKE} -C ${SRCTOP}/topology clean
	@echo "-----------------------------"
	@echo "Clean up Python bytecode     "
	@echo "-----------------------------"
	find ${SRCTOP}/ -name "*.pyc" -delete

topo:
	${MAKE} -C ${SRCTOP}/topology topo; ${MAKE} clean

app:
	${MAKE} -C ${SRCTOP}/application app

test:
	chmod -R +x ${SRCTOP}/test/
	bash ${SRCTOP}/test/runall.sh
