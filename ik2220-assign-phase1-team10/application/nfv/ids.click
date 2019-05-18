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
	-> ipcls :: IPClassifier(
		proto icmp or proto udp,
		tcp opt syn or tcp opt fin or tcp opt ack or tcp opt rst,
		-,
	);

	http_cls :: Classifier(
		52/504f5354, // HTTP POST
		52/505554, // HTTP PUT	
		-,
	);
	
	ipcls[0] -> [1]output; // ICMP
    ipcls[1] -> [2]output; // TCP signaling
    ipcls[2] -> [0]http_cls;

	http_cls[0] -> [3]output; // HTTP POST
	http_cls[1] -> [4]output; // HTTP PUT
	http_cls[2] -> [5]output; // Drop
}

elementclass IDS{ |
    td_internal :: SimpleQueue -> [1]output;
    td_external :: SimpleQueue-> [0]output;
    
    //Classifying outgoing packets
    input[0] -> cls_internal :: EtherClassifier;

    //Classifying incoming packets
    input[1] -> cls_external :: EtherClassifier;

    // Forward ARP directly
    cls_internal[0] -> Print(ARP) -> td_external;
    cls_external[0] -> Print(ARP) -> td_internal;
    
    //ICMP and UDP
    cls_internal[1]	-> Print(UDP-ICMP) -> Unstrip(14) -> td_external;
	cls_external[1]	-> Print(UDP-ICMP) -> Unstrip(14) -> td_internal;
    
    //TCP
	cls_internal[2] -> Print(TCP-SIGI) -> td_external;
	cls_external[2] -> Print(TCP-SIGE) -> td_internal;

	// HTTP PUT
	cls_internal[3] -> Print(HTTP-PUTI) -> td_external;
	cls_external[3] -> Print(HTTP-PUTE) -> td_internal;

	// HTTP POST
	cls_internal[4] -> Print(HTTP-POSTI) -> td_external;
	cls_external[4] -> Print(HTTP-POSTE) -> td_internal;

	// TO IDS
	cls_internal[5] -> Print(otherI) -> Discard;
	cls_external[5] -> Print(otherE) -> Discard;
}


ids :: IDS();


FromDevice(ids-eth2, SNIFFER false)
-> [0]ids[0]
-> ToDevice(ids-eth1);
FromDevice(ids-eth1, SNIFFER false)
-> [1]ids[1]
-> ToDevice(ids-eth2);
