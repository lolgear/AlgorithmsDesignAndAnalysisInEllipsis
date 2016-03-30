use Data::Dumper;
use lib qq($ENV{HOME}/Documents/Projects/Perls/);
use LolgearTools qw(chmp say sayEvery sayToFile);
#-------- Begin ----------#
my ($input) = @ARGV;
print "$input\n";
my $out = '>';
do {$output = "out.txt";
	$out.=$out;
} if defined $input;
$input ||= 'input.txt';
$output ||= 'output.txt';
open $fh, '<', $input or die qq'cant open $input! $!';
open $oh, $out, $output or die qq'cant open $output! $!';

$,=",";
$"=":";

# ---------- Main ---------- #
sub Main{
	my ($inputFile,$outputFile) = @_;

	my ($array,$knapSackSize,$countOfItems) = readData($inputFile);
	# main algorithm
	# ok, now I must set knapsack algorithm with data
	
	my $optimalSolution = KnapSackProblemAlgorithm($array,$knapSackSize,$countOfItems);
	say Dumper $optimalSolution;
	sayAboutTwoDHash($optimalSolution);
	say "knak: $knapSackSize; count: $countOfItems";
	sayToFile $outputFile, "I have optimal solution value", $optimalSolution->{"$countOfItems;$knapSackSize"};
}
Main($input,$output);

# ------- Output Data ------- #
sub filterOnlyLeaders{
	my($graph) = @_;
	my $leaders = $graph->{leaders};
	return $leaders;
}

sub filterOnlyClusters{
	my ($graph) = @_;
	return $clusters;
}

# ------- Data Input -------- #
sub readData {
	my $array = []; # needed in algorithm for min computing
	my ($knapSackSize,$countOfItems) = ();
	my $inputFile = shift;
	open $fh, '<', $inputFile or die "can't open file on read! $inputFile! $!";
	while (<$fh>){
		last if ($_ eq '\n');
		next if ($_ =~ m/^[#]/);
		chomp;
		do{($knapSackSize,$countOfItems) = (split/\s+/); next} if $.==1;

		insertToArray($array,$_);
		say "I read $. !";
	}
	return ($array,$knapSackSize,$countOfItems);
}

sub createItem{
	my ($array,$itemValue,$itemWeight) = @_;
	push @$array, {value=>$itemValue, weight=>$itemWeight};
}

sub insertToArray{
	my ($array,$lineToBreak) = @_;
	$lineToBreak =~ s/\s+$//;
	my ($itemValue,$itemWeight) = (split/\s+/,$lineToBreak);
	createItem($array,$itemValue,$itemWeight);
}

# ------- Algorithm --------- #
=pod 
Let A = 2-D array
W - KnapSack Problem Size
w_i - weight of i item
v_i - value of i item
Initialize A[0; x] = 0 for x = 0 .. W
For i = 1 .. n
	For x = 0 .. W
A[i ; x] := max { A[i - 1; x] , A[i - 1; x - w_i ] + v_i }
Return A[n;W]

=cut 

sub sayAboutTwoDHash{
	my ($hash) = @_;
	my @keys = keys %$hash;
	my @sorted = 
	sort{$a->[0]<=>$b->[0]}
	sort{$a->[1]<=>$b->[1]}
	map{$_ = [(split/;/)]}
	@keys;

	for (@sorted){
		say "$_->[0];$_->[1]  =  ", $hash->{"$_->[0];$_->[1]"};
	}
}
sub sayAboutTwoDArray {
	my ($array) = @_;
	my @oneDArrays = @$array;
	for my $eachArray(@oneDArrays){
		for my $iterator(0..$#$eachArray){
			my $element = $eachArray->[$iterator];
			print "| $element |";
		}
		print "\n";
	}
}
sub max{
	my ($first,$last) = @_;
	return $first>$last?$first:$last;
}
sub KnapSackProblemAlgorithm{
	my($array,$knapSackSize,$countOfItems) = @_;
	my %solution = ();
	$solution{"0;$_"} = 0 for (0 .. $knapSackSize);
	for my $itemID(1 .. $countOfItems){
		for my $nowWeight(0 .. $knapSackSize){
			my $previousIndex = $itemID - 1;
			my $currentItem = $array->[$previousIndex];

			my $ifChosenWeight = $nowWeight - $currentItem->{weight};

			if ($ifChosenWeight < 0){
				$solution{"$itemID;$nowWeight"} = $solution{"$previousIndex;$nowWeight"};					
			} 
			else{
				my $ifNotChosenWeight = $nowWeight;
				my $currentItemChosen = $solution{"$previousIndex;$ifChosenWeight"} + $currentItem->{value};
				my $currentItemNotChosen = $solution{"$previousIndex;$ifNotChosenWeight"};
				$solution{"$itemID;$nowWeight"} = max($currentItemChosen,$currentItemNotChosen);
			}
		}
	}
	return \%solution;
}
