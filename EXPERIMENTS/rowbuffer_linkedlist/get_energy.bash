#!/bin/bash

# This experiment is for seeing if a row buffer in the NDP setup makes a difference in the linkedlist microbenchmark

base_dir="../../"   # Must run master script from main repo dir
target_dir=$PWD # Put result files in current experiment dir
cd $base_dir

run_name="pim"
./SCRIPTS/master_script.bash XML_FILES/arm15_HostCPUs-PIM.xml XML_FILES/arm15_PimCPUs.xml $target_dir/baseline_buffersize32_final_config.json $target_dir/baseline_buffersize32_final_stats.txt $run_name $target_dir

# Move result files to a specified results folder
if [ ! -d "$target_dir/$run_name" ]; then # If results dir doesn't exist already, make it
   mkdir $target_dir/$run_name 
fi
mv *-$run_name* $target_dir/$run_name
mv $target_dir.tsv $target_dir/$run_name
