########################################################################
# Mandatory synthesis parameters
########################################################################
# source_files:                 list of VHDL source files, e.g. {a.vhd b.vhd c.vhd}
# top_level_entity:             name of top-level entity, e.g. accumulator
# target_library                name of target standard cells library, e.g. saed32rvt_tt0p85v25c.db
# clock_period                  clock period (ns), e.g. 2.0
########################################################################
# Optional synthesis parameters without a default value
########################################################################
# clock_name                    name of clock port, needed for proper handling of synchronous designs, e.g. clk
# input_delay                   external input delay (ns), e.g. 1.0
# output_delay                  external output delay (ns), e.g. 1.0
# driving_cell                  external driving cell of all inputs but clock, e.g. DFFX2_RVT
# output_load                   external load on outputs (fF), e.g. 2.0
# max_area                      target maximum silicon area (gates), e.g. 10000
# auto_wire_load_selection      automatic selection of the wire load model (boolean), e.g. true
# html_log_enable               generate HTML log file (boolean), e.g. true
# html_log_filename             name of HTML log file, e.g. dc_log.html
# max_cores                     maximum number of cores to use (1 to 16), e.g. 16
########################################################################

########################################################################
# Synthesis parameters definitions
########################################################################
array set synthesis_parameters [ list \
        source_files             { accumulator.vhd } \
        top_level_entity         accumulator \
        clock_name               clk \
        clock_period             2.0 \
        input_delay              0.5 \
        output_delay             0.5 \
        driving_cell             DFFX2_RVT \
        output_load              2 \
        auto_wire_load_selection true \
        target_library           saed32rvt_tt0p85v25c.db \
        max_cores                4 \
        html_log_enable          true \
        html_log_filename        dc_log.html \
]

########################################################################
# Synthesis parameters, priority:
#   TCL variable > environment variable > synthesis_parameters
# If a TCL variable named dc_foo exists, its value is used for parameter foo.
# Else, if an environment variable named DC_FOO exists, its value is used for
# parameter foo. Else the value defined in array synthesis_parameters(foo) is
# used.
#
# Example of use: to define the source files and the top-level entity using an
# environment variable, call dc_shell with:
#   DC_SOURCE_FILES="{a.vhd b.vhd}" DC_TOP_LEVEL_ENTITY=foobar dc_shell -f syn.tcl
########################################################################
foreach o [ array names synthesis_parameters ] {
        set oo dc_$o
        set OO [ string toupper $oo ]
        if [ info exists $oo ] {
                eval "set synthesis_parameters($o) [ set $oo ]"
        } elseif [ info exists ::env($OO) ] {
                eval "set synthesis_parameters($o) $::env($OO)"
        }
}

########################################################################
# Synthesis parameters, apply
########################################################################
# Target standard cells library
if { ![info exists synthesis_parameters(target_library)] } {
        puts "***** Target standard cells library undefined"
        exit 1
}
puts "***** Target standard cells library: $synthesis_parameters(target_library)"
set_app_var target_library $synthesis_parameters(target_library)
# Maximum number of CPU cores to use
if { [info exists synthesis_parameters(max_cores)] } {
        puts "***** Maximum number of cores to use: $synthesis_parameters(max_cores)"
        set_host_options -max_cores $synthesis_parameters(max_cores)
}
# Generate HTML log file
if { [info exists synthesis_parameters(html_log_enable)] } {
        puts "***** Generate HTML log file: $synthesis_parameters(html_log_enable)"
        set_app_var html_log_enable $synthesis_parameters(html_log_enable)
}
# Name of HTML log file
if { [info exists synthesis_parameters(html_log_filename)] } {
        puts "***** Name of HTML log file: $synthesis_parameters(html_log_filename)"
        set_app_var html_log_filename $synthesis_parameters(html_log_filename)
}

# In case you know what you are doing and you know what the following variables
# do, adapt their values to your needs. Else, leave them as they are, the
# default values are reasonable ones.

# Search path for libraries, library definitions
set edk ${synopsys_root}/../../../EDK/SAED32_EDK/lib
set search_path [concat $search_path ${edk}/stdcell_rvt/db_ccs]
set search_path [concat $search_path ${edk}/stdcell_rvt/db_nldm]
set search_path [concat $search_path ${edk}/stdcell_hvt/db_ccs]
set search_path [concat $search_path ${edk}/stdcell_hvt/db_nldm]
set link_library  [list * $target_library]
set symbol_library ""

########################################################################
# Run the whole synthesis design flow
########################################################################

# You shouldn't change anything after this line. But of course if you know what
# you're doing...

# Read HDL files and elaborate
if { ![info exists synthesis_parameters(source_files)] } {
        puts "***** VHDL source files undefined"
        exit 1
}
foreach f $synthesis_parameters(source_files) {
        if { ![file exists $f] } {
                puts "***** $f: file not found"
                exit 1
        }
        puts "***** Analysing: $f"
        analyze -format vhdl -library work $f
}
if { ![info exists synthesis_parameters(top_level_entity)] } {
        puts "***** Top-level entity undefined"
        exit 1
}
puts "***** Top-level entity: $synthesis_parameters(top_level_entity)"
elaborate $synthesis_parameters(top_level_entity)
if { [current_design] == "" } {
        puts "***** Could not elaborate $synthesis_parameters(top_level_entity) top-level entity"
        exit 1
}

# Set timing constraints
if { ![info exists synthesis_parameters(clock_name)] } {
        set $synthesis_parameters(clock_name) virtual_clock
        puts "***** Clock name undefined, using the default ($synthesis_parameters(clock_name))"
}
if { ![info exists synthesis_parameters(clock_period)] } {
        puts "***** Target clock period undefined"
        exit 1
}
puts "***** Clock period: $synthesis_parameters(clock_period)"
if {[sizeof_collection [get_ports $synthesis_parameters(clock_name)]] > 0} {
        create_clock -period $synthesis_parameters(clock_period) $synthesis_parameters(clock_name)
} else {
        create_clock -period $synthesis_parameters(clock_period) -name $synthesis_parameters(clock_name)
}
if { [info exists synthesis_parameters(input_delay)] } {
        puts "***** Input delays: $synthesis_parameters(input_delay)"
        set_input_delay -clock $synthesis_parameters(clock_name) $synthesis_parameters(input_delay) [all_inputs]
}
if { [info exists synthesis_parameters(output_delay)] } {
        puts "***** Output delays: $synthesis_parameters(output_delay)"
        set_output_delay -clock $synthesis_parameters(clock_name) $synthesis_parameters(output_delay) [all_outputs]
}

# Set design constraints
if { [info exists synthesis_parameters(driving_cell)] } {
        puts "***** Driving cell: $synthesis_parameters(driving_cell)"
        set_driving_cell -no_design_rule -lib_cell $synthesis_parameters(driving_cell) [all_inputs]
}
# If real clock, set infinite drive strength
if {[sizeof_collection [get_ports $synthesis_parameters(clock_name)]] > 0} {
        set_drive 0 $synthesis_parameters(clock_name)
}
if { [info exists synthesis_parameters(output_load)] } {
        puts "***** Output load: $synthesis_parameters(output_load)"
        set_load $synthesis_parameters(output_load) [all_outputs]
}
if [ info exists synthesis_parameters(max_area) ] {
        puts "***** Max area: $synthesis_parameters(max_area)"
        set_max_area $synthesis_parameters(max_area)
}

# Turn on auto wire load selection (library must support this feature)
if [ info exists synthesis_parameters(auto_wire_load_selection) ] {
        puts "***** Automatic wire load selection: $synthesis_parameters(auto_wire_load_selection)"
        set auto_wire_load_selection $synthesis_parameters(auto_wire_load_selection)
}

# Check design
check_design

# Synthesize
compile

# Reports
echo "*********************"
echo "***** AREA REPORT ***"
echo "*********************"
report_area
report_area > $synthesis_parameters(top_level_entity).area
echo "***********************"
echo "***** TIMING REPORT ***"
echo "***********************"
report_timing
report_timing > $synthesis_parameters(top_level_entity).timing

# Write output files
write_file -format verilog -hierarchy -output $synthesis_parameters(top_level_entity).v $synthesis_parameters(top_level_entity)
write_file -format ddc -hierarchy -output $synthesis_parameters(top_level_entity).ddc $synthesis_parameters(top_level_entity)

# Launch GUI
gui_start
gui_create_schematic

# Quit
# quit

# Target technology libraries: in 32/28 nm node, the libraries are named according
# the following syntax:
#
#   saed32Xvt_YYVpVVvTTTc.db
#
# where:
#
# - Xvt = hvt, rvt or lvt, for high, regular and low voltage threshold. The
#   higher the voltage threshold, the slower the library and the lower the
#   static power.
# - YY = ff, tt or ss, for fast-fast, typical-typical and slow-slow, 3 different
#   characterization corners for 3 different manufacturing qualities of N-P
#   transistors. A fast-fast chip is faster than a slow-slow but if the
#   synthesizer is asked to work in the fast-fast corner, it can be that, after
#   manufacturing, typical-typical and slow-slow chips are not fast enough and
#   must be discarded...
# - VpVVv = the power supply voltage used for characterization (in volts).
# - TTT = the temperature used for characterization (in Celsius degrees). If the
#   first character in TTT is a 'n', the temperature is negative.
#
# Example: the saed32hvt_ss0p75v125c.db library is a high voltage threshold one
# (slower than regular or low voltage threshold) with low leakage power. It has
# been characterized for a slow-slow manufacturing process, with a 0.75 V
# voltage and at a 125 C temperature. Use it if you are more concerned with
# leakage power than speed and you want all your manufactured circuits, even the
# ones manufactured in the slow-slow corner, to operate normally with a rather
# low 0.75 V power supply and at a rather high 125 C temperature.
#
# The following libraries are available:
#
# saed32hvt_ff0p85v125c.db
# saed32hvt_ff0p85v25c.db
# saed32hvt_ff0p85vn40c.db
# saed32hvt_ff0p95v125c.db
# saed32hvt_ff0p95v25c.db
# saed32hvt_ff0p95vn40c.db
# saed32hvt_ff1p16v125c.db
# saed32hvt_ff1p16v25c.db
# saed32hvt_ff1p16vn40c.db
# saed32hvt_ss0p75v125c.db
# saed32hvt_ss0p75v25c.db
# saed32hvt_ss0p75vn40c.db
# saed32hvt_ss0p7v125c.db
# saed32hvt_ss0p7v25c.db
# saed32hvt_ss0p7vn40c.db
# saed32hvt_ss0p95v125c.db
# saed32hvt_ss0p95v25c.db
# saed32hvt_ss0p95vn40c.db
# saed32hvt_tt0p78v125c.db
# saed32hvt_tt0p78v25c.db
# saed32hvt_tt0p78vn40c.db
# saed32hvt_tt0p85v125c.db
# saed32hvt_tt0p85v25c.db
# saed32hvt_tt0p85vn40c.db
# saed32hvt_tt1p05v125c.db
# saed32hvt_tt1p05v25c.db
# saed32hvt_tt1p05vn40c.db
# saed32lvt_ff0p85v125c.db
# saed32lvt_ff0p85v125c.lib
# saed32lvt_ff0p85v25c.db
# saed32lvt_ff0p85v25c.lib
# saed32lvt_ff0p85vn40c.db
# saed32lvt_ff0p85vn40c.lib
# saed32lvt_ff0p95v125c.db
# saed32lvt_ff0p95v125c.lib
# saed32lvt_ff0p95v25c.db
# saed32lvt_ff0p95v25c.lib
# saed32lvt_ff0p95vn40c.db
# saed32lvt_ff0p95vn40c.lib
# saed32lvt_ff1p16v125c.db
# saed32lvt_ff1p16v125c.lib
# saed32lvt_ff1p16v25c.db
# saed32lvt_ff1p16v25c.lib
# saed32lvt_ff1p16vn40c.db
# saed32lvt_ff1p16vn40c.lib
# saed32lvt_ss0p75v125c.db
# saed32lvt_ss0p75v125c.lib
# saed32lvt_ss0p75v25c.db
# saed32lvt_ss0p75v25c.lib
# saed32lvt_ss0p75vn40c.db
# saed32lvt_ss0p75vn40c.lib
# saed32lvt_ss0p7v125c.db
# saed32lvt_ss0p7v125c.lib
# saed32lvt_ss0p7v25c.db
# saed32lvt_ss0p7v25c.lib
# saed32lvt_ss0p7vn40c.db
# saed32lvt_ss0p7vn40c.lib
# saed32lvt_ss0p95v125c.db
# saed32lvt_ss0p95v125c.lib
# saed32lvt_ss0p95v25c.db
# saed32lvt_ss0p95v25c.lib
# saed32lvt_ss0p95vn40c.db
# saed32lvt_ss0p95vn40c.lib
# saed32lvt_tt0p78v125c.db
# saed32lvt_tt0p78v125c.lib
# saed32lvt_tt0p78v25c.db
# saed32lvt_tt0p78v25c.lib
# saed32lvt_tt0p78vn40c.db
# saed32lvt_tt0p78vn40c.lib
# saed32lvt_tt0p85v125c.db
# saed32lvt_tt0p85v125c.lib
# saed32lvt_tt0p85v25c.db
# saed32lvt_tt0p85v25c.lib
# saed32lvt_tt0p85vn40c.db
# saed32lvt_tt0p85vn40c.lib
# saed32lvt_tt1p05v125c.db
# saed32lvt_tt1p05v125c.lib
# saed32lvt_tt1p05v25c.db
# saed32lvt_tt1p05v25c.lib
# saed32lvt_tt1p05vn40c.db
# saed32lvt_tt1p05vn40c.lib
# saed32rvt_ff0p85v125c.db
# saed32rvt_ff0p85v25c.db
# saed32rvt_ff0p85vn40c.db
# saed32rvt_ff0p95v125c.db
# saed32rvt_ff0p95v25c.db
# saed32rvt_ff0p95vn40c.db
# saed32rvt_ff1p16v125c.db
# saed32rvt_ff1p16v25c.db
# saed32rvt_ff1p16vn40c.db
# saed32rvt_ss0p75v125c.db
# saed32rvt_ss0p75v25c.db
# saed32rvt_ss0p75vn40c.db
# saed32rvt_ss0p7v125c.db
# saed32rvt_ss0p7v25c.db
# saed32rvt_ss0p7vn40c.db
# saed32rvt_ss0p95v125c.db
# saed32rvt_ss0p95v25c.db
# saed32rvt_ss0p95vn40c.db
# saed32rvt_tt0p78v125c.db
# saed32rvt_tt0p78v25c.db
# saed32rvt_tt0p78vn40c.db
# saed32rvt_tt0p85v125c.db
# saed32rvt_tt0p85v25c.db
# saed32rvt_tt0p85vn40c.db
# saed32rvt_tt1p05v125c.db
# saed32rvt_tt1p05v25c.db
# saed32rvt_tt1p05vn40c.db
#
# Example:
#
# saed32rvt_tt0p85v25c.db is a regular threshold voltage library, that is, it is
# designed for medium leakage power and medium speed. It has been characterized
# with a 0.85 volts power supply, at 25 C° and for a Typical-Typical
# manufacturing quality. Use this library if your design is more sensitive to
# leakage power than to speed, if you accept to drop the Slow-Slow samples after
# manufacturing and if you want your chips to operate in medium voltage and
# temperature conditions. Be warned, however: if your speed contraints are too
# tight, the synthesizer will have a much more difficult job to do; it may fail
# or end up with a larger silicon area than expected.
