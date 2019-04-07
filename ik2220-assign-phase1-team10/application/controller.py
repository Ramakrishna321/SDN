''' WIP controller '''

from pox.core import core

from components import SwitchManager

log = core.getLogger()

class Controller(object):
    slots = ('sw_manager',
             'conn')
    def __init__(self):
        core.openflow.addListeners(self)
        self.sw_manager = SwitchManager()
        self.conn = None

    def _handle_ConnectionUp(self, event):
        self.conn = event.connection
        self.sw_manager.register(event.dpid)

    def _handle_PacketIn(self, event):
        self.sw_manager.dispatch(event, self.conn)
