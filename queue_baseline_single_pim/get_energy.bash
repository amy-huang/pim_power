#!/bin/bash

exp=queue_baseline_single_pim

cd ../

# host fc
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/pim-config.json $exp/single_pim_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp

mv ${exp}.tsv $exp

#TODO: adapt for queue
#python generate_graph.py Skiplist Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
#mv *.png $exp
