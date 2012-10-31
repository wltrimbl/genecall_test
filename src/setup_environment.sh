#!/bin/bash
# This script prepares data and dependencies for wltrimbl/genecall_test

sudo apt-get install git -y
sudo apt-get install zip -y
mkdir ~/bin
mkdir ~/build
cd    ~/build

# get genecall test scripts
git clone https://github.com/wltrimbl/genecall_test.git
ln -s ~/build/genecall_test/* ~/bin

# install blast
wget ftp://ftp.ncbi.nih.gov/blast/executables/release/2.2.26/blast-2.2.26-x64-linux.tar.gz
tar xvf blast-2.2.26-x64-linux.tar.gz
rm blast-2.2.26-x64-linux.tar.gz
ln -s $HOME/build/blast-2.2.26/bin/blastall         ~/bin
ln -s /home/ubuntu/build/blast-2.2.26/bin/formatdb  ~/bin

# get FragGeneScan
git clone https://github.com/wltrimbl/FGS.git
cd FGS
make
make fgs
export PATH=$PATH:$HOME/build/FGS

# get labeled test data bundle
cd /mnt
mkdir testing
cd testing
wget http://www.mcs.anl.gov/~trimble/abinitio/fixedlength-bygenome-byreadingframe.zip 
unzip fixedlength-bygenome-byreadingframe.zip

testFGS.pl --input ./ --output testout2 --quicktest


