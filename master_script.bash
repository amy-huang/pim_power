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

do_with_border "./get_stats_and_config.bash"

do_with_border "python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json $xmltemplate"

# Change print level 0-5
do_with_border "./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt"
#cat mcpat_power.txt # Comment to not print output to terminal

do_with_border "cd cacti"
do_with_border "./cacti -infile $cacticonfig > ../cacti_power.txt"
echo "./master_script.bash: line 29:  5662 Segmentation fault      (core dumped) ./cacti -infile pim.cfg > ../cacti_power.txt"
echo "If above 2 lines match, is ok. Cacti segfaults after giving relevant information."
#cat ../cacti_power.txt # Comment to not print output to terminal
do_with_border "cd .."

do_with_border "python record_results.py mcpat_power.txt cacti_power.txt results.txt"


