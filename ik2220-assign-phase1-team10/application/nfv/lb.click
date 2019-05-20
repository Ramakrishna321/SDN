elementclass EtherClassifier { |
    input
    -> cls :: Classifier(
        12/0806 20/0001,    // ARP-REQ
        12/0806 20/0002,    // ARP-REP
        12/0800,            // IP
    );

    // Forward ARP
    cls[0] -> [0]output;
    cls[1] -> [1]output;

    cls[2]
    -> Strip(14)
    -> CheckIPHeader
    -> [2]output;
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
    -> cls_internal :: EtherClassifier;

    // Checking incoming packets
    input[1]
    -> cls_external :: EtherClassifier;

    // ARP-REQ
    // telling internal requests that the packet has to go through 100.0.0.25 or 100.0.0.45
    cls_internal[0]
    -> ARPResponder($internal_if)
    -> Counter
    -> td_internal;

    // telling external requests that the service is at 100.0.0.25 or 100.0.0.45
    cls_external[0]
    -> ARPResponder($external_if)
    -> Counter
    -> td_external;

    // ARP-REP
    cls_internal[1]
    -> Counter
    -> [1]qry_internal :: ARPQuerier($internal_if)
    -> td_internal;

    // getting the arps for the virtual service
    cls_external[1]
    -> Counter
    -> [1]qry_external :: ARPQuerier($external_if)
    -> td_external;

    // IP rewriting
    lbrw :: LBRewriter($lb_mapping);


    cls_internal[2] ->IPPrint(fromINT-1) -> [0]lbrw;
    cls_external[2] ->IPPrint(fromOUT-1) -> [1]lbrw;



    lbrw[0] -> IPPrint(OUT-2) -> Counter -> [0]qry_external
    lbrw[1] -> IPPrint(IN-2)  -> Counter -> [0]qry_internal;
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
-> AverageCounter
-> Counter
-> [0]lb[0]
-> AverageCounter
-> Counter
-> ToDevice($ifExternal);

FromDevice($ifExternal, SNIFFER false)
-> AverageCounter
-> Counter
-> [1]lb[1]
-> AverageCounter
-> Counter
-> ToDevice($ifInternal);
