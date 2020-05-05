create_clock -name clk -period 20 [get_ports clk]

derive_clock_uncertainty

# this is tAC in the data sheet
set_input_delay -max -clock clk 6 [get_ports sdram_dq[*]]

# this is tOH in the data sheet
set_input_delay -min -clock clk 2.5 [get_ports sdram_dq[*]]

# this is tIS in the data sheet (setup time)
set_output_delay -max -clock clk 1.5 [get_ports sdram_*]

# this is tIH in the data sheet (hold time)
set_output_delay -min -clock clk 1.5 [get_ports sdram_*]

# constrain I/O ports
set_false_path -from * -to [get_ports {key*}]
set_false_path -from * -to [get_ports {led*}]
