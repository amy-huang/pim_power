#!/bin/bash

exp=skiplist_hostlockfree

cd ../

# host 
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/hostlockfree_stats.txt cacti-out.txt host $exp
mv *-host* $exp
mv ${exp}.tsv $exp

#python generate_graph.py "Skiplist(${num_partitions}-partition)" Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
#mv *.png $exp
