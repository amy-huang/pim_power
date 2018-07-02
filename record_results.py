import sys

if len(sys.argv) != 4:
    print("\n Argument format: <mcpat text output> <cacti text output> <results file to append to>\n")
    exit(0)

mcpat_file = open(str(sys.argv[1]), 'r') 
mcpat_lines = mcpat_file.readlines()
mcpat_file.close()

total_power = 0

# Finds first Gate Leakage and Runtime Dynamic power entries, which are for the whole system
for line in mcpat_lines:
    words = line.split()
    if len(words) and words[0] == "Gate":
        total_power += float(words[3])
    if len(words) and words[0] == "Runtime":
        total_power += float(words[3])
        break

print total_power

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
    if cols[0] == "Read energy": 
        read_energy = float(cols[1].split()[0])
    if cols[0] == "Write energy": 
        write_energy = float(cols[1].split()[0])
    if cols[0] == "Activation energy": 
        activation_energy = float(cols[1].split()[0])
    if cols[0] == "Precharge energy": 
        precharge_energy = float(cols[1].split()[0])

stats = open('cut_stats.txt', 'r')
stat_lines = stats.readlines()
stats.close()

num_reads = 0
num_writes = 0

for line in stat_lines[::-1]:
    cols = line.split()
    if cols[0] == "system.mem_ctrls.memory_reads":
         num_reads = int(cols[1])
    if cols[0] == "system.mem_ctrls.memory_writes":
         num_writes = int(cols[1])
    if num_reads and num_writes:
        break

total_power += num_reads * (activation_energy + read_energy + precharge_energy)
total_power += num_writes * (activation_energy + write_energy + precharge_energy)
print(str(total_power) + " nJ")

print num_banks
print read_energy
print write_energy
print activation_energy 
print precharge_energy
print num_reads
print num_writes
