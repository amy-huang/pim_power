#!/bin/bash

exp=queue_page_policy

cd ../

# pim
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/config.json $exp/pim_closepage_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp

mv ${exp}.tsv $exp

#python generate_graph.py Queue-Close-Page-Policy Pim $exp/$exp-pim.tsv
#mv *.png $exp
