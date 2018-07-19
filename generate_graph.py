import matplotlib.pyplot as plt
import sys

#####################################################################################
# This script generates graphs based on the information in the tsv files given to it
#####################################################################################

if len(sys.argv) < 4:
    print("\n Argument format: <title> <y axis label> [for each tsv file: <legend label> <tsv file>]\n")
    exit(0)

graph_colors = ['m', 'b', 'r', 'c', 'g', 'y', 'k']
data = {}   # Key is column header, and value is list of values for each thread number
thread_nums = [2, 4, 6, 8]
plt.xlabel("Number of threads")
plt.xlim([0,10])

title = sys.argv[1]
plt.title(title)
y_axis = sys.argv[2]
plt.ylabel(y_axis)
num_tsvs = (len(sys.argv) - 3)/2
curr_sys_arg = 3 

for curr_tsv in range(num_tsvs): 
    label = sys.argv[curr_sys_arg + 2*curr_tsv]
    tsv_file = open(sys.argv[curr_sys_arg + 2*curr_tsv + 1], 'r')
    tsv_lines = tsv_file.readlines()
    tsv_file.close()
    
    # headers are Total_NG McPAT_NG Cacti_a/rw/p Gem5_a/rw/p Refr Background Seconds Reads Writes Acts/Pres 
    col_headers = tsv_lines[0].split()
    num_cols = len(col_headers)
    
    for header in col_headers:
        data[header] = []
    
    for line in tsv_lines[1:]:
        cols = line.split()
    
        for i in range(num_cols):
            data[col_headers[i]].append(cols[i])
    
    plt.plot(thread_nums, data[col_headers[0]], color=graph_colors[curr_tsv % 7], marker='o', linestyle='-', label=label)

plt.legend()
plt.show()
