#!/usr/bin/perl -w
#  This script opens a set of seven reading-frame-accuracy reporting files,
# filters the results (using awk) and reports summary accuracy statistics,
# allowing construction of the precision / recall  sensitivity / specificity graph.

# TN2  TP   FN2   FP   WF    N   P    total

my @stems     = ('0p0', '0p2', '0p5', '2p8', '1e2', '1e3', '1e4', '1e5', '1e9');
@stems=@ARGV;
my $m ;
%map=(0=>0, 1=>2, 2=>1, 3=>3, 4=>5, 5=>4, 6=>6); # fgs, prod

$post = "pro.csv";
$post = "fg3.csv";
$post = "mga.csv";
$post = "fg0.csv";
$post = "csv";

die "$stems[0].0.$post missing" unless -e "$stems[0].0.$post" ;

if($post =~ /mga/)  {%map=(0=>2, 1=>1, 2=>0, 3=>3, 4=>5, 5=>4, 6=>6); } # mga alternative 
foreach $stem (@stems)
{
$pre = "TOT-$stem"; 
$pre = "$stem"; 
for($r = 0.9; $r < 1.6; $r+=.02)   # FGS 
# for($r = 0; $r < 110; $r+=5)
{
# $filter = " awk '\$3>=$r' ";
  $filter = " awk '\$3<=$r' ";  # For FGS

 print "$pre\t$post\t$r\t";

$N = `cat $pre.6.$post | wc -l`;
chomp($N);

for ($i = 0; $i<7; $i++)
	{
	for ($j = 0; $j<7; $j++)
	{
              $s = "cat $pre.$i.$post | $filter  | cut -f 4 | grep ^$map{$j} | wc -l";
if($j == 6) { $s = "cat $pre.$i.$post |            cut -f 4 | grep ^$map{$j} | wc -l";}
	#print STDERR "$s\n";
	$a = `$s`;
	chomp($a);
	$m->{$i}->{$j} = $a;
#	print "$a\t";
	}
#	print "\n";
	#print "$i: $r: $a";
	}

 my $total =0  ; my $trace =0;
$P = 0;
for($i=0; $i<7 ; $i++) 
	{ $sum1{$i}=0; $sum2{$i} = 0;
	$P+=`cat $pre.$i.$post | wc -l`;
	}
$P-= $N;
$WF=0;
	for($i=0; $i<7 ; $i++) 
	{
	for($j=0; $j<7 ; $j++) 
		{ 
		$total    += $m->{$i}->{$j};
		$sum1{$i} += $m->{$i}->{$j};
		$sum2{$j} += $m->{$i}->{$j};
if($i==$j) {	$trace    += $m->{$i}->{$i};}
	else 
	{if($i < 6 && $j < 6) {$WF += $m->{$i}->{$j};} }
	}
	}
#print "TRACE: $trace\n";
for($i=0; $i<7 ; $i++) 
{
#print "SUM $i $sum1{$i}\t$sum2{$i}\n";
}

my $TN = $m->{6}->{6};
my $TP = $trace - $TN;
my $FN = $sum2{6} - $TN;
my $FP = $sum1{6} - $TN;
my $FN2 = $P - $TP - $WF;
my $TN2 = $N - $FP;

#print "TN\tTP\tFN\tFP\n";
#print "TN $TN TP $TP FN $FN  FP $FP \n";
print "$TN2\t$TP\t$FN2\t$FP\t$WF\t$N\t$P\t$total\n";
}

}

