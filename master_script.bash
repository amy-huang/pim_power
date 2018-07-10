#!/bin/bash

if [ $# -ne 3 ]
    then 
     echo "Master power script: pass in name of xml template and cacti config file and name of result file."
     exit 1
fi

xmltemplate=$1
cacticonfig=$2
resultfile=$3

export scenarionum=12  #Unique to scenario
echo "Getting stats and aggregating, cleaning into cut_stats.txt"
./get_stats_and_config.bash $scenarionum

echo "Running gem5tomcpat to make XML for mcpat"
python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json $xmltemplate

echo "Running McPAT"
./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt

echo "Running CACTI"
cd cacti
./cacti -infile $cacticonfig > ../cacti_power.txt
cd ..

echo "Calculating final results"
cat mcpat_power.txt >> $resultfile
cat cacti_power.txt >> $resultfile
python record_results.py mcpat_power.txt cacti_power.txt >> $resultfile



