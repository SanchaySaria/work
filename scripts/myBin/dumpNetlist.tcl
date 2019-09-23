##############pins#############
set ps [open ps.pins w]
set ps_pins [get_pins -of_objects [get_cells -hierarchical versal_cips]]
foreach pin $ps_pins {
    puts $ps $pin
}
close $ps
exec sort -V ps.pins > ps.pins.sort

set noc [open noc.pins w]
set noc_pins [get_pins -of_objects [get_cells -hierarchical axi_noc_0]]
foreach pin $noc_pins {
    puts $noc $pin
}
close $noc
exec sort -V noc.pins > noc.pins.sort

set hub [open hub.pins w]
set hub_pins [get_pins -of_objects [get_cells -hierarchical axi_dbg_hub_0]]
foreach pin $hub_pins {
    puts $hub $pin
}
close $hub
exec sort -V hub.pins > hub.pins.sort

##############nets#############
set ps [open ps.net w]
set ps_pins [get_pins -of_objects [get_cells -hierarchical versal_cips_0]]
foreach pin $ps_pins {
	if { [llength [get_nets -of_objects $pin]] == 0 } {
		puts $ps $pin
	}
}
close $ps
exec sort -V ps.net > ps.net.sort


set noc [open noc.net w]
set noc_pins [get_pins -of_objects [get_cells -hierarchical axi_noc_0]]
foreach pin $noc_pins {
	if { [llength [get_nets -of_objects $pin]] == 0 } {
      puts $noc $pin
	}
}
close $noc
exec sort -V noc.net > noc.net.sort



set hub [open hub.net w]
set hub_pins [get_pins -of_objects [get_cells -hierarchical axi_dbg_hub_0]]
foreach pin $hub_pins {
	if { [llength [get_nets -of_objects $pin]] == 0 } {
		puts $hub $pin
	}
}
close $hub
exec sort -V hub.net > hub.net.sort
#######################################################
set cell [open all.cells w]
set cells [get_cells -hierarchical]
foreach each $cells {
    puts $cell $each
}
close $cell
exec sort -V all.cells > all.cells.sort

set net [open all.nets w]
set nets [get_nets -hierarchical]
foreach each $nets {
    puts $net $each
}
close $net
exec sort -V all.nets > all.nets.sort

#######################################################
##############pins#############
set ps [open ps.pins w]
set ps_pins [get_pins -of_objects [get_cells design_1_i/versal_cips_0]]
foreach pin $ps_pins {
    puts $ps $pin
}
close $ps
exec sort -V ps.pins > ps.pins.sort

set noc [open noc.pins w]
set noc_pins [get_pins -of_objects [get_cells design_1_i/axi_noc_0]]
foreach pin $noc_pins {
    puts $noc $pin
}
close $noc
exec sort -V noc.pins > noc.pins.sort

set hub [open hub.pins w]
set hub_pins [get_pins -of_objects [get_cells design_1_i/axi_dbg_hub_0]]
foreach pin $hub_pins {
    puts $hub $pin
}
close $hub
exec sort -V hub.pins > hub.pins.sort

##############nets#############
set ps [open ps.net w]
set ps_pins [get_pins -of_objects [get_cells design_1_i/versal_cips_0]]
foreach pin $ps_pins {
	if { [llength [get_nets -of_objects $pin]] == 0 } {
		puts $ps $pin
	}
}
close $ps
exec sort -V ps.net > ps.net.sort


set noc [open noc.net w]
set noc_pins [get_pins -of_objects [get_cells design_1_i/axi_noc_0]]
foreach pin $noc_pins {
	if { [llength [get_nets -of_objects $pin]] == 0 } {
      puts $noc $pin
	}
}
close $noc
exec sort -V noc.net > noc.net.sort



set hub [open hub.net w]
set hub_pins [get_pins -of_objects [get_cells design_1_i/axi_dbg_hub_0]]
foreach pin $hub_pins {
	if { [llength [get_nets -of_objects $pin]] == 0 } {
		puts $hub $pin
	}
}
close $hub
exec sort -V hub.net > hub.net.sort

###########################
set cells_prop [open cells_prop w]
set cells [get_cells]
foreach cell $cells {
	set prop [get_property LIB_CELL [get_cells $cell]]
	puts $cells_prop $cell
	puts $cells_prop $prop
}
close $ps
###########################

