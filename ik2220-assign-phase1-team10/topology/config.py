''' IK2220 SDN Phase 1 Topology Configuration '''

class Dpid(object):
    cnt = 1
    def __init__(self):
        pass
    @staticmethod
    def get():
        dpid = hex(Dpid.cnt)[2:]
        dpid = dpid.rjust(16, '0')
        Dpid.cnt += 1
        return dpid

TOPOLOGY = {"h1"   : ('h1', 'Host', '100.0.0.11/24'),
            "h2"   : ('h2', 'Host', '100.0.0.12/24'),
            "ds1"  : ('ds1', 'Host', '100.0.0.20/24'),
            "ds2"  : ('ds2', 'Host', '100.0.0.21/24'),
            "ds3"  : ('ds3', 'Host', '100.0.0.22/24'),
            "ws1"  : ('ws1', 'Host', '100.0.0.40/24'),
            "ws2"  : ('ws2', 'Host', '100.0.0.41/24'),
            "ws3"  : ('ws3', 'Host', '100.0.0.42/24'),
            "h3"   : ('h3', 'Host', '100.0.0.51/24'),
            "h4"   : ('h4', 'Host', '100.0.0.52/24'),
            "sw1"  : ('sw1', 'Switch', Dpid.get()),
            "sw2"  : ('sw2', 'Switch', Dpid.get()),
            "sw3"  : ('sw3', 'Switch', Dpid.get()),
            "sw4"  : ('sw4', 'Switch', Dpid.get()),
            "sw5"  : ('sw5', 'Switch', Dpid.get()),
            "fw1"  : ('fw1', 'Switch', Dpid.get()),
            "fw2"  : ('fw2', 'Switch', Dpid.get()),
            "ib1"  : ('ib1', 'Switch', Dpid.get()),
            "ib2"  : ('ib2', 'Switch', Dpid.get()),
            "napt" : ('napt', 'Switch', Dpid.get()),
            "ids"  : ('ids', 'Switch', Dpid.get()),
            "insp" : ('insp', 'Host', '100.0.0.30/24')}

LINKS = {('h1', 'sw1'),
         ('h2', 'sw1'),
         ('h3', 'sw5'),
         ('h4', 'sw5'),
         ('ds1', 'sw3'),
         ('ds2', 'sw3'),
         ('ds3', 'sw3'),
         ('ws1', 'sw4'),
         ('ws2', 'sw4'),
         ('ws3', 'sw4'),
         ('sw1', 'fw1'),
         ('fw1', 'sw2'),
         ('sw2', 'fw2'),
         ('sw2', 'ib1'),
         ('sw2', 'ids'),
         ('ids', 'insp'),
         ('ids', 'ib2'),
         ('ib2', 'sw4'),
         ('ib1', 'sw3'),
         ('fw2', 'napt'),
         ('napt', 'sw5')}
