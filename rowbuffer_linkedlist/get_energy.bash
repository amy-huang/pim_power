#!/bin/bash

exp=rowbuffer_linkedlist

cd ../

# pim
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/baseline_buffersize32_final_config.json $exp/baseline_buffersize32_final_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp

mv $exp.tsv $exp

#python generate_graph.py Linkedlist-Close-Page-Policy Pim $exp/$exp-pim.tsv
#mv *.png $exp
