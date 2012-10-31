#!/usr/bin/perl -w
# fgs output parser that keeps track of insertions and deletions
# FGS output is 

if ($#ARGV+1 != 1)
	{
	print "usage: fgsparser3.pl filename.out\n";
	print "\n "; die;
	}
my $filename    = $ARGV[0];
	{
        local($/, *FILE);
        $/ = ">";
	print STDERR "Reading genome data...\n";
        open FILE, "<$filename";
        @fastasequences = <FILE>;  # slurp file on >s
	}

foreach $inputrecord (@fastasequences)
	{  
	$gene =0; @h=('');
	chop($inputrecord);  # removes trailing >
        if($inputrecord =~ /(.*?)\n(.*)/s)
		{$header = $1; $restinput =$2;
		@h = split(' ', $header);  # label for debugging purposes
		$fastaid = $h[0];
		if($header =~ /length ([-\d]*)/) {$fragmentlength = abs($1) +1;}
		$middleoffragment= abs($fragmentlength)/2 ;
		@fgsoutlines = split("\n", $restinput);

		foreach $rest (@fgsoutlines)  # These are (possibly multiple) gene calls  per fragment
		{
			chomp($rest);
			$rest =~ s/\s+/\t/;  # convert spaces to tabs;
			@fields = split('\t', $rest);
			$callstart = $fields[0];
			$callstop  = $fields[1];
			$strand    = $fields[2];
			$calledframe= $fields[3];
			$fgsscore   = $fields[4];
			$insertionlist= $fields[5];
			$deletionlist = $fields[6];
			if($insertionlist =~ /I:(.*)/ ) {$in= $1;} else {$in="";}
			if($deletionlist  =~ /D:(.*)/ ) {$de= $1;} else {$de="";}
			@insertions = split(/,/, $in);
			@deletions  = split(/,/, $de);
			$adjust = 0;
			foreach $ins (@insertions) { if($middleoffragment > $ins) {$adjust +=1;} }
			foreach $del (@deletions)  { if($middleoffragment > $del) {$adjust -=1;} }
			if(( $middleoffragment) < $callstop && ($middleoffragment ) > $callstart) 
				{
				if($strand eq '+')
					{
					$strandnumber = "+1";
					$frame = ($calledframe + $adjust ) % 3   ;
					} 
				else 
					{
					$strandnumber = "-1";
					$frame = ($calledframe + $adjust ) %  3 +3 ;
					}
				$gene =1;
				print join("\t", $callstart, $callstop, $fgsscore)."\t$frame\t$fastaid\n" ;
				}
			}  # rest loop
		} # parser for multiple lines 
	else 	{	 # if no predictions for this fragment, parse fasta header anyway...
		$header=$inputrecord;
                @h = split(' ', $header);  # label for debugging purposes
                $fastaid = $h[0];
		}

	if($gene ==0  && length($inputrecord)>1 )   # failed to ID gene
		{ @fields = ("1", "0", "+", "0", "0.000001", "I:", "D:"); $frame=6;
		print join("\t", 0, 0, 0)."\t$frame\t$fastaid\n" ;
		} # failed to id a gene

#	
#	$oldfastaid = $fastaid;
	}  # inputrecord loop

if($gene == 0 && 0  )   # failed to ID gene
	{ @fields = ("1", "0", "+", "0", "0.000001", "I:", "D:"); $frame=6;
	print join("\t", 0, 0, 0)."\t$frame\t$fastaid\n" ;
	} # failed to id a gene


