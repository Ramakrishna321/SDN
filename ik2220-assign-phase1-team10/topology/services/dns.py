''' IK2220 SDN Phase 1 DNS Service '''
import sys
import logging

from scapy.all import DNS, DNSQR, DNSRR, dnsqtypes
from socket import AF_INET, SOCK_DGRAM, socket
from traceback import print_exc
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)

args = sys.argv[1:]

sock = socket(AF_INET, SOCK_DGRAM)

sock.bind((args[0], 53))
NAME_RECORD = {"ws1.ik2220.com.":"100.0.0.40", 
               "ws2.ik2220.com.":"100.0.0.41", 
               "ws3.ik2220.com.":"100.0.0.42" }

while True:
  request, addr = sock.recvfrom(4096)

  try:
    dns = DNS(request)
    # Validate that request is ipv4 and not a redirect
    assert dns.opcode == 0, dns.opcode  # QUERY
    assert dnsqtypes[dns[DNSQR].qtype] == 'A', dns[DNSQR].qtype
    
    # Checking query present in NAME_RECORD else sending default
    if dns.qd.qname.lower() in NAME_RECORD:
      dest_ip = NAME_RECORD[dns.qd.qname.lower()]
      query = dns[DNSQR].qname.decode('ascii')
      response = DNS(id=dns.id, ancount=1, qr=1, an=DNSRR(rrname=str(query), 
                     type='A', rdata=str(dest_ip), ttl=1234))
      print(repr(response))
      sock.sendto(bytes(response), addr)
    else:
    #default is ws1
      query = dns[DNSQR].qname.decode('ascii')
      response = DNS(id=dns.id, ancount=1, qr=1, 
                     an=DNSRR(rrname=str("Default:100.0.0.45"), type='A', 
                     rdata=str("100.0.0.45"), ttl=1234))
      print(repr(response))
      sock.sendto(bytes(response), addr)
  except Exception as e:
    print('')
    print_exc()
    print('garbage from {!r}? data {!r}'.format(addr, request))

