''' WIP controller '''

from collections import defaultdict

from pox.core import core
from pox.lib.util import dpid_to_str
from pox.forwarding.l2_learning import LearningSwitch

from config import NODEDEFS as cfg
from firewall import Firewall

class Controller(object):
    slots = ('switches', 'extensions')

    @staticmethod
    def to_pox_dpid(dpid):
        pox_dpid = ''
        for (i, c) in enumerate(dpid[4:]):
            pox_dpid += c
            if i % 2 == 1:
                pox_dpid += '-'
        return pox_dpid[:-1]

    def __init__(self):
        self.switches = dict()
        self.extensions = defaultdict(dict)
        for nodedef in cfg:
            mode = nodedef.get('mode')
            config = nodedef.get('config')
            dpid = nodedef.get('dpid')
            if mode and config and dpid:
                dpid = Controller.to_pox_dpid(dpid)
                self.switches[dpid] = {'mode': mode, 'config': config}
        core.openflow.addListeners(self)

    def _handle_ConnectionUp(self, event):
        dpid = dpid_to_str(event.dpid)
        conf = self.switches.get(dpid)
        if conf and type(conf) == dict:
            if conf['mode'] == 'FIREWALL':
                self.switches[dpid] = Firewall(event.connection, conf['config'], dpid)
        else:
            self.switches[dpid] = LearningSwitch(event.connection, False)
