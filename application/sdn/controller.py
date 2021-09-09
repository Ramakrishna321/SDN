''' IK2220 SDN Phase 1 Pox Controller '''

import subprocess
from collections import defaultdict

from pox.core import core
from pox.lib.util import dpid_to_str
from pox.forwarding.l2_learning import LearningSwitch

from config import NODEDEFS as cfg
from firewall import Firewall

class Controller(object):
    ''' POX controller

    This is controller listens for new connection from
    switches, according to the type it is set up as a
    learning switch or a firewall.
    '''

    slots = ('switches', 'extensions')

    @staticmethod
    def to_pox_dpid(dpid):
        ''' Converts Mininet dpids to pox format '''
        pox_dpid = ''
        for (i, c) in enumerate(dpid[4:]):
            pox_dpid += c
            if i % 2 == 1:
                pox_dpid += '-'
        return pox_dpid[:-1]

    def __init__(self):
        '''
        Loads the nodedef(mode, config and dpid) from
        config to POX
        '''
        self.switches = dict()
        self.extensions = defaultdict(dict)
        for nodedef in cfg:
            mode = nodedef.get('mode')
            config = nodedef.get('config')
            dpid = nodedef.get('dpid')
            script = nodedef.get('script')
            # add pre-definition for non-standard switches
            if mode and config and dpid:
                dpid = Controller.to_pox_dpid(dpid)
                self.switches[dpid] = {'mode': mode, 'config': config}
            elif mode and script and dpid:
                dpid = Controller.to_pox_dpid(dpid)
                self.switches[dpid] = {'mode': mode, 'script': script}
                print('NFV step 1')
        core.openflow.addListeners(self)

    def _handle_ConnectionUp(self, event):
        '''
        Listens for new connection event, then
        propagates to the appropriate switch or firewall
        controller
        '''
        dpid = dpid_to_str(event.dpid)
        conf = self.switches.get(dpid)
        # load pre-definition based on dpid or create a
        # l2_learning switch
        if conf and type(conf) == dict:
            if conf['mode'] == 'FIREWALL':
                self.switches[dpid] = Firewall(event.connection, conf['config'], dpid)
            if conf['mode'] == 'NFV':
                subprocess.call(conf['script'], shell=True)
        else:
            self.switches[dpid] = LearningSwitch(event.connection, False)
