import matplotlib.pyplot as plt
import sys

#####################################################################################
# This script generates graphs based on the information in the tsv files given to it
#####################################################################################

if len(sys.argv) < 4:
    print("\nIf you want spaces in an argument, use '-' instead and it'll be replaced by a space.")
    print("Argument format: <Experiment name> [for each tsv file: <legend label> <tsv file>]\n")
    exit(0)

graph_colors = ['m', 'b', 'r', 'c', 'g', 'y', 'k']
thread_nums = [2, 4, 6, 8]
data = {}
col_headers = "Total-Energy McPAT-Energy Cacti-Operational-Energy Gem5-Operational-Energy Gem5-Refresh-Energy Gem5-Background-Energy Execution-Time Reads Writes Activations-and-Precharges".split()
y_labels = "Energy-in-Joules Energy-in-Joules Energy-in-Joules Energy-in-Joules Energy-in-Joules Energy-in-Joules Seconds Amount Amount Amount".split()

experiment = sys.argv[1]
num_tsvs = (len(sys.argv) - 2)/2

for curr_graph in range(len(col_headers)):

    # Get title and y axis lable from command line arguments
    plt.title(experiment.replace('-', ' ') + " " + col_headers[curr_graph].replace('-', ' '))
    plt.ylabel(y_labels[curr_graph].replace('-', ' '))

    # For keeping track of which arguments are legend names and tsv files
    start_arg = 2

    for curr_tsv in range(num_tsvs):
        label = sys.argv[start_arg + 2*curr_tsv].replace('-', ' ')
        tsv_file = open(sys.argv[start_arg + 2*curr_tsv + 1], 'r')
        tsv_lines = tsv_file.readlines()
        tsv_file.close()

        # headers are Total_NG McPAT_NG Cacti_a/rw/p Gem5_a/rw/p Refr Background Seconds Reads Writes Acts/Pres 
        num_cols = len(col_headers)

        for header in col_headers:
            data[header] = []

        for line in tsv_lines[1:]:
            cols = line.split()

            for i in range(num_cols):
                data[col_headers[i]].append(cols[i])

        plt.plot(thread_nums, data[col_headers[curr_graph]], color=graph_colors[(curr_graph + curr_tsv) % 7], marker='o', linestyle='-', label=label)

    plt.xlabel("Number of threads")
    plt.xlim([0,10])
    plt.legend()
    plt.grid(True)
    plt.savefig(experiment + "-" + col_headers[curr_graph])
    plt.clf()

