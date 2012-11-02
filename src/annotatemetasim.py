#!/usr/bin/env python

import sys, os, random
from optparse import OptionParser
from Bio import SeqIO

def inputglimmerpredictions(filename):  
  '''Parse annotation file, return table'''
  i=0
  table = []
  for line in open(filename):
    fields = line.split("\t")
    if i >=3 :
      big = fields[0].split("..")
      if fields[1] == "+" or filename.find("predict") > 0:
        table.append([int(big[1]), int(big[0])]) 
      else :
        table.append([int(big[0]), int(big[1])])
    i+=1
  return(table)

def makeannotationindex(table):
  '''Makes a map of the start and stop site '''
  startmap = {}
  stopmap  = {}
  if 0:
    tableindexes = range( len(table)-1, 0 , -1)
  else:
    tableindexes = range(0, len(table)  )  
  for i in tableindexes  :  
     annotationstart = table[i][0]
     annotationstop  = table[i][1]
     genelen = annotationstop - annotationstart
     for j in range( 0, abs(genelen)) :
        if genelen > 0: 
           ntindex = annotationstart + j 
        else :
           ntindex = annotationstart - j
      #  print "Walking", ntindex, annotationstart, annotationstop
        startmap[ntindex] = annotationstart
        stopmap[ntindex]  = annotationstop
  return([startmap, stopmap])

def metasimparser(desc, l):
  import re
  middle = int(l/2)
  # get the fields out of the metasim fasta header
  m = re.search("SOURCES=\{(.*?)\}\|", desc)  # pull off coordinates and direction
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
#      print "found dleete"
  nerrors=len(elist)-1
  if strand=="f":
    return(strand, offset1, offset2, shiftmap, nerrors)
  elif strand=="b": 
    return(strand, offset2, offset1, shiftmap, nerrors)

def checkit(off1, off2, shiftmap, l, nerrors):
   fmid = int((off1+off2) / 2)   # note this is a genome coordinate
   center = int(l/2)             # note this is a fragment coordinate
   try:
     gstart = stopmap[fmid]
     gstop  = startmap[fmid]
   except KeyError: 
     gstart=0
     gstop =0
   flen = off2-off1
   glen = gstop -gstart
   adjust = shiftmap[center] 
   offset = off1 - gstart
   gene=0
   readingframe=6
   if gstart < gstop and gstart > 0 :  # gene is on forward strand
       if fmid > gstart and fmid < gstop :  
          if flen > 0 : gene =  1   # fragment on forward strand 
          else:         gene = -1   # fragment on reverse
   else:
       if fmid < gstart and fmid > gstop:  # gene is on reverse strand
          if flen < 0 :  gene =  1         # fragment is on reverse
          else:          gene = -1         # fragment is on forward
   
   if flen > 0 and glen > 0 : readingframe = (3+offset-1* adjust) % 3
   if flen < 0 and glen < 0 : readingframe = (2-offset-1* adjust) % 3 
   if flen > 0 and glen < 0 : readingframe = (2+offset-1* adjust  % 3) % 3 
   if flen < 0 and glen > 0 : readingframe = (1-offset-1* adjust  % 3) % 3  

   if gene==0:  readingframe=" "
   returnstring = " WTM gene nerrors %d (%d - %d) flen %d length %d gene (%.0d-%.0d) glen %d   gene %d rf %s off %d   adj %d  \n"%(0, off1, off2, flen, l, gstart, gstop, glen, gene, str(readingframe), offset, adjust)
   return(returnstring)

def metasimparseandannotate(desc, annotationtable, l):
  import re
  (strand, offset1, offset2, shiftmap, nerrors) = metasimparser(desc,l) 
  center = int(l/2)
  annotationtext = checkit(offset1, offset2, shiftmap,l,nerrors)
  shift = shiftmap[center]
  middle = int((offset1+offset2)/2)
  desc = desc + "%s"%annotationtext
  return(desc)


if __name__ == '__main__':
  usage  = "usage: %prog <metasim.fa> <file.ptt> \n metasim-format fasta annotator, outputs to std out"
  parser = OptionParser(usage)
  parser.add_option("-m", "--minlength", dest="minlength",default=0 , help="minimum sequence length")
  parser.add_option("-v", "--verbose", dest="verbose", action="store_true", default=True, help="Verbose [default off]")
  (opts, args) = parser.parse_args() 

  metasim_filename = args[0]
  ptt_filename     = args[1]
  if not (metasim_filename and os.path.isfile(metasim_filename) ):
    parser.error("Missing input file %s"%(metasim_filename) )
  if not (ptt_filename and os.path.isfile(ptt_filename) ):
    parser.error("Missing input file %s"%(ptt_filename) )

  annotationtable    = inputglimmerpredictions(ptt_filename)
  [startmap, stopmap] = makeannotationindex(annotationtable)

#  print "len annotationtable ", len(annotationtable)
  for seq_record in SeqIO.parse(metasim_filename, "fasta"):
    desc  = seq_record.description
    seq   = seq_record.seq
#    print desc 
    newdesc = metasimparseandannotate(desc, annotationtable, len(seq))
    seq_record.description=newdesc  
    SeqIO.write(seq_record, sys.stdout, "fasta")
#    print ">%s"%( seq_record.description )
  if opts.verbose: sys.stdout.write("Done. \n")
