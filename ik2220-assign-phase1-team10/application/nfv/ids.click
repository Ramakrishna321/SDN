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
        -
	);
    http_cls :: Classifier(
        66/505554,	       //PUT 
        66/504f5354	,      //POST
        66/474554,         //GET
        66/48454144,	   //HEAD 
        66/4f5054494f4e53, //OPTIONS 
        66/5452414345,	   //TRACE 
        66/44454c455445,   //DELETE 
        66/434f4e4e454354, //CONNECT 
        -,                 //Headers not matched
    );

	ipcls[0] -> [1]output; // ICMP
    ipcls[1] -> Unstrip(14) -> [0]http_cls; //TCP
    ipcls[2] -> [2]output; // Other
    
	http_cls[0]  ->[3]output; // 
	http_cls[1]  ->[4]output; // 
	http_cls[2]  ->[5]output; // 
    http_cls[3]  ->[6]output; // 
    http_cls[4]  ->[7]output; // 
    http_cls[5]  ->[8]output; // 
    http_cls[6]  ->[9]output; // 
    http_cls[7]  ->[10]output; // 
    http_cls[8]  ->[11]output; // 
}

elementclass PUTCLS{ |
    input 
    -> cls :: Classifier(
        82/636174202f6574632f706173737764,          // cat /etc/passwd
        82/636174202f7661722f6c6f672f,              // cat /var/log/
        82/494e53455254,                            // INSERT
        82/555044415445,                            // UPDATE
        66/44454c455445,                            // DELETE
        -,                                          // rest
    );
    cls[0] -> [1]output;
    cls[1] -> [1]output;
    cls[2] -> [1]output;
    cls[3] -> [1]output;
    cls[4] -> [1]output;
    cls[5] -> [0]output;
}

elementclass IDS{ |
    td_internal :: SimpleQueue -> [0]output;
    td_insp :: SimpleQueue -> [1]output;
    
    
    //Classifying incoming packets
    input -> cls_external :: EtherClassifier;
    
    ////////////////////////////////////////////////////////
    // These are not needed to be checked
    // Forward ARP directly
    cls_external[0] -> Print(ARP, MAXLENGTH 140, CONTENTS ASCII) -> Counter -> td_internal;
    //ICMP and UDP
	cls_external[1]	-> Print(UDP-ICMP, MAXLENGTH 140, CONTENTS ASCII) -> Unstrip(14) -> Counter -> td_internal;
     //Other
	cls_external[2] -> Print(Other-e, MAXLENGTH 140, CONTENTS ASCII) -> Unstrip(14) -> Counter -> td_internal;
    // HTTP OTHERS
    cls_external[11] -> Print(HeaderNotMatched, MAXLENGTH 140, CONTENTS ASCII) -> Counter -> td_internal;
    /////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////
    //These have to check for patterns
	// HTTP PUT
	cls_external[3] -> Print(HTTP-GET, MAXLENGTH 140, CONTENTS ASCII) -> putcls:: PUTCLS;
    putcls[0]   -> td_internal;
    putcls[1]   -> td_insp;
    // HTTP POST
    cls_external[4] -> Print(HTTP-GET, MAXLENGTH 140, CONTENTS ASCII) -> td_internal;    
    ////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////
    // These go to insp and have to pcap
    // HTTP GET
    cls_external[5] -> Print(HTTP-insp, MAXLENGTH 140, CONTENTS ASCII) -> td_insp;
    // HTTP HEAD
    cls_external[6] -> Print(HTTP-insp, MAXLENGTH 140, CONTENTS ASCII) -> td_insp;
    // HTTP OPTIONS
    cls_external[7] -> Print(HTTP-insp, MAXLENGTH 140, CONTENTS ASCII) -> td_insp;
    // HTTP TRACE
    cls_external[8] -> Print(HTTP-insp, MAXLENGTH 140, CONTENTS ASCII) -> td_insp;
    // HTTP DELETE
    cls_external[9] -> Print(HTTP-insp, MAXLENGTH 140, CONTENTS ASCII) -> td_insp;
    // HTTP CONNECT
    cls_external[10] -> Print(HTTP-insp, MAXLENGTH 140, CONTENTS ASCII) -> td_insp;
    ////////////////////////////////////////////////////////
}


ids :: IDS();

FromDevice(ids-eth2, SNIFFER false)
-> AverageCounter
-> Counter
-> ids[0]
-> Counter
-> ToDevice(ids-eth1);
ids[1]
-> Counter
-> ToDevice(ids-eth3);

FromDevice(ids-eth1, SNIFFER false)
-> SimpleQueue 
-> ToDevice(ids-eth2);
