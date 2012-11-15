#!/usr/bin/env python
# script to generate the testing data by truncating artificial, error-containing 
# data and running the reading-frame annotator.

from optparse import OptionParser

lengths=["75", "100", "150", "200", "300", "400", "600", "1000"]

accessiondict ={ "M1":"NC_012960", "M2":"NC_007633", "M3":"NC_000912" }

def createsubsets(f, label, err):
  for l in lengths:
    print "metasim-trunc.py -n %s %s > %s-%s-%s.fa "%(l, f, label, err, l)
    print "annotatemetasim.py %s-%s-%s.fa %s.ptt >%s-%s-%s.fasta"%(label, err, l, accessiondict[f[0:2]], label, err, l)

if __name__=='__main__':
  usage  = "usage: %prog -i <input sequence file> -o <output file>"
  parser = OptionParser(usage)
  (opts, args) = parser.parse_args()
  for i in args:
    createsubsets(i, i[0:2], i[3:6])
