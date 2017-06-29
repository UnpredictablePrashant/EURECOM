# Maximum number of CPU cores to use
set_host_options -max_cores 16
# Generate HTML log file
set_app_var html_log_enable true
# Name of HTML log file
set_app_var html_log_filename dc_log.html
# Target standard cells library
set_app_var target_library saed32rvt_tt0p85v25c.db
set edk ${synopsys_root}/../../../EDK/SAED32_EDK/lib
set search_path [concat $search_path ${edk}/stdcell_rvt/db_ccs]
set search_path [concat $search_path ${edk}/stdcell_rvt/db_nldm]
set search_path [concat $search_path ${edk}/stdcell_hvt/db_ccs]
set search_path [concat $search_path ${edk}/stdcell_hvt/db_nldm]
set link_library  [list * $target_library]
set symbol_library ""
# Wire load model
set auto_wire_load_selection true
