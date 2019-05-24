0) Explain what mcpat briefly does and what we want to accomplish w these scripts
1) Explain how to create a new experiment and run the scripts, and what they do
    1a) first as a very quick overview of bare minimum
    1b) second as in depth walk through of what is happening
2) Explain how to customize the scripts 
    20) changing num threads, how stats are aggregated
    2a) changing params within existing components
    2b) by adding/removing components
        2bi) this covers using diff kinds of memory I think?? yea

# Overview

This collection of scripts was written to provide energy and power statistics for simulating concurrent data structure microbenchmarks on novel NDP architecture designs on [SMCSim](https://iis-git.ee.ethz.ch/erfan.azarkhish/SMCSim). It uses statistics files provided by [gem5](http://gem5.org/Main_Page), the architecture simulator SMCSim is based on, and system configuration files as inputs to the architecture energy estimation tool [McPAT](https://github.com/HewlettPackard/mcpat) to get energy statistics, from which power can be calculated.  


# Setting up for the first time
1. **Set up SMCSim on your machine.**
2. **Clone this repo somewhere.** We will be copying stats files from the results directory of SMCSim to experiment directories within here.
3. **From the main repo dir, run** **`SCRIPTS/setup_gem5tomcpat_and_mcpat.bash`**. This should clone both the gem5tomcpat and mcpat repos to your base, add them to your .gitignore, and compile mcpat.
5. Change line 134 of gem5tomcpat/Gem5ToMcPAT.py from `statKind = statLine.match(line).group(1)` to 

       try:
        	statKind = statLine.match(line).group(1)
        except:
        	continue
	This was a hack I made to get around this script not recognizing regex patterns of stats that we weren't interested in - the one leading to this quick fix was `system.pim_vault_ctrls0.rdPerTurnAround::1.31072e+06-1.44179e+06`

# Creating an experiment
1. **Make a new directory in EXPERIMENTS/ and name it however you like.** 
2. **Copy over the **`get_energy.bash`** script of the example experiment directory to your new one.** This script calls the master script and then places the result files neatly in a results dir within this experiment dir.
3. Copy over or create the following files for each simulation. These need to be fed as arguments to the master script:
	1. the **XML file** for the host cores. The sample experiment uses the 8 core one for the NDP setup; the host setup one has 16 (that's the only difference between the two)
	2. the **XML file** for NDP cores. The sample experiment uses an 8 core one (which is used both for NDP and host setups)
	4. the **config.json** from the SMCSim results directory
	5. the **stats.txt** from the SMCSim results directory. The master script assumes the structure of this file is 8 timestamps representing 2, 4, 6, and 8 thread executions of the same benchmark.
4.  Replace the file paths in the template script with the desired ones, and run **`get_energy.bash`** from the experiment directory.

The output for each number of threads should look like:

    Getting stats and aggregating, cleaning into 8 8-pim-stats.txt
		Aggregating stats across all CPUs, interconnects, and memory controllers
    Summed stats in 8-pim-stats.txt 
    Running gem5tomcpat to pull stats and put into XML for mcpat 
    Reading GEM5 stats from: 8-pim-stats.txt 
    Reading config from: /home/amy/new_pim_power/EXPERIMENTS/rowbuffer_linkedlist/baseline_buffersize32_final_config.json 
    Reading McPAT template from: XML_FILES/arm15_HostCPUs-PIM.xml 
    Writing input to McPAT in: mcpat-out.xml 
    Running McPAT - energy for host cores, caches, interconnects, memory controllers 
    Running gem5tomcpat to pull stats and put into XML for mcpat 
    Reading GEM5 stats from: 8-pim-stats.txt 
    Reading config from: /home/amy/new_pim_power/EXPERIMENTS/rowbuffer_linkedlist/baseline_buffersize32_final_config.json 
    Reading McPAT template from: XML_FILES/arm15_PimCPUs.xml 
    Writing input to McPAT in: mcpat-out.xml 
    Running McPAT - energy for pim cores, memory controllers 
    Writing detailed results to 8-pim-results.txt and just numbers to /home/amy/new_pim_power/EXPERIMENTS/rowbuffer_linkedlist-pim.tsv

# Acknowledgements

Amy Huang UTRA research fellowship, 2018. With the gracious help of Ph.D. candidate Jiwon Choe and Professor Iris Bahar at Brown University.
