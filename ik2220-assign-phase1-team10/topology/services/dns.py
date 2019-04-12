import sys
import logging

logging.getLogger("scapy.runtime").setLevel(logging.ERROR)
 
from scapy.all import DNS, DNSQR, DNSRR, IP, send, sniff, sr1, UDP
args = sys.argv[1:]

IFACE = args[0]   # Or your default interface
DNS_SERVER_IP = args[1]  # Your local IP
 
BPF_FILTER = "udp port 53 and ip dst %s" % (DNS_SERVER_IP)
 
 
def dns_responder(local_ip):
 
    def forward_dns(orig_pkt):
        print("Forwarding:%s"%(orig_pkt[DNSQR].qname))
        response = sr1(IP(dst='8.8.8.8')/ UDP(sport=orig_pkt[UDP].sport)/ DNS(rd=1, id=orig_pkt[DNS].id, qd=DNSQR(qname=orig_pkt[DNSQR].qname)), verbose=0,  )
        resp_pkt = IP(dst=orig_pkt[IP].src, src=DNS_SERVER_IP)/UDP(dport=orig_pkt[UDP].sport)/DNS()
        resp_pkt[DNS] = response[DNS]
        send(resp_pkt, verbose=0)
        return "Responding to %s"% (orig_pkt[IP].src)
 
    def get_response(pkt):
        if (
            DNS in pkt and
            pkt[DNS].opcode == 0 and
            pkt[DNS].ancount == 0
        ):
            if "trailers.apple.com" in str(pkt["DNS Question Record"].qname):
                spf_resp = IP(dst=pkt[IP].src)/UDP(dport=pkt[UDP].sport, sport=53)/DNS(id=pkt[DNS].id,ancount=1,an=DNSRR(rrname=pkt[DNSQR].qname, rdata=local_ip)/DNSRR(rrname="trailers.apple.com",rdata=local_ip))
                send(spf_resp, verbose=0, iface=IFACE)
                return "Spoofed DNS Response Sent: %s"% (pkt[IP].src)
 
            else:
                # make DNS query, capturing the answer and send the answer
                return forward_dns(pkt)
 
    return get_response
 
sniff(filter=BPF_FILTER, prn=dns_responder(DNS_SERVER_IP), iface=IFACE)
