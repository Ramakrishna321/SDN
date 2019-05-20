// IK2220 - Phase 2. NAT implementation
//
// This implementation of NAPT supports address and port translation of TCP, UDP
// and ICMP packets. ICMP translation only happens for echo requests and
// responses.
// The translation is from 10.0.0.0/24 to 100.0.0.0/24 subnet.

elementclass NATClassifier { |
	input
	-> cls :: Classifier(
		12/0806 20/0001,	// ARP-REQ
		12/0806 20/0002,	// ARP-REP
		12/0800,			// IP
		-,
	);

	// Forward ARP
	cls[0] -> [0]output;
	cls[1] -> [1]output;

	// Split IP flow
	cls[2]
	-> Strip(14)
	-> CheckIPHeader
	-> ipcls :: IPClassifier(proto icmp, proto tcp or proto udp);

	ipcls[0] -> [2]output;
	ipcls[1] -> [3]output;

	cls[3] -> [4]output;
}

elementclass NATRewriter {
	$nat_mapping|
	IPRewriterPatterns(NAT $nat_mapping);

	// IP rewriter elements
	rw :: IPRewriter(pattern NAT 0 1, drop);
	irw :: ICMPPingRewriter(pattern NAT 0 1, drop);

	join_internal :: Null;
	join_external :: Null;

	// ICMP
	// internal to external mapping
	input[0] -> [0]irw[1] -> join_external;
	// external to internal mapping
	input[1] -> [1]irw[0] -> join_internal;

	// UDP and TCP
	// internal to external mapping
	input[2] -> [0]rw[1] -> join_external;
	// external to internal mapping
	input[3] -> [1]rw[0] -> join_internal;

	join_internal -> [0]output;
	join_external -> [1]output;
}

elementclass NAT {
	$internal_if,
	$external_if,
	$nat_mapping |

	td_internal :: SimpleQueue -> [0]output; // internal device
	td_external :: SimpleQueue -> [1]output; // external device

	input[0] // internal device
	-> napt_int :: AverageCounter
	-> cls_internal :: NATClassifier;

	cls_internal[4] -> drop_int :: Counter -> Discard;

	input[1] // external device
	-> napt_ext :: AverageCounter
	-> cls_external :: NATClassifier;

	cls_external[4] -> drop_ext :: Counter -> Discard;

	// ARP-REQ
	cls_internal[0]
	-> ARPResponder($internal_if)
	-> arp_req_int :: Counter
    -> td_internal;

	cls_external[0]
	-> ARPResponder($external_if)
	-> arp_req_ext :: Counter
    -> td_external;

	// ARP-REP
	cls_internal[1]
	-> [1]qry_internal :: ARPQuerier($internal_if)
	-> arp_rep_int :: Counter
    -> td_internal;

	cls_external[1]
	-> [1]qry_external :: ARPQuerier($external_if)
	-> arp_rep_ext :: Counter
    -> td_external;

	// IP rewriting
	natrw :: NATRewriter($nat_mapping);

	// ICMP
	cls_internal[2]	-> icmp_int :: Counter -> [0]natrw;
	cls_external[2]	-> icmp_ext :: Counter -> [1]natrw;
	
	// UDP-TCP
	cls_internal[3]	-> udp_tcp_int :: Counter -> [2]natrw;
	cls_external[3]	-> udp_tcp_ext :: Counter -> [3]natrw;

	natrw[0] -> rw_ext :: Counter -> [0]qry_external;

	natrw[1] -> rw_int :: Counter -> [0]qry_internal;

	DriverManager(
		pause,
		print "====================== NAPT Report =======================",
		print "Input packet rate (pps) internal: ", print napt_int.rate,
		print "Input packet rate (pps) external: ", print napt_ext.rate,
		print "-----------------------------------------------------------",
		print "ARP request internal:", print arp_req_int.count,
		print "ARP request external:", print arp_req_ext.count,
		print "ARP response internal:", print arp_rep_int.count,
		print "ARP response external:", print arp_rep_ext.count,
		print "-----------------------------------------------------------",
		print "ICMP internal:", print icmp_int.count,
		print "ICMP external:", print icmp_ext.count,
		print "UDP and TCP internal:", print udp_tcp_int.count,
		print "UDP and TCP external:", print udp_tcp_ext.count,
		print "-----------------------------------------------------------",
		print "NAPT mapped packets (int-ext):", print rw_ext.count,
		print "NAPT mapped packets (ext-int):", print rw_int.count,
		print "-----------------------------------------------------------",
		print "Dropper packets internal:", print drop_int.count,
		print "Dropper packets external:", print drop_ext.count,
		print "===========================================================",
		stop
	);
}

// NAPT interface addresses
AddressInfo(
	internal	10.0.0.1	10.0.0.0/24		$ifInternalMAC,
	external	100.0.0.1	100.0.0.0/24	$ifExternalMAC,
);

// Initialize NAT
nat :: NAT(
	internal,	// internal interface
	external,	// external interface
	100.0.0.1 50000-65535 - -	// rewrite pattern
);

FromDevice(napt-eth2, SNIFFER false)
-> [0]nat[0]
-> ToDevice(napt-eth2);

FromDevice(napt-eth1, SNIFFER false)
-> [1]nat[1]
-> ToDevice(napt-eth1);
