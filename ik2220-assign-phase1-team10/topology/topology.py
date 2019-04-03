'''IK2220 SDN Topology Module'''

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import Switch
from mininet.cli import CLI

from config import TOPOLOGY
from config import LINKS

class Topology(Topo):
    slots = ('machines')

    def __init__(self):
        Topo.__init__(self)
        self.machines = dict()

        for (name, typ, addr) in TOPOLOGY.values():
            if typ == 'Host':
                self.machines[name] = self.addHost(name)
            if typ == 'Switch':
                self.machines[name] = self.addSwitch(name)

        for (node1, node2) in LINKS:
            self.addLink(self.machines[node1], self.machines[node2])
        print('INIT DONE')

if __name__ == '__main__':
    topo = Topology()
    net = Mininet(topo=topo)
    net.start()
    CLI(net)
