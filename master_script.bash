#!/bin/bash
#####################################################################################################
# This script calculates energy consumed by a scenario experiment. It takes in
#
# 1) An XML template for gem5tomcpat, with stat values set to the names of stats from the stats file
# 2) A CACIT config file, which is in the cacti directory, used to model HMC usage
# 3) A config.json file from the simulation needed by McPAT
# 4) A stats file containing 2, 4, 6, 8 thread stats in the timestamp periods of the same numbers.
#    In total there are 8 timestamps, with odd ones showing stats for preparing data structures
#    and the even ones showing stats for the application execution - what we care about
#
# First, the stats processing script get_stats_and_config.bash is called to aggregate stats across
# multiple cores/memory controllers for the right timestamp durations. Then gem5tomcpat, mcpat, and
# cacti are run, then final calculation of energy is put into a result file.
#####################################################################################################

# Check that the number of arguments is correct and print usage if not
if [ $# -ne 6 ]
    then 
     echo "./master_script.bash <XML template> <config.json path> <stats path> <cacti out file> <host or pim> <experiment dir or name>"
     exit 1
fi

# Name arguments
xmltemplate=$1
config_path=$2
original_stats=$3
cacti_out=$4
pim_or_host=$5
experiment=$6

# Copy config file to current directory for use by gem5tomcpat
cp $config_path ./config.json

# Add column headers to result file that only has numbers
echo "Total mcpat_ng activ/rw/pre    refresh background  sim_seconds num_reads   num_writes" > $experiment-$pim_or_host.tsv

# Calculate energy for each number of threads
for num_threads in 2 4 6 8 # For 2, 4, 6, 8 threads
do
    # Copy the relevant timestamps to new stats file with both timestamps; some stats are cumulative
    # Ex. if num_threads is 6, we copy timestamps 5 and 6 to cut_stats.txt
    grep timestamp$num_threads $original_stats > $num_threads-$pim_or_host-stats.txt

    grep "timestamp$((num_threads-1))\|timestamp$num_threads" $original_stats > cut_stats.txt

	echo "Getting stats and aggregating, cleaning into cut_stats.txt"
	./aggregate_stats.bash "$((num_threads-1))" num_threads 

	echo "Running gem5tomcpat to pull stats and put into XML for mcpat"
	python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json $xmltemplate

	echo "Running McPAT - energy for cores, caches, interconnects"
	./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt
	
    echo "Writing detailed results to $num_threads-$pim_or_host-results.txt and just numbers to $experiment-$pim_or_host.tsv"
	python record_results.py mcpat_power.txt $cacti_out $experiment-$pim_or_host.tsv > $num_threads-$pim_or_host-results.txt
	cat mcpat_power.txt >> $num_threads-$pim_or_host-results.txt 
done


