#!/bin/sh
$out
date
outdir=$1
if [ ! -d "$outdir" ]; then
   mkdir $outdir
fi
for f in *.fa
do
   echo "processing $f"
   outfile="${f%.*}"
   outfileorigin=`cut -d "." -f 1 $f`
   echo $outfileorigin
   echo run_FragGeneScan.pl -genome=$f -out=$outfile -complete=0 -train=complete
   run_FragGeneScan.pl -genome=$f -out=$outfile -complete=0 -train=complete
   
   $s = "cleangenecalls.pl fg5 $outstem/$file"
done
date
