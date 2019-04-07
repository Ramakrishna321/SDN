from collections import defaultdict

from pox.lib.util import dpid_to_str
from pox.core import core
import pox.openflow.libopenflow_01 as of

LOG = core.getLogger()

class SwitchManager(object):
    ''' Class to dispatch events between virtual switches '''
    slots = ('switches', 'conn')

    class Switch(object):
        ''' A virtual switch that manages the state of an OVSSwitch '''
        slots = ('mac_to_port')
        def __init__(self, conn):
            self.mac_to_port = dict()
            self.conn = conn

        def resend(self, pkt_in, out_port):
            ''' Resend packet to switch on given port(s)'''
            msg = of.ofp_packet_out()
            msg.data = pkt_in
            msg.actions.append(of.ofp_action_output(port=out_port))
            self.conn.send(msg)

        def receive(self, pkt, pkt_in):
            ''' Receives packet and decides if flow table modification is needed '''
            self.mac_to_port[pkt.src] = pkt_in.in_port
            dst = self.mac_to_port.get(pkt.dst)
            if dst:
                self.resend(pkt_in, dst)
                msg = of.ofp_flow_mod()
                msg.match.dl_dst = pkt.dst
                msg.actions.append(of.ofp_action_output(port=dst))
                self.conn.send(msg)
            else:
                self.resend(pkt_in, of.OFPP_ALL)

    def __init__(self):
        self.switches = defaultdict(dict)

    def register(self, rawdpid, conn):
        dpid = dpid_to_str(rawdpid)
        self.switches[dpid] = {'switch':SwitchManager.Switch(conn)}

    def dispatch(self, event):
        pkt = event.parsed
        if not pkt:
            LOG.warning('incomplete packet received, ignore...')
            return
        pkt_in = event.ofp
        dpid = dpid_to_str(event.dpid)

        switchdef = self.switches.get(dpid)
        if switchdef:
            switch = switchdef.get('switch')
            switch.receive(pkt, pkt_in)
        else:
            LOG.warning('DISPATCH: unknown dpid: %s' % dpid)
