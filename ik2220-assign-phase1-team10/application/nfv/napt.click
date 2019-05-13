AddressInfo(
	inface	10.0.0.1	10.0.0.0/24		00-00-00-00-00-17,
	outface	100.0.0.1	100.0.0.0/24	00-00-00-00-00-16,
);


elementclass ArpIpClassifier { |
	input
	-> cls :: Classifier(
		12/0806 20/0001,
		12/0806 20/0002,
		12/0800,
		-,
	);

	cls[0] -> [0]output; // ARP-REQ
	cls[1] -> [1]output; // ARP-REP
	cls[2] -> [2]output; // IP
	cls[3] -> Print(AIP) -> Discard;
}


elementclass IpSplitter { |
	input
	-> Strip(14)
	-> CheckIPHeader
	-> cls :: IPClassifier(
		proto icmp,
		proto tcp or proto udp
	);

	cls[0] -> [0]output;
	cls[1] -> [1]output;
}

arpq :: ARPQuerier(outface);

out_int :: Queue(1024) -> ToDevice(napt-eth2);
out_ext :: Queue(1024) -> ToDevice(napt-eth1);

FromDevice(napt-eth2)
-> aip :: ArpIpClassifier;

aip[0]
-> Print(ARP-REQ)
-> arp :: ARPResponder(inface, outface);

arp[0]
-> out_int;

arp[1]
-> out_ext;

aip[1]
-> Print(ARP-REP)
-> [1]arpq;

aip[2]
-> Strip(14)
-> CheckIPHeader
-> ipcls :: IPClassifier(
	dst host outface,
	src net inface,
);

iprw :: IPRewriterPatterns(NAT outface 50000-65535 - -);

rw :: IPRewriter(pattern NAT 0 1, drop);
irw :: ICMPPingRewriter(pattern NAT 0 1, drop);

// If destination is 100.0.0.1:X pass it through the rewriter [1]
// to get back the 10.0.0.Y mapping.
ipcls[1]
-> icls_1 :: IPClassifier(icmp, udp or tcp);

icls_1[0]
-> [0]irw;

icls_1[1]
-> [0]rw;

// If source is from 10.0.0.0/24 pass it through the rewriter [0]
// to map it to 100.0.0.1:X
ipcls[0]
-> icls_0 :: IPClassifier(icmp, udp or tcp);

icls_0[0]
-> [1]irw;

icls_0[1]
-> [1]rw;

// If header is rewriten send it to PbZ
rw[0] -> n_0 :: Null;
irw[0] -> n_0
-> IPPrint(TO-PBZ)
-> [0]arpq
-> out_ext;

rw[1] -> n_1 :: Null;
irw[1] -> n_1
-> IPPrint(TO-PRZ)
-> Unstrip(14)
-> out_int;
