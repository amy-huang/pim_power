#!/bin/bash
xmltemplate=$1

echo "./get_stats_and_config.bash"
./get_stats_and_config.bash

echo "python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json ARM_gem5_template.xml"
python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json $xmltemplate 

echo "./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt"
./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt

echo "cd cacti"
cd cacti

echo "./cacti -infile pim.cfg > ../cacti_power.txt"
./cacti -infile pim.cfg > ../cacti_power.txt

echo "cd .."
cd ..

echo "python record_results.py mcpat_power.txt cacti_power.txt results.txt"
python record_results.py mcpat_power.txt cacti_power.txt results.txt 


