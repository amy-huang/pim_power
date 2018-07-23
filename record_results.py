import sys

# This script calculates how much energy main memory has consumed based on CACTI and the stats file, and then adds it to the energy of everything else as estimated by McPAT to get a total number.
# The CACTI output, McPAT, then stats file is parsed.

if len(sys.argv) != 5:
    print("\n Argument format: <cpu mcpat out> <pim mcpat out> <cacti text output> <name of tsv file for totals> \n")
    exit(0)

######################################################################################################

print("Getting CACTI numbers")

cacti_file = open(str(sys.argv[3]), 'r') 
cacti_lines = cacti_file.readlines()
cacti_file.close()

cacti_read = 0
cacti_write = 0
cacti_act = 0
cacti_pre = 0

for line in cacti_lines:
    # Ignore whitespace at beginning of lines
    while line[0] == '\t' or line[0] == ' ':
        line = line[1:]
    
    cols = line.split(':')

    if cols[0] == "Read energy": 
        cacti_read = float(cols[1].split()[0])
    if cols[0] == "Write energy": 
        cacti_write = float(cols[1].split()[0])
    if cols[0] == "Activation energy": 
        cacti_act = float(cols[1].split()[0])
    if cols[0] == "Precharge energy": 
        cacti_pre = float(cols[1].split()[0])

######################################################################################################

print("\tCalculating hybrid memory cube energy using memory access stats")

stats = open('cut_stats.txt', 'r')
stat_lines = stats.readlines()
stats.close()

sim_seconds = 0
num_reads = 0
num_writes = 0
num_act_pre = 0

total_energy = 0
gem5_act_total = 0
gem5_read_total = 0
gem5_write_total = 0
gem5_pre_total = 0
gem5_act_back_total = 0
gem5_pre_back_total = 0
gem5_refr_total = 0
l2_accesses = 0

pim_reads = 0
pim_writes = 0
cpu_reads = 0
cpu_writes = 0

# Row buffer; used for cacti estimation energy
read_hits = 0
write_hits = 0

# TODO: could be interesting to look at interconnect accesses, committed instructions, memory accesses
for line in stat_lines[::-1]:
    cols = line.split()
    if len(cols):
        if cols[0] == "total_sim_seconds" in cols[0]:
	        sim_seconds = float(cols[1])
	        print("\tSeconds simulated: " + str(sim_seconds) + " s")


        if "total_reads" in cols[0]:
            num_reads += float(cols[1])
            print("\tReads: " + str(num_reads))
            if "pim" in cols[0]:
                pim_reads += float(cols[1])
            else:
                cpu_reads += float(cols[1])


        if "total_writes" in cols[0]:
            num_writes += float(cols[1])
            print("\tWrites: " + str(num_writes))
            if "pim" in cols[0]:
                pim_writes += float(cols[1])
            else:
                cpu_writes += float(cols[1])

        # For CACTI ng estimation
        #if "total_readRowHits" in cols[0]:
        #    read_hits += float(cols[1]) 
        #    print("\tRead row hits: " + str(read_hits))
        #if "total_writeRowHits" in cols[0]:
        #    write_hits += float(cols[1])
        #    print("\tWrites: " + str(write_hits))

        if "activations" in cols[0]:
            num_act_pre += float(cols[1])  

        if "total_actEnergy" in cols[0]:
            gem5_act_total += float(cols[1])/1e12 # Stats file records energy in pJ (1E-12 J)

        if "total_readEnergy" in cols[0]:
            gem5_read_total += float(cols[1])/1e12

        if "total_writeEnergy" in cols[0]:
            gem5_write_total += float(cols[1])/1e12
            print("\tWrite ng: " + str(float(cols[1])/1e12))

        if "total_preEnergy" in cols[0]:
            gem5_pre_total += float(cols[1])/1e12

        if "total_actBackEnergy" in cols[0]:
            gem5_act_back_total += float(cols[1])/1e12

        if "total_preBackEnergy" in cols[0]:
            gem5_pre_back_total += float(cols[1])/1e12

        if "total_refreshEnergy" in cols[0]:
            gem5_refr_total += float(cols[1])/1e12  

        if cols[0] == "system.l2.ReadReq_accesses::total" or cols[0] == "system.l2.Writeback_accesses::total":
            l2_accesses += float(cols[1]) 


# Compare cacti versus gem5 stats per-operation energy
print("in nJ:")
print("\tCacti per read: " + str(cacti_read) + "\t\tgem5 per read: " + str(gem5_read_total*1e9/num_reads))
print("\tCacti per write: " + str(cacti_write) + "\t\tgem5 per write: " + str(gem5_write_total*1e9/num_writes))
print("\tCacti per activation: " + str(cacti_act) + "\t\tgem5 per activation: " + str(gem5_act_total*1e9/num_act_pre))
print("\tCacti per precharge: " + str(cacti_pre) + "\t\tgem5 per precharge: " + str(gem5_pre_total*1e9/num_act_pre))

# Compare total energy by type of operation
activ_rw_prech = gem5_act_total + gem5_read_total + gem5_write_total + gem5_pre_total
act_pre_back = gem5_act_back_total + gem5_pre_back_total
print("\tStats reported total energy activ/RW/prech: " + str(activ_rw_prech))
print("\tStats reported total energy act/pre background: " + str(act_pre_back))
print("\tStats reported total energy refr: " + str(gem5_refr_total))
print("\tTotal stats reported energy (used this for total energy): " + str(activ_rw_prech + gem5_refr_total + act_pre_back))
total_energy += activ_rw_prech
total_energy += gem5_refr_total 
total_energy += act_pre_back

######################################################################################################

print("Getting cpu core, cache, interconnect, and memory controller McPAT numbers")
mcpat_file = open(str(sys.argv[1]), 'r') 
mcpat_lines = mcpat_file.readlines()
mcpat_file.close()

watts = 0

# Finds first Gate Leakage and Runtime Dynamic power entries, which are for the whole system
for line in mcpat_lines:
    words = line.split()
    if len(words) and words[0] == "Gate":
        #print("\tCore, cache and interconnect gate leakage: " + words[3] + " W")
        watts += float(words[3])
    if len(words) and words[0] == "Runtime":
        #print("\tCore, cache and interconnect runtime dynamic: " + words[3] + " W")
        watts += float(words[3])
        break

#print("\tCore, cache and interconnect total watts: " + str(watts) + " W")
print("\tCPU cores, caches, interconnects, memory controller energy consumed = Watts * seconds =  " + str(watts) + " * " + str(sim_seconds) + " = " + str(watts * sim_seconds) + " J")
cpu_energy = watts * sim_seconds
total_energy += cpu_energy

######################################################################################################

print("Getting pim core McPAT numbers")
mcpat_file = open(str(sys.argv[2]), 'r') 
mcpat_lines = mcpat_file.readlines()
mcpat_file.close()

watts = 0

# Finds first Gate Leakage and Runtime Dynamic power entries, which are for the whole system
for line in mcpat_lines:
    words = line.split()
    if len(words) and words[0] == "Gate":
        #print("\tCore, cache and interconnect gate leakage: " + words[3] + " W")
        watts += float(words[3])
    if len(words) and words[0] == "Runtime":
        #print("\tCore, cache and interconnect runtime dynamic: " + words[3] + " W")
        watts += float(words[3])
        break

#print("\tCore, cache and interconnect total watts: " + str(watts) + " W")
print("\tPim core energy = Watts * seconds =  " + str(watts) + " * " + str(sim_seconds) + " = " + str(watts * sim_seconds) + " J")
if watts > 0: 
    pim_energy = watts * sim_seconds
    total_energy += pim_energy

######################################################################################################
# Comparing CACTI estimation of DRAM energy vs. gem5 - not including refresh or background

cacti_energy = (read_hits * cacti_read + (num_reads - read_hits) * (cacti_act + cacti_read + cacti_pre) + \
               write_hits * cacti_write + (num_writes - write_hits) * (cacti_act + cacti_write + cacti_pre)) \
               / 1e9    # energy per operation is in nJ from CACTI 
print read_hits
print write_hits
print cacti_read
print cacti_write
print num_reads
print num_writes
print cacti_act
print cacti_pre

######################################################################################################

print("\tTotal energy is " + str(total_energy) + " J. ")
power = total_energy/sim_seconds
print("\tAverage power is " + str(power) + " J. ")

result_file = open(str(sys.argv[4]), 'a')
result_file.write('%.4f' % power + "\t")
result_file.write('%.4f' % sim_seconds + "\t")
result_file.write('%.4f' % total_energy + "\t")

#result_file.write('%.4f' % mcpat_energy + "\t")
#result_file.write('%.6f' % activ_rw_prech + "\t")
#result_file.write('%.4f' % gem5_refr_total + "\t")
#result_file.write('%.4f' % act_pre_back + "\t")
result_file.write('%.6f' % cpu_energy + "\t")
result_file.write('%.6f' % pim_energy + "\t")

result_file.write('%.0f' % cpu_reads + "\t")
result_file.write('%.0f' % pim_reads + "\t")
result_file.write('%.0f' % cpu_writes + "\t")
result_file.write('%.0f' % pim_writes + "\t")
#result_file.write('%.0f' % num_reads + "\t")
#result_file.write('%.0f' % num_writes + "\t")
result_file.write('%.0f' % num_act_pre + "\t")
result_file.write('%.0f' % l2_accesses + "\t")

result_file.write("\n")
result_file.close()

