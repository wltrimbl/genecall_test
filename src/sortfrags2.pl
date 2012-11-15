#!/usr/bin/perl 
# sortfrags2.pl  fragments.fa stem -- splits reading frame labeled data into 
# files each with known reading frames

die "Usage: sortfrags2.pl <labeled fragments> \n" 
	unless $#ARGV +1 == 1;
$filename = $ARGV[0] ;
$stem = $filename;
$stem =~ s/.fasta$//;  $stem =~ s/.fna$//; $stem =~ s/.fa$//;

open $FILE, "<$filename" or die "sortfrags2: can't open $filename !";
open $O0, ">$stem.0.fa";
open $O1, ">$stem.1.fa";
open $O2, ">$stem.2.fa";
open $O3, ">$stem.3.fa";
open $O4, ">$stem.4.fa";
open $O5, ">$stem.5.fa";
open $O6, ">$stem.6.fa";

$/ = '>' ;
@fragments = <$FILE>;
foreach $line (@fragments)
{
chop($line); # removes trailing ">"
# print STDERR "LINE: $line\n";
@fields = split '\n', $line;
if( $fields[0] =~ m/gen.*gen.*gene 1 rf 0/  ) 
	{print $O0 ">".join("\n", @fields)."\n";}
if( $fields[0] =~ m/gen.*gen.*gene 1 rf 1/  )                            
	{print $O1 ">".join("\n", @fields)."\n";}
if( $fields[0] =~ m/gen.*gen.*gene 1 rf 2/ )                            
	{print $O2 ">".join("\n", @fields)."\n";}
if( $fields[0] =~ m/gen.*gen.*gene -1 rf 0/ || $fields[0] =~ m/gen.*gen.*gene -1 rf 3/  )
	{print $O3 ">".join("\n", @fields)."\n";}
if( $fields[0] =~ m/gen.*gen.*gene -1 rf 1/ || $fields[0] =~ m/gen.*gen.*gene -1 rf 4/ )   
	{print $O4 ">".join("\n", @fields)."\n";}
if( $fields[0] =~ m/gen.*gen.*gene -1 rf 2/ )                         
	{print $O5 ">".join("\n", @fields)."\n";}
if( $fields[0] =~ m/gen.*gen.*gene 0/ )
	{print $O6 ">".join("\n", @fields)."\n";}
}
