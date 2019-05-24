#!/bin/bash

# Clone the packages from their respective repos
git clone https://github.com/HewlettPackard/mcpat.git
git clone https://bitbucket.org/dskhudia/gem5tomcpat.git

# Have git ignore both repos
echo "mcpat" >> .gitignore
echo "gem5tomcpat" >> .gitignore
echo ".gitignore" >> .gitignore

# Build mcpat
cd mcpat
make
