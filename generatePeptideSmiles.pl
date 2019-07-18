#!usr/bin/perl

#TAKES DIRECTORY CONTAINING LIST OF AMINOACID SEQUENCES SEPARATED BY NEW LINE.
#FILE NAME SHOULD BE SEQ DEFINITION WITH 'comb' AS EXTENSION.
#THESE FILES ARE CAN BE GENERATED USING peptideCombinations.pl.



$inDir = "testCombinations";

$aaSmilesFile = "aaSmiles";

my %aaSmiles = ();
open(AASMILES,$aaSmilesFile)||die "Can not open AASMILES.\n";
$aaStartFlag = 0;
foreach (<AASMILES>)
{
	if($#{[keys %aaSmiles]}+1 == 20){last;}
	if($aaStartFlag)
	{
		if($_=~m/(.)\s:\s(.{3})\s:\s(.+)\s:\s(.+)\n/)
		{
#			($aa,$smiles) = ($1,trim($4));
			$aaSmiles{$1} = trim($4);
		}
	}
	if($_=~m/^-/){$aaStartFlag = 1;}
}


opendir(INDIR,$inDir)||die "Can not open INDIR.\n";

foreach $file(grep{/\.comb$/}readdir(INDIR))
{
	print "Processing file $file ...\n";

	$file=~m/(.+)\.comb/;
	$seqDef = $1;

	mkdir("$inDir/smiles");

	open("IN", $inDir."/".$file)||print "Can not open IN.\n";

	open(OUT, ">".$inDir."/smiles/".$seqDef.".smiles")||print "Can not open OUT.\n";

	print OUT "#SEQDEF: $seqDef\n#SEQLENGTH: ".($#{[split("",$seqDef)]}+1)."\n";
	foreach (<IN>)
	{
##SEQDEF: X X
##SEQLENGTH: 2
#A A
#A R
#A N

		if($_!~m/^#/)
		{
			chomp $_;
			@seq = split("",$_);
			my @smiles = generatePeptSmiles(@seq);
			print OUT join("",@seq),"\t",join("",@smiles),"\n";
#			die;
		}
	}
	close(OUT);
#	die;
}
##########################################

sub generatePeptSmiles
{
	my @seq = @_;

	my @seqSmiles = ();

	my $cnt = 0;
	foreach my $aa(@seq)
	{
		$aaSmiles{$aa}=~m/(.+)O$/;
		push(@seqSmiles,$1);
	}
#Append last oxygen atom to the last amino acid of the sequence.
	$seqSmiles[$#seqSmiles] .= 'O';

#	print "@seqSmiles\n";
	return(@seqSmiles);
}


sub trim
{
	my $str = $_[0];
	$str=~s/^\s*(.*)/$1/;
	$str=~s/\s*$//;
	return $str;
}
