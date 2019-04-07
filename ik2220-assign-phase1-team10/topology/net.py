''' IK2220 Main Mininet network simulation '''

# import guard
if __name__ != '__main__':
    raise ImportError()

import config as cfg
from topobuilder import TopoBuilder

from mininet.net import Mininet
from mininet.node import Switch
from mininet.node import RemoteController
from mininet.node import OVSSwitch
from mininet.cli import CLI

# Build topology with default mininet.topo.Topo implementation
# from phase1 configuration
TOPO = TopoBuilder(cfg.TOPOLOGY).build()

# Create remote controller, that will connect to POX on localhost
CTRL = RemoteController('c0', ip='127.0.0.1', port=6633)

# Create mininet with external switches, and controller
NET = Mininet(topo=TOPO,
              switch=OVSSwitch,
              controller=CTRL,
              autoSetMacs=True,
              autoStaticArp=True,
              build=True,
              cleanup=True)

NET.start()
CLI(NET)
