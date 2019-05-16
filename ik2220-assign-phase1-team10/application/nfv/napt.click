// IK2220 - Phase 2. NAT implementation
//
// This implementation of NAT supports address and port translation of TCP, UDP
// and ICMP packets. ICMP translation only happens for echo requests and
// responses.
// The translation is from 10.0.0.0/24 to 100.0.0.0/24 subnet.

elementclass NATClassifier { |
	input
	-> cls :: Classifier(
		12/0806 20/0001,	// ARP-REQ
		12/0806 20/0002,	// ARP-REP
		12/0800,			// IP
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
	$internal_if, $internal_dev,
	$external_if, $external_dev,
	$nat_mapping |

	td_internal :: Queue(1024) -> ToDevice($internal_dev);
	td_external :: Queue(1024) -> ToDevice($external_dev);

	FromDevice($internal_dev, SNIFFER false)
	-> cls_internal :: NATClassifier;

	FromDevice($external_dev, SNIFFER false)
	-> cls_external :: NATClassifier;

	// ARP-REQ
	cls_internal[0]
	-> ARPResponder($internal_if)
	-> td_internal;

	cls_external[0]
	-> ARPResponder($external_if)
	-> td_external;

	// ARP-REP
	cls_internal[1]
	-> [1]qry_internal :: ARPQuerier($internal_if)
	-> td_internal;

	cls_external[1]
	-> [1]qry_external :: ARPQuerier($external_if)
	-> td_external;

	// IP rewriting
	natrw :: NATRewriter($nat_mapping);

	// ICMP
	cls_internal[2]	-> [0]natrw;
	cls_external[2]	-> [1]natrw;
	
	// UDP-TCP
	cls_internal[3]	-> [2]natrw;
	cls_external[3]	-> [3]natrw;

	natrw[0] -> split_1 :: Tee; // not necessary 
	split_1[0] -> [0]qry_external;
//	split_1[1] -> [0]qry_internal;

	natrw[1] -> split_2 :: Tee; // not necessary
	split_2[0] -> [0]qry_internal;
//	split_2[1] -> [0]qry_external; // Removed the query to external.
}

// NAPT interface addresses
AddressInfo(
	internal	10.0.0.1	10.0.0.0/24		00-00-00-00-00-17,
	external	100.0.0.1	100.0.0.0/24	00-00-00-00-00-16,
);

// Initialize NAT
nat :: NAT(
	internal, napt-eth2,		// internal interface
	external, napt-eth1,		// external interface
	100.0.0.1 50000-65535 - -	// rewrite pattern
);
