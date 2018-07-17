import sys

is_pim = sys.argv[1]

# Get these values in nanoJoules from running cacti on pim.cfg from the cacti directory
# ./cacti -infile pim.cfg
act_e = .922577	# activation energy
read_e = 2.12648	# read energy
write_e = 2.12671	# write energy
pre_e = .246752	# precharge energy

# Get the lines from stats file
stats = open('2-pim-stats.txt', 'r')
stat_lines = stats.readlines()
stats.close()

# Keys are (pim or mem, number)  
read_hits = {}
write_hits = {}
reads = {}
writes = {}

for line in stat_lines:
    cols = line.split()
    stat_name = cols[0].split('.')
        
    if len(stat_name) > 3 and stat_name[3] == "readRowHitRate":
        print line
        ctrl_num = int(stat_name[2][-1])
        pim_or_mem = stat_name[2][:-1].split("_")[0]    # Is pim or mem controller
        read_hits[(pim_or_mem, ctrl_num)] = float(cols[1])
    if len(stat_name) > 3 and stat_name[3] == "writeRowHits":
        ctrl_num = int(stat_name[2][-1])
        pim_or_mem = stat_name[2][:-1].split("_")[0]    
        write_hits[(pim_or_mem, ctrl_num)] = float(cols[1])
    if len(stat_name) > 3 and stat_name[3] == "num_reads::total":
        print line
        ctrl_num = int(stat_name[2][-1])
        pim_or_mem = stat_name[2][:-1].split("_")[0]   
        reads[(pim_or_mem, ctrl_num)] = float(cols[1])
    if len(stat_name) > 3 and stat_name[3] == "num_writes::total":
        ctrl_num = int(stat_name[2][-1])
        pim_or_mem = stat_name[2][:-1].split("_")[0]  
        writes[(pim_or_mem, ctrl_num)] = float(cols[1])

#print reads
#print writes 
#print write_hits

total = 0

if is_pim:
    for i in range(8):
        try:
            read_hits["mem", i]
        except Exception:
            print "oh no " + str(i)

        print str(i)
        print read_hits["mem", i]
        print reads["mem", i]
        print write_hits["mem", i]
        print writes["mem", i]


        ctrlr_total = read_hits[("mem", i)] * read_e + (reads[("mem", i)] - read_hits[("mem", i)]) * (read_e + act_e + pre_e)
        print ctrlr_total
        
else:
    key_range = 15


