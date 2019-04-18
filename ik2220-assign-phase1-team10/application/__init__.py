''' IK2220 Main SDN Application entry-point '''

from pox.core import core
from controller import Controller

# Pox entry point
def launch():
    core.registerNew(Controller)
