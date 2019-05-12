elementclass Forwarder {
	$internal, $external, $arp |
	// Split flow to ARP-REQ, ARP-REP, IP, rest is dropped
	elementclass ArpIpClassifier { |
		input
		-> cls::Classifier(
			12/0806 20/0001,
			12/0806 20/0002,
			12/0800
		);
		cls[0] -> [0]output;
		cls[1] -> [1]output;
		cls[2] -> [2]output;
	}

	fd_internal :: FromDevice($internal)
	-> cls_internal :: ArpIpClassifier;

	cls_internal[0]
	-> Print(ARP-REQ:INTERNAL)
	-> [0]output;

	cls_internal[1]
	-> Print(ARP-REP:INTERNAL)
	-> Discard;

	cls_internal[2]
	-> Print(IP:INTERNAL)
	-> [1]output;

	fs_external :: FromDevice($external)
	-> cls_external :: ArpIpClassifier;

	cls_external[0]
	-> Print(ARP-REQ:EXTERNAL)
	-> ARPResponder($arp)
	-> [2]output;

	cls_external[1]
	-> Print(ARP-REP:EXTERNAL)
	-> Discard;

	cls_external[2]
	-> Print(IP:EXTERNAL)
	-> [3]output;
}

td_internal :: Queue -> ToDevice(napt-eth2);
td_external :: Queue -> ToDevice(napt-eth1);

fw :: Forwarder(
	napt-eth2,
	napt-eth1,
	100.0.0.1 100.0.0.50/30 DE-AD-DE-AD-DE-AD
);

fw[0] -> td_external;
fw[1] -> td_external;
fw[2] -> td_internal;
fw[3] -> td_internal;
