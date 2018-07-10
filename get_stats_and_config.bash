#!/bin/bash

# This script copies the stats file from the result directory in SMC-WORK created by simulation,
# and then sums important stats across all CPUs/Mem controllers that are added to a new stats file

echo "Preparing config and stats."
#################################################################################################################
# Copying config and stats file over 

config_path="$(find ../SMC-WORK/scenarios/$1/ -name config.json)"
#original_stats_path="$(find ../SMC-WORK/scenarios/$1/ -name stats.txt)"
original_stats_path="$(find ../SMC-WORK/scenarios/$1/ -name stats_gem5.txt)"
newstats=./cut_stats.txt   #Make a copy of stats file in current directory to add sum stats to

echo "	Copying over config.json file from simulation result directory to here..."
#cp $config_path .

echo "	Copying over stats.txt file from simulation result directory to here..."
#cp $original_stats_path $newstats

#################################################################################################################
# Functions to create stats over CPUs, memory controllers, and etc.

sum () {  # Pulls all stats containing first argument and sum; print as non-scientific notated integer
    #sum=$(grep -w $1 $newstats | grep -v "pim_sys" | awk '{s+=$2}END{printf ("%1.0d",s)}')  #ignore pim CPU value
    sum=$(grep -w $1 $newstats | awk '{s+=$2}END{printf ("%1.0d",s)}')  #include PIM core values
   
    # Write to new stats file under name of second argument      
    echo $2"                       "$sum >> $newstats
}

sum_float () { # Same as sum except supports floats
    sum=$(grep -w $1 $newstats | grep -v "pim_sys" | awk '{s+=$2}END{print s}')  #ignore pim CPU value
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

sum system.mem_ctrls[0-9].totalEnergy   system.mem_ctrls.totalEnergy
# First get total time simulated
sum_float  sim_seconds                      total_sim_seconds 
# Remove timestamp from sim_seconds entries, so they aren't deleted
#sed -i -e 's/timestamp[0-9].sim_seconds/sim_seconds/g' $newstats
# Remove all other lines without timestamp6 in front of them
sed -i '/timestamp[1]/d' $newstats
# Remove 'timestamp6.' from remaining stats
#sed -i -e 's/timestamp4.//g' $newstats
sed -i -e 's/timestamp[0-9].//g' $newstats

echo "	Aggregating stats across all CPUs, memory controllers."
sum  system.cpu[0-9].numCycles                        system.cpu.totalNumCycles
sum  system.cpu[0-9].num_idle_cycles                  system.cpu.totalIdleCycles
sum  system.cpu[0-9].num_int_insts                    system.cpu.int_instructions
sum  system.cpu[0-9].num_fp_insts                     system.cpu.fp_instructions
sum  system.cpu[0-9].Branches                         system.cpu.branch_instructions
sum  system.cpu[0-9].num_load_insts                   system.cpu.load_instructions
sum  system.cpu[0-9].num_store_insts                  system.cpu.store_instructions
sum  system.cpu[0-9].committedInsts                   system.cpu.committed_instructions
sum  system.cpu[0-9].num_int_register_reads           system.cpu.int_regfile_reads
sum  system.cpu[0-9].num_int_register_writes          system.cpu.int_regfile_writes
sum  system.cpu[0-9].num_fp_register_reads            system.cpu.float_regfile_reads
sum  system.cpu[0-9].num_fp_register_writes           system.cpu.float_regfile_writes
sum  system.cpu[0-9].num_func_calls                   system.cpu.function_calls
sum  system.cpu[0-9].num_int_alu_accesses             system.cpu.ialu_accesses
sum  system.cpu[0-9].num_fp_alu_accesses              system.cpu.fpu_accesses
sum  system.cpu[0-9].itb.accesses                     system.cpu.itlb.total_accesses
sum  system.cpu[0-9].itb.misses                       system.cpu.itlb.total_misses
sum  system.cpu[0-9].icache.ReadReq_accesses::total   system.cpu.icache.read_accesses
sum  system.cpu[0-9].icache.demand_misses::total      system.cpu.icache.read_misses
sum  system.cpu[0-9].dcache.ReadReq_accesses::total   system.cpu.dcache.read_accesses
sum  system.cpu[0-9].dcache.WriteReq_accesses::total  system.cpu.dcache.write_accesses
sum  system.cpu[0-9].dtb.accesses                     system.cpu.dtlb.total_accesses
sum  system.cpu[0-9].dtb.misses                       system.cpu.dtlb.total_misses
sum  system.cpu[0-9].dcache.ReadReq_misses::total     system.cpu.dcache.read_misses
sum  system.cpu[0-9].dcache.WriteReq_misses::total    system.cpu.dcache.write_misses
#sum  system.mem_ctrls[0-9][0-9].readReqs              system.mem_ctrls.memory_reads
#sum  system.mem_ctrls[0-9][0-9].writeReqs             system.mem_ctrls.memory_writes
sum  system.mem_ctrls[0-9].readReqs              system.mem_ctrls.memory_reads # For new pim setup with only 8 mem ctrllers not associated with pim cores
sum  system.mem_ctrls[0-9].writeReqs             system.mem_ctrls.memory_writes
sum_interconnect_accesses
peak bw_total::total  system.mem_ctrls.peak_bandwidth

#################################################################################################################
# Further cleaning

# Remove physical address tracking (which was to solve skiplist issue)
sed -i '/physaddr/d' $newstats
# Set all nan stats to 0 (or else will print warnings)
sed -i -e 's/nan/0/g' $newstats

#################################################################################################################
echo "Summed stats in $newstats"
