#!/bin/bash

exp=skiplist_2part_experiment
host_stats=2parthost_stats.txt
pim_stats=2partpim_stats.txt

cd ../

## host 
#./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/$host_stats cacti-out.txt host $exp
#mv *-host* $exp
#
## pim
#./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/pim-config.json $exp/$pim_stats cacti-out.txt pim $exp
#mv *-pim* $exp
#
python generate_graph.py "Skiplist(2-partition)" Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
mv *.png $exp
