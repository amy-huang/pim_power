#!/bin/bash

experiment_dir=$1
cd $experiment_dir

read_ng=$(grep "Read energy:" 2-pim-results.txt | awk '{s=$3}END{printf("%f",s)}')
write_ng=$(grep "Write energy:" 2-pim-results.txt | awk '{s=$3}END{printf("%f",s)}')
act_ng=$(grep "Activation energy:" 2-pim-results.txt | awk '{s=$3}END{printf("%f",s)}')
pre_ng=$(grep "Precharge energy:" 2-pim-results.txt | awk '{s=$3}END{printf("%f",s)}')

get_energy () {

        hit_rate=$(grep $1 $3 | awk '{s=$2}END{printf("%f",s)}') 
            if [ "$1" == "nan" ] || [ "$1" == "" ]; then    
                hit_rate=0 
            fi
        ops=$(grep $2 $3 | awk '{s=$2}END{printf("%f",s)}')
            if [ "$2" == "nan" ] || [ "$2" == "" ]; then    
                ops=0 
            fi
        
        current=$(awk -v hr=$hit_rate -v ops=$ops -v re=$read_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{printf("%f", (hr/100*ops*re + (1-hr/100)*ops*(ae+re+pe))/1000000000)}')
        $4=$(echo $total + $current | bc)
        echo $num_threads $ctrlr_num $hit_rate $ops $current $total
}


for num_threads in 2 4 6 8
do
    total=0

    grep timestamp$num_threads pim-stats.txt > temp.txt    
   
    for ctrlr_num in {0..7} 
    do
        grep pim_vault_ctrls$ctrlr_num temp.txt > temp-$ctrlr_num.txt 
       
        ########################### READS ################################ 
        hit_rate=$(grep readRowHitRate temp-$ctrlr_num.txt | awk '{s=$2}END{printf("%f",s)}') 
            if [ "$hit_rate" == "nan" ] || [ "$hit_rate" == "" ]; then    
                hit_rate=0 
            fi
        ops=$(grep num_reads::total temp-$ctrlr_num.txt | awk '{s=$2}END{printf("%f",s)}')
            if [ "$ops" == "nan" ] || [ "$ops" == "" ]; then    
                ops=0 
            fi
        
        current=$(awk -v hr=$hit_rate -v ops=$ops -v re=$read_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{printf("%f", (hr/100*ops*re + (1-hr/100)*ops*(ae+re+pe))/1000000000)}')
        total=$(echo $total + $current | bc)
        echo $num_threads $ctrlr_num $hit_rate $ops $current $total

        grep mem_ctrls$ctrlr_num temp.txt > temp-$ctrlr_num.txt 
        ########################### WRITES ################################ 
        hit_rate=$(grep writeRowHitRate temp-$ctrlr_num.txt | awk '{s=$2}END{printf("%f",s)}') 
            if [ "$hit_rate" == "nan" ] || [ "$hit_rate" == "" ]; then    
                hit_rate=0 
            fi
        ops=$(grep num_writes::total temp-$ctrlr_num.txt | awk '{s=$2}END{printf("%f",s)}')
            if [ "$ops" == "nan" ] || [ "$ops" == "" ]; then    
                ops=0 
            fi
        
        current=$(awk -v hr=$hit_rate -v ops=$ops -v re=$write_ng -v ae=$act_ng -v pe=$pre_ng 'BEGIN{printf("%f", (hr/100*ops*re + (1-hr/100)*ops*(ae+re+pe))/1000000000)}')
        current=$(awk -v hr=$hit_rate -v ops=$ops 'BEGIN{printf("%f", hr ops)}')
        total=$(echo $total + $current | bc)
        echo $num_threads $ctrlr_num $hit_rate $ops $current $total

    
        #grep mem_ctrls$ctrlr_num temp.txt > temp-mem-$ctrlr_num.txt 
    done

    
 
done
