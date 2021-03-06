
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
# multiple cores/memory controllers for the right timestamp durations. Then gem5tomcpat and mcpat are 
# run, then final calculation of energy is put into a result file.
#
# THIS MUST BE RUN FROM THE MAIN REPO DIR.
#####################################################################################################

# Check that the number of arguments is correct and print usage if not
if [ $# -ne 6 ]
    then 
     echo "master_script.bash <cpu XML template> <pim XML template> <config.json path> <stats path> <host or pim> <experiment dir or name>"
     exit 1
fi

# The XML, config, and stats files affect the calculations done for the final energy numbers
cpu_xml=$1
pim_xml=$2
config_path=$3
original_stats=$4
# This variable is entirely for naming results files, and doesn't affect calculations
pim_or_host=$5
# This variable ensures that result files are stored in the right experiment dir, under the appropriate results dir
experiment=$6

# Calculate energy for each number of threads
for num_threads in 2 4 6 8 # For 2, 4, 6, 8 threads
do
	relevant_stats="$num_threads-$pim_or_host-stats.txt"
	echo "Getting stats and aggregating, cleaning into $relevant_stats"
    	grep "timestamp$((num_threads-1))\|timestamp$num_threads" $original_stats > $relevant_stats
	./SCRIPTS/aggregate_stats.bash "$((num_threads-1))" $num_threads $relevant_stats

	echo "Running gem5tomcpat to pull stats and put into XML for mcpat"
	python gem5tomcpat/GEM5ToMcPAT.py $num_threads-$pim_or_host-stats.txt $config_path $cpu_xml

	echo "Running McPAT - energy for host cores, caches, interconnects, memory controllers"
	./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > $num_threads-$pim_or_host-cpu_power.txt
	
	echo "Running gem5tomcpat to pull stats and put into XML for mcpat"
	python gem5tomcpat/GEM5ToMcPAT.py $num_threads-$pim_or_host-stats.txt $config_path $pim_xml

	echo "Running McPAT - energy for pim cores, memory controllers"
	./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > $num_threads-$pim_or_host-pim_power.txt 
    rm mcpat-out.xml

    echo "Writing detailed results to $num_threads-$pim_or_host-results.txt and just numbers to $experiment-$pim_or_host.tsv"
	python ./SCRIPTS/calculate_results.py $num_threads-$pim_or_host-stats.txt $num_threads-$pim_or_host-cpu_power.txt $num_threads-$pim_or_host-pim_power.txt ${experiment}.tsv

done


