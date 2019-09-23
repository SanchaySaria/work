proc removeUnrelatedInfoUsingPlatformDependentCalls { outFile {ignoreFilePath 0}} {
  if {![file isfile $outFile]} {
    error "File $outFile does not exist"
    return
  }

  set pform [lindex $::tcl_platform(platform) 0]

  if { $pform == "windows" } {
    exec sed -i {s/.:.*my_pr_project\\//my_pr_project\\//g} $outFile
    exec sed -i {s/\\/.*my_pr_project\\//my_pr_project\\//g} $outFile
    exec sed -i {s/.:.*pr_flow\\//pr_flow\\//g} $outFile
    exec sed -i {s/\\/.*pr_flow\\//pr_flow\\//g} $outFile
    exec sed -i {s/TEST_WORK.*win64\\///g} $outFile
    exec sed -i {s/TEST_WORK.*lnx64\\///g} $outFile
  } else {
    exec sed -i {s/.:.*my_pr_project\//my_pr_project\//g} $outFile
    exec sed -i {s/\/.*my_pr_project\//my_pr_project\//g} $outFile
    exec sed -i {s/\/.*pr_flow\//pr_flow\//g} $outFile
    exec sed -i {s/TEST_WORK.*lnx64\///g} $outFile
  }
  if { $ignoreFilePath == 1 } {
    exec sed -i {s/read_xdc.*\//read_xdc /g} $outFile
  }
  exec sed -i {s/_l6//g} $outFile
}

proc removeUnrelatedInfo { tmpFile outFile {ignoreFilePath 0}} {
  if {![file isfile $tmpFile]} {
    error "ERROR: File $tmpFile does not exist"
    return
  }
  if {[file isfile $outFile]} {
    puts "File $outFile already exists. Removing"
    exec rm -f $outFile
  }

  exec cat $tmpFile | grep -v -e "set_param" > $outFile

  removeUnrelatedInfoUsingPlatformDependentCalls $outFile $ignoreFilePath
}

proc removeIPRepoPaths { file } {
  if {![file isfile $file]} {
    error "ERROR: File $file does not exist"
    return
  }

  set isIPRepoPathInfoPresent [catch {exec grep "ip_repo_paths" $file} result]
  if {$isIPRepoPathInfoPresent != 0} {
    return
  }

  set isIPRepoOneLiner [catch {exec grep "ip_repo_paths.*current_project" $file} result]

  if { $isIPRepoOneLiner == 0 } {
#   puts "Clipping the only ip_repo_paths entry"
    exec sed -i {/ip_repo_paths/d} $file
  } else {
#   puts "Clipping multiple ip_repo_paths entries"
    exec sed -i {/ip_repo_paths/,/current_project/d} $file
  }
}

proc extractInitDesignStepInfoFromFile { file outFile {ignoreFilePath 0}} {
  if {[file isfile $outFile]} {
    error "ERROR: File $outfile already exists"
    exec rm -f $outFile
  }

  set stepS [catch {exec grep "create_msg_db init_design" $file} result]
  set stepE [catch {exec grep "close_msg_db -file init_design"  $file} result]

  if {$stepS != 0} {
    error "ERROR: create_msg_db init_design information not found in $file"
    return
  }
  if {$stepE != 0} {
    error "ERROR: close_msg_db -file init_design information not found in $file"
    return
  }

  set blockStart [eval exec {grep -n "create_msg_db init_design" $file | sed -e "s/:.*//g"}]
  set blockEnd [eval exec {grep -n "close_msg_db -file init_design"  $file | sed -e "s/:.*//g"}]
  set blockLines [expr $blockEnd - $blockStart]

  if { $blockLines > 0} {
    exec grep -A$blockLines "create_msg_db init_design.pb" $file > $outFile.tmp

    removeUnrelatedInfo $outFile.tmp $outFile.tmp1 $ignoreFilePath

    removeIPRepoPaths $outFile.tmp1

    exec cat $outFile.tmp1 | grep -e "add_files" -e "get_files" -e "lock_design" -e "link_design" -e "read_xdc" -e "open_checkpoint" | sort > $outFile

    exec rm -f $outFile.tmp1
    exec rm -f $outFile.tmp
  } else {
    error "ERROR: $step information not correctly aligned in $file"
    exec touch $outFile
  }
}

proc extractStepInfoFromFile { step file outFile {ignoreFilePath 0}} {
# puts "extractStepInfoFromFile $step $file"
  if {[file isfile $outFile]} {
    puts "File $outfile already exists. Removing"
    exec rm -f $outFile
  }

  set stepS [catch {exec grep "create_msg_db $step" $file} result]
  set stepE [catch {exec grep "close_msg_db -file $step"  $file} result]

  if {$stepS != 0} {
    error "ERROR: create_msg_db $step information not found in $file"
    return
  }
  if {$stepE != 0} {
    error "ERROR: close_msg_db -file $step information not found in $file"
    return
  }

  set blockStart [eval exec {grep -n "create_msg_db $step" $file | sed -e "s/:.*//g"}]
  set blockEnd [eval exec {grep -n "close_msg_db -file $step"  $file | sed -e "s/:.*//g"}]
# puts "$file: Step $step starts at line: $blockStart"
# puts "$file: Step $step ends at line: $blockEnd"
  set blockLines [expr $blockEnd - $blockStart]

  if { $blockLines > 0} {
    exec grep -A$blockLines "create_msg_db $step.pb" $file > $outFile.tmp

    exec cat $outFile.tmp | grep -e "write_checkpoint" -e "update_design" -e "lock_design" -e "write_bitstream" -e "set_property.*HD.RECONFIGURABLE.*get_cells" > $outFile.tmp1

    removeUnrelatedInfo $outFile.tmp1 $outFile $ignoreFilePath

    exec rm -f $outFile.tmp
    exec rm -f $outFile.tmp1
  } else {
    error "ERROR: $step information not correctly aligned in $file"
  }
}

proc compareSteps { steps dir file goldFile {ignoreFilePath 0}} {
# puts "compareSteps $steps $dir $file $goldFile"
  if {![file isdirectory $dir]} {
    error "ERROR: Directory $dir does not exist"
    return
  }
  if {![file isfile $dir/$file]} {
    error "ERROR: File $dir/$file does not exist"
  }
  if {![file isfile $dir/$goldFile]} {
    error "ERROR: File $dir/$goldFile does not exist"
  }

  exec rm -rf tmp
  exec mkdir tmp
  exec cp $dir/$file tmp
  exec cp $dir/$goldFile tmp
  cd tmp

#TODO.Include disabled step names as well.
  foreach step $steps {
    switch $step {
      "init_design" {
        puts "Comparing step: $step in $dir/$file and $dir/$goldFile"
        extractInitDesignStepInfoFromFile $file tmp.$step.$file $ignoreFilePath
        extractInitDesignStepInfoFromFile $goldFile tmp.$step.$goldFile $ignoreFilePath
      }
      "opt_design" -
      "place_design" -
      "route_design" -
      "post_route_phys_opt_design" -
      "write_bitstream" {
        puts "Comparing step: $step in $dir/$file and $dir/$goldFile"
        extractStepInfoFromFile $step $file tmp.$step.$file $ignoreFilePath
        extractStepInfoFromFile $step $goldFile tmp.$step.$goldFile $ignoreFilePath
      }
      default {
        error "Typo in Step name: $step"
        return
      }
    }

    set retVal [catch {exec diff -w tmp.$step.$file tmp.$step.$goldFile} err]
    if { $retVal != 0 } {
      puts "$err"
      error "Step $step mismatch found. For details, check files tmp.$step.$file and tmp.$step.$goldFile"
      return
    }
  }

  cd ..
  exec rm -rf tmp
}
