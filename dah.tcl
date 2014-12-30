# DihedrAl Histogram (DAH)
# Written by D.K. Weber, 2014

namespace eval ::dah:: {
 namespace export dah
 }

proc dah::example_single {} {
	dah "1 to 54" "N4 C5 C6 O7" 180 -180 12
	dah "1 to 54" "N4 C5 C6 O7" 180 -180 12 -start 200 -stop 300 -skip 2
	}

proc dah::example_single_output {} {
	# Output in xy format for plotting
	set outfile [open "example_xy.dat" w]
	set result [dah "1 to 54" "N4 C5 C6 O7" 180 -180 24]
	set xlist [lindex $result 0]
	set ylist [lindex $result 1]

	set i 0
	foreach bin $xlist {
		set freq [lindex $ylist $i]
		puts $outfile "$bin\t$freq"
		incr i
		}
	close $outfile
	}

proc dah::example_batch_output {} {
	set outfile [open "example_batch.dat" w]
	set dihedrallist {
	"N4 C5 C6 O7"
	"C5 C6 O7 P8"
	"C6 O7 P8 O11"
	"O7 P8 O11 C12"
	"P8 O11 C12 C13"
	"O11 C12 C13 C14"
	"C12 C13 C14 C15"
	"C13 C14 C15 C16"
	"C14 C15 C16 C17"
	"C15 C16 C17 C18"
	"C16 C17 C18 C19"
	"C17 C18 C19 C20"
	"C18 C19 C20 C21"
	"C19 C20 C21 C22"
	"C20 C21 C22 C23" }
	foreach dihedral $dihedrallist {
		puts $outfile [lindex [dah "1 to 54" $dihedral 180 -180 12] 1]
		}
	close $outfile
	}

proc dah { resmask atommask max min bins { args } } {

	# Evaluate flag options
	set start [ dah::variable_assign $args "-start" 1 0 ]
	set stop [ dah::variable_assign $args "-stop" 1 [molinfo top get numframes] ]
	set skip [ dah::variable_assign $args "-skip" 1 1 ]
	
	puts "Measuring resid $resmask and atoms $atommask"
	puts "Frames $start to $stop every $skip"

	set sel [atomselect top "resid $resmask and name $atommask"] 
	set indlist [$sel get index]
	set ridlist [$sel get resid]
	set ridlistu [lsort -unique $ridlist]
	$sel delete
	unset sel

	# Provide array a list of indices for each resid
	set i 0
	foreach resid $ridlist {
		lappend ridindices($resid) [lindex $indlist $i]
		incr i
		}

	# Set the range of each bin
	set dr [expr ($max - $min) / $bins]

	# Initialise arrayed distribution variable
	for {set k 0} {$k < $bins} {incr k} {
		set distribution($k) 0
		}

	# Information for progress meter
	set nf [expr (($stop + 1) - $start) / $skip]
	set f 0

	# Loop over all frames
	for {set frame $start} {$frame <= $stop} {incr frame $skip} {
		# And all residues
		foreach resid $ridlistu {
			set dihedral [measure dihed $ridindices($resid) frame $frame]
			set k [expr int(($dihedral - $min) / $dr)]
			incr distribution($k)
			}
		if { $nf >= 10 } { dah::progress $f $nf }
		incr f
		}	
	puts ""

	# Output results
	for {set k 0} {$k < $bins} {incr k} {
		lappend outlist1 [expr ($k * $dr) + $min]
		lappend outlist2 $distribution($k)
		}

	return [list $outlist1 $outlist2]
	}


######################
#### Dependancies ####
######################

# Modified from http://wiki.tcl.tk/16939
proc dah::progress {cur tot} {
	if {$cur % ($tot/10)} { return }
	# set to total width of progress bar
	set total 100
	set percent [expr {100.*$cur/$tot}]
	set val (\ [format "%6.2f%%" $percent]\ )
	set str "[expr {round($percent*$total/100)}]% "
	puts -nonewline $str
	}

proc dah::variable_assign { args flag input_index default } {
	set value $default
	if { [ lsearch $args $flag ] != -1 } { 
		set value [lindex $args [expr ([lsearch $args $flag ] + $input_index)]]
  		} 
 	return $value
 	}


