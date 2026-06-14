# ==============================================================================
# Vivado Parameter Sweep Script (Non-Project Mode)
# ==============================================================================

# 1. Define your sweep parameters and target FPGA
set stages_list {4 5 6 7 8 9 10 11 12 13}
# CHANGE THIS to your actual FPGA part number
set target_part "xc7a100tcsg324-1" ;

# 2. Start the sweep loop
foreach val $stages_list {
    puts "======================================================="
    puts " STARTING RUN: STAGES = $val"
    puts "======================================================="

    # Clear Vivado's memory from the previous loop iteration
    close_project -quiet
    create_project -in_memory -part $target_part

    # 3. Read your source code and constraints
    # (Update these paths to point to your actual .sv and .xdc files)
    read_verilog -sv [glob ./*.sv]
    read_xdc ./constraints.xdc

    # 4. Run Synthesis AND INJECT THE PARAMETER
    # The -generic flag overwrites the default parameter in your SystemVerilog file
    synth_design -top R2SDC -part $target_part -generic STAGES=$val
    
    # 5. Run Implementation (Physical Place and Route)
    opt_design
    place_design
    route_design
    phys_opt_design -directive Explore

    # 6. Generate Custom Reports for this specific run
    # We append the $val variable to the filenames so they don't overwrite each other
    # 6. Generate a single Master Report for this run
    set report_file "reports/master_report_STAGES_${val}.txt"

    # Step A: Open the file in write mode ("w") for raw Tcl outputs
    set fp [open $report_file "w"]
    
    puts $fp "======================================================="
    puts $fp " MASTER REPORT: R2SDC FFT (STAGES = $val)"
    puts $fp "======================================================="
    
    # Calculate and write the total net count
    set total_nets [llength [get_nets -hierarchical]]
    puts $fp "\n--- TOTAL NET COUNT ---"
    puts $fp "Logical Nets: $total_nets\n"
    
    # Close the file so Vivado can take over
    close $fp

    # Step B: Append all Vivado reports to the same file
    report_utilization -hierarchical -file $report_file -append
    report_route_status -show_all -file $report_file -append
    report_timing_summary -file $report_file -append
    report_power -file $report_file -append
    
    
    

    # Optional: Save a physical checkpoint so you can open the implemented 
    # design in the GUI later if you want to look at the routing.
    write_checkpoint -force "checkpoints/R2SDC_implemented_STAGES_${val}.dcp"

    puts "======================================================="
    puts " FINISHED RUN: STAGES = $val"
    puts "======================================================="
}

puts "All parameter sweeps completed successfully!"
