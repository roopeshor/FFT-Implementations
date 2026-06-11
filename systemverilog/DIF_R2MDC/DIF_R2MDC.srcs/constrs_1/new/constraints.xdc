create_clock -period 10.000 -name clk [get_ports clk]


set_switching_activity -toggle_rate 2.000 -static_probability 0.950 [get_ports in_valid]
set_switching_activity -toggle_rate 50.000 -static_probability 0.500 [get_ports {{din_re[*]} {din_im[*]}}]
set_switching_activity -toggle_rate 0.000 -static_probability 0.000 [get_ports rst]

