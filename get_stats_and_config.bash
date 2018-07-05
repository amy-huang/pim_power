#!/bin/bash

# This script copies the stats file from the result directory in SMC-WORK created by simulation,
# and then sums important stats across all CPUs/Mem controllers that are added to a new stats file

echo "	Copying over config.json file from simulation result directory to here..."
config_path=../SMC-WORK/scenarios/31/multithread_fc_q-partition-threads8-initialsize-042000-050/m5out/config.json
cp $config_path .

echo "	Copying over stats.txt file from simulation result directory to here..."
original_stats_path=../SMC-WORK/scenarios/31/multithread_fc_q-partition-threads8-initialsize-042000-050/m5out/stats.txt
newfile=cut_stats.txt   #Make a copy of stats file in current directory to add aggregate stats to
cp $original_stats_path $newfile 

aggregate () {    # Adds some statistic, like # cycles executed, for all 8 CPUs
    # 1st arg is stat name. In stats.txt, the line looks like "system.cpu[0-7].<stat_name>  <value>"
    sum=$(grep -w $1 $newfile | grep -v "pim_sys" | awk '{s+=$2}END{printf ("%1.0d",s)}')  #ignore pim CPU value
    # Print full whole number, not in scientific notation (3.4+e3)
    
    # 2nd arg is new stat name. Add a new line to copied stats file with sum	
    echo $2"                       "$sum >> $newfile
}

aggregate_float () {
    sum=$(grep -w $1 $newfile | grep -v "pim_sys" | awk '{s+=$2}END{print s}')  #ignore pim CPU value
    echo $2"                       "$sum >> $newfile
}

sum_interconnect_accesses () {
    sum=$(grep "\.trans_dist::ReadResp\|\.trans_dist::ReadRespWithInvalidate\|\.trans_dist::WriteResp\|\.trans_dist::Writeback\|\.trans_dist::UpgradeResp\|\.trans_dist::ReadExResp\|\.trans_dist::SCUpgradeFailReq" $newfile | grep -v "pim" | awk '{s+=$2}END{print s}')  #ignore pim CPU value
    echo "total_interconnect_accesses                       "$sum >> $newfile
}

peak () {
    peak=$(grep $1 $newfile | awk '{if (s<$2) s=$2}END{print s/1000000}')
    echo $2"                       "$peak >> $newfile
}

# First get total time simulated
aggregate_float  timestamp[0-9].sim_seconds                      total_sim_seconds 

# Remove timestamp from sim_seconds entries, so they aren't deleted
sed -i -e 's/timestamp[0-5].sim_seconds/sim_seconds/g' $newfile
# Remove all other lines without timestamp6 in front of them
sed -i '/timestamp[0-5]/d' $newfile
# Remove 'timestamp6.' from remaining stats
sed -i -e 's/timestamp6.//g' $newfile

echo "	Aggregating stats across all CPUs, memory controllers."
aggregate  system.cpu[0-9].numCycles                        system.cpu.totalNumCycles
aggregate  system.cpu[0-9].num_idle_cycles                  system.cpu.totalIdleCycles
aggregate  system.cpu[0-9].num_int_insts                    system.cpu.int_instructions
aggregate  system.cpu[0-9].num_fp_insts                     system.cpu.fp_instructions
aggregate  system.cpu[0-9].Branches                         system.cpu.branch_instructions
aggregate  system.cpu[0-9].num_load_insts                   system.cpu.load_instructions
aggregate  system.cpu[0-9].num_store_insts                  system.cpu.store_instructions
aggregate  system.cpu[0-9].committedInsts                   system.cpu.committed_instructions
aggregate  system.cpu[0-9].num_int_register_reads           system.cpu.int_regfile_reads
aggregate  system.cpu[0-9].num_int_register_writes          system.cpu.int_regfile_writes
aggregate  system.cpu[0-9].num_fp_register_reads            system.cpu.float_regfile_reads
aggregate  system.cpu[0-9].num_fp_register_writes           system.cpu.float_regfile_writes
aggregate  system.cpu[0-9].num_func_calls                   system.cpu.function_calls
aggregate  system.cpu[0-9].num_int_alu_accesses             system.cpu.ialu_accesses
aggregate  system.cpu[0-9].num_fp_alu_accesses              system.cpu.fpu_accesses
aggregate  system.cpu[0-9].itb.accesses                     system.cpu.itlb.total_accesses
aggregate  system.cpu[0-9].itb.misses                       system.cpu.itlb.total_misses
aggregate  system.cpu[0-9].icache.ReadReq_accesses::total   system.cpu.icache.read_accesses
aggregate  system.cpu[0-9].icache.demand_misses::total      system.cpu.icache.read_misses
aggregate  system.cpu[0-9].dcache.ReadReq_accesses::total   system.cpu.dcache.read_accesses
aggregate  system.cpu[0-9].dcache.WriteReq_accesses::total  system.cpu.dcache.write_accesses
aggregate  system.cpu[0-9].dtb.accesses                     system.cpu.dtlb.total_accesses
aggregate  system.cpu[0-9].dtb.misses                       system.cpu.dtlb.total_misses
aggregate  system.cpu[0-9].dcache.ReadReq_misses::total     system.cpu.dcache.read_misses
aggregate  system.cpu[0-9].dcache.WriteReq_misses::total    system.cpu.dcache.write_misses
aggregate  system.mem_ctrls[0-9][0-9].readReqs              system.mem_ctrls.memory_reads
aggregate  system.mem_ctrls[0-9][0-9].writeReqs             system.mem_ctrls.memory_writes
sum_interconnect_accesses
peak bw_total::total  system.mem_ctrls.peak_bandwidth

echo "  Cutting out unnecessary stats and setting NaN's to 0's.."

# Remove physical address tracking (which was to solve skiplist issue)
sed -i '/physaddr/d' $newfile

# Set all nan stats to 0 (or else will print warnings)
sed -i -e 's/nan/0/g' $newfile

echo "Timestamp6 and aggregate stats in cut_stats.txt."
