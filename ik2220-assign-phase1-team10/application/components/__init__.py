from collections import defaultdict

from pox.lib.util import dpid_to_str
from pox.core import core
import pox.openflow.libopenflow_01 as of

LOG = core.getLogger()

class SwitchManager(object):
    ''' Class to dispatch events between virtual switches '''
    slots = ('switches')

    class Switch(object):
        ''' A virtual switch that manages the state of an OVSSwitch '''
        slots = ('mac_to_port')
        def __init__(self):
            self.mac_to_port = dict()

        @staticmethod
        def resend(pkt_in, out_port, conn):
            ''' Resend packet to switch on given port(s)'''
            msg = of.ofp_packet_out()
            msg.data = pkt_in
            msg.actions.append(of.ofp_action_output(port=out_port))
            conn.send(msg)

        def receive(self, pkt, pkt_in, conn):
            ''' Receives packet and decides if flow table modification is needed '''
            self.mac_to_port[pkt.src] = pkt_in.in_port
            dst = self.mac_to_port.get(pkt.dst)
            if dst:
                LOG.info('known destination, installing flow...')
                self.resend(pkt_in, dst, conn)
                msg = of.ofp_flow_mod()
                msg.match.dl_dst = of.ofp_match(dl_dst=pkt.dst)
                msg.actions.append(of.ofp_action_output(port=dst))
                conn.send(msg)
            else:
                self.resend(pkt_in, of.OFPP_ALL, conn)

    def __init__(self):
        self.switches = defaultdict(dict())

    def register(self, rawdpid):
        dpid = dpid_to_str(rawdpid)
        self.switches[dpid] = {'switch':SwitchManager.Switch()}

    def dispatch(self, event, conn):
        pkt = event.parsed
        if not pkt:
            LOG.warning('incomplete packet received, ignore...')
            return
        pkt_in = event.ofp
        dpid = dpid_to_str(event.dpid)

        switchdef = self.switches.get(dpid)
        if switchdef:
            switch = switchdef.get('switch')
            switch.receive(pkt, pkt_in, conn)
        else:
            LOG.warning('unknown switch: %s' % dpid)
