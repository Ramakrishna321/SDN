''' IK2220 SDN Phase 1 Firewall '''

from pox.forwarding.l2_learning import LearningSwitch
from pox.lib.packet.ipv4 import ipv4
from pox.lib.addresses import IPAddr
from pox.lib.recoco import Timer
import pox.openflow.libopenflow_01 as of
from pox.core import core

from . import config as cfg

LOG = core.getLogger()

class Firewall(LearningSwitch):
    '''
    L2 Learning Switch extended with Firewall 
    capabilities.
    '''
    IDLE_TIMEOUT = 30
    HARD_TIMEOUT = 90
    slots = ('rules', 'active_conns')
    def __init__(self, conn, config, dpid):
        self.rules = cfg.RULES.get(config)
        if not self.rules:
            LOG.error('missing rules: %s' % config)
            self.rules = cfg.RULES['default']
        self.active_conns = dict()
        self.dpid = dpid
        LearningSwitch.__init__(self, conn, False)

    def rm_conn(self, active):
        '''Remove connection after timeout'''
        try:
            timer = self.active_conns.pop(active)
            timer.cancel()
        except KeyError:
            # sometimes this can trigger due to timer.cancel()
            # baing called later in is_active() then the timer
            # expires,  just ignore, since we don't want to touch
            # POX code...
            LOG.warn('time-out race condition')


    def timed_msg(self, match, port):
        ''' Creates a ofp flow mod message with timeout. '''
        msg = of.ofp_flow_mod()
        msg.match = match
        msg.idle_timeout = Firewall.IDLE_TIMEOUT
        msg.hard_timeout = Firewall.HARD_TIMEOUT
        msg.actions.append(of.ofp_action_output(port=port))
        self.connection.send(msg)

    def drop_msg(self, event):
        ''' Creates an ofp flow mod message for packets to 
        be dropped. '''
        pkt = event.parsed
        msg = of.ofp_flow_mod()
        msg.match = of.ofp_match.from_packet(pkt)
        msg.idle_timeout = Firewall.IDLE_TIMEOUT
        msg.hard_timeout = Firewall.HARD_TIMEOUT
        self.connection.send(msg)

    def is_active(self, conn):
        ''' Checks if response arrived before timeout'''
        try:
            timer = self.active_conns.pop(conn)
            timer.cancel()
            return True
        except KeyError:
            return False

    def match_event(self, event):
        '''
        Check packet header against firewall rules
        '''
        # Disecting the packet
        pkt = event.parsed
        ip_pkt = pkt.find('ipv4')
        if not ip_pkt:
            # ARPs need to be let through, phase1 doesn't specifies handling ARPs,
            # but phase2 firewall cannot work without handling them...
            # no specific firewall rule is applied, flow is just simply installed.
            arp_pkt = pkt.find('arp')
            return True if arp_pkt else False
        src = ip_pkt.srcip
        dst = ip_pkt.dstip
        proto = ip_pkt.protocol
        ports = ('*', '*')
        if proto == ipv4.TCP_PROTOCOL:
            tcp = ip_pkt.find('tcp')
            ports = (tcp.srcport, tcp.dstport)
        elif proto == ipv4.UDP_PROTOCOL:
            udp = ip_pkt.find('udp')
            ports = (udp.srcport, udp.dstport)
        elif proto != ipv4.ICMP_PROTOCOL:
            return

        src_str = src.toStr()
        dst_str = dst.toStr()
        conn = (src_str, dst_str, proto, ports)
        # Check if packet is a response
        if self.is_active(conn):
            match = of.ofp_match.from_packet(pkt)
            self.timed_msg(match, event.ofp.in_port)
            return True
        # Match against rules
        for (sip, dip, prot, dport, allow) in self.rules:
            if sip != '*' and not src.inNetwork(sip):
                continue
            if dip != '*' and not dst.inNetwork(dip):
                continue
            if not prot in ('*', proto):
                continue
            dp = ports[1]
            if dp != dport:
                continue
            if not allow:
                self.drop_msg(event)
                return False
            match = of.ofp_match.from_packet(pkt)
            self.timed_msg(match, event.ofp.in_port)
            flip_ports = (ports[1], ports[0])
            flip_conn = (dst_str, src_str, proto, flip_ports)
            LOG.info("rule matched: {}".format((sip, dip, prot, dport, allow)))
            LOG.info("connection: {}".format(conn))
            self.active_conns[flip_conn] = Timer(Firewall.IDLE_TIMEOUT, self.rm_conn, args=[flip_conn])
            return True
        self.drop_msg(event)
        return False

    def _handle_PacketIn(self, event):
        matched = self.match_event(event)
        if matched:
            LearningSwitch._handle_PacketIn(self, event) 
