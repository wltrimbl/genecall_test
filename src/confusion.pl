#!/usr/bin/perl -w
# this script takes the csv format-normalized gene call files
# normalizes the gene calling convention, and outputs a single
# line with the categories for the confusion matrix;
#     TN2  TP   FN2   FP   WF  N   P total
if($#ARGV+1 != 1) {die "requires stem";}
$confusion =0;
my $stem = $ARGV[0];
my $m ;
%map=(0=>0, 1=>2, 2=>1, 3=>3, 4=>5, 5=>4, 6=>6); # fgs, prod

@postoptions = ("pro.csv", "fg3.csv", "fg5.csv", "mga.csv", "gff.csv", "op3.csv", "op7.csv", "fg0.csv");
@postoptions = ("csv") ;
for $post (@postoptions)
{
if($post =~ /mga/)  {%map=(0=>2, 1=>1, 2=>0, 3=>3, 4=>5, 5=>4, 6=>6); } # mga remapping 
	else        {%map=(0=>0, 1=>2, 2=>1, 3=>3, 4=>5, 5=>4, 6=>6);}  # standard remapping

	{  # unused stem loop
	$pre = "$stem"; 
 	if(-e "$pre.6.$post") {
	$N = `cat $pre.6.$post | wc -l`;
	chomp($N);

	for ($i = 0; $i<7; $i++)
		{
		for ($j = 0; $j<7; $j++)
			{
              $s = "cat $pre.$i.$post |  cut -f 4 | grep ^$map{$j} | wc -l";
if($j == 6) { $s = "cat $pre.$i.$post |  cut -f 4 | grep ^$map{$j} | wc -l";}
			#print STDERR "$s\n";
			$a = `$s`;
			chomp($a);
			$m->{$i}->{$j} = $a;
			if($confusion){	print "$a\t";}
			}
		if($confusion){	print "\n";}
		#print "$i: $r: $a";
		}

	my $total =0  ; my $trace =0;
	$P = 0;
	for($i=0; $i<7 ; $i++) 
		{ 
		$sum1{$i}=0; $sum2{$i} = 0;
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
			if($i==$j) 
				{$trace    += $m->{$i}->{$i};   }
			else 
				{if($i < 6 && $j < 6) {$WF += $m->{$i}->{$j};} }
			}
		}
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
	if(!$confusion)
		{print "$stem\t$post\t";
		print "$TN2\t$TP\t$FN2\t$FP\t$WF\t$N\t$P\t$total\n";
		}
 	} # end if
	} # end stem loop

} # end post

