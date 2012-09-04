#!/usr/bin/perl -w
# one line at a time fasta parser parse fasta
use Getopt::Long;
my $usage = qq(fastalength.pl [-fasta ] <FILENAME> 
);
my $fastq = 0;

if ( ! GetOptions (
                   "header!"          => \$header,
                   "q!"          => \$fastq,
                  )
   ) { die $usage; }

# relying on positional argument and <> here...
if(!$fastq)
{
$/='>';
while(<>)
	{
	if(length($_) > 1)
		{
		if( m/(.*?)\n(.*)/is) { $fastaheader=$1; $sequencestring=$2;}
		chomp;  # removes delimiter
		if( $fastaheader =~ /(.*?) (.*)/) {$fastaid = $1;} else {$fastaid = $fastaheader;}
		$sequencestring =~ s/>$//i;  # remove trailing >
		$sequence = $sequencestring; $sequence  =~ s/\n//isg;
		if($header){ print "$fastaid\t";}
	        print length($sequence)."\n";
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
		$fastaheader=$1;
		if( $fastaheader =~ /(.*?) (.*)/) {$fastaid = $1;} else {$fastaid = $fastaheader;}
		if( m/(.*?)\n(.*)/is) { $fastaheader=$1; $sequencestring=$2;}
		$sequencestring = <>;
		$sequence = $sequencestring; $sequence  =~ s/\n//isg;
		<>; <>; 		
		if($header){ print "$fastaid\t";}
	        print length($sequence)."\n";
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


