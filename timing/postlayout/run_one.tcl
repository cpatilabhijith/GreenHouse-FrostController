# Single-corner post-layout STA (netlist + SPEF)
# Environment variables expected: LIB_FILE, NETLIST_FILE, SDC_FILE, SPEF_FILE

read_liberty $env(LIB_FILE)
read_verilog $env(NETLIST_FILE)
link_design greenhouse_frost_controller
read_sdc $env(SDC_FILE)
read_spef $env(SPEF_FILE)

puts "----- SETUP (max) -----"
report_checks -path_delay max -format summary -digits 4
report_worst_slack -max

puts "----- HOLD (min) -----"
report_checks -path_delay min -format summary -digits 4
report_worst_slack -min

puts "----- TNS / WNS -----"
report_tns
report_wns

exit
