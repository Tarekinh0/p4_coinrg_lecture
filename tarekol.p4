// Code a injecter dans la switch pour la laisser faire le protocol Tarekol
// Define Ethernet header
header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

// Define IPv4 header
header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

// Define Tarekol header
header tarekol_t {
    bit<8>  op_type;
    bit<16> operand1;
    bit<16> operand2;
    bit<16> result;
}

// Combine headers into a single struct
struct headers {
    ethernet_t ethernet;
    ipv4_t ipv4;
    tarekol_t tarekol;
}

// Define parser for the Tarekol protocol
parser MyParser(packet_in pkt,
                out headers hdr,
                inout standard_metadata_t standard_metadata) {
    state start {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            0x0800: parse_ipv4;
            default: accept;
        }
    }
    
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            0x11: parse_tarekol; // Assuming UDP for simplicity
            default: accept;
        }
    }
    
    state parse_tarekol {
        pkt.extract(hdr.tarekol);
        transition accept;
    }
}

// Define actions for Tarekol computations
action compute_addition() {
    hdr.tarekol.result = hdr.tarekol.operand1 + hdr.tarekol.operand2;
}

action compute_subtraction() {
    hdr.tarekol.result = hdr.tarekol.operand1 - hdr.tarekol.operand2;
}

action send_response() {
    // Swap IPv4 addresses
    bit<32> temp_ip = hdr.ipv4.srcAddr;
    hdr.ipv4.srcAddr = hdr.ipv4.dstAddr;
    hdr.ipv4.dstAddr = temp_ip;

    // Swap Ethernet addresses
    bit<48> temp_mac = hdr.ethernet.srcAddr;
    hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
    hdr.ethernet.dstAddr = temp_mac;

    standard_metadata.egress_spec = standard_metadata.ingress_port;
}

// Define table for Tarekol computations
table tarekol_compute {
    key = {
        hdr.tarekol.op_type: exact;
    }
    actions = {
        compute_addition;
        compute_subtraction;
    }
    size = 256;
    default_action = compute_addition(); // Default action to handle unexpected op_type
}

// Define control block for ingress processing
control MyIngress(inout headers hdr,
                  inout standard_metadata_t standard_metadata) {
    apply(tarekol_compute);
    apply(send_response);
}

// Define control block for egress processing
control MyEgress(inout headers hdr,
                 inout standard_metadata_t standard_metadata) {
    // Egress processing (if needed) can be added here
}

// Define deparser to reassemble the packet
control MyDeparser(packet_out pkt,
                   in headers hdr) {
    pkt.emit(hdr.ethernet);
    pkt.emit(hdr.ipv4);
    pkt.emit(hdr.tarekol);
}

// Define checksum verification control block
control MyVerifyChecksum(inout headers hdr) {
    // Verify checksums if needed
}

// Define checksum computation control block
control MyComputeChecksum(inout headers hdr) {
    // Compute checksums if needed
}

// Define the main control block that ties everything together
V1Switch(MyParser(),
         MyVerifyChecksum(),
         MyIngress(),
         MyEgress(),
         MyComputeChecksum(),
         MyDeparser()) main;
