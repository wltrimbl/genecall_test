#!/usr/bin/perl 
use strict;
# calculatereadingframe.pl 

my $usage = qq(
usage: calculatereadingframe.pl <metasim.fa> <genome.predict> 
inputs metasim fasta file and PTT gene prediction table; 
outputs metasim fasta file augmented with reading frame labels
);
die($usage)  unless ($#ARGV+1 ==2);

my $filein 	= $ARGV[0]; 
my $filepred 	= $ARGV[1]; 

my @annotationstart;
my @annotationstop;
my @annotationname;
my $annotationn;
my @startmap;
my @stopmap ;

print STDERR "inputting annotations from $filepred\n";
inputannotationpredictions();

print STDERR "making annotation index...\n";
makeannotationindex();
print STDERR "Done... Now parsing metasim fasta $filein\n";
$/ = ">";
open FILE, "<$filein" or die "Input file $filein not found!";
my $n=0;
my ($headerline, $source, $source1, $errlist, $sequence, $sequencelines);
my ($off, $k, $ins, $ch, $e, $offset1, $offset2, $strand, $nerrors);

while( <FILE>)  # load in metasim fasta one record at a time
{
if(length($_) >1)  # don't output nonsense line at beginning
	{
	chop($_);  # remove trailing >
	$n++;
	if($_ =~ /(.*?)\n(.*)/s)    # separate fasta header from sequence
		{$headerline=$1; $sequencelines=$2;
#		 print "HEADER: $headerline\nSEQUENCE: $sequencelines\n";
		}
	$sequence = $sequencelines; $sequence =~ s/\n//g;
	my $len    = length($sequence);
	if($headerline =~ /SOURCES={(.*?)}/) 	{$source = $1;}
	if($headerline =~ /ERRORS={(.*?)}/) 	{$errlist = $1;}
	if($headerline =~ /SOURCE_1={(.*?)}/)	{$source1 = $1;}
	if($source =~ /KEY=.*,(.)w,(\d*)-(\d*)/	 || $source =~ /GI=.*,(.)w,(\d*)-(\d*)/)
		{ 
		$strand = $1; $offset1 = $2 ; $offset2 = $3;
		}
		else {$offset1=undef; $offset2=undef; print STDERR "FAIL TO PARSE\n";}
#	print "SOURCE : $source\nERRORS: $errlist\n";
#	print "DIR : $strand\nStart: $offset1 STOP: $offset2\n";
	my @errors = split(',', $errlist);
	my $center = int($len /2);
	my $genelen = $offset2 - $offset1;
	my $adjustfwd = 0;
	my @shiftmap = ();
	my $fwd=0;
	my $k =0;
	foreach $e (@errors)
		{
		if($e =~ /([-\d]*)(_?\d*):(.*)/)
			{$off = $1; $ins = $2; $ch = $3; 
#	 		print STDERR "OF: $off INS:$ins CH:$ch\n";
			for($k = $k ; $k < $off; $k++) {
				$shiftmap[$k] = $fwd;
#				print STDERR "K $k: OF: $off FWD: $fwd\n";
				}
				{ 
				if( $ins =~ /_/) 	{$fwd++;}
				elsif( $ch  =~ /-/) 	{$fwd--;}
				}
			}
		}	

                for($k = $k ; $k <= $len; $k++)
                        {
		#	print STDERR "K $k: OF: $off FWD: $fwd\n";
			$shiftmap[$k] = $fwd;
			}


		$nerrors = 0;
	foreach $e (@errors)   # construct adjustforward
		{
		if($e =~ /([-\d]*)(_?\d*):(.*)/)
			{$off = $1; $ins = $2; $ch = $3; 
#			print STDERR "OF: $off INS:$ins CH:$ch\n";
			if( $off < ($center) ) 
				{ 
				if( $ins =~ /_/) {$adjustfwd++;}
				if( $ch  =~ /-/) {$adjustfwd--;}
				}
			}
                     $nerrors+=1;
		}

		print ">$headerline" ;
#  		print STDERR "strand $strand\n";

	 if($strand eq "f") { checkit($offset1, $offset2, \@shiftmap, $len);}
   		else        { checkit($offset2, $offset1, \@shiftmap, $len); }
#	print STDERR "$sequence\n";
	pint($sequence);
	if($n % 100000 == 0) {print STDERR "N: $n\n";}
	}
}  # end input <FILE>

print STDERR "Done.\n";

sub pint  # pretty-print sequences 
	{
	my($str) = shift;
	#	print "STR: $str\n";
	if(length($str) < 80) {print "$str\n";}
		else
		{
			for(my $i =0; $i < (length($str)/ 60) ; $i++)
			{print substr($str, $i * 60, 60)."\n"; }
		}
	}


sub inputannotationpredictions  # loads gene-coordinate table from annotation
{
my $i=0;
my $FILE;
open $FILE, "<$filepred";
print STDERR "Inputting annotation predictions... opening $filepred...\n";
my @fields;
if($filepred =~ /predict/)
	{
	while(<$FILE>)
		{
        	chomp;
	        @fields = split('\s+',$_);
		$annotationstart[$i] =   int( $fields[1]);
		$annotationstop[$i]  =   int( $fields[2]);
		$annotationname[$i]  =  $fields[0];
		$i++;
       		}
	$annotationn=$i; print STDERR "annotationn: $annotationn\n";
	}
elsif($filepred=~/ptt/)
        {
        my $n=0; 
	my $strand ="";
        while(<$FILE>)
                {
                chomp;
                if((    @fields = split("\t",$_)) && ($n >3))
                        {
#                       print "fields0 $fields[0]\n";
                        my @first = split('\.\.', $fields[0]);
#                       print "First0 $first[0]\n";
                        $annotationstart[$i] =   int( $first[0] );
                        $annotationstop[$i]  =   int( $first[1] );
                        $annotationname[$i]  =    $fields[7];
                        $strand  	     =    $fields[1];
			if ($strand eq "-")                        
				{my $f= $annotationstart[$i]; 
                                $annotationstart[$i]=$annotationstop[$i];
                                $annotationstop[$i]=$f;}
#                       print "$i GLIMSTART $annotationstart[$i]\n   GLIMSTop  $annotationstop[$i]\n  GLIMname  $annotationname[$i]\n  STRAND $strand\n";
                        $i++;
                        }
                $n++;
                }
        $annotationn=$i; print STDERR "Glimmern $annotationn\n";
        }
}

sub makeannotationindex
{
 my $ntindex;
for (my $i=1; $i < $annotationn; $i++)
	{
	my $genelen = $annotationstop[$i] - $annotationstart[$i];
	my $signgene = ($genelen) / abs($genelen);
	for (my $j=0; $j <= abs($genelen); $j++)
		{
		if($genelen>0) 
			{$ntindex = $annotationstart[$i] + $j;}
		else	
			{$ntindex = $annotationstart[$i]-$j; }

		$startmap[$ntindex] 		= $annotationstart[$i];  # coordinate of the start
		$stopmap[$ntindex] 		= $annotationstop[$i];   # coordinate of the stop
		}
	}
}

sub checkit   # checks status of gene fragment against annotation
{
	my $fstart 	= shift; # start coordinate reported by metasim
	my $fstop 	= shift; # stop  coordinate reported by metasim
	my $shiftmap 	= shift; # net number of frameshifts 
	my $len 	= shift;
	my $fmid = int(($fstart+$fstop) / 2); 
	my $flen = $fstop - $fstart;
	my $halfway = int($len / 2);
	my $gene = 0;
	my $i=0;
	my $gstart = $startmap[$fmid];
	my $gstop  = $stopmap[$fmid];
	my $glen = $gstop - $gstart;     # 
	if($gstart< $gstop && $gstart >0 ) # gene is on forward strand
		{
		if (($fmid > $gstart) && ($fmid < $gstop)) 
			{
			if($flen > 0) { $gene = 1;} # fragment on forward strand
			else { $gene = -1;}  # fragment on backward strand
			}
		} 
	else 	{  # gene is on backward strand
		if ($fmid < $gstart && $fmid > $gstop) 
			{
			if($flen < 0) { $gene =  1;}  # fragment on forward strand
			else  { $gene = -1;}  # fragment on backward strand
			}
		}

my $offset = $fstart - $gstart;
my $readingframe;

my  $adjust = $$shiftmap[$halfway] ;
# print STDERR "Adjust $adjust\n";
if($flen > 0 && $glen >0) {$readingframe = (3+$offset-1* $adjust) % 3 ;}
if($flen < 0 && $glen <0) {$readingframe = (2-$offset-1* $adjust) % 3 ;}
if($flen > 0 && $glen <0) {$readingframe = (2+$offset-1* $adjust % 3) % 3 ;}
if($flen < 0 && $glen >0) {$readingframe = (1-$offset-1* $adjust % 3) % 3  ;}

print "WTM gene nerrors $nerrors ($fstart - $fstop) flen $flen length $len gene ($gstart-$gstop) glen $glen  gene $gene rf $readingframe off $offset  adj $adjust  \n";
return($gene);
}

