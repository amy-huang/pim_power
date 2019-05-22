#!/bin/bash

# Must run the master script from the base directory, and know target directory to put result files in
base_dir="../../"
target_dir=$PWD
cd $base_dir

# pim
./SCRIPTS/master_script.bash XML_FILES/arm15_HostCPUs-PIM.xml XML_FILES/arm15_PimCPUs.xml $target_dir/baseline_buffersize32_final_config.json $target_dir/baseline_buffersize32_final_stats.txt pim $target_dir
# Move result files to a specified results folder
run_name="pim_results"
if [ ! -d "$target_dir/$run_name" ]; then
   mkdir $target_dir/$run_name 
fi
mv *-pim* $target_dir/$run_name
mv $target_dir.tsv $target_dir/$run_name
