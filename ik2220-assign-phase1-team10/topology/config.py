''' IK2220 SDN Phase 1 Topology Configuration '''

# Defining the nodes and switches based on the network layout in the project 
# description.
#
# Fields of NODEDEFS:
# - name : name of the node shown in the network layout
# - type : node type to construct [HOST , SWITCH]
# - ip   : [optional field present in HOST] ip address of the HOST
# - links: [optional field present in SWITCH] links to generate between nodes
# - mode : [optional field present in SWITCH defined for FIREWALL] overwrite 
#           functionality for SWITCH 
# - dpid : [optional field present in SWITCH mandatory if mode defined] OpenFlow
#           Switch identifier, auto-gen unless defined
# - config: [mandatory field present in Switch if mode is defined] configuration
#           for specific modes 
NODEDEFS = [
    {
        'name':'h1',
        'type':'HOST',
        'ip':'100.0.0.11/24',
        'MAC':'00:00:00:00:00:01'
    },
    {
        'name':'h2',
        'type':'HOST',
        'ip':'100.0.0.12/24',
        'MAC':'00:00:00:00:00:02'
    },
    {
        'name':'ds1',
        'type':'HOST',
        'ip':'100.0.0.20/24',
        'MAC':'00:00:00:00:00:03'
    },
    {
        'name':'ds2',
        'type':'HOST',
        'ip':'100.0.0.21/24',
        'MAC':'00:00:00:00:00:04'
    },
    {
        'name':'ds3',
        'type':'HOST',
        'ip':'100.0.0.22/24',
        'MAC':'00:00:00:00:00:05'
    },
    {
        'name':'ws1',
        'type':'HOST',
        'ip':'100.0.0.40/24',
        'MAC':'00:00:00:00:00:06'
    },
    {
        'name':'ws2',
        'type':'HOST',
        'ip':'100.0.0.41/24',
        'MAC':'00:00:00:00:00:07'
    },
    {
        'name':'ws3',
        'type':'HOST',
        'ip':'100.0.0.42/24',
        'MAC':'00:00:00:00:00:08'
    },
    {
        'name':'h3',
        'type':'HOST',
        'ip':'10.0.0.51/24',
        'MAC':'00:00:00:00:00:09'
    },
    {
        'name':'h4',
        'type':'HOST',
        'ip':'10.0.0.52/24',
        'MAC':'00:00:00:00:00:0a'
    },
    {
        'name':'insp',
        'type':'HOST',
        'ip':'100.0.0.30/24',
        'MAC':'00:00:00:00:00:0b'
    },
    {
        'name':'sw1',
        'type':'SWITCH',
        'links':{
            'h1',
            'h2',
            'fw1',
        }
    },
    {
        'name':'sw2',
        'type':'SWITCH',
        'links':{
            'fw1',
            'fw2',
            'lb1',
            'ids',
        }
    },
    {
        'name':'sw3',
        'type':'SWITCH',
        'links':{
            'ds1',
            'ds2',
            'ds3',
            'lb1',
        }
    },
    {
        'name':'sw4',
        'type':'SWITCH',
        'links':{
            'ws1',
            'ws2',
            'ws3',
            'lb2',
        }
    },
    {
        'name':'sw5',
        'type':'SWITCH',
        'links':{
            'h3',
            'h4',
            'napt',
        }
    },
    {
        'name':'fw1',
        'type':'SWITCH',
        'dpid':'0000000000000001',
        'mode':'FIREWALL',
        'config':'fw1_rules',
        'links':{
            'sw1',
            'sw2',
        }
    },
    {
        'name':'fw2',
        'type':'SWITCH',
        'dpid':'0000000000000002',
        'mode':'FIREWALL',
        'config':'fw2_rules',
        'links':{
            'napt',
            'sw2',
        }
    },
    {
        'name':'lb1',
        'type':'SWITCH',
#        'dpid':'0000000000000003',
#        'mode':'NFV',
        'links':{
            'sw2',
            'sw3',
        }
    },
    {
        'name':'lb2',
        'type':'SWITCH',
#        'dpid':'0000000000000004',
#        'mode':'NFV',
        'links':{
            'ids',
            'sw4',
        }
    },
    {
        'name':'napt',
        'type':'SWITCH',
        'dpid':'0000000000000005',
        'mode':'NFV',
        'links':{
            'fw2',
            'sw5',
        }
    },
    {
        'name':'ids',
        'type':'SWITCH',
#        'dpid':'0000000000000006',
#        'mode':'NFV',
        'links':{
            'sw2',
            'insp',
        }
    },
]
