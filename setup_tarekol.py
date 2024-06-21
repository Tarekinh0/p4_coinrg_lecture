# Rentrer dans la switch et la configurer pour ajouter les entrees

from p4runtime_switch import P4RuntimeSwitch, P4RuntimeClient

p4info_path = "build/tarekol.p4.p4info.txt"
bmv2_json_path = "build/tarekol.json"

switch = P4RuntimeSwitch("s1", p4info_path, bmv2_json_path)

# Connect to the switch
client = P4RuntimeClient(switch.grpc_addr, switch.device_id)
client.connect()

# Insert table entries
client.add_table_entry(
    table_name="tarekol_compute",
    match_fields={
        "hdr.tarekol.op_type": 1  # Assuming op_type 1 is addition
    },
    action_name="compute_addition"
)

client.add_table_entry(
    table_name="tarekol_compute",
    match_fields={
        "hdr.tarekol.op_type": 2  # Assuming op_type 2 is subtraction
    },
    action_name="compute_subtraction"
)

client.disconnect()

