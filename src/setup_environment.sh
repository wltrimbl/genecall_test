#!/bin/bash
# This script prepares data and dependencies for wltrimbl/genecall_test

sudo apt-get update 
sudo apt-get install git -y
sudo apt-get install zip unzip -y
sudo apt-get install make gcc -y  # needed to compile FGS
sudo apt-get install python-matplotlib  -y
mkdir ~/bin
mkdir ~/build
cd    ~/build
chown ubuntu /mnt

# get genecall test scripts
git clone https://github.com/wltrimbl/genecall_test.git
ln -s ~/build/genecall_test/* ~/bin
export PATH=$PATH:$HOME/build/genecall_test/src
echo 'export PATH=$PATH:$HOME/build/genecall_test/src' >> ~/.profile

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
echo 'export PATH=$PATH:$HOME/build/FGS' >> ~/.profile

# get labeled test data bundle
cd /mnt
mkdir testing
cd testing
wget http://www.mcs.anl.gov/~trimble/abinitio/fixedlength-bygenome-byreadingframe.zip 
unzip fixedlength-bygenome-byreadingframe.zip

testFGS.pl --input ./ --output testout2 --quicktest
testFGS.pl --input ./ --output testout2 --quicktest --addup | grep '    ' > testout2/summary.csv

generate-roc.pl /mnt/testing/testout2/BS-0p5-150  >  /mnt/testing/testout2/BS-0p5-150.ROCinput.csv

for i in /mnt/testing/testout2/??-???-*.0.csv 
do 
	f=${i/.0.csv/}
	echo generate-roc.pl $f 
	generate-roc.pl $f > $f.ROCinput.csv 
done

roc-plot.py /mnt/testing/testout2/??-0p5-150.ROCinput.csv

annotatemetasim.py  BP-0p2.metasim.fasta BP1.ptt 
