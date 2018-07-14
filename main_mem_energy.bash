#!/bin/bash

results=2-pim-results.txt

read_ng=$(grep "Read energy:" $results | awk '{s=$3}END{printf("%f",s)}')
write_ng=$(grep "Write energy:" $results | awk '{s=$3}END{printf("%f",s)}')
act_ng=$(grep "Activation energy:" $results | awk '{s=$3}END{printf("%f",s)}')
pre_ng=$(grep "Precharge energy:" $results | awk '{s=$3}END{printf("%f",s)}')

sum=0

for ctrl_num in {0..7}
do
    pim_rhr=$(grep pim_vault_ctrls$ctrl_num cut_stats.txt | grep readRowHitRate | awk '{s=$2}END{printf ("%f", s)}')
    pim_reads=$(grep pim_vault_ctrls$ctrl_num cut_stats.txt | grep num_reads::total | awk '{s+=$2}END{print s}')  #ignore pim CPU value
    awk -v rhr=$pim_rhr -v r=$pim_reads -v re=$read_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{printf ("%f", (rhr/100) * r * re + (1-rhr/100) * r * (ae + re + pe))}'
    echo ""
     
    cpu_rhr=$(grep mem_ctrls$ctrl_num cut_stats.txt | grep readRowHitRate | awk '{s=$2}END{printf ("%f", s)}')
    cpu_reads=$(grep mem_ctrls$ctrl_num cut_stats.txt | grep num_reads::total | awk '{s+=$2}END{print s}')  #ignore cpu CPU value
    awk -v rhr=$cpu_rhr -v r=$cpu_reads -v re=$read_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{print (rhr/100) * r * re + (1-rhr/100) * r * (ae + re + pe)}'

done

