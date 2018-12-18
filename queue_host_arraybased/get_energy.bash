#!/bin/bash

exp=queue_host_arraybased

cd ../

# host fc
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/config.json $exp/host_dualfc_initsize524288_numops789432.txt cacti-out.txt host $exp-host
rename -v 's/-host/-hostFC/' ./*
mv *-hostFC* $exp

# host fc
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/config.json $exp/host_lockfree_initsize524288_numops786432.txt cacti-out.txt host $exp-host
rename -v 's/-host/-hostLF/' ./*
mv *-hostLF* $exp

# mv *${exp}* $exp

#TODO: adapt for queue
#python generate_graph.py Skiplist Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
#mv *.png $exp
