SRCTOP = $(shell (cd ..; pwd))
PYTHONPATH = "${SRCTOP}/:"

export PYTHONPATH

.PHONY: clean topo

clean:
	@echo "-------------------------"
	@echo "Clean up Mininet         "
	@echo "-------------------------"
# this last line is just here because mn returns
# with non-zero exitcode and it trips up make...
	@sudo mn -c; \
	echo -n


topo:
	@echo "-------------------------"
	@echo "Starting Mininet         "
	@echo "-------------------------"
	@sudo python net.py
