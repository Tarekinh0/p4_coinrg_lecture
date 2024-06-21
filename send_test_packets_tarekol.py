# tester si ca marche avec 5+3
from scapy.all import *

# Define the custom Tarekol header
class Tarekol(Packet):
    name = "Tarekol"
    fields_desc = [ ByteField("op_type", 1),
                    ShortField("operand1", 0),
                    ShortField("operand2", 0),
                    ShortField("result", 0) ]

bind_layers(IP, Tarekol, proto=0x11)

# Create and send a packet
pkt = Ether(dst="ff:ff:ff:ff:ff:ff") / IP(dst="10.0.0.2", proto=0x11) / Tarekol(op_type=1, operand1=5, operand2=3)
sendp(pkt, iface="h1-eth0")

