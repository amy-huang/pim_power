import sys

# This script calculates how much energy main memory has consumed based on CACTI and the stats file, and then adds it to the energy of everything else as estimated by McPAT to get a total number.
# The CACTI output, McPAT, then stats file is parsed.

if len(sys.argv) != 4:
    print("\n Argument format: <mcpat text output> <cacti text output> <name of tsv file for totals> \n")
    exit(0)

######################################################################################################

print("Getting CACTI numbers")

cacti_file = open(str(sys.argv[2]), 'r') 
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

# Row buffer; used for cacti estimation energy
read_hits = 0
write_hits = 0

for line in stat_lines[::-1]:
    cols = line.split()
    if len(cols):
        if cols[0] == "total_sim_seconds":
	        sim_seconds = float(cols[1])
	        print("\tSeconds simulated: " + str(sim_seconds) + " s")

        if cols[0] == "system.all_ctrls.total_reads":
            num_reads = float(cols[1])
            print("\tReads: " + str(num_reads))

        if cols[0] == "system.all_ctrls.total_writes":
            num_writes = float(cols[1])
            print("\tWrites: " + str(num_writes))

        if cols[0] == "system.all_ctrls.activations":
            num_act_pre += float(cols[1])  

        if cols[0] == "system.all_ctrls.total_actEnergy":
            gem5_act_total += float(cols[1])/1e12 # Stats file records energy in pJ (1E-12 J)

        if cols[0] == "system.all_ctrls.total_readEnergy":
            gem5_read_total += float(cols[1])/1e12

        if cols[0] == "system.all_ctrls.total_writeEnergy":
            gem5_write_total += float(cols[1])/1e12
            print("\tWrite ng: " + str(float(cols[1])/1e12))

        if cols[0] == "system.all_ctrls.total_preEnergy":
            gem5_pre_total += float(cols[1])/1e12

        if cols[0] == "system.all_ctrls.total_actBackEnergy":
            gem5_act_back_total += float(cols[1])/1e12

        if cols[0] == "system.all_ctrls.total_preBackEnergy":
            gem5_pre_back_total += float(cols[1])/1e12

        if cols[0] == "system.all_ctrls.total_refreshEnergy":
            gem5_refr_total += float(cols[1])/1e12  

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

print("Getting McPAT numbers")
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
print("\tEnergy consumed = Watts * seconds =  " + str(watts) + " * " + str(sim_seconds) + " = " + str(watts * sim_seconds) + " J")
mcpat_energy = watts * sim_seconds
total_energy += mcpat_energy

######################################################################################################
# Comparing CACTI estimation of DRAM energy vs. gem5 - not including refresh or background

cacti_energy = (read_hits * cacti_read + (num_reads - read_hits) * (cacti_act + cacti_read + cacti_pre) + \
               write_hits * cacti_write + (num_writes - write_hits) * (cacti_act + cacti_write + cacti_pre)) \
               / 1e9    # energy per operation is in nJ from CACTI 

######################################################################################################

print("\tTotal energy is " + str(total_energy) + " J. ")
power = total_energy/sim_seconds
print("\tAverage power is " + str(power) + " J. ")

result_file = open(str(sys.argv[3]), 'a')
result_file.write('%.4f' % power + "\t")
result_file.write('%.4f' % total_energy + "\t")
result_file.write('%.4f' % sim_seconds + "\t")

result_file.write('%.4f' % mcpat_energy + "\t")
result_file.write('%.4f' % cacti_energy + "\t")
result_file.write('%.6f' % activ_rw_prech + "\t")
result_file.write('%.4f' % gem5_refr_total + "\t")
result_file.write('%.4f' % act_pre_back + "\t")

result_file.write('%.0f' % num_reads + "\t")
result_file.write('%.0f' % num_writes + "\t")
result_file.write('%.0f' % num_act_pre + "\t")

result_file.write("\n")
result_file.close()

