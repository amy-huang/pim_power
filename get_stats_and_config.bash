#!/bin/bash

#################################################################################################################
# This script copies the stats file from the result directory in SMC-WORK created by simulation,
# and then sums important stats across all CPUs/Mem controllers that are added to a new stats file
#################################################################################################################

newstats=./cut_stats.txt   #Make a copy of stats file in current directory to add sum stats to

#################################################################################################################

sum () {  # Pulls all stats containing first argument and sum; print as non-scientific notated integer
    sum_both=$(grep $1 $newstats | awk '{s+=$2}END{printf ("%f",s)}')
    sum_cpu=$(grep $1 $newstats | grep -v "pim_sys" | awk '{s+=$2}END{printf ("%f",s)}')  #ignore pim CPU value
    sum_pim=$(grep $1 $newstats | grep "pim_sys" | awk '{s+=$2}END{printf ("%f",s)}')  #include PIM core values
   
    # Write to new stats file under name of second argument      
    echo $2"                       "$sum_both >> $newstats
    #echo $2"                       "$sum_cpu >> $newstats
    #echo $3"                       "$sum_pim >> $newstats
}

sum_float () { 
    sum=$(grep $1 $newstats | grep -v "pim_sys" | awk '{s+=$2}END{print s}')  #ignore pim CPU value
    echo $2"                       "$sum >> $newstats
}

sum_interconnect_accesses () { # Sum accesses to all interconnect access types
    sum=$(grep "\.trans_dist::ReadResp\|\.trans_dist::ReadRespWithInvalidate\|\.trans_dist::WriteResp\|\.trans_dist::Writeback\|\.trans_dist::UpgradeResp\|\.trans_dist::ReadExResp\|\.trans_dist::SCUpgradeFailReq" $newstats | grep -v "pim" | awk '{s+=$2}END{print s}')  #ignore pim CPU value
    echo "total_interconnect_accesses                       "$sum >> $newstats
}

peak () { # Find the highest value for some stat
    peak=$(grep $1 $newstats | awk '{if (s<$2) s=$2}END{print s/1000000}')
    echo $2"                       "$peak >> $newstats
}

get_mem_ctrl_energies () {
    sum
    for ctrl_num in {0..7}
    do
        pim_rhr=$(grep pim_vault_ctrls$ctrl_num $newstats | grep readRowHitRate | awk '{s=$2}END{printf ("%f", s)}')
        pim_reads=$(grep pim_vault_ctrls$ctrl_num $newstats | grep num_reads::total | awk '{s+=$2}END{print s}')  #ignore pim CPU value
        
        cpu_hr=$(grep pim_vault_ctrls$ctrl_num | grep readRowHitRate | awk '{s=$2}END{printf ("%f", s)}')
        
    done

    echo "finalEnergy                       "$final_ng >> $newstats

}
#################################################################################################################
# DRAM energy calculations/sanity checks

#total_energy_first=$(grep totalEnergy $newstats | grep timestamp$1 | awk '{s+=$2}END{printf ("%f",s)}')
#total_energy_second=$(grep totalEnergy $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}')
#total_energy=$(($total_energy_second-$total_energy_first))

avg_pwr=$(grep "averagePower::0" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}')
seconds=$(grep "sim_seconds" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}')
#
#echo $avg_pwr $seconds
#
#act=$(grep "actEnergy" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}' > test_add.txt)
#echo \n >> test_add.txt
#pre=$(grep "preEnergy" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}' >> test_add.txt)
#echo \n >> test_add.txt
#r_ng=$(grep "readEnergy" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}' >> test_add.txt)
#echo \n >> test_add.txt
#w_ng=$(grep "writeEnergy" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}' >> test_add.txt)
#echo \n >> test_add.txt
#refresh=$(grep "refreshEnergy" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}' >> test_add.txt)
#echo \n >> test_add.txt
#actBack=$(grep "actBackEnergy" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}' >> test_add.txt)
#echo \n >> test_add.txt
#preBack=$(grep "preBackEnergy" $newstats | grep timestamp$2 | awk '{s+=$2}END{printf ("%f",s)}' >> test_add.txt)
#echo \n >> test_add.txt

#awk '{sum+=$1};END{print sum}' test_add.txt

#################################################################################################################
# Aggregating stats 

# Mem ctrl energy is cumulatively recorded among timestamps, so calculate first before removing first timestamp
# get_mem_ctrl_energies

# Remove all other lines not in the execution time duration
sed -i '/timestamp['$1']/d' $newstats
# Remove timestamp from remaining stats
sed -i -e 's/timestamp[0-9].//g' $newstats
# Sum the stats that aren't cumulative, and are only for the execution time
echo "	Aggregating stats across all CPUs, memory controllers."
sum_float  sim_seconds                      total_sim_seconds 
sum  numCycles                        system.cpu.totalNumCycles          system.pim.totalNumCycles
sum  num_idle_cycles                  system.cpu.totalIdleCycles         system.pim.totalIdleCycles
sum  num_int_insts                    system.cpu.int_instructions        system.pim.int_instructions
sum  num_fp_insts                     system.cpu.fp_instructions         system.pim.fp_instructions
sum  Branches                         system.cpu.branch_instructions     system.pim.branch_instructions
sum  num_load_insts                   system.cpu.load_instructions       system.pim.load_instructions
sum  num_store_insts                  system.cpu.store_instructions      system.pim.store_instructions
sum  committedInsts                   system.cpu.committed_instructions  system.pim.committed_instructions
sum  num_int_register_reads           system.cpu.int_regfile_reads       system.pim.int_regfile_reads
sum  num_int_register_writes          system.cpu.int_regfile_writes      system.pim.int_regfile_writes
sum  num_fp_register_reads            system.cpu.float_regfile_reads     system.pim.float_regfile_reads
sum  num_fp_register_writes           system.cpu.float_regfile_writes    system.pim.float_regfile_writes
sum  num_func_calls                   system.cpu.function_calls          system.pim.function_calls
sum  num_int_alu_accesses             system.cpu.ialu_accesses           system.pim.ialu_accesses
sum  num_fp_alu_accesses              system.cpu.fpu_accesses            system.pim.fpu_accesses
sum  itb.accesses                     system.cpu.itlb.total_accesses     system.pim.itlb.total_accesses
sum  itb.misses                       system.cpu.itlb.total_misses       system.pim.itlb.total_misses
sum  icache.ReadReq_accesses::total   system.cpu.icache.read_accesses    system.pim.icache.read_accesses
sum  icache.demand_misses::total      system.cpu.icache.read_misses      system.pim.icache.read_misses
sum  dcache.ReadReq_accesses::total   system.cpu.dcache.read_accesses    system.pim.dcache.read_accesses
sum  dcache.WriteReq_accesses::total  system.cpu.dcache.write_accesses   system.pim.dcache.write_accesses
sum  dtb.accesses                     system.cpu.dtlb.total_accesses     system.pim.dtlb.total_accesses
sum  dtb.misses                       system.cpu.dtlb.total_misses       system.pim.dtlb.total_misses
sum  dcache.ReadReq_misses::total     system.cpu.dcache.read_misses      system.pim.dcache.read_misses
sum  dcache.WriteReq_misses::total    system.cpu.dcache.write_misses     system.pim.dcache.write_misses
#sum  system.mem_ctrls[0-9].readReqs system.mem_ctrls.memory_reads # For pim setup 
#sum  system.mem_ctrls[0-9].writeReqs system.mem_ctrls.memory_writes
#sum  system.mem_ctrls[0-9][0-9].readReqs system.mem_ctrls.memory_reads 
#sum  system.mem_ctrls[0-9][0-9].writeReqs system.mem_ctrls.memory_writes
sum_interconnect_accesses
peak bw_total::total  system.mem_ctrls.peak_bandwidth

sum actEnergy system.mem_ctrls.total_actEnergy
sum preEnergy system.mem_ctrls.total_preEnergy
sum readEnergy system.mem_ctrls.total_readEnergy
sum writeEnergy system.mem_ctrls.total_writeEnergy
sum refreshEnergy system.mem_ctrls.total_refreshEnergy
sum actBackEnergy system.mem_ctrls.total_actBackEnergy
sum preBackEnergy system.mem_ctrls.total_preBackEnergy

sum [0-9].num_reads::total total_reads
sum [0-9].num_writes::total total_writes


#################################################################################################################
# Further cleaning

# Remove physical address tracking (which was to solve skiplist issue)
sed -i '/physaddr/d' $newstats
# Set all nan stats to 0 (or else will print warnings)
sed -i -e 's/nan/0/g' $newstats

#################################################################################################################
echo "Summed stats in $newstats"
