####################################################################################
#
# newTclApp.tcl (Experiment with incremental implementation flow)
#
# Created on 10/09/2017 (Xilinx, Inc.)
#
# 2018.1 - v1.0 (rev 1)
#  * initial version
#
####################################################################################
package require Vivado 1.2014.1

namespace eval IncrFlowUtils {

namespace export newTclApp

variable a_all_runs [list]
variable a_global_vars

proc newTclApp {args} {
  # Summary: 
  # 

  # Argument Usage: 
  # [-launch]: Create _incr run of not already created. Setup input run as well as _incr run. Launch input run as well as _incr run.
  # [-reset] : Setup _incr run. Reset input run.
  # [-delete]: Delete input run as well as _incr run.
  # run      : Input run

  # Return Value: None

  variable a_global_vars
  variable a_all_runs
 
  reset_global_vars_
 
  # process options
  for {set i 0} {$i < [llength $args]} {incr i} {
    set option [string trim [lindex $args $i]]
    switch -regexp -- $option {
      "-launch"  { set a_global_vars(operation)    "launch" }
      "-reset"   { set a_global_vars(operation)    "reset"  }
      "-delete"  { set a_global_vars(operation)    "delete" }
      "-jobs"    { incr i; set a_global_vars(jobs) [lindex $args $i] }
      default {
        # is any incorrect switch specified?
        if { [regexp {^-} $option] } {
          error "Unknown option '$option', please type 'newTclApp -help' for usage info\n"
          return
        }

        if { [regex "_incr$" $option] == 0 } {
          lappend a_all_runs $option
        }
      }
    }
  }

  if { [string length $a_global_vars(jobs)] != 0 && ! [string equal $a_global_vars(operation) "launch"] } {
    error "-jobs options is only supported with -launch"
    return
  }

  if { [string length $a_global_vars(jobs)] != 0 } {
    if { [regex "^-" $a_global_vars(jobs)] == 1 || [string is integer $a_global_vars(jobs)] == 0 } {
      error "-jobs can only be a natural number"
      return
    }
  }

  set ret [catch {get_param project.autoParallelRunType} err] 
  if { $ret != 0 } {
    error "Required param project.autoParallelRunType not available"
    return
  }

  set ret [catch {get_param project.autoParallelDCPPath} err] 
  if { $ret != 0 } {
    error "Required param project.autoParallelDCPPath not available"
    return
  }

  if { [get_property IS_READONLY [ current_project ] ] == 1 } {
    error "Cannot operate on READONLY project"
    return
  }
  
  if { ! [file writable [get_property DIRECTORY [current_project]]] } {
    error "Project directory is not writable"
    return
  }

  if {[catch [newTclAppImpl_] err]} {
    reset_global_vars_
  }
}

proc reset_global_vars_ { } {
  variable a_all_runs
  variable a_global_vars

  set a_global_vars(input_run)    ""
  set a_global_vars(incr_run)     "" 
  set a_global_vars(operation)    ""
  set a_global_vars(dirSeparator) ""
  set a_global_vars(jobs)         ""
  set a_all_runs [list]
}

proc newTclAppImpl_ { } {
  variable a_global_vars

  switch -regexp -- $a_global_vars(operation) {
    "launch"  { launch_run_ }
    "reset"   { reset_run_  }
    "delete"  { delete_run_ }
  }

  reset_global_vars_
}

proc launch_run_ { } {
  variable a_all_runs
  variable a_global_vars

  set launch_cmd "launch_runs"
  if { [string length $a_global_vars(jobs)] != 0 } {
    lappend launch_cmd "-jobs"
    lappend launch_cmd $a_global_vars(jobs)
  }

  foreach run $a_all_runs {
    set a_global_vars(input_run)    ""
    set a_global_vars(incr_run)     "" 

    set a_global_vars(input_run) $run
    set a_global_vars(incr_run)  ${run}_incr

    set ret [setup_launch_]

    lappend launch_cmd $ret
#   lappend launch_cmd " "
  }

  set retVal [eval $launch_cmd]
}

proc reset_run_  { } {
  variable a_all_runs
  variable a_global_vars

  foreach run $a_all_runs {
    set a_global_vars(input_run)    ""
    set a_global_vars(incr_run)     "" 

    set a_global_vars(input_run) $run
    set a_global_vars(incr_run)  ${run}_incr

    setup_reset_

    set reset_cmd "reset_run "
    lappend reset_cmd $a_global_vars(input_run)
    set retVal [eval $reset_cmd]
  }
}

proc delete_run_ { } {
  variable a_all_runs
  variable a_global_vars

  foreach run $a_all_runs {
    set a_global_vars(input_run)    ""
    set a_global_vars(incr_run)     "" 

    set a_global_vars(input_run) $run
    set a_global_vars(incr_run)  ${run}_incr

    setup_delete_
  }
}

proc setup_launch_ { } {
  variable a_global_vars

  set cmd [list]
  #if validate fails, anyway launch input run
  #if succeeds, go on to do incremental run setup and then launch them together
  if { [validateLaunch_] == 1 } {
    set allImplRuns [get_runs -filter {SRCSET == sources_1 && IS_IMPLEMENTATION==true}]
    if { [lsearch $allImplRuns $a_global_vars(incr_run)] == -1 } {
      set parent_synth_run [get_property PARENT [get_runs $a_global_vars(input_run)]]
      copy_run -name $a_global_vars(incr_run)   [get_runs $a_global_vars(input_run)] -parent_run $parent_synth_run
      set allImplRuns [get_runs -filter {SRCSET == sources_1 && IS_IMPLEMENTATION==true}]
    }
    #this sets up only in case of ManualRef, else it is set during reset_run
    setIncrementalCheckpointUsing_ $a_global_vars(input_run) $allImplRuns
    if { [is_incremental_checkpoint_set_] == 1 } {
      set incrRunStatus [get_property STATUS [get_runs $a_global_vars(incr_run)]]
      if { ! [string equal $incrRunStatus "Not started"] } {
        set reset_cmd "reset_run "
        lappend reset_cmd $a_global_vars(incr_run)
        set retVal [eval $reset_cmd]
      }

      lappend cmd $a_global_vars(incr_run)
    }
  }

  lappend cmd $a_global_vars(input_run)

  return $cmd
}

proc setup_reset_  { } {
  variable a_global_vars

  if { [isAutoRef_] == 0 } {
    return
  }

  set allImplRuns [get_runs -filter {SRCSET == sources_1 && IS_IMPLEMENTATION==true}]
  if { [isImplRun_ $a_global_vars(input_run)] == 1 } {
    setIncrementalCheckpointUsing_ $a_global_vars(input_run) $allImplRuns
    return
  }

  set childOfInputRun [list]
  foreach implRun $allImplRuns {
    if { [get_property PARENT [get_runs $implRun]] == $a_global_vars(input_run) } {
      lappend childOfInputRun $implRun
    }
  }

  foreach run $childOfInputRun {
    setIncrementalCheckpointUsing_ $run $allImplRuns
  }
}

proc setup_delete_ { } {
  variable a_global_vars

  set origRun [get_runs $a_global_vars(input_run)]
  set isImpl  [isImplRun_  $origRun]

  if { $isImpl == 1 } {
    set allImplRuns [get_runs -filter {SRCSET == sources_1 && IS_IMPLEMENTATION==true}]
    delete_incr_run_ $origRun $allImplRuns
    return
  }

##is synth run is being deleted, bit more cleanup required
##do it here onwards
  set implRuns [get_runs -filter {SRCSET == sources_1 && IS_IMPLEMENTATION==true}]
  set allImplRuns [list]
  foreach run $implRuns {
    set parent [get_property PARENT $run]
    if { $parent == $a_global_vars(input_run) } {
      lappend allImplRuns $run
    }
  }

  set mainRuns [list]
  set incrRuns [list]

  foreach run $allImplRuns {
    if { [regex "_incr$" $run] == 0 } {
      lappend mainRuns $run
    }
  }

  foreach implRun $mainRuns {
    delete_incr_run_ $implRun $allImplRuns
  }
}

proc validateLaunch_ { } {
  variable a_global_vars

  set isAR [isAutoRef_]
  set isMR [isManualRef_]

  if { $isAR == 0 && $isMR == 0 } {
    return 0
  }

# set autoDCPPath [getAutoParallelDCPPath_]
# if { ! [file exists $autoDCPPath] } {
#   return 0
# }

  set runs [get_runs -filter {SRCSET == sources_1 && IS_IMPLEMENTATION==true}]
  if { [lsearch $runs $a_global_vars(input_run)] == -1 } {
    error "Input run '$a_global_vars(input_run)' is not available in project"
    return 0
  } elseif { [isImplRun_ $a_global_vars(input_run)] == 0 } {
    error "Input run '$a_global_vars(input_run)' must be implementation run"
    return 0
  }
   
  # <input_run>_incr can only be associated with <input_run>
  # There is no logic in object model to ascertain that
  # We will purely rely on user to not break this relation
  if { [lsearch $runs $a_global_vars(incr_run)] != -1 } {
    #run is already available
    if { [isImplRun_ $a_global_vars(incr_run)] == 0 } {
      error "Incr run must be implementation run. Rename $a_global_vars(input_run) or $a_global_vars(incr_run) to make sure that this unique pair exists for incremental flow"
      return 0
    }
  }

  return 1
}

proc delete_incr_run_ { origRun allImplRuns } {
  set runDataDir [get_run_data_dir_ $origRun]
  if { [file exists $runDataDir] } {
    file delete -force -- $runDataDir
  }

  set tmp "_incr"
  set incrRun ${origRun}${tmp}
  if { [lsearch $allImplRuns $incrRun] != -1 } {
    delete_runs $incrRun
  }
}

proc setIncrementalCheckpointUsing_ { run allImplRuns } {
  set incrRun ${run}_incr

  if { [lsearch $allImplRuns $incrRun] == -1 } {
    return
  }

  set origRun [get_runs $run]
  set runDataDir [get_run_data_dir_ $origRun]
  if { ! [file exists $runDataDir] } {
    #what if any precedent directory does not exist?
    file mkdir $runDataDir
  }

  set ds [getDS_]
  set isMR [isManualRef_]
  if { $isMR == 1 } {
    set manualRefDCP [getAutoParallelDCPPath_]
    if { ! [file exists $manualRefDCP] } {
      return
    }

    set tmp "reference.dcp"
    set incrCheckpoint ${runDataDir}${ds}${tmp}

    file copy -force $manualRefDCP $runDataDir

    set_property INCREMENTAL_CHECKPOINT $incrCheckpoint [get_runs $incrRun]
    return
  }

  set basename [get_property top [get_filesets sources_1]]
  set dcpPostFix ""

# if { [get_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED $origRun] == 1 } {
#   set dcpPostFix "_postroute_physopt.dcp" 
# } else {
#   set dcpPostFix "_routed.dcp" 
# }

  set dcpPostFix "_routed.dcp" 
  set postRouteDCP ${basename}${dcpPostFix}

  set runDir [get_property DIRECTORY $origRun]

  set dcpFile ${runDir}${ds}${postRouteDCP}

  if { ! [file exists $dcpFile] } {
    return
  }

  set tmp "ref_"
  set incrCheckpoint ${runDataDir}${ds}${tmp}${postRouteDCP}
  file copy -force $dcpFile $incrCheckpoint

  set_property INCREMENTAL_CHECKPOINT $incrCheckpoint [get_runs $incrRun]
}

proc isImplRun_ { run } {
  if { [get_property IS_IMPLEMENTATION [get_runs $run]] == 1 } {
    return 1
  }

  return 0
}

proc get_run_data_dir_ { run } {
##TODO##Cache directory can be set outside project as well##TODO##
  set projectDir [get_property DIRECTORY [current_project]]
  set projAlias  [get_property NAME      [current_project]]
  set runDataDir ""
  set ds [getDS_]

  append runDataDir $projectDir $ds $projAlias ".cache" $ds $run

  return $runDataDir
}

proc getDS_ { } {
  variable a_global_vars

  if { [string length $a_global_vars(dirSeparator)] == 0 } {
    set pform [lindex $::tcl_platform(platform) 0]
    if { $pform == "unix" } {
      set a_global_vars(dirSeparator) "\/"
    } else {
      #windows
      set a_global_vars(dirSeparator) "\\"
    }
  }

  return $a_global_vars(dirSeparator)
}

proc getAutoParallelRunType_ { } {
  set retVal [get_param project.autoParallelRunType]

  return $retVal
}

proc getAutoParallelDCPPath_ { } {
  set retVal [get_param project.autoParallelDCPPath]

  return $retVal
}

proc isAutoRef_ { } {
  set refType [getAutoParallelRunType_]
  if { [string equal $refType "AutoRef"] } {
    return 1
  }

  return 0
}

proc isManualRef_ { } {
  set refType [getAutoParallelRunType_]
  if { [string equal $refType "ManualRef"] } {
    return 1
  }

  return 0
}

proc is_incremental_checkpoint_set_ { } {
  variable a_global_vars

  set incrCheckpoint [get_property INCREMENTAL_CHECKPOINT [get_runs $a_global_vars(incr_run)]]
  set retval 1
  if { [string length $incrCheckpoint] == 0 } {
    set retval 0
  }

  return $retval
}
#### End of TCL App####
}
