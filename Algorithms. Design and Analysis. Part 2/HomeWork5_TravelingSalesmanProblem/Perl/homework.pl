use Data::Dumper;
use lib qq($ENV{HOME}/Documents/Projects/Perls/);
use LolgearTools qw(chmp say sayEvery sayToFile sayTimer);
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

	say "read data begin";
	my ($graph,$countOfVertexes) = readData($inputFile);
	say "read data end";

	say Dumper $graph;
	say "algorithm begin";
	say "algorithm end";
	say "distance between 5 and 20: ". distanceBetweenTwoCities($graph,5,20);
	my $totalTime = time() - $^T;
	sayToFile 
	"out$inputFile", "I have min path length: $shortestPath 
	\n and negative cycle exists: $doesNegativeCycleExists
	\n and total Time: $totalTime";
	# print "this is source $sourceVertex";
	# need some clear here
	# CorrectDataStructureForGraph($graph);
	# main algorithm
	# ClusteringAlgorithm($array,$graph,$countOfVertexes,$maximumNumberOfClusters);
	
	# sayToFile $outputFile,"count of elements in array: ", scalar @$array;
	# sayToFile $outputFile,Dumper $graph;
	# my $leaders = filterOnlyClusters($graph);
	# sayToFile $outputFile, "this is leaders!";
	# say "leaders count is: ", scalar @$leaders;
	# sayToFile $outputFile, Dumper(map{ {$_ => $graph->{$_}} }@$leaders);
	# sayToFile $outputFile, Dumper $array;
	# sayToFile $outputFile, Dumper $spanningTree;
	# sayToFile $outputFile, " I have total length: ", computeTotalLengthOfSpanningTree($spanningTree);
	# sayToFile $outputFile, "and total edges: ", scalar keys %{$spanningTree->{edges}};
}
Main($input,$output);

# ------- Data Correcting --- #
sub CorrectDataStructureForGraph{
	my ($graph) = @_;
	for (keys %$graph){
		delete $graph->{$_}->{connections};
	}
}
# ------- Output Data ------- #
sub filterOnlyLeaders{
	my($graph) = @_;
	my $leaders = [grep{$_==$graph->{$_}->{leader}}keys %$graph];
	return $leaders;
}

sub filterOnlyClusters{
	my ($graph) = @_;
	my $clusters = [grep{$_==$graph->{$_}->{leader}||!defined($graph->{$_}->{leader})}keys %$graph];
	return $clusters;
}

# ------- Data Input -------- #
sub readData {
	my $graph = {}; # needed in algorithm for min computing
	my $countOfVertexes = undef;
	my $inputFile = shift;
	open $fh, '<', $inputFile or die "can't open file on read! $inputFile! $!";
	while (<$fh>){		
		chomp;
		do{$countOfVertexes = [split(/\s+/)]->[0]; next} if $.==1;
		insertToGraph($graph,"$. ".$_);
	}
	return ($graph,$countOfVertexes);
}

sub nodeWithName{
	my ($graph,$name) = @_;
	return undef unless exists $graph->{$name};
	return $graph->{$name};
}

sub createNode{
	my ($graph,$node,$x,$y) = @_;
	unless (exists $graph->{$node}){
		$graph->{$node} = {
			x => $x,
			y => $y
		};
	}
}

sub insertToGraph{
	my ($graph, $lineToBreak) = @_;
	my @pieces = split /\s+/, $lineToBreak;
	my ($first,$x,$y) = @pieces;
	createNode($graph,$first,$x,$y);
	# createNode($graph,$second);
	# addConnection($graph,$first,$second,$weight);
}

sub addConnection{
	my ($graph,$first,$second,$weight) = @_;
	if ($first!=$second){
		unless(exists $graph->{$first}->{connections}->{$second}){
			$graph->{$first}->{connections}->{$second} = $weight;
		}
		# graph is directed, I don't need to know tails and heads edges
		# unless(exists $graph->{$second}->{connections}->{$first}){
		# 	$graph->{$second}->{connections}->{$first} = $weight;
		# }
	}
}

sub removeConnection{
	my ($graph,$first,$second) = @_;
	if (exists $graph->{$first}->{connections}->{$second} && 
		exists $graph->{$second}->{connections}->{$first}){
		delete $graph->{$first}->{connections}->{$second};
		delete $graph->{$second}->{connections}->{$first};
	}
}

sub countOfVertexes{
	my $graph = shift;
	return scalar @{[keys %$graph]};
}

# ------- Travel Salesman Algorithm --------- #
# First, we must sort all edges in ascending order. #

# really, we need quicksort here :\ #

sub minUndefAsInf{
	my (@array) = @_;
	return (sort{$a<=>$b}grep{defined}@array)[0];
}
sub min{
	my (@array) = @_;
	return (sort{$a<=>$b}@array)[0];
}

sub distanceBetweenTwoCities{
	my ($graph,$first,$second) = @_;
	my $distance = sqrt(
	               ($graph->{$first}->{x} - $graph->{$second}->{x})**2 +
	               ($graph->{$first}->{y} - $graph->{$second}->{y})**2 );
	return $distance;
}

sub subtractItemFromSet{
	my ($set, $item) = @_;
	return grep{$_!=$item}@$set;
}

sub allSetsConstrainedToSize{
	my ($size) = @_;

}

sub TravelSalesmanAlgorithm{
	my ($graph,$countOfVertexes) = @_;
	# here we should create support matrix with 2^n rows and n columns
	# I must store only previous n values, because only they are needed for further computations

	my $startSizeOfSets = 2;
	my $endSizeOfSets = $countOfVertexes;
	for my $sizeOfSet( $startSizeOfSets .. $endSizeOfSets ){
		my $allSetsForCurrentSize = allSetsConstrainedToSize($sizeOfSet);
		for my $j (@$allSetsForCurrentSize){
			# algorithm here
		}
	}
}