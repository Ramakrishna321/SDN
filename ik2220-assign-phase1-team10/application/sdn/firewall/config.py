''' IK2220 SDN Phase 1 Firewall Rules '''

from pox.lib.packet.ipv4 import ipv4

RULES = {
    'fw1_rules':[
        # source, destination, protocol, port, allow?
        ('*', '100.0.0.45/32', ipv4.TCP_PROTOCOL, 80, True),
        ('*', '100.0.0.25/32', ipv4.TCP_PROTOCOL, 53, True),
        ('*', '100.0.0.25/32', ipv4.UDP_PROTOCOL, 53, True),
        ('*', '100.0.0.11/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('*', '100.0.0.12/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('100.0.0.1/32', '*', '*', '*', True),
        ('*', '*', '*', '*', False),
    ],
    'fw2_rules':[
        # source, destination, protocol, port, allow?
        ('100.0.0.1/32', '100.0.0.45/32', ipv4.TCP_PROTOCOL, 80, True),
        ('100.0.0.1/32', '100.0.0.25/32', ipv4.TCP_PROTOCOL, 53, True),
        ('100.0.0.1/32', '100.0.0.25/32', ipv4.UDP_PROTOCOL, 53, True),
        ('100.0.0.1/32', '100.0.0.11/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('100.0.0.1/32', '100.0.0.12/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('*', '*', '*', '*', False),
    ],
    'default':[
        # source, destination, protocol, port, allow?
        ('*', '*', '*', '*', False),
    ],
}
