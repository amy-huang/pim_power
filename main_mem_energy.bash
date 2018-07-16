#!/bin/bash

experiment_dir=$1
cd $experiment_dir

echo "Calculating PIM energy"

read_ng=$(grep "Read energy:" 2-pim-results.txt | awk '{s=$3}END{printf("%f",s)}')
write_ng=$(grep "Write energy:" 2-pim-results.txt | awk '{s=$3}END{printf("%f",s)}')
act_ng=$(grep "Activation energy:" 2-pim-results.txt | awk '{s=$3}END{printf("%f",s)}')
pre_ng=$(grep "Precharge energy:" 2-pim-results.txt | awk '{s=$3}END{printf("%f",s)}')



for num_threads in 2 4 6 8
do

    sum=0

	for ctrl_num in {0..7}
	do
	    pim_rhr=$(grep timestamp$num_threads pim-stats.txt | grep pim_vault_ctrls$ctrl_num | grep readRowHitRate | awk '{s=$2}END{printf ("%f", s)}')
        if [ "$pim_rhr" == "nan" ]; then
            pim_rhr=0
        fi
	    pim_reads=$(grep timestamp$num_threads pim-stats.txt | grep pim_vault_ctrls$ctrl_num | grep num_reads::total | awk '{s+=$2}END{print s}')  #ignore pim CPU value
 	    interm_sum=$(awk -v rhr=$pim_rhr -v r=$pim_reads -v re=$read_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{printf ("%f", (rhr/100) * r * re + (1-rhr/100) * r * (ae + re + pe))}')
        sum=$(awk -v is=$interm_sum -v s=$sum 'BEGIN{printf("%f", is+s)}')
        echo "read hit rate: "$pim_rhr" reads:"$pim_reads
        echo $num_threads" threads, pim vault"$ctrl_num" intermediate sum is "$interm_sum
        echo "Current sum is "$sum
	    echo ""
	     
	    pim_whr=$(grep timestamp$num_writes pim-stats.txt | grep pim_vault_ctrls$ctrl_num | grep writeRowHitRate | awk '{s=$2}END{printf ("%f", s)}')
        if [ "$pim_whr" == "nan" ]; then
            pim_whr=0
        fi
	    pim_writes=$(grep timestamp$num_writes pim-stats.txt | grep pim_vault_ctrls$ctrl_num | grep num_writes::total | awk '{s+=$2}END{print s}')  #ignore pim CPU value
 	    interm_sum=$(awk -v whr=$pim_whr -v w=$pim_writes -v we=$write_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{printf ("%f", (whr/100) * w * we + (1-whr/100) * w * (ae + we + pe))}')
        sum=$(awk -v is=$interm_sum -v s=$sum 'BEGIN{printf("%f", is+s)}')
        echo "write hit rate: "$pim_whr" writes:"$pim_writes
        echo $num_writes" thwrites, pim vault"$ctrl_num" intermediate sum is "$interm_sum
        echo "Current sum is "$sum
	    echo ""


	    cpu_rhr=$(grep timestamp$num_threads pim-stats.txt | grep mem_ctrls$ctrl_num | grep readRowHitRate | awk '{s=$2}END{printf ("%f", s)}')
	    cpu_reads=$(grep timestamp$num_threads pim-stats.txt | grep mem_ctrls$ctrl_num | grep num_reads::total | awk '{s+=$2}END{print s}')  #ignore pim CPU value
        interm_sum=$(awk -v rhr=$cpu_rhr -v r=$cpu_reads -v re=$read_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{print (rhr/100) * r * re + (1-rhr/100) * r * (ae + re + pe)}')
        sum=$(awk -v is=$interm_sum -v s=$sum 'BEGIN{printf("%f", is+s)}')
        echo "read hit rate: "$cpu_rhr" reads:"$cpu_reads
        echo $num_threads" threads, cpu ctrlr"$ctrl_num" intermediate sum is "$interm_sum
        echo "Current sum is "$sum
	    echo ""
	
	    cpu_whr=$(grep timestamp$num_writes pim-stats.txt | grep mem_ctrls$ctrl_num | grep writeRowHitRate | awk '{s=$2}END{printf ("%f", s)}')
        if [ "$cpu_whr" == "nan" ]; then
            cpu_whr=0
        fi
	    cpu_writes=$(grep timestamp$num_writes pim-stats.txt | grep mem_ctrls$ctrl_num | grep num_writes::total | awk '{s+=$2}END{print s}')  #ignore pim CPU value
 	    interm_sum=$(awk -v whr=$cpu_whr -v w=$pim_writes -v we=$write_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{printf ("%f", (whr/100) * w * we + (1-whr/100) * w * (ae + we + pe))}')
        sum=$(awk -v is=$interm_sum -v s=$sum 'BEGIN{printf("%f", is+s)}')
        echo "write hit rate: "$cpu_whr" writes:"$pim_writes
        echo $num_writes" thwrites, cpu vault"$ctrl_num" intermediate sum is "$interm_sum
        echo "Current sum is "$sum
	    echo ""
	done

    echo "total joules is " $(awk -v s=$sum 'BEGIN{printf("%f", s/1000000000)}')
done	

echo "read ng "$read_ng" write ng "$write_ng" act_ng "$act_ng" pre_ng "$pre_ng


echo "Calculating host energy"
