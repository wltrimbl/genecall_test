#!/usr/bin/perl -w

use strict;
use Getopt::Long;
my ($stem, $verbose, $mga) = ('', 0,0);
my ($fgs3, $fgs5, $test, $blat, $prod, $parseonly, $addup) = (0,0, 0, 0,0, 0,0);
my ($orph300, $orph700, $mgm) = (0,0, 0, 0,0);
my $usage = qq(Usage: testFGS.pl --stem <STEM> [--mga | --fgs3 | --fgs5] 
		--stem <STEM>  (required)
		--test   don't take action, just print
		--parseonly   complete processing steps, not calling
		--blat   
		--addup   
	) ;
if ( ! GetOptions ("stem=s"     => \$stem,
                   "verbose!"   => \$verbose,
                   "prod!"      => \$prod,
                   "test!"      => \$test,
                   "blat!"      => \$blat,
                   "addup!"      => \$addup,
                   "parseonly!"      => \$parseonly,
                  )   ) { print "GO $usage \n"; die;}
if($fgs3 + $fgs5 + $mga + $orph300 + $orph700 + $mgm + $blat+$prod+$addup== 0) 
		  { $fgs3 =1;}  # default
my $filein  = $stem;
my $tempdir = "";

my $doit = !($test);
die "$usage" unless $stem ne "";
print "in file : $filein";
print "Stem : $stem\n";

my @sizes     = ('075', '100', '150', '200', 300, 400, 600, 1000);
#my @qualities = ('0p0', '0p2', '0p5', '2p3', '1e2', '1e3', '1e4', '1e5', '1e9');
#my @qualities = ('1e2', '1e3', '1e4', '1e5', '1e9');
my @qualities = ('0p0', '0p2', '0p5', '2p3');

$tempdir = "./tmp$stem/";
$tempdir = "";
system(mkdir $tempdir) unless -e $tempdir;

foreach my $length (@sizes)
{
foreach my $q (@qualities)
{
 my $fileorig = "$stem-$q-$length";
#my $fileorig = "$stem";
my $file =  "$tempdir"."$fileorig";

my $s = "sortfrags2.pl $fileorig.fasta $file";
print "$s\n"; if($doit ==1) {system $s;}


{for(my $i = 0; $i <= 6; $i++)
{
# if( !(-e "$file.$i.out")) 


if($blat)
{
$s = "blat -prot Hoff-tot.faa $file.$i.faa >> $file.blat ";
print "$s\n"; if($doit ==1) {system $s;}

}

}    # end reading frame loop
}    # end parseonly
#================collate the output==============


if($blat)
{
$s = "cleanblat.pl $file";
print "$s\n"; if($doit ==1) {system $s;}
}
if($addup)
{
$s = "confusion.pl $file";
print "$s\n"; if($doit ==1) {system $s;}
}
#================done with cleanup================

}   # end quality foreach loop
}   # end length foreach loop
