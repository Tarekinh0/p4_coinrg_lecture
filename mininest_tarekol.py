# deployer le reseau
from mininet.net import Mininet
from mininet.node import RemoteController
from mininet.link import TCLink
from mininet.cli import CLI

def tarekol_topology():
    net = Mininet(controller=RemoteController, link=TCLink)

    h1 = net.addHost('h1')
    h2 = net.addHost('h2')

    s1 = net.addSwitch('s1')

    net.addLink(h1, s1)
    net.addLink(h2, s1)

    net.addController('c0')

    net.start()
    CLI(net)
    net.stop()

if __name__ == '__main__':
    tarekol_topology()

