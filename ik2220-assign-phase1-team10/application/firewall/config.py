''' Default firewall rules '''

from pox.lib.packet.ipv4 import ipv4

RULES = {
    'fw1_rules':[
        # source, destination, protocol, port, allow?
        ('*', '100.0.0.40/30', ipv4.TCP_PROTOCOL, 80, True),
        ('*', '100.0.0.20/30', ipv4.TCP_PROTOCOL, 53, True),
        ('*', '100.0.0.20/30', ipv4.UDP_PROTOCOL, 53, True),
        ('*', '100.0.0.11/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('*', '100.0.0.12/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('100.0.0.51/32', '*', '*', '*', True),
        ('100.0.0.52/32', '*', '*', '*', True),
        ('*', '*', '*', '*', False),
    ],
    'fw2_rules':[
        # source, destination, protocol, port, allow?
        ('100.0.0.51/32', '100.0.0.40/30', ipv4.TCP_PROTOCOL, 80, True),
        ('100.0.0.52/32', '100.0.0.40/30', ipv4.TCP_PROTOCOL, 80, True),
        ('100.0.0.51/32', '100.0.0.20/30', ipv4.TCP_PROTOCOL, 53, True),
        ('100.0.0.52/32', '100.0.0.20/30', ipv4.TCP_PROTOCOL, 53, True),
        ('100.0.0.51/32', '100.0.0.20/30', ipv4.UDP_PROTOCOL, 53, True),
        ('100.0.0.52/32', '100.0.0.20/30', ipv4.UDP_PROTOCOL, 53, True),
        ('100.0.0.51/32', '100.0.0.11/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('100.0.0.52/32', '100.0.0.11/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('100.0.0.51/32', '100.0.0.12/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('100.0.0.52/32', '100.0.0.12/32', ipv4.ICMP_PROTOCOL, '*', True),
        ('*', '*', '*', '*', False),
    ],
    'default':[
        # source, destination, protocol, port, allow?
        ('*', '*', '*', '*', False),
    ],
}
