elementclass EtherClassifier { |
    input
    -> cls :: Classifier(
        12/0806 20/0001,    // ARP-REQ
        12/0806 20/0002,    // ARP-REP
        12/0800,            // IP
		-,
    );

    // Forward ARP
    cls[0] -> [0]output;
    cls[1] -> [1]output;

    cls[2]
    -> Strip(14)
    -> CheckIPHeader
    -> [2]output;

	cls[3] -> [3]output;
}

elementclass LBRewriter {
    $lb_mapping|

	IPRewriterPatterns(SRW $lbIP - - -);

    // IP rewriter elements
    rw :: IPRewriter($lb_mapping);
    irw :: IPRewriter(pattern SRW 0 0);

    //IP
    // internal to external mapping
    input[0] -> irw -> [0]output;;

    // external to internal mapping
    input[1] -> rw -> [1]output;

}
elementclass LB {
    $internal_if,
    $external_if,
    $lb_mapping |

    td_internal :: SimpleQueue -> [1]output;
    td_external :: SimpleQueue -> [0]output;

    //Checking outgoing packets
    input[0]
	-> lb_avg_out :: AverageCounter
    -> cls_internal :: EtherClassifier;

    // Checking incoming packets
    input[1]
	-> lb_avg_in :: AverageCounter
    -> cls_external :: EtherClassifier;

    // ARP-REQ
    // telling internal requests that the packet has to go through 100.0.0.25 or 100.0.0.45
    cls_internal[0]
    -> ARPResponder($internal_if)
	-> arp_req_int :: Counter
    -> td_internal;

    // telling external requests that the service is at 100.0.0.25 or 100.0.0.45
    cls_external[0]
    -> ARPResponder($external_if)
	-> arp_req_ext :: Counter
    -> td_external;

    // ARP-REP
    cls_internal[1]
    -> [1]qry_internal :: ARPQuerier($internal_if)
	-> arp_rep_int :: Counter
    -> td_internal;

    // getting the arps for the virtual service
    cls_external[1]
    -> [1]qry_external :: ARPQuerier($external_if)
	-> arp_rep_ext :: Counter
    -> td_external;

    // IP rewriting
    lbrw :: LBRewriter($lb_mapping);


    cls_internal[2] -> [0]lbrw;
    cls_external[2] -> [1]lbrw;

    lbrw[0] -> ip_ext :: Counter -> [0]qry_external
    lbrw[1] -> ip_int :: Counter -> [0]qry_internal;

	cls_internal[3] -> Discard;
	cls_external[3] -> drop_ext :: Counter -> Discard;

	DriverManager(
		pause,
		print "Total # of input packets:", print lb_avg_in.count,
		print "Input packet rate (pps):", print lb_avg_in.rate,
		print "Total # of output packets:", print lb_avg_out.count,
		print "Output packet rate (pps):", print lb_avg_out.rate,
		print "----------------------------------------------------------",
		print "ARP requests (internal):", print arp_req_int.count,
		print "ARP requests (external):", print arp_req_ext.count,
		print "----------------------------------------------------------",
		print "IP packets (internal):", print ip_int.count,
		print "IP packets (external):", print ip_ext.count,
		print "----------------------------------------------------------",
		print "Dropped packets:", print drop_ext.count,
		stop
	);
}


// LB interface addresses
AddressInfo(
	internal $lbIP 100.0.0.0/24 $ifInternalMAC,
	external $lbIP $lbExternalRange $ifExternalMAC,
);

rrmapper :: RoundRobinIPMapper($server0, $server1, $server2);


// Initialize Load Balancer
lb :: LB(
    internal, // internal interface
    external, // external interface
    rrmapper,
);

FromDevice($ifInternal, SNIFFER false)
-> [0]lb[0]
-> ToDevice($ifExternal);

FromDevice($ifExternal, SNIFFER false)
-> [1]lb[1]
-> ToDevice($ifInternal);
