''' WIP controller '''

from pox.core import core

from components import SwitchManager

class Controller(object):
    slots = ('sw_manager')

    def __init__(self):
        core.openflow.addListeners(self)
        self.sw_manager = SwitchManager()

    def _handle_ConnectionUp(self, event):
        self.sw_manager.register(event.dpid, event.connection)

    def _handle_PacketIn(self, event):
        self.sw_manager.dispatch(event)
