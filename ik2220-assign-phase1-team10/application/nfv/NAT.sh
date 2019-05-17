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

echo "Starting NAT with params:"
echo NAT :: ifInternalMAC: "$ifInternalMAC"
echo NAT :: ifExternalMAC: "$ifExternalMAC"

sudo click \
	ifInternalMAC="$ifInternalMAC" \
	ifExternalMAC="$ifExternalMAC" \
	$CLICK_SCRIPT_DIR/napt.click
