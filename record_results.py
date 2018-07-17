import sys

# This script calculates how much energy main memory has consumed based on CACTI and the stats file, and then adds it to the energy of everything else as estimated by McPAT to get a total number.
# The CACTI output, McPAT, then stats file is parsed.

if len(sys.argv) != 4:
    print("\n Argument format: <mcpat text output> <cacti text output> <name of tsv file for totals> \n")
    exit(0)

######################################################################################################

print("CACTI numbers")

cacti_file = open(str(sys.argv[2]), 'r') 
cacti_lines = cacti_file.readlines()
cacti_file.close()

num_banks = 0
read_energy = 0
write_energy = 0
activation_energy = 0
precharge_energy = 0

for line in cacti_lines:
    # Ignore whitespace at beginning of lines
    while line[0] == '\t' or line[0] == ' ':
        line = line[1:]
    
    cols = line.split(':')

    if cols[0] == "Read energy": 
        read_energy = float(cols[1].split()[0])
        print("\tRead energy: " + str(read_energy) + " nJ")

    if cols[0] == "Write energy": 
        write_energy = float(cols[1].split()[0])
        print("\tWrite energy: " + str(write_energy) + " nJ")

    if cols[0] == "Activation energy": 
        activation_energy = float(cols[1].split()[0])
        print("\tActivation energy: " + str(activation_energy) + " nJ")

    if cols[0] == "Precharge energy": 
        precharge_energy = float(cols[1].split()[0])
        print("\tPrecharge energy: " + str(precharge_energy) + " nJ")

######################################################################################################

print("\tCalculating hybrid memory cube energy using memory access stats")

stats = open('cut_stats.txt', 'r')
stat_lines = stats.readlines()
stats.close()

num_reads = 0
num_writes = 0
sim_seconds = 0
total_power = 0
reported_memctrl_ng = 0
activ_rw_prech = 0
refresh = 0
act_pre_back = 0

for line in stat_lines[::-1]:
    cols = line.split()
    if len(cols):
        if cols[0] == "system.mem_ctrls.total_refreshEnergy":
            refresh = float(cols[1])/1000000000000
        if cols[0] == "system.mem_ctrls.total_actEnergy" or cols[0] == "system.mem_ctrls.total_preEnergy" or cols[0] == "system.mem_ctrls.total_readEnergy" or cols[0] == "system.mem_ctrls.total_writeEnergy":
            activ_rw_prech += float(cols[1])/1000000000000
        if cols[0] == "system.mem_ctrls.total_actBackEnergy" or cols[0] == "system.mem_ctrls.total_preBackEnergy":
            act_pre_back += float(cols[1])/1000000000000
        if cols[0] == "total_reads":
            num_reads = float(cols[1])
            print("\tReads: " + str(num_reads))
        if cols[0] == "total_writes":
            num_writes = float(cols[1])
            print("\tWrites: " + str(num_writes))
        if cols[0] == "total_sim_seconds":
	    sim_seconds = float(cols[1])
	    print("\tSeconds simulated: " + str(sim_seconds) + " s")



print("\tStats reported total energy activ/RW/prech: " + str(activ_rw_prech))
print("\tStats reported total energy refr: " + str(refresh))
print("\tStats reported total energy act/pre background: " + str(act_pre_back))
print("\tTotal stats reported energy (used this for total energy): " + str(activ_rw_prech + refresh + act_pre_back))
total_power += activ_rw_prech
total_power += refresh 
total_power += act_pre_back


read_total = num_reads * (activation_energy + read_energy + precharge_energy) * (1.0/1000000000)
write_total = num_writes * (activation_energy + write_energy + precharge_energy) * (1.0/1000000000)
print("\tReads+writes: " + str(num_reads + num_writes))
print("\tCACTI maximum estimate for DRAM energy is " + str(read_total+write_total) + " J")

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
total_power += watts * sim_seconds

######################################################################################################

print("\tTotal power is " + str(total_power) + " J. ")

result_file = open(str(sys.argv[3]), 'a')
result_file.write(str(total_power) + "\t")
result_file.write(str(activ_rw_prech) + "\t")
result_file.write(str(refresh) + "\t")
result_file.write(str(act_pre_back) + "\t")
result_file.write("\n")
result_file.close()
