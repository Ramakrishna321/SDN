elementclass EtherClassifier { |
    input
    -> cls :: Classifier(
        12/0806,            // ARP
        12/0800,            // IP
    );

    // Forward ARP
    cls[0] -> [0]output;
    
    // Split IP flow
	cls[1]
	-> Strip(14)
	-> CheckIPHeader
	-> ipcls :: IPClassifier( proto icmp, proto udp, http, proto tcp);

	
	ipcls[0] -> [2]output; //ICMP
    ipcls[1] -> [3]output; //UDP
    ipcls[2] -> [1]output; //HTTP
    ipcls[3] -> [4]output; //TCP
}
elementclass IDS{ |
    td_internal :: Queue(1024) -> [1]output;
    td_external :: Queue(1024) -> [0]output;
    
    //Classifying outgoing packets
    input[0] -> cls_internal :: EtherClassifier;

    //Classifying incoming packets
    input[1] -> cls_external :: EtherClassifier;

    // Forward ARP directly
    cls_internal[0] -> Print(ARP) -> Unstrip(14) -> td_external;
    cls_external[0] -> Print(ARP) -> Unstrip(14) -> td_internal;
    
    //ICMP
    cls_internal[2]	-> Print(ICMP) -> Unstrip(14) -> td_external;
	cls_external[2]	-> Print(ICMP) -> Unstrip(14) -> td_internal;
    
    //UDP
    cls_internal[3]	-> Print(UDP) -> Unstrip(14) -> td_external;
	cls_external[3]	-> Print(UDP) -> Unstrip(14) -> td_internal;
    
    //TCP Signalling
    cls_internal[4]	-> Print(TCP-SIG) -> Unstrip(14) -> td_external;
	cls_external[4]	-> Print(TCP-SIG) -> Unstrip(14) -> td_internal;
    
    //HTTP
    cls_internal[1]	->StripIPHeader ->  Strip(32) -> Print(HTTP) -> Unstrip(32) -> UnstripIPHeader -> Unstrip(14) -> td_external;
	cls_external[1]	->StripIPHeader ->  Strip(32) -> Print(HTTP) -> Unstrip(32) -> UnstripIPHeader -> Unstrip(14) -> td_internal;

}


ids :: IDS();


FromDevice(ids-eth2, SNIFFER false)
-> [0]ids[0]
-> ToDevice(ids-eth1);
FromDevice(ids-eth1, SNIFFER false)
-> [1]ids[1]
-> ToDevice(ids-eth2);