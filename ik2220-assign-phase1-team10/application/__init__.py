''' IK2220 Main SDN Application entry-point '''

from pox.core import core
from controller import Controller

def launch():
    core.registerNew(Controller)
