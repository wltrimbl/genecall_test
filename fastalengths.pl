#!/usr/bin/perl -w
# one line at a time fasta parser parse fasta
use Getopt::Long;
use strict;
my $usage = qq(fastalength.pl [-q] [-header] [-ambig] [-gc] [-nolength] <FILENAME> 
);
my $fastq = 0;
my $ambig = 0;
my $gc = 0;
my $header = 0;
my $nolength = 0;

if ( ! GetOptions (
                   "header!"          => \$header,
                   "ambig!"          => \$ambig,
                   "nolength!"          => \$nolength,
                   "gc!"          => \$gc,
                   "q!"          => \$fastq,
                  )
   ) { die $usage; }

# relying on positional argument and <> here...
if($#ARGV+1 > 1 && ($ARGV[0] =~ m/fq$/ || $ARGV[0] =~ m/fastq$/)) {$fastq=1;}

if(!$fastq)
{
$/='>';
while(<>)
	{
	if(length($_) > 1)
		{
		my ($fastaheader, $sequencestring, $fastaid, $sequence);
		if( m/(.*?)\n(.*)/is) { $fastaheader=$1; $sequencestring=$2;}
		chomp;  # removes delimiter
		if( $fastaheader =~ /(.*?) (.*)/) {$fastaid = $1;} else {$fastaid = $fastaheader;}
		$sequencestring =~ s/>$//i;  # remove trailing >
		$sequence = $sequencestring; $sequence  =~ s/\n//isg;
		if($header){ print "$fastaid\t";}
		if($gc){ if(length($sequence)>0) {my $x = (s/G/G/g + s/C/C/g)/length($sequence); print "$x\t";}else {print "0\t";}}
		if($ambig) { my $s = $sequence; my $n= length($sequence) - ($s =~ s/[AaCcGgTt]/N/g) ; print "$n\t";} 
	        if(!$nolength){print length($sequence);}
		print "\n";
		}
	}
}
else
{
$/="\n";
while(<>)
	{
	if(/^@(.*)\n/)
		{
		my ($fastaheader, $sequencestring, $fastaid, $sequence);
		$fastaheader=$1;
		if( $fastaheader =~ /(.*?) (.*)/) {$fastaid = $1;} else {$fastaid = $fastaheader;}
		if( m/(.*?)\n(.*)/is) { $fastaheader=$1; $sequencestring=$2;}
		$sequencestring = <>;
		$sequence = $sequencestring; $sequence  =~ s/\n//isg;
		<>; <>; 		
		if($header){ print "$fastaid\t";}
		if($ambig) { my $s = $sequence; my $n= length($sequence) - ($s =~ s/[AaCcGgTt]/N/g) ; print "$n\t";} 
	        if(!$nolength){print length($sequence);}
		print "\n";
		}
	}
}

sub pint  # pretty-print sequences 
{
my($str) = shift;
#       print "STR: $str\n";
for(my $i =0; $i < (length($str)/ 60) ; $i++)
        {print substr($str, $i * 60, 60)."\n";
        }
}


