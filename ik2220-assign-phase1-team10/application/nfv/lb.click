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

rrmapper1 :: RoundRobinIPMapper( - - 100.0.0.20 - 0 0, - - 100.0.0.21 - 0 0, - - 100.0.0.22 - 0 0);
rrmapper2 :: RoundRobinIPMapper( - - 100.0.0.40 - 0 0, - - 100.0.0.41 - 0 0, - - 100.0.0.42 - 0 0);

elementclass LBRewriter {
    $lb_mapping|

    // IP rewriter elements
    rw :: IPRewriter($lb_mapping);
    irw :: IPRewriter(pattern 100.0.0.25 - - - 0 0);

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

    td_internal :: Queue(1024) -> [1]output;
    td_external :: Queue(1024) -> [0]output;

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
    -> td_internal;

    // telling external requests that the service is at 100.0.0.25 or 100.0.0.45
    cls_external[0]
    -> ARPResponder($external_if)
    -> td_external;

    // ARP-REP
    cls_internal[1]
    -> [1]qry_internal :: ARPQuerier($internal_if)
    -> td_internal;

    // getting the arps for the virtual service
    cls_external[1]
    -> [1]qry_external :: ARPQuerier($external_if)
    -> td_external;

    // IP rewriting
    lbrw :: LBRewriter($lb_mapping);


    cls_internal[2] ->IPPrint(fromINT-1) -> [0]lbrw;
    cls_external[2] ->IPPrint(fromOUT-1) -> [1]lbrw;



    lbrw[0] -> IPPrint(OUT-2) ->[0]qry_external
    lbrw[1] -> IPPrint(IN-2) ->[0]qry_internal;

}
// Initialize Load Balancer
lb :: LB(
    // load balancer 1
    internal, // internal interface
    external, // external interface
    rrmapper1,

);



// LB interface addresses
AddressInfo(
    internal 100.0.0.25 100.0.0.0/24  00-00-00-00-00-11,
    external 100.0.0.25 100.0.0.16/28 00-00-00-00-00-10,




//    lb2_internal  100.0.0.45                  00-00-00-00-00-12,
//  lb2_external    100.0.0.45  100.0.0.32/28   00-00-00-00-00-13,
);

//for input and output from lb1
FromDevice(lb1-eth2, SNIFFER false)
-> [0]lb[0]
-> ToDevice(lb1-eth1);
FromDevice(lb1-eth1, SNIFFER false)
-> [1]lb[1]
-> ToDevice(lb1-eth2);