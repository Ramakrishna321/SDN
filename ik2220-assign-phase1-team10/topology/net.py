''' IK2220 Main Mininet network simulation '''
import sys
import time

from config import NODEDEFS as cfg
from topobuilder import TopoBuilder

from mininet.net import Mininet
from mininet.node import Switch
from mininet.node import RemoteController
from mininet.node import OVSSwitch
from mininet.cli import CLI
from mininet.log import output

# import guard
if __name__ != '__main__':
    raise ImportError('module cannot be imported!')

# Build topology with default mininet.topo.Topo implementation
# from phase1 configuration
TOPO = TopoBuilder(cfg).build()

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


#Define the Web Server nodes, start the servers
WS1 = NET.get('ws1')
WS1.cmd('python services/webserver.py &')

WS2 = NET.get('ws2')
WS2.cmd('python services/webserver.py &')

WS3 = NET.get('ws3')
WS3.cmd('python services/webserver.py &')

#Define the Name Server nodes, start the servers
DS1 = NET.get('ds1')
DS1.cmd('python services/dns.py %s %s &' % (DS1.IP(), DS1.intfNames()[0]))

DS2 = NET.get('ds2')
DS2.cmd('python services/dns.py %s %s &' % (DS2.IP(), DS2.intfNames()[0]))

DS3 = NET.get('ds3')
DS3.cmd('python services/dns.py %s %s &' % (DS3.IP(), DS3.intfNames()[0]))

#Define the user nodes
H1 = NET.get('h1')
H2 = NET.get('h2')
H3 = NET.get('h3')
H4 = NET.get('h4')

INSP = NET.get('insp')

#Run script to test the topo, tests are defined in script
script = None
if len(sys.argv) > 1:
    script = sys.argv[1:]
    output("STARTING IN TEST MODE\n")
    output("Wait for 10 seconds for nodes to come up:\n")
    time.sleep(10)
    output("------------------------------------------------------------------------------\n")
    output("Begin Tests:")
    output("Test 1:\n")
    output("Netcat from h4 to ds1 using UDP and TCP at different ports\n")
    CLI(NET, script=script[0])
    output("------------------------------------------------------------------------------\n")
    output("Test 2:\n")
    output("Netcat from h2 to ds2 using UDP and TCP at different ports\n")
    CLI(NET, script=script[1])
    output("------------------------------------------------------------------------------\n")
    output("Test 3:\n")
    output("Netcat from insp to ds3 using UDP and TCP at different ports\n")
    CLI(NET, script=script[2])
    output("------------------------------------------------------------------------------\n")
    output("Test 4:\n")
    output("DIG at port 80 of ds1 ds2 ds3 from h1 h3 and insp resp. \n")
    CLI(NET, script=script[3])
    output("------------------------------------------------------------------------------\n")
    output("Test 5:\n")
    output("DIG at port 69 of ds1 ds2 ds3 from h1 h3 and insp resp. \n")
    CLI(NET, script=script[4])
    output("------------------------------------------------------------------------------\n")
    output("Test 6:\n")
    output("CURL at port 80 of ws1 ws2 ws3 from h1 h3 and insp resp. \n")
    CLI(NET, script=script[5])
    output("------------------------------------------------------------------------------\n")
    output("Test 7:\n")
    output("CURL at port 80 of ws1 ws2 ws3 from h1 h3 and insp resp. \n")
    CLI(NET, script=script[6])
    output("------------------------------------------------------------------------------\n")
    output("Test 8:\n")
    output("CURL at port 69 of ws1 ws2 ws3 from h2 h4 and insp resp. \n")
    CLI(NET, script=script[7])
    output("--------------------------------------------------------------------\n")
    output("Test 9:\n")
    output("Final Test: Ping All\n")
    CLI(NET, script=script[8])
    output("--------------------------------------------------------------------\n")
else:
    CLI(NET, None)