#!/bin/bash

exp=skiplist_page_policy

cd ../

# pim
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/config.json $exp/close_page_largesize_8partpim_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp

mv ${exp}.tsv $exp

#python generate_graph.py Queue-Close-Page-Policy Pim $exp/$exp-pim.tsv
#mv *.png $exp
