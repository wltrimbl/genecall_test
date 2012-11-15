#!/usr/bin/env python
#  This script truncates metasim output, preserving the beginning of the fragment
#  but changing the length, changing the genome coordinates to match the truncation.

import sys, os, random
from optparse import OptionParser
from Bio import SeqIO

def metasimparser(desc, l):
  import re
  metasimobject={}
  middle = int(l/2)
  # get the fields out of the metasim fasta header
  metasimobject["header"]=re.search("(r.*?) ", desc).group(1)
  metasimobject["SOURCE_1"]=re.search("SOURCE_1=(.*)", desc).group(1)
  m = re.search("SOURCES=\{(.*?)\}\|", desc)  # pull off coordinates and direction
  metasimobject["gi"] = m.group(1).split(',')[0]
  strand = m.group(1).split(',')[1][0]
  offs   = m.group(1).split(',')[2].split("-")
  offset1 = int(offs[0])
  try:
    offset2 = int(offs[1])
  except ValueError:
    offset2 = 0
  e = re.search("ERRORS=\{(.*?)\}", desc)
  liste = e.group(1).split(",")
  elist =[]
  for er in liste:
    aux = re.split(":", er)
    q= re.search("(.*)_(.*)", aux[0])
    if q:
      elist.append([int(q.groups(1)[0]), int(q.groups(1)[1]), aux[1]] )
    else:
      if aux[0]:
         elist.append([int(aux[0]),  "0" , aux[1]] )
      else:
         pass
  elist.append( [ l, "0", "0" ] )
  shiftmap={}
  fwd = 0
  k=0
  for er in elist:   # construct shiftmap, walking through k 
    for k in range(k, int(er[0])) :
      shiftmap[k] = fwd
#      print k, shiftmap[k], fwd, er[0], er[1], er[2]
    if int(er[1]) >= 1   :  
     fwd +=1  # indicates insertions
#     print "found insert"
    if er[2] == "-" :  
      fwd = fwd -1  # indicates deletions
#      print "found delete"
  nerrors=len(elist)-1
  metasimobject["elist"]     = elist
  metasimobject["strand"]    = strand
  metasimobject["shiftmap"]  = shiftmap
  metasimobject["nerrors"]   = nerrors
  if strand=="f" or strand=="b":
    metasimobject["offset1"]  = offset1
    metasimobject["offset2"]  = offset2
    return(metasimobject)


def metasimparseandtruncate(desc, seq, n):
  import re
  l=len(seq)
  metasim = metasimparser(desc,l) 
  offset1 = metasim["offset1"]
  offset2 = metasim["offset2"]
  o = min(n, l-1 ) -1 
  c = metasim["shiftmap"][l-1] - metasim["shiftmap"][o]
  diff = max( l - n-1  , 0)
#  print "l: %d, n: %d diff %d endc: %d c: %d"%(l, n, diff, metasim["shiftmap"][l-1], c),
  if metasim["strand"] =="f" : 
    one = metasim["offset1"]
    two = metasim["offset1"] + o    # recalculate end coordinate
  else:
    one = metasim["offset2"] - o    # recalculate end coordinate
    two = metasim["offset2"] 
#  print "%d\t%d\t%d\t%d"%(offset1, offset2, one, two)
  e= ""  
  for i in range(len(metasim["elist"])-1):
   er = metasim["elist"][i]
   if er[0] <= n: 
     if int(er[1]) >=1 :
        e=e+"%s_%s:%s,"%(er[0], er[1], er[2] )
     else:
        e=e+"%s:%s,"%(er[0], er[2] )
  try: 
   if e[-1] == ",":  e=e[0:len(e)-1] 
  except:
   pass

  des = "|SOURCES={%s,%sw,%d-%d}|ERRORS={%s}|SOURCE_1=%s"%( metasim["gi"], metasim["strand"], one, two, e, metasim["SOURCE_1"])

  center = int(l/2)
  shift = metasim["shiftmap"][center]
  middle = int((offset1+offset2)/2)
  annotationtext = " truncated" 
  desc = desc + "%s"%annotationtext
  seq = seq[0:n]
  return(des, seq)


if __name__ == '__main__':
  usage  = "usage: %prog <metasim.fa> -n <length> \n metasim-format fasta mutilator, outputs to std out"
  parser = OptionParser(usage)
  parser.add_option("-n", "--maxlength", dest="maxlength",default=None , help="maximum sequence length")
  parser.add_option("-v", "--verbose", dest="verbose", action="store_true", default=True, help="verbose")
  (opts, args) = parser.parse_args() 

  metasim_filename = args[0]
  maxlength       = int(opts.maxlength)
  if not (metasim_filename and os.path.isfile(metasim_filename) ):
    parser.error("Missing input file %s"%(metasim_filename) )

  for seq_record in SeqIO.parse(metasim_filename, "fasta"):
    desc  = seq_record.description
    seq   = seq_record.seq
    (newdesc, newseq) = metasimparseandtruncate(desc, seq, maxlength)
    seq_record.description=newdesc  
    seq_record.seq=newseq  
    SeqIO.write(seq_record, sys.stdout, "fasta")
  if opts.verbose: sys.stdout.write("Done. \n")
