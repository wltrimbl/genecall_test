#!/usr/bin/env python

import sys, os
from optparse import OptionParser
import numpy as np
import matplotlib.pyplot as plt

if __name__ == '__main__':
  usage  = "usage: %prog -i <input sequence file> -o <output file>"
  parser = OptionParser(usage)
#  parser.add_option("-o", "--output", dest="output", default=None, help="Output file.")
#  parser.add_option("-v", "--verbose", dest="verbose", action="store_true", default=True, help="Verbose [default off]")
  
  (opts, args) = parser.parse_args()
  infile=args[0]
  for infile in args: 
    if not (infile and os.path.isfile(infile) ):
      parser.error("Missing input file %s"%infile )
    a = np.loadtxt(infile, skiprows=1, usecols=(3,4,8,9)  )
    TNR = a[:,0] / a[:,2]
    TPR = a[:,1] / a[:,3]
    plt.plot(TNR, TPR, "o-", label=infile)
    plt.xlabel("TNR")
    plt.ylabel("TPR")
  plt.legend(loc=0)
  plt.show()
