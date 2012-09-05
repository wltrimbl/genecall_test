#!/bin/bash
# This script prepares data and dependencies for wltrimbl/genecall_test

sudo apt-get install git -y
sudo apt-get install zip -y
mkdir ~/bin

mkdir ~/build
cd ~/build

git clone https://github.com/wltrimbl/genecall_test.git

ln -s ~/build/genecall_test/* ~/bin

cd /mnt
mkdir testing
cd testing
wget http://www.mcs.anl.gov/~trimble/abinitio/fixedlength-bygenome-byreadingframe.zip 
unzip fixedlength-bygenome-byreadingframe.zip

testFGS.pl --input ./ --output testout2 --quicktest

