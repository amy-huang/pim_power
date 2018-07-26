#!/bin/bash

exp=linkedlist_page_policy

cd ../

# pim
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/config.json $exp/pim_closed_page_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp

mv $exp.tsv $exp

#python generate_graph.py Linkedlist-Close-Page-Policy Pim $exp/$exp-pim.tsv
#mv *.png $exp
