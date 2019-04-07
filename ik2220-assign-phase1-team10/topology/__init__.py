''' IK2220 Topology module '''

from config import TOPOLOGY
import topobuilder as builder

def nodeselect(nodename=None, selector=None, many=False):
    def nameselect(nodedef):
        return nodedef.get('name') == nodename

    if not nodename and not selector:
        raise ValueError('provide `nodename` or `selector`')

    if not selector:
        selector = nameselect
    elif not callable(selector):
        raise ValueError('`selector` must be callable')

    matches = []
    for nodedef in TOPOLOGY:
        if selector(nodedef):
            if many:
                matches.append(nodedef)
            else:
                return nodedef
    if matches:
        return matches
