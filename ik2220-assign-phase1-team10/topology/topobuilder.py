from mininet.topo import Topo
from collections import defaultdict

'''Declarative topology builder.

This module aims to decouple the mininet.topo.Topo class from populating the
topology.
The TopoBuilder class provides an interface to validate passed in configuration,
and instanciate any object that inherits from mininet.topo.Topo.

CLASSES:
	TopoBuilder
'''

class TopoBuilder(object):
    '''Build Mininet topology from configuration'''
    slots = ('nodes', 'links', '__dpid_cnt', '__man_assigned_dpid')

    def __init__(self, topology):
        self.links = set()
        self.__dpid_cnt = 1
        self.__man_assigned_dpid = set()
        self.nodes = defaultdict(dict)

        for nodedef in topology:
		# Load topology and check for duplicates
            name = nodedef.get('name')
            if not name:
                raise ValueError('`name` not specified')
            typ = nodedef.get('type')
            if not typ:
                raise ValueError('`type` not specified')
            dpid = nodedef.get('dpid')
            if dpid:
                if not dpid in self.__man_assigned_dpid:
                    self.__man_assigned_dpid.add(dpid)
                else:
                    raise ValueError('reuse of `dpid`: %s' % dpid)
            if not self.nodes.get(name):
                self.nodes[name] = nodedef
            else:
                print('WARNING: duplicate entry for %s' % name)

    def __link_exists(self, node1, node2):
        return (node1, node2) in self.links or (node2, node1) in self.links

    def __gen_dpid(self):
        ''' Auto generate DPIDs for switches '''
        # ignore 0x from hex() then pad with 0
        while True:
            dpid = hex(self.__dpid_cnt)[2:].rjust(16, '0')
            self.__dpid_cnt += 1
            if not dpid in self.__man_assigned_dpid:
                break
        return dpid


    def build(self, topo=Topo):
        '''Generate mininet.topo.Topo compatible topology'''

        # instanciate Topo implementation
        impl = topo()
        # any custom type that inherits from mininet.topo.Topo can be used
        # to create the nodes.
        if not isinstance(impl, Topo):
            raise TypeError('`topo` is not instance of `Topo`')
        # load configuration into topo
        for node in self.nodes.values():
            name = node.get('name')
            typ = node.get('type')
            # add matching node types
            if typ == 'HOST':
                ip = node.get('ip')
                impl.addHost(name, ip=ip)
            elif typ in ('SWITCH', 'FIREWALL'):
                links = node.get('links')
                if not links:
                    raise ValueError('%s: dangling switch: missing `links`' % name)
                else:
                    for other in links:
                        if not self.__link_exists(name, other):
                            self.links.add((name, other))
                dpid = node.get('dpid')
                if not dpid:
                    dpid = self.__gen_dpid()
                impl.addSwitch(name, dpid=dpid)
            else:
                raise ValueError('unknown `type`: %s' % typ)
        # set up links
        for (n, m) in self.links:
            impl.addLink(n, m)

        return impl
