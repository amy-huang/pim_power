#!/bin/bash

# This script copies the stats file from the result directory in SMC-WORK created by simulation,
# and then sums important stats across all CPUs/Mem controllers that are added to a new stats file

newstats=./cut_stats.txt   #Make a copy of stats file in current directory to add sum stats to

# Functions to create stats over CPUs, memory controllers, and etc.

sum () {  # Pulls all stats containing first argument and sum; print as non-scientific notated integer
    sum_cpu=$(grep $1 $newstats | grep -v "pim_sys" | awk '{s+=$2}END{printf ("%.1d",s)}')  #ignore pim CPU value
    sum_pim=$(grep $1 $newstats | grep "pim_sys" | awk '{s+=$2}END{printf ("%1.1d",s)}')  #include PIM core values
   
    # Write to new stats file under name of second argument      
    echo $2"                       "$sum_cpu >> $newstats
    echo $3"                       "$sum_pim >> $newstats
}

sum_float () { # Same as sum except supports floats
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

#################################################################################################################
# Aggregating stats 

# Get this first to subtract from total energy
prep_energy=$(grep "totalEnergy" cut_stats.txt | grep "timestamp$2" | awk '{s+=$2}END{print s}')
echo "system.prep.Energy                       "$prep_energy >> $newstats

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
sum  committedInsts                   system.cpu.committed_instructions  system.pim.committed_instructio
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
sum  dcache.WriteReq_accesses::total  system.cpu.dcache.write_accesses   system.pim.dcache.write_accesse
sum  dtb.accesses                     system.cpu.dtlb.total_accesses     system.pim.dtlb.total_accesses
sum  dtb.misses                       system.cpu.dtlb.total_misses       system.pim.dtlb.total_misses
sum  dcache.ReadReq_misses::total     system.cpu.dcache.read_misses      system.pim.dcache.read_misses
sum  dcache.WriteReq_misses::total    system.cpu.dcache.write_misses     system.pim.dcache.write_misses
sum  system.mem_ctrls[0-9].readReqs system.mem_ctrls.memory_reads 
sum  system.mem_ctrls[0-9].writeReqs system.mem_ctrls.memory_writes
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
