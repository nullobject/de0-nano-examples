create_clock -name clk -period "50MHz" [get_ports clk]

derive_clock_uncertainty

# constrain output ports
set_false_path -from * -to [get_ports {led*}]
