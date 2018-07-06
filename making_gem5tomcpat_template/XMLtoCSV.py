import sys

def get_first_word(line):
    # Break up line by spaces as delimiter 
    words = line.split(' ')
    # Break up first chunk by tabs
    tabs_and_firstword = words[0].split('\t')
    # Get first non-tab string
    first_word = tabs_and_firstword[len(tabs_and_firstword) - 1]

    return first_word

if len(sys.argv) < 3:
    print "usage: python XMLtoCSV.py <input file> <output file>"
    exit(0)

# Get lines from XML file passed in as command line arg
xml_file = open(str(sys.argv[1]), 'r')
full_text = xml_file.read()
full_text = full_text.replace(" , ", ",").replace(", ", ",").replace(" ,", ",").replace(" +  ", "+").replace(" + ", "+").replace(" / ", "/").replace(" - ", "-").replace(" * ", "*")
lines = full_text.splitlines()
xml_file.close()

delim = "`"

new_csv = open(str(sys.argv[2]), 'w')

component = None
trait = None
value = None
p_or_s = None
comment = []
val_not_done = False

for line in lines:
    # Break up line by spaces as delimiter 
    words = line.split()
     
    if len(words) > 0:        

        if words[0] == "<component":
            component = words[1].split("\"")[1]  
            component_name = words[2].split("\"")[1] 
        
        if words[0] == "<param" or words[0] == "<stat":
            p_or_s = words[0][1:] 
            trait = words[1].split("\"")[1]
            value = words[2].split("\"")[1]
            new_csv.write(component + delim + p_or_s + delim + trait + delim + value + delim + component_name)
            new_csv.write('\n')

new_csv.close()
