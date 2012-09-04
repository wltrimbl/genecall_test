#!/bin/bash
# This script prepares data and dependencies for wltrimbl/genecall_test

sudo apt-get install git

mkdir ~/bin

mkdir ~/build
cd ~/build

git clone https://github.com/wltrimbl/genecall_test.git

wget http://www.mcs.anl.gov/~trimble/abinitio/fixedlength-bygenome-byreadingframe.zip 
