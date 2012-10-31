#!/usr/bin/perl -w

 if($#ARGV+1 != 2)
{print "usage: cleangenecalls <filetype> <filestem> \n";
 print "calls gene call parsers on seven files and creates filestem.n.typ.csv .\n";
  die;}
$type = $ARGV[0];
$filestem = $ARGV[1];
print STDERR "Stem : $filestem";

for($i = 0; $i<7; $i++)
{
if($type eq "fg3")
		{
		$s = "fgsparser3.pl $filestem.$i.out | grep -v '>'    > $filestem.$i.csv";
		print "$s\n";
		system $s;
		}
if($type eq "fg0")
		{
		$s = "fgsparser3.pl $filestem.$i.fg0.out | grep -v '>'    > $filestem.$i.fg0.csv";
		print "$s\n";
		system $s;
		}
if($type eq "fg5")
		{
		$s = "fgsparser3.pl $filestem.$i.fg5.out | grep -v '>' > $filestem.$i.fg5.csv";
		print "$s\n";
		system $s;
		}

if($type eq "mga")
		{
		$s = "mgaparser3.pl $filestem.$i.mga  > $filestem.$i.mga.csv";
		print "$s\n";
		system $s;
		}


if($type eq "op3")
		{
		$n = `grep -c '>' $filestem.$i.fa `; chomp($n);
		
		$s = "ophparser3.pl $filestem.$i.op3 $n > $filestem.$i.op3.csv";
		print "$s\n";
		system $s;
		}
if($type eq "op7")
		{
		$n = `grep -c '>' $filestem.$i.fa`; chomp($n);
		$s = "ophparser3.pl $filestem.$i.op7 $n > $filestem.$i.op7.csv";
		print "$s\n";
		system $s;
		}
	

if($type eq "gff")
		{
		$s = "gffparser3.pl $filestem.$i.gff  > $filestem.$i.gff.csv";
		print "$s\n";
		system $s;
		}
	

if($type eq "pro")
	
		{
		$s = "proparser3.pl $filestem.$i.pro  > $filestem.$i.pro.csv";
		print "$s\n";
		system $s;
		}
	
}
