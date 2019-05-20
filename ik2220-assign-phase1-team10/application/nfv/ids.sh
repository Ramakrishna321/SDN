#!/bin/bash
echo "Starting IDS"

sudo click $CLICK_SCRIPT_DIR/ids.click > ${SRCTOP}/results/ids.report
