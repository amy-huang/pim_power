#!/bin/bash

pim_stats=$1

pim_energy () {
    vault=$1
    ng_type=$2
    prep_tstamp=$3
    exe_tstamp=$4
   
    exe=$(grep pim_vault_ctrls${vault} ${pim_stats} | grep timestamp${exe_tstamp} | grep ${ng_type} | awk '{s+=$2}END{printf ("%f",s/1e12)}')
    prep=$(grep pim_vault_ctrls${vault} ${pim_stats} | grep timestamp${prep_tstamp} | grep ${ng_type} | awk '{s+=$2}END{printf ("%f",s/1e12)}')
    echo $vault $ng_type $exe $prep
}

for curr_exec in 2 4 6 8
do
    curr_prep=$(($curr_exec-1))

    pim_energy 0 actBackEnergy $curr_prep $curr_exec
    pim_energy 1 actBackEnergy $curr_prep $curr_exec
    pim_energy 2 actBackEnergy $curr_prep $curr_exec
    pim_energy 3 actBackEnergy $curr_prep $curr_exec
    pim_energy 4 actBackEnergy $curr_prep $curr_exec
done

for curr_exec in 2 4 6 8
do
    curr_prep=$(($curr_exec-1))

    pim_energy 0 preBackEnergy $curr_prep $curr_exec
    pim_energy 1 preBackEnergy $curr_prep $curr_exec
    pim_energy 2 preBackEnergy $curr_prep $curr_exec
    pim_energy 3 preBackEnergy $curr_prep $curr_exec
done
