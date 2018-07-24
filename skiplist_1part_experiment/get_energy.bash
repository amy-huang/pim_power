#!/bin/bash

exp=skiplist_1part_experiment

cd ../

# host 
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/host-stats.txt cacti-out.txt host $exp
mv *-host* $exp

# pim
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/pim-config.json $exp/pim-stats.txt cacti-out.txt pim $exp
mv *-pim* $exp

python generate_graph.py Skiplist Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
mv *.png $exp
