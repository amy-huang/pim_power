import sys

if len(sys.argv) != 3:
    print("\n Argument format: <mcpat text output> <cacti text output> \n")
    exit(0)

######################################################################################################

print("\tGetting CACTI numbers")

cacti_file = open(str(sys.argv[2]), 'r') 
cacti_lines = cacti_file.readlines()
cacti_file.close()

num_banks = 0
read_energy = 0
write_energy = 0
activation_energy = 0
precharge_energy = 0

for line in cacti_lines:
    while line[0] == '\t' or line[0] == ' ':
        line = line[1:]
    
    cols = line.split(':')
    if cols[0] == "Number of banks":
        num_banks = int(cols[1])
        print("\t\tNumber of banks: " + str(num_banks))

    if cols[0] == "Read energy": 
        read_energy = float(cols[1].split()[0])
        print("\t\tRead energy: " + str(read_energy) + " nJ")

    if cols[0] == "Write energy": 
        write_energy = float(cols[1].split()[0])
        print("\t\tWrite energy: " + str(write_energy) + " nJ")

    if cols[0] == "Activation energy": 
        activation_energy = float(cols[1].split()[0])
        print("\t\tActivation energy: " + str(activation_energy) + " nJ")

    if cols[0] == "Precharge energy": 
        precharge_energy = float(cols[1].split()[0])
        print("\t\tPrecharge energy: " + str(precharge_energy) + " nJ")

print("\t\tPer read energy: " + str(activation_energy + read_energy + precharge_energy))
print("\t\tPer write energy: " + str(activation_energy + write_energy + precharge_energy))

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
            print("\t\tReads: " + str(num_reads))
        if cols[0] == "total_writes":
            num_writes = float(cols[1])
            print("\t\tWrites: " + str(num_writes))
        if cols[0] == "total_sim_seconds":
		    sim_seconds = float(cols[1])
		    print("\t\tSeconds simulated: " + str(sim_seconds) + " s")



print("\tStats reported total energy activ/RW/prech: " + str(activ_rw_prech))
print("\tStats reported total energy refr: " + str(refresh))
print("\tStats reported total energy act/pre background: " + str(act_pre_back))
print("\tReads+writes: " + str(num_reads + num_writes))

read_total = num_reads * (activation_energy + read_energy + precharge_energy) * (1.0/1000000000)
print("\t\tRead energy = number of reads * (activation energy + read energy + precharge energy) = " + str(read_total) + " J")
write_total = num_writes * (activation_energy + write_energy + precharge_energy) * (1.0/1000000000)
print("\t\tWrite energy = number of writes * (activation energy + read energy + precharge energy) = " + str(write_total) + " J")

total_power += read_total
total_power += write_total
print("\tTotal power so far is " + str(total_power) + " J")

######################################################################################################

print("\tGetting McPAT numbers")
mcpat_file = open(str(sys.argv[1]), 'r') 
mcpat_lines = mcpat_file.readlines()
mcpat_file.close()

watts = 0

# Finds first Gate Leakage and Runtime Dynamic power entries, which are for the whole system
for line in mcpat_lines:
    words = line.split()
    if len(words) and words[0] == "Gate":
        print("\t\tCore, cache and interconnect gate leakage: " + words[3] + " W")
        watts += float(words[3])
    if len(words) and words[0] == "Runtime":
        print("\t\tCore, cache and interconnect runtime dynamic: " + words[3] + " W")
        watts += float(words[3])
        break

print("\t\tCore, cache and interconnect total watts: " + str(watts) + " W")
print("\t\tEnergy consumed = Watts * seconds =  " + str(watts) + " * " + str(sim_seconds) + " = " + str(watts * sim_seconds) + " J")
total_power += watts * sim_seconds

######################################################################################################

print("\tTotal power is " + str(total_power) + " J. ")
"""
result_file = open(str(sys.argv[3]), 'a')
result_file.write(str(total_power) + " J\n")
result_file.close()
"""
