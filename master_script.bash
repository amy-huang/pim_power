#!/bin/bash
#####################################################################################################
# This script calculates energy consumed by a scenario experiment. It takes in
#
# 1) An XML template for gem5tomcpat, with stat values set to the names of stats from the stats file
# 2) A CACIT config file, which is in the cacti directory, used to model HMC usage
# 3) A config.json file from the simulation needed by McPAT
# 4) A stats file containing 2, 4, 6, 8 thread stats in the timestamp periods of the same numbers.
#
# First, the stats processing script get_stats_and_config.bash is called to aggregate stats across
# multiple cores/memory controllers for the right timestamp durations. Then gem5tomcpat, mcpat, and
# cacti are run, then final calculation of energy is put into a result file.
#####################################################################################################

# Check that the number of arguments is correct and print usage if not
if [ $# -ne 5 ]
    then 
     echo "./master_script.bash <XML template> <config.json path> <stats path> <cacti out file> <host or pim>"
     exit 1
fi

# Name arguments
xmltemplate=$1
config_path=$2
original_stats=$3
cacti_out=$4
pim_or_host=$5

# Copy config file to current directory for use by gem5tomcpat
cp $config_path ./config.json

# Calculate energy for each number of threads
for num_threads in 2 4 6 8 # For 2, 4, 6, 8 threads
do
    # Copy the relevant timestamps to new stats file with both timestamps; some stats are cumulative
    # Ex. if num_threads is 6, we copy timestamps 5 and 6 to cut_stats.txt
    grep timestamp$num_threads $original_stats > $num_threads-$pim_or_host-stats.txt

    grep "timestamp$((num_threads-1))\|timestamp$num_threads" $original_stats > cut_stats.txt

	echo "Getting stats and aggregating, cleaning into cut_stats.txt"
	./get_stats_and_config.bash "$((num_threads-1))" num_threads 

	echo "Running gem5tomcpat to pull stats and put into XML for mcpat"
	python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json $xmltemplate

	echo "Running McPAT - energy for cores, caches, interconnects"
	./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt
	
    echo "Calculating energy for memory controllers, HMC main memory, and total; writing mcpat, cacti output and final results"
	python record_results.py mcpat_power.txt $cacti_out > $num_threads-$pim_or_host-results.txt
	cat mcpat_power.txt >> $num_threads-$pim_or_host-results.txt 
	
done


