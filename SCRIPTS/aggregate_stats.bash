#!/bin/bash

if [ $# -ne 3 ] 
    then 
     echo "usage: <preparation time stamp> <execution time stamp> <new stats file>"
     exit 1
fi

#################################################################################################################
# For each number of threads in {2 4 6 8}, the master script greps lines of the 2 relevant timestamps into below.
prep_tstamp=$1
exec_tstamp=$2
newstats=$3

# DRAM energy is the only cumulative stat, so that is found by subtracting the energy stat at the execution 
# timestamp from the one at the preparation timestamp. The others are taken just from execution timestamp. 
# Then, this script aggregates stats for CPUs and memory controllers, since mcpat takes in total number of 
# operations of each kind done on all CPUs/controllers.
#################################################################################################################

sum () {  # Pulls all stats containing first argument, sums them, and print to new stats file as new stat with
          # value as non-scientific notated float
    sum_both=$(grep $1 $newstats | awk '{s+=$2}END{printf ("%f",s)}')
    sum_cpu=$(grep $1 $newstats | grep -v "pim" | awk '{s+=$2}END{printf ("%f",s)}')  #ignore pim CPU value
    sum_pim=$(grep $1 $newstats | grep "pim" | awk '{s+=$2}END{printf ("%f",s)}')  #include PIM core values
   
    # Write to new stats file under name of second argument      
    #echo $2"                       "$sum_both >> $newstats
    echo $2"                       "$sum_cpu >> $newstats
    echo $3"                       "$sum_pim >> $newstats
}

sum_cumulative () { # Add negative sum for prep timestamp, and positive sum for exec timestamp under same stat 
                    # name so that total sum is their difference 
    cpu_prep=$(grep $1 $newstats | grep -v "pim" | grep timestamp$prep_tstamp | awk '{s-=$2}END{printf ("%f",s)}')
    cpu_exe=$(grep $1 $newstats | grep -v "pim" | grep timestamp$exec_tstamp | awk '{s+=$2}END{printf ("%f",s)}')
    echo $2"                       "$cpu_prep >> $newstats
    echo $2"                       "$cpu_exe >> $newstats
    pim_prep=$(grep $1 $newstats | grep "pim" | grep timestamp$prep_tstamp | awk '{s-=$2}END{printf ("%f",s)}')
    pim_exe=$(grep $1 $newstats | grep "pim" | grep timestamp$exec_tstamp | awk '{s+=$2}END{printf ("%f",s)}')
    echo $3"                       "$pim_prep >> $newstats
    echo $3"                       "$pim_exe >> $newstats
}

sum_float () { 
    sum=$(grep $1 $newstats | awk '{s+=$2}END{print s}')  
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

#################################################################################################################
# Aggregating stats 

# Main memory energy is cumulative for both timestamps, so subtract the values at the first one from those
# of the second. These are total energies from each kind of operation as recorded by DRAMpower in gem5
sum_cumulative  actEnergy      system.mem_ctrls.total_actEnergy       system.pim_vault_ctrls.total_actEnergy
sum_cumulative  preEnergy      system.mem_ctrls.total_preEnergy       system.pim_vault_ctrls.total_preEnergy
sum_cumulative  readEnergy     system.mem_ctrls.total_readEnergy      system.pim_vault_ctrls.total_readEnergy
sum_cumulative  writeEnergy    system.mem_ctrls.total_writeEnergy     system.pim_vault_ctrls.total_writeEnergy
sum_cumulative  refreshEnergy  system.mem_ctrls.total_refreshEnergy   system.pim_vault_ctrls.total_refreshEnergy
sum_cumulative  actBackEnergy  system.mem_ctrls.total_actBackEnergy   system.pim_vault_ctrls.total_actBackEnergy
sum_cumulative  preBackEnergy  system.mem_ctrls.total_preBackEnergy   system.pim_vault_ctrls.total_preBackEnergy

# Remove lines of first timestamp, because rest of stats are not cumulative
sed -i '/timestamp['$prep_tstamp']/d' $newstats
# Remove timestamp from remaining stats
sed -i -e 's/timestamp[0-9].//g' $newstats
# Sum the stats that aren't cumulative, and are only for the execution time
echo "	Aggregating stats across all CPUs, interconnects, and memory controllers"
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
sum  icache.ReadReq_misses::total      system.cpu.icache.read_misses      system.pim.icache.read_misses
sum  dcache.ReadReq_accesses::total   system.cpu.dcache.read_accesses    system.pim.dcache.read_accesses
sum  dcache.WriteReq_accesses::total  system.cpu.dcache.write_accesses   system.pim.dcache.write_accesses
sum  dtb.accesses                     system.cpu.dtlb.total_accesses     system.pim.dtlb.total_accesses
sum  dtb.misses                       system.cpu.dtlb.total_misses       system.pim.dtlb.total_misses
sum  dcache.ReadReq_misses::total     system.cpu.dcache.read_misses      system.pim.dcache.read_misses
sum  dcache.WriteReq_misses::total    system.cpu.dcache.write_misses     system.pim.dcache.write_misses
sum_interconnect_accesses

sum  [0-9].num_reads::total     system.mem_ctrls.total_reads         system.pim_vault_ctrls.total_reads
sum  [0-9].num_writes::total    system.mem_ctrls.total_writes        system.pim_vault_ctrls.total_writes
sum  bytesPerActivate::samples  system.mem_ctrls.activations         system.pim_vault_ctrls.activations
sum  readRowHits                system.mem_ctrls.total_readRowHits   system.pim_vault_ctrls.total_readRowHits
sum  writeRowHits               system.mem_ctrls.total_writeRowHits  system.pim_vault_ctrls.total_writeRowHits

sum  smcxbar.trans_dist::ReadReq system.smcxbar.reads_from_pim
sum  smcxbar.trans_dist::WriteReq system.smcxbar.writes_to_pim
sum smcxbar.pkt_count_system.seriallink[0-9].master::system.pim_sys0 not_applicable system.smcxbar.pkts_to_pim_sys0
sum smcxbar.pkt_count_system.seriallink[0-9].master::system.pim_sys1 not_applicable system.smcxbar.pkts_to_pim_sys1
sum smcxbar.pkt_count_system.seriallink[0-9].master::system.pim_sys2 not_applicable system.smcxbar.pkts_to_pim_sys2
sum smcxbar.pkt_count_system.seriallink[0-9].master::system.pim_sys3 not_applicable system.smcxbar.pkts_to_pim_sys3
sum smcxbar.pkt_count_system.seriallink[0-9].master::system.pim_sys4 not_applicable system.smcxbar.pkts_to_pim_sys4
sum smcxbar.pkt_count_system.seriallink[0-9].master::system.pim_sys5 not_applicable system.smcxbar.pkts_to_pim_sys5
sum smcxbar.pkt_count_system.seriallink[0-9].master::system.pim_sys6 not_applicable system.smcxbar.pkts_to_pim_sys6
sum smcxbar.pkt_count_system.seriallink[0-9].master::system.pim_sys7 not_applicable system.smcxbar.pkts_to_pim_sys7

#################################################################################################################
# Further cleaning

# Remove physical address tracking (which was to solve skiplist issue)
sed -i '/physaddr/d' $newstats
# Set all nan stats to 0 (or else will print warnings)
sed -i -e 's/nan/0/g' $newstats

#################################################################################################################
echo "Summed stats in $newstats"
