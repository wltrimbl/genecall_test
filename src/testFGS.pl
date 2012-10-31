#!/usr/bin/perl -w

use strict;
use Getopt::Long;
my ($stem, $verbose, $mga) = ('', 0,0);
my ($fgs3, $fgs5, $test, $prod, $parseonly, $addup) = (0,0, 0, 0,0, 0,0);
my ($orph300, $orph700, $mgm) = (0,0, 0, 0,0);
my ($outstem, $quicktest, $input);
my $usage = qq(Usage: testFGS.pl --input <dir> [--mga | --fgs3 | --fgs5] 
		--output <dir>  (required) destination directory
		--fgs3  (default)   
		--fgs5 (illumina model)
		--mga   (metageneannotator)
		--mgm   (MetaGeneMark (linux only))
		--orph300 (only on linux w/jre 1.6)
		--orph700 (only on linux w/jre 1.6)
		--test   don't take action, just print
		--parseonly   complete processing steps, not calling
		--addup       calculate confusion matrices
		--quicktest   only iterate over genomes, 150, 0p5   
	) ;
if ( ! GetOptions ("output=s"     => \$outstem,
                   "input=s"     => \$input,
                   "verbose!"   => \$verbose,
                   "mga!"       => \$mga,
                   "fgs3!"      => \$fgs3,
                   "fgs5!"     => \$fgs5,
                   "orph300!"   => \$orph300,
                   "orph700!"   => \$orph700,
                   "mgm!"       => \$mgm,
                   "prod!"      => \$prod,
                   "test!"      => \$test,
                   "addup!"      => \$addup,
                   "parseonly!"      => \$parseonly,
                   "quicktest!"      => \$quicktest,
                  )   ) { print "GO $usage \n"; die;}
if($fgs3 + $fgs5 + $mga + $orph300 + $orph700 + $mgm + $prod +$addup> 1) 
                  { print "must specify only one model\n$usage";die;}
if($fgs3 + $fgs5 + $mga + $orph300 + $orph700 + $mgm + $prod+$addup== 0) 
		  { $fgs3 =1;}  # default

my $doit = !($test);
die "$usage" unless $outstem ne "";
my @genomes = ('A1','A2','A3','BA','BP','BS','CJ','CT','EC','HP','PA','PM','WE');
for $stem (@genomes) 
	{
print "Stem : $stem\n";

my @sizes     = ('075', '100', '150', '200', '300', '400', '600', '1000');
if($quicktest){ @sizes     = ('150');}
#my @qualities = ('0p0', '0p2', '0p5', '2p3', '1e2', '1e3', '1e4', '1e5', '1e9');
#my @qualities = ('1e2', '1e3', '1e4', '1e5', '1e9');
my @qualities = ('0p0', '0p2', '0p5', '2p3');
if($quicktest){ @qualities     = ('0p5');}

if( ! -e $outstem ) { system "mkdir $outstem";}

print "Input: $input Output: $outstem\n";

foreach my $length (@sizes)
{
foreach my $q (@qualities)
{
 my $fileorig = "$stem-$q-$length";
#my $fileorig = "$stem";
my $file =  "$input"."$fileorig";
my $s;

#$s = "sortfrags2.pl $fileorig.fasta $file";
#print "$s\n"; if($doit ==1) {system $s;}


if(!$parseonly)
{for(my $i = 0; $i <= 6; $i++)
{
# if( !(-e "$file.$i.out")) 
if( $fgs3) 
{
my $fgstrain = "454_30";
if( length(`which run_FragGeneScan.pl`) < 10 ) { die "Can't find run_FragGeneScan.pl!";}
$s = "run_FragGeneScan.pl -genome=$file.$i.fa -out=$outstem/$fileorig.$i -complete=0  -train=$fgstrain";
print "$s\n"; if($doit ==1) {system $s; }
#unlink "$file.$i.faa";
unlink "$outstem/$fileorig.$i.ffn";
}

if($fgs5 ) 
{
my $fgstrain = "illumina_5";
$s = "run_FragGeneScan.pl -genome=$file.$i.fa -out=$outstem/$fileorig.$i.fg5 -complete=0  -train=$fgstrain";
print "$s\n"; if($doit ==1) {system $s; }
#unlink "$file.$i.fg5.faa";
unlink "$outstem/$fileorig.$i.fg5.ffn";
}

if($mga)
{
$s = "mga $file.$i.fa > $file.$i.mga";
print "$s\n"; if($doit ==1) {system $s; }
}

if($orph700)
{
$s = "orph700 $file.$i.fa ; mv /var/tmp/orphout/gene.pred $file.$i.oph ";
print "$s\n"; if($doit ==1) {system $s;}
}

if($orph300)
{
$s = "orph300 $file.$i.fa ; mv /var/tmp/orphout/gene.pred $file.$i.oph ";
print "$s\n"; if($doit ==1) {system $s;}
}

if($mgm)
{
$s = "MetaGeneMark -f -g -o $file.$i.gff $file.$i.fa ";
print "$s\n"; if($doit ==1) {system $s;}
}

if($prod)
{
my $s = "/homes/trimble/bin/prodigal -f gff -o $file.$i.pro -i $file.$i.fa ";
print "$s\n"; if($doit ==1) {system $s;}
}


}    # end reading frame loop
}    # end parseonly
#================collate the output==============

if($fgs5 ) 
{
$s = "cleangenecalls.pl fg5 $outstem/$file";
print "$s\n"; if($doit ==1) {system $s;} 
}
if($fgs3) 
{
$s = "cleangenecalls.pl fg3 $outstem/$file";
print "$s\n"; if($doit ==1) {system $s;} 
}
if($mga)
{
$s = "cleangenecalls.pl mga $outstem/$file";
print "$s\n"; if($doit ==1) {system $s;}
}
if($orph300 )
{
$s = "cleangenecalls.pl op3 $outstem/$file";
print "$s\n"; if($doit ==1) {system $s;}
}
if($orph700)
{
$s = "cleangenecalls.pl op7 $outstem/$file";
print "$s\n"; if($doit ==1) {system $s;}
}
if($mgm)
{
$s = "cleangenecalls.pl gff $outstem/$file";
print "$s\n"; if($doit ==1) {system $s;}
}
if($prod)
{
my $s = "cleangenecalls.pl pro $outstem/$file";
print "$s\n"; if($doit ==1) {system $s;}
}
if($addup)
{
$s = "confusion.pl $outstem/$file";
print "$s\n"; if($doit ==1) {system $s;}
}
#================done with cleanup================

}   # end quality foreach loop
}   # end length foreach loop
}   # end genome id loop
