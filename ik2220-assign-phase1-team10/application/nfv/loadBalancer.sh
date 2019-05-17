#!/bin/bash

getMAC () {
	local ifName=$1
	echo $(ifconfig \
		  | grep $ifName \
		  | sed 's/.*HWaddr \(.*\)/\1/' \
		  | sed 's/:/-/g')
}

createRRMapping () {
	local i=$1
	local base=$(echo -n $2 | head -c -1)
	echo "- - $base$i - 0 0"
}

lbName=$1
lbIP=$2
lbExternalRange=$3

ifInternal=$lbName-eth2
ifExternal=$lbName-eth1

ifInternalMAC="$(getMAC $ifInternal)"
ifExternalMAC="$(getMAC $ifExternal)"

server0="$(createRRMapping 0 $lbIP)"
server1="$(createRRMapping 1 $lbIP)"
server2="$(createRRMapping 2 $lbIP)"

echo "Starting LoadBalancer with params:"
echo lbIP: "$lbIP" 
echo lbExternalRange: "$lbExternalRange" 
echo ifInternal: "$ifInternal" 
echo ifExternal: "$ifExternal" 
echo ifInternalMAC: "$ifInternalMAC" 
echo ifExternalMAC: "$ifExternalMAC" 
echo server0: "$server0" 
echo server1: "$server1" 
echo server2: "$server2" 

sudo click \
	lbIP="$lbIP" \
	lbExternalRange="$lbExternalRange" \
	ifInternal="$ifInternal" \
   	ifExternal="$ifExternal" \
	ifInternalMAC="$ifInternalMAC" \
	ifExternalMAC="$ifExternalMAC" \
	server0="$server0" \
	server1="$server1" \
	server2="$server2" \
	$CLICK_SCRIPT_DIR/lb.click
