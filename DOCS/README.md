# Overview

This collection of scripts was written to provide energy and power statistics for simulating concurrent data structure microbenchmarks on novel near-data processing (NDP) architecture designs on [SMCSim](https://iis-git.ee.ethz.ch/erfan.azarkhish/SMCSim). It uses statistics files provided by [gem5](http://gem5.org/Main_Page), the architecture simulator SMCSim is based on, and system configuration files as inputs to the architecture energy estimation tool [McPAT](https://github.com/HewlettPackard/mcpat) to get energy statistics, from which power can be calculated.  


# Setting up for the first time
1. **Set up SMCSim on your machine.**
2. **Clone this repo somewhere.** We will be copying stats files from the results directory of SMCSim to experiment directories within here.
3. **From the main repo dir, run** **`SCRIPTS/setup_gem5tomcpat_and_mcpat.bash`**. This should clone both the gem5tomcpat and mcpat repos to your base, add them to your .gitignore, and compile mcpat.
5. **Change line 134 of gem5tomcpat/Gem5ToMcPAT.py** from `statKind = statLine.match(line).group(1)` to 

       try:
        	statKind = statLine.match(line).group(1)
        except:
        	continue
	This was a hack I made to get around this script not recognizing regex patterns of stats that we weren't interested in - the one leading to this quick fix was `system.pim_vault_ctrls0.rdPerTurnAround::1.31072e+06-1.44179e+06`

# Creating an experiment
1. **Make a new directory in EXPERIMENTS/**. Name it however you like. 
2. **Copy over the **`get_energy.bash`** script** of the example experiment directory to your new one. This script calls the master script and then places the result files neatly in a results dir within this experiment dir.
3. **Copy over or create the following files for each simulation**. These need to be fed as arguments to the master script:
	1. the **XML file** for the host cores. The sample experiment uses the 8 core one for the NDP setup; the host setup one has 16 (that's the only difference between the two)
	2. the **XML file** for NDP cores. The sample experiment uses an 8 core one (which is used both for NDP and host setups)
	4. the **config.json** from the SMCSim results directory
	5. the **stats.txt** from the SMCSim results directory. The master script assumes the structure of this file is 8 timestamps representing 2, 4, 6, and 8 thread executions of the same benchmark.
4.  **Replace the file paths in the template script with the desired ones**. If you want to have multiple simulations analyzed, then repeat this process, making sure to assign a different **run_name** for the result files to be put in.
5. **Run** **`get_energy.bash`** from the experiment directory.

The terminal print outs for each number of threads should look like:

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
	    Calculating hybrid memory cube energy using memory access stats
	Getting host core, cache, interconnect, and memory controller McPAT numbers
	Getting pim core, cache, interconnect, and memory controller McPAT numbers
		Total energy is 19.4116089914 J.
		Average power is 8.32416035926 J.
Afterwards, there should be new dirs named after each 'run' or simulation. Each should contain:
* for each *number of threads*,
	* a **stats file** with the two relevant timestamps' lines from the original stats file
	* **cpu power and pim power files** that are simply the printouts of the mcpat tool for cpu cores and memory controllers, and pim cores/mcs, respectively
* **.tsv files** for each simulation, which can be copy pasted [into this google sheets template](https://docs.google.com/spreadsheets/d/1mwKPn-BNp2J4LLqhCkfSk6GMR2c_H86D2sv7m2mKpaw/edit?usp=sharing) for easily readable formatting and chart generation (in google sheets, or from excel when downloaded as an excel file)

# Walk-through of the script functionality
This will be deeper description of what scripts are called when, and what each of them does. At a high level, we use **McPAT for cores and memory controller energy/power**, and **gem5's self-calculated numbers for DRAM energy/power**.

**`get_energy.bash`** script is the first level, called from its experiment directory. 
* For each simulation, it calls **`master_script.bash`** with the relevant *XML files*, *config json file*, and *stats file* paths as arguments. The following is then done for each # of threads:
	* A new stats file containing just the relevant timestamps' data (# threads, # threads - 1) is created using `grep`. 
	* **`aggregate_stats.bash`** adds additional lines of statistics that total numbers of interest across all components of the same type; e.g., # of reads for all host memory controllers.
	* **`gem5tomcpat/Gem5ToMcPAT.py`** is called with the *new stats file*, *the config.json file*, and *the host core XML file*. The XML file has *system configuration parameters* that stay the same between runs (like # cores), and *performance statistics parameters*. The values of these are set to names of corresponding gem5 stats.txt statistic names. **`gem5tomcpat/Gem5ToMcPAT.py`** then replaces those gem5 statistic names with the corresponding values from the new stats file in a new XML called `mcpat-out.xml`.
	* **`mcpat`** is run with `mcpat-out.xml` as a single argument, and the resulting printout is saved to a file whose name ends with "cpu_power.txt". This is the energy info for host cores and memory controllers.
	* The above 2 bullet points are repeated for NDP cores and memory controllers. **`gem5tomcpat/Gem5ToMcPAT.py`** is called again, but now with the NDP core XML file. **`mcpat`** is run with the output. Printout is saved in a file whose name ends in "pim_power.txt".
	* **`calculate_results.py`** is run with the stats file and newly created power files as arguments. This is where the memory energy and power are parsed from the stats file, and combined with the McPAT-created numbers into the final .tsv file.

All result files were made in the main repo dir, so **`get_energy.bash`** finally moves them to the results dir within the experiment folder.

# Changing experiment parameters
## Changing number of threads
In the master script, we divide the original stats file into separate files containing two timestamps' data each for each number of threads. 
This is because for each num_threads, timestamp # num_threads - 1 is for preparing the execution of the benchmark, while timestamp # num_threads is for stats from the actual execution. 

If the structure of execution changes - we either don't need a prep timestamp any more, or there are multiple timestamps of preparation or execution consecutively - then the function used to aggregate the affected stats must be changed.

This is because the value of some stats must be calculated by subtracting the value for it from the first timestamp from the total recorded at the second timestamp, because we aren't interested in measuring energy or performance of setting up the data structures needed for our benchmarks.

This is done in **`SCRIPTS/aggregate_stats.bash`**, by the function **sum_cumulative**. One can then add sum functions if the order/number of relevant timestamps changes.

## XML file editing overview
We need to edit the XML template files directly in **`XML_FILES`** if we are to get energy numbers for numbers of or types of components different from the default ones. The existing default files describe the following system conigurations:
    * **`arm15_HostCPUs.xml`** - 8 host cores and 8 memory controllers, meant for host system
    * **`arm15_HostCPUs-PIM.xml`** - 8 host cores and 16 memory controllers, meant for NDP-enhanced system
    * **`arm15_PimCPUs.xml`** - 8 NDP cores and 8 memory controllers
All core configuration settings are based on what I could find about the Arm 15 Cortex.

The relevant differences between NDP cores/memory controllers and host ones with respect to the XML files are that NDP cores are simpler (lacking caches, NoCs) and must get their stats from different places in the stats file (the aggregated pim component stats that **`aggregate_stats.bash`** calculates, instead of the host ones).

### Changing the number and type of existing components 
To edit system configuration settings, find the relevant "param" tag and change its value. For example, for cores there is "number_or_cores" or "number_of_L2s". If there is a type of configuration not listed as a paramter, then it isn't taken into account when McPAT does its calculations and thus won't make a difference in the final energy numbers.

There are more templates in the **`mcpat/ProcessorDescriptionFiles/`** if you'd like to see more.

### Adding and removing components
The other kind of components are L1 and L2 directories (a different configuration of caches than what we needed), niu (network interface unit?), pcie, and flashc (flash controller). There are additionally sub-components within cores that I ultimately did not include, like BTB's. They are included as components in the default files but not used in the energy calculations at all, since the number of units for each is 0. 

If you want to include one, you must change the number of units and change the settings to be representative of your system. If in **`mcpat/ProcessorDescriptionFiles`** you don't find any example XML file with the type of component you want, then there isn't a way to account for it in McPAT energy calculations, as that would require writing more McPAT code to calculate circuit energy given certain configurations of it+performance stats.

# Acknowledgements

Amy Huang UTRA research fellowship, 2018. With the gracious help of Ph.D. candidate Jiwon Choe and Professor Iris Bahar at Brown University.
