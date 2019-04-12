import sys
import logging

logging.getLogger("scapy.runtime").setLevel(logging.ERROR)

from scapy.all import DNS, DNSQR, DNSRR, IP, send, sniff, sr1, UDP
args = sys.argv[1:]

IFACE = args[0]   # Or your default interface
DNS_SERVER_IP = args[1]  # Your local IP

BPF_FILTER = "udp port 53 and ip dst {} and not ip src {}".format(DNS_SERVER_IP, DNS_SERVER_IP)

NAME_RECORD= {"ws1":"100.0.0.40", "ws2":"100.0.0.41", "ws3":"100.0.0.42" }

def dns_responder(local_ip):
  print("Query received")
  def get_response(pkt):
    query = pkt[DNS].qd.qname.lower()
    print("Query : %s"% query)
    if query in NAME_RECORD:
      dest_ip = NAME_RECORD[pkt[DNS].qd.qname.lower()]
      spf_resp = IP(dst=pkt[IP].src)/UDP(dport=pkt[UDP].sport, sport=53)/DNS(id=pkt[DNS].id,ancount=1,an=DNSRR(rrname=pkt[DNSQR].qname, rdata=dest_ip)/DNSRR(rrname="ws1.ik2220.com",rdata=dest_ip))
      send(spf_resp, verbose=0, iface=IFACE)
      return "DNS Response Sent: %s"% (pkt[IP].src)
    else:
      # make DNS query, capturing the answer and send the answerr
      spf_resp = IP(dst=pkt[IP].src)/UDP(dport=pkt[UDP].sport, sport=53)/DNS(id=pkt[DNS].id,ancount=1,an=DNSRR(rrname=pkt[DNSQR].qname, rdata="100.0.0.40")/DNSRR(rrname="ws1.ik2220.com",rdata="100.0.0.40"))
      send(spf_resp, verbose=0, iface=IFACE)
      return "sent ws1 tio: %s"% (pkt[IP].src)

sniff(filter=BPF_FILTER, prn=dns_responder(DNS_SERVER_IP), iface=IFACE)

