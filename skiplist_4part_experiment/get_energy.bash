#!/bin/bash

num_partitions=4
exp=skiplist_${num_partitions}part_experiment
host_stats=${num_partitions}parthost_stats.txt
pim_stats=${num_partitions}partpim_stats.txt

cd ../

# host 
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/$host_stats cacti-out.txt host $exp
mv *-host* $exp

# pim
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/pim-config.json $exp/$pim_stats cacti-out.txt pim $exp
mv *-pim* $exp

mv ${exp}.tsv $exp

#python generate_graph.py "Skiplist(${num_partitions}-partition)" Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
#mv *.png $exp
