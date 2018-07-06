import sys

# Print error message if input and output files not specified
if len(sys.argv) < 3:
    print "usage: python CSVtoXML.py <input file> <output file>"
    exit(0)

# Get lines from csv file input
csv_file = open(str(sys.argv[1]), 'r')
lines = csv_file.readlines()
csv_file.close()

# Keep track of list of current component hieararchy and num tabs
curr_components = []
tabs = ""

# Write xml header and root component to file
new_xml = open(str(sys.argv[2]), 'w')
new_xml.write("<?xml version=\"1.0\" ?>\n")
new_xml.write("<component id=\"root\" name=\"root\">\n")

for line in lines:
    # List of component ancestors
    cols = line.split('\t')
    new_components = cols[0].split('.')
    
    # If component name has changed, 
    if curr_components == [] or new_components[-1] != curr_components[-1]:
        if len(new_components) == len(curr_components):
            new_xml.write(tabs + "</component>\n")
            new_xml.write(tabs + "<component id=\"" + ".".join(new_components) + "\" name=\"" + cols[4][:-1] + "\">\n") 
        if len(new_components) > len(curr_components):
            tabs += "\t"
            new_xml.write(tabs + "<component id=\"" + ".".join(new_components) + "\" name=\"" + cols[4][:-1] + "\">\n") 
        if len(new_components) < len(curr_components):
            while len(curr_components) > len(new_components):
                new_xml.write(tabs + "</component>\n")
                curr_components = curr_components[:-1]
                tabs = tabs[:-1]
            new_xml.write(tabs + "</component>\n")
            new_xml.write(tabs + "<component id=\"" + ".".join(new_components) + "\" name=\"" + cols[4][:-1] + "\">\n") 
        curr_components = new_components
    # Write parameter or stat 
    new_xml.write(tabs + "\t<" + cols[1] + " name=\"" + cols[2] + "\" value=\"" + cols[3] + "\"/>\n")

# Close last components, and root            
while (tabs != ""):
    new_xml.write(tabs + "</component>\n")
    tabs = tabs[:-1]
new_xml.write(tabs + "</component>\n")

new_xml.close()

