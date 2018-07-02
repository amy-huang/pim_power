#!/bin/bash

./get_stats_and_config.bash
python gem5tomcpat/GEM5ToMcPAT.py cut_stats.txt config.json ARM_gem5_template.xml
./mcpat/mcpat -infile mcpat-out.xml -print_level 5 > mcpat_power.txt
cd cacti
./cacti -infile pim.cfg > ../cacti_power.txt
cd ..
