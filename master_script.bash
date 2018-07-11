#!/bin/bash

if [ $# -ne 3 ]
    then 
     echo "Master power script: pass in name of xml template and cacti config file and name of result file."
     exit 1
fi

xmltemplate=$1
cacticonfig=$2

config_path="linkedlist_experiment/host-config.json"
original_stats="linkedlist_experiment/host-stats.txt"
scenarionum=12 

cp $config_path ./config.json

for num_threads in 2 4 6 8 # For 2, 4, 6, 8 threads
do
    grep "timestamp$((num_threads-1))\|timestamp$num_threads" $original_stats > cut_stats.txt

	echo "Getting stats and aggregating, cleaning into cut_stats.txt"
	./get_stats_and_config.bash "$((num_threads-1))" 

	echo "Running gem5tomcpat to make XML for mcpat"
	python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json $xmltemplate

	echo "Running McPAT"
	./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt

	echo "Running CACTI"
	cd cacti
	./cacti -infile $cacticonfig > ../cacti_power.txt
	cd ..
	
    echo "Calculating final results"
	cat mcpat_power.txt > $num_threads-testresults.txt 
	cat cacti_power.txt >> $num_threads-testresults.txt
	python record_results.py mcpat_power.txt cacti_power.txt >> $num_threads-testresults.txt
done


