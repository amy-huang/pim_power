#!/bin/bash

do_with_border () {
    echo "----------------------------------------------------------------------------------"
    echo $1
    $1
}

if [ $# -ne 2 ]
    then 
     echo "Master power script: pass in name of xml template and cacti config file."
     exit 1
fi

xmltemplate=$1
cacticonfig=$2

#do_with_border "./get_stats_and_config.bash"
echo "Getting stats and aggregating, cleaning into cut_stats.txt"
./get_stats_and_config.bash

#do_with_border "python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json $xmltemplate"
echo "Running gem5tomcpat to make XML for mcpat"
python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json $xmltemplate

#do_with_border "./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt"
echo "Run McPAT"
./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt

#do_with_border "cd cacti"
echo "Run CACTI"
cd cacti
#do_with_border "./cacti -infile $cacticonfig > ../cacti_power.txt"
./cacti -infile $cacticonfig > ../cacti_power.txt
#do_with_border "cd .."
cd ..

#do_with_border "python record_results.py mcpat_power.txt cacti_power.txt results.txt"
echo "Calculate final results"
python record_results.py mcpat_power.txt cacti_power.txt results.txt


