#!/bin/sh
date
for f in *.fa
do
   echo "processing $f"
   outfile="${f%.*}"
   echo run_FragGeneScan.pl -genome=$f -out=$outfile -complete=0 -train=complete
   run_FragGeneScan.pl -genome=$f -out=$outfile -complete=0 -train=complete
done
date
