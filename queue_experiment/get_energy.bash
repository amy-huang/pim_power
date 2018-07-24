#!/bin/bash

exp=queue_experiment

cd ../

# host fc
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/host_fc_stats.txt cacti-out.txt host $exp
rename -v 's/-host/-hostFC/' ./*
mv *-hostFC* $exp

# host fc new
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/host_fc_new_stats.txt cacti-out.txt host $exp
rename -v 's/-host/-hostFCnew/' ./*
mv *-hostFCnew* $exp

# host lockfree 
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/host_lockfree_stats.txt cacti-out.txt host $exp
rename -v 's/-host/-hostLF/' ./*
mv *-hostLF* $exp

# pim
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/pim-config.json $exp/pim_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp

#TODO: adapt for queue
#python generate_graph.py Skiplist Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
#mv *.png $exp
