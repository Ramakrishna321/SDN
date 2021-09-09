FromDevice(napt-eth2, SNIFFER false, BURST 8)
-> SimpleQueue
-> ToDevice(napt-eth1);

FromDevice(napt-eth1, SNIFFER false, BURST 8)
-> Queue
-> ToDevice(napt-eth2);
