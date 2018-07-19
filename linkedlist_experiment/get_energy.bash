#!/bin/bash

cd ../
# Host flat combine
./master_script.bash tentative_arm15.xml linkedlist_experiment/host-config.json linkedlist_experiment/HOST_FC_SORT4dies.txt cacti-out.txt host linkedlist_experiment

rename -v 's/-host/-hostFC/' ./*
mv *-hostFC* linkedlist_experiment

# Host lazy lock 
./master_script.bash tentative_arm15.xml linkedlist_experiment/host-config.json linkedlist_experiment/HOST_LAZYLOCK4dies.txt cacti-out.txt host linkedlist_experiment

rename -v 's/-host/-hostLL/' ./*
mv *-hostLL* linkedlist_experiment

# pim
./master_script.bash tentative_arm15.xml linkedlist_experiment/pim-config.json linkedlist_experiment/pim-stats.txt cacti-out.txt pim linkedlist_experiment
mv *-pim* linkedlist_experiment

python generate_graph.py Linked-List-Total-Energy-Consumption Energy-in-Joules Host-Flat-Combine linkedlist_experiment/linkedlist_experiment-hostFC.tsv Host-Lazy-Lock linkedlist_experiment/linkedlist_experiment-hostLL.tsv PIM linkedlist_experiment/linkedlist_experiment-pim.tsv
