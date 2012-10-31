#!/bin/bash
run_FragGeneScan.pl  -genome=TEST9.fna -out=TEST9 -complete=1 -train=complete 
../src/fasta-splitter.py -i TEST9.faa -t TEST9.table.csv 

