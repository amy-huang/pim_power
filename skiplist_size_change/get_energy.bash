#!/bin/bash

exp=skiplist_size_change

cd ../
#
## host 
#l1d_size="001kB"
#l2_size="032kB"
#./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-host-config.json $exp/${l1d_size}L1D_${l2_size}L2_hostLF_stats.txt cacti-out.txt host $exp
#mv *-host* $exp
#echo "" >> ${exp}.tsv
#
#l1d_size="008kB"
#l2_size="256kB"
#./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-host-config.json $exp/${l1d_size}L1D_${l2_size}L2_hostLF_stats.txt cacti-out.txt host $exp
#mv *-host* $exp
#echo "" >> ${exp}.tsv
#
#l1d_size="032kB"
#l2_size="001MB"
#./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-host-config.json $exp/${l1d_size}L1D_${l2_size}L2_hostLF_stats.txt cacti-out.txt host $exp
#mv *-host* $exp
#echo "" >> ${exp}.tsv
#
#l1d_size="064kB"
#l2_size="002MB"
#./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-host-config.json $exp/${l1d_size}L1D_${l2_size}L2_hostLF_stats.txt cacti-out.txt host $exp
#mv *-host* $exp
#echo "" >> ${exp}.tsv
#
#l1d_size="128kB"
#l2_size="004MB"
#./master_script.bash arm15_HostCPUs.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-host-config.json $exp/${l1d_size}L1D_${l2_size}L2_hostLF_stats.txt cacti-out.txt host $exp
#mv *-host* $exp
#echo "" >> ${exp}.tsv

############################################################################################################# pim 
l1d_size="001kB"
l2_size="032kB"
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-pim-config.json $exp/${l1d_size}L1D_${l2_size}L2_8partpim_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp
echo "" >> ${exp}.tsv

l1d_size="008kB"
l2_size="256kB"
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-pim-config.json $exp/${l1d_size}L1D_${l2_size}L2_8partpim_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp
echo "" >> ${exp}.tsv

l1d_size="032kB"
l2_size="001MB"
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-pim-config.json $exp/${l1d_size}L1D_${l2_size}L2_8partpim_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp
echo "" >> ${exp}.tsv

l1d_size="064kB"
l2_size="002MB"
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-pim-config.json $exp/${l1d_size}L1D_${l2_size}L2_8partpim_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp
echo "" >> ${exp}.tsv

l1d_size="128kB"
l2_size="004MB"
./master_script.bash arm15_HostCPUs-PIM.xml arm15_PimCPUs.xml $exp/${l1d_size}L1D_${l2_size}L2-pim-config.json $exp/${l1d_size}L1D_${l2_size}L2_8partpim_stats.txt cacti-out.txt pim $exp
mv *-pim* $exp
echo "" >> ${exp}.tsv

mv ${exp}.tsv $exp

#python generate_graph.py "Skiplist(${num_partitions}-partition)" Host $exp/$exp-host.tsv Pim $exp/$exp-pim.tsv
#mv *.png $exp
