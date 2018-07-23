#!/bin/bash

exp=queue_experiment

cd ../

# host 
#./master_script.bash tentative_arm15.xml arm15_PIM.xml $exp/host-config.json $exp/host-stats.txt cacti-out.txt host $exp
#mv *-host* $exp

# pim
#./master_script.bash tentative_arm15.xml arm15_PIM.xml $exp/pim-config.json $exp/pim-stats.txt cacti-out.txt pim $exp
#mv *-pim* $exp

python generate_graph.py Queue Host $exp/$exp-host.tsv PIM $exp/$exp-pim.tsv
mv *.png $exp
