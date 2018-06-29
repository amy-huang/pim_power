import sys

###############################################################################################
#
# This script takes a template XML file, a text file with 3 columns: 1) component name, 
# 2) param or stat name, and 3) value that param or stat should take from the config stat file, 
# and then an output file name where the resulting XML goes.
#
# That way, gem5tomcpat can again replace the values of those params and stats with the values
# in the config and stats file to create the final mcpat in file.
#
###############################################################################################

# If number of arguments is incorrect, prints file usage
if len(sys.argv) != 4:
    print("\nArgument format: <input XML file> <replacements text file> <output XML file>\n")
    exit(0)

# The first argument is the input XML. Read each line from it as a string ending in \n, and 
# store them in a list in_xml_lines.
in_xml = open(str(sys.argv[1]), 'r')
in_xml_lines = in_xml.readlines()
in_xml.close()

###############################################################################################
#
# The second argument, the replacements text file, is used to build a hash table - 
# The key is the tuple (component id, parameter or stat name) and the value is the value that
# should replace the current value, so a name from the config or stats file.
#
# These are exactly the three space-separated columns in the replacements text file.
#
###############################################################################################
to_change = {}
replacements = open(str(sys.argv[2]), 'r')
for line in replacements.readlines():
    cols = line.split()
    to_change[(cols[0], cols[1])] = cols[2] 

###############################################################################################
#
# Now, we iterate through the original xml file lines, rewriting each line to the new xml file. 
# If it's a component opening or closing line, we just update the current component id.
# If it's a parameter or statistic line, then we see if its value needs replacing.
# If (component id, param or stat name) is found in the dictionary to_change, then we rewrite
# the line to the new xml file. Otherwise the line is copied without change. For example:
#
# Component id currently: system.core0.dcache
# Say (system.core0.dcache, )
#
#
###############################################################################################
component_id = ""
# The third argument is the name of the output XML file; open for writing to 
out_xml = open(str(sys.argv[3]), 'w') 

for line in in_xml_lines:
    # Break up line with spaces as delimiter - words is a list of the space separated strings
    # in the current line of the XML file. 
    words = line.split()
     
    if len(words) > 0:    

        # ADD A NESTED COMPONENT, e.g.
        # <component id="system.core0.dtlb" name="dtlb">
        # words is a list of strings delimited by spaces, so words[1] is id="system.core0.dtlb"
        # and system.core0.dtlb is the second item with " as another delimiter.
        # We record the new component_id and copy the line over as is
        if words[0] == "<component":
            component_id = words[1].split("\"")[1]  
            out_xml.write(line)

        # END A NESTED COMPONENT, e.g.
        # </component>
        # The new component_id is the component one level above - so system.core0.dcache to
        # system.core0. We can get this by splitting with a . delimiter and rejoining without
        # the last item, the old component
        if words[0] == "</component>":
            component_id = '.'.join(component_id.split('.')[:-1])
            out_xml.write(line)

        # REPLACE PARAM OR STAT VALUE IF NEEDED, e.g.
        # <stat name="read_accesses" value="800000"/>
        # with component_id as system.core0.dcache
        # The name of the stat or param, trait, is in words[1], and with " as delimiter, it's the 2nd
        # item. Now we can check if (system.core0.dcache, read_accesses) is in the dictionary
        # of params and stats to change. If it isn't, the line is copied as is to the new XML.
        # If it is, we indent the right number of tabs - the 
        # number of currently nested components + 1. Then we replace the value 
        # with the string stored in the dictionary, replacing the last item of words:
        # value="800000"/>\n becomes value="stats.system.cpu.dcache.read_access"/>\n 
        if words[0] == "<param" or words[0] == "<stat":
            trait = words[1].split("\"")[1] 
            if (component_id, trait) in to_change.keys():   
                for i in range(len(component_id.split('.')) + 1):  
                    out_xml.write("\t")
                words[-1] = "value=\"" + to_change[(component_id, trait)] + "\"/>\n"
                out_xml.write(" ".join(words))
            else:
                out_xml.write(line)     
out_xml.close()
