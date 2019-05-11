define($if_prz napt-eth2, $if_pbz napt-eth1);

AddressInfo(if_pbz 100.0.0.1);

elementclass ArpIpClassifier { |
	input-> cls::Classifier(
		12/0806 20/0001,
		12/0806 20/0002,
		12/0800
	);
	cls[0] -> [0]output; // ARP-REQ
	cls[1] -> [1]output; // ARP-REP
	cls[2] -> [2]output; // IP
}

elementclass PrepareIP { |
	input -> Strip(14) -> chk::CheckIPHeader(VERBOSE true);
	chk[0] -> output;
	chk[1] -> Print(PrepareIP:ERR) -> Discard;
}

out_pbz :: Unstrip(14) -> Queue(1024) -> ToDevice($if_pbz);
FromDevice($if_prz)-> aip1::ArpIpClassifier; 

ipcls :: IPClassifier(proto icmp, proto udp or proto tcp);
IPRewriterPatterns(NAT 100.0.0.1 50000-65535 - -);

icmprw :: ICMPPingRewriter(pattern NAT 0 0);
iprw :: IPRewriter(pattern NAT 0 0);

aip1[0]
-> Print(ARP-REQ)
-> ARPResponder(100.0.0.1 100.0.0.50/24 DE-AD-DE-AD-DE-AF)
-> out_pbz;

aip1[1] -> Print(ARP-REP) -> Discard;


aip1[2]
-> PrepareIP
-> ipcls;

ipcls[0]
-> icmprw
-> IPPrint(ICMP-RW)
-> out_pbz;

ipcls[1]
-> iprw
-> IPPrint(IP-RW)
-> out_pbz;
