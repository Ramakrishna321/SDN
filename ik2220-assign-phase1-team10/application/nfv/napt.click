AddressInfo(
	inface	10.0.0.1	10.0.0.0/24		00-00-00-00-00-17,
	outface	100.0.0.1		00-00-00-00-00-16,
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

arpq_o :: ARPQuerier(outface, TABLE = 'table1');
arpq_i :: ARPQuerier(inface, TABLE = 'table1');

out_int :: Queue(1024) -> ToDevice(napt-eth2);
out_ext :: Queue(1024) -> ToDevice(napt-eth1);

FromDevice(napt-eth2)
-> aip_in :: ArpIpClassifier;

FromDevice(napt-eth1)
-> aip_out :: ArpIpClassifier;



aip_in[0]
-> Print(ARP-REQ)
-> arp_in :: ARPResponder(inface, outface);

arp_in[0]
-> out_int;

arp_in[1]
-> out_ext;

aip_in[1]
-> Print(ARP-REP)
-> [1]arpq_o;

aip_in[2]
-> Strip(14)
-> CheckIPHeader
-> ipcls_in :: IPClassifier(
	dst host outface,
	src net inface,
);

aip_out[0]
-> Print(ARP-REQ)
-> arp_out :: ARPResponder(inface, outface);

arp_out[0]
-> out_ext;

arp_out[1]
-> out_int;

aip_out[1]
-> Print(ARP-REP)
-> [1]arpq_i;

aip_out[2]
-> Strip(14)
-> CheckIPHeader
-> ipcls_out :: IPClassifier(
	dst host outface,
	src net inface,
);


iprw :: IPRewriterPatterns(NAT outface 50000-65535 - -);

rw :: IPRewriter(pattern NAT 0 1, drop);
irw :: ICMPPingRewriter(pattern NAT 0 1, drop);

// If destination is 100.0.0.1:X pass it through the rewriter [1]
// to get back the 10.0.0.Y mapping.
ipcls_in[1]
-> icls_1 :: IPClassifier(icmp, udp or tcp);

icls_1[0]
-> [0]irw;

icls_1[1]
-> [0]rw;



ipcls_out[1]
-> icls_2 :: IPClassifier(icmp, udp or tcp);

icls_2[0]
-> [1]irw;

icls_2[1]
-> [1]rw;




// If source is from 10.0.0.0/24 pass it through the rewriter [0]
// to map it to 100.0.0.1:X
ipcls_in[0]
-> icls_0 :: IPClassifier(icmp, udp or tcp);

icls_0[0]
-> [1]irw;

icls_0[1]
-> [1]rw;

ipcls_out[0]
-> icls_3 :: IPClassifier(icmp, udp or tcp);

icls_3[0]
-> [0]irw;

icls_3[1]
-> [0]rw;


// If header is rewriten send it to PbZ
rw[0] -> n_0 :: Null;
irw[0] -> n_0
-> t ::Tee;
t[0]
-> [0]arpq_o
-> Print(TO-PBZ)
-> out_ext;

t[1]
-> [0]arpq_i
-> Print(TO-PRZ)
-> out_int;

rw[1] -> n_1 :: Null;
irw[1] -> n_1
-> IPPrint(TO-PRZ)
-> Unstrip(14)
-> out_int;
