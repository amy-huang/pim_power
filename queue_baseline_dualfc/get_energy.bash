#!/bin/bash

exp=queue_baseline_dualfc

cd ../

# host fc
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/host_dualfc_stats.txt cacti-out.txt host $exp
mv *-host* $exp

mv ${exp}.tsv $exp

#TODO: adapt for queue
#python generate_graph.py Skiplist Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
#mv *.png $exp
