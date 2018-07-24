#!/bin/bash

exp=queue_size_pimcore_onoff

cd ../

# host fc
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/hostFC_smallsize_stats.txt cacti-out.txt host $exp
rename -v 's/-host/-hostFC/' ./*
mv *-hostFC* $exp

# host lockfree 
./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/host-config.json $exp/hostLF_smallsize_stats.txt cacti-out.txt host $exp
rename -v 's/-host/-hostLF/' ./*
mv *-hostLF* $exp

# pim baseline on
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/pim-config.json $exp/pim_baseline_pimON_stats.txt cacti-out.txt pim $exp
rename -v 's/-pim/-pim_base_on/' ./*
mv *-pim_base_on* $exp

# pim small on
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/pim-config.json $exp/pim_smallsize_pimON_stats.txt cacti-out.txt pim $exp
rename -v 's/-pim/-pim_small_on/' ./*
mv *-pim_small_on* $exp

# pim small on and off
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/pim-config.json $exp/pim_smallsize_pimONOFF_stats.txt cacti-out.txt pim $exp
rename -v 's/-pim/-pim_small_onoff/' ./*
mv *-pim_small_onoff* $exp

#TODO: adapt for queue
#python generate_graph.py Skiplist Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
#mv *.png $exp
