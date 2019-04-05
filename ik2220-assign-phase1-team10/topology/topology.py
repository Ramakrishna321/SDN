'''IK2220 SDN Topology Module'''

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import Switch
from mininet.node import RemoteController
from mininet.node import OVSSwitch
from mininet.cli import CLI

from config import TOPOLOGY
from config import LINKS

class Topology(Topo):
    slots = ('machines')

    def __init__(self):
        Topo.__init__(self)
        self.machines = {}

        for (name, typ, ident) in TOPOLOGY.values():
            if typ == 'Host':
                self.machines[name] = self.addHost(name)
            if typ == 'Switch':
                self.machines[name] = self.addSwitch(name, dpid=ident)

        for (node1, node2) in LINKS:
            self.addLink(self.machines[node1], self.machines[node2])

if __name__ == '__main__':
    topo = Topology()
    ctrl = RemoteController('c0', ip='127.0.0.1', port=6633)
    net = Mininet(topo=topo,
                  switch=OVSSwitch,
                  controller=ctrl,
                  autoSetMacs=True,
                  autoStaticArp=True,
                  build=True,
                  cleanup=True)
    net.start()
    CLI(net)
