#!/bin/bash

getMAC () {
	local ifName=$1
	echo $(ifconfig \
		  | grep $ifName \
		  | sed 's/.*HWaddr \(.*\)/\1/' \
		  | sed 's/:/-/g')
}

ifInternalMAC="$(getMAC napt-eth2)"
ifExternalMAC="$(getMAC napt-eth1)"

sudo click \
	ifInternalMAC="$ifInternalMAC" \
	ifExternalMAC="$ifExternalMAC" \
	$CLICK_SCRIPT_DIR/napt.click > ${SRCTOP}/results/napt.report
