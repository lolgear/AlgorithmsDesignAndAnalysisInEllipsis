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

	say "algorithm begin";
	my ($matrixOfPaths) = FloydWarshallAlgorithm($graph,$countOfVertexes);
	say "algorithm end";
	my ($doesNegativeCycleExists) = CheckGraphForNegativeCycle($matrixOfPaths,$countOfVertexes);
	my $shortestPath = -1;
	if ($doesNegativeCycleExists eq "NO"){
		my $plainShortestPathMatrixArray = MatrixPlainification($matrixOfPaths,$countOfVertexes,$countOfVertexes,$countOfVertexes);	
		$shortestPath = minUndefAsInf(@$plainShortestPathMatrixArray);
	}
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
		insertToGraph($graph,$_);
	}
	return ($graph,$countOfVertexes);
}

sub nodeWithName{
	my ($graph,$name) = @_;
	return undef unless exists $graph->{$name};
	return $graph->{$name};
}

sub createNode{
	my ($graph,$node) = @_;
	unless (exists $graph->{$node}){
		$graph->{$node} = {
			connections => {},
			shortest_path_from_zero_vertex => undef,
		};
	}
}

sub insertToGraph{
	my ($graph, $lineToBreak) = @_;
	my @pieces = split /\s+/, $lineToBreak;
	my ($first,$second,$weight) = @pieces;
	createNode($graph,$first);
	# createNode($graph,$second);
	addConnection($graph,$first,$second,$weight);
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

sub insertToEdgesArray{
	my $array = shift;
	my $lineToBreak = shift;
	my @parts = split /\s+/, $lineToBreak;
	my $element = {
		nodes => [@parts[0,1]],
		edge => $parts[2],
	};
	push @$array,$element;
}

# ------- Johnson Algorithm --------------- #
sub addZeroConnectedVertexToGraph{
	my ($graph) = @_;
	my $label = -1;
	createNode($graph,$label);
	for my $node (keys %$graph){
		unless(exists $graph->{$label}->{connections}->{$node}){
			$graph->{$label}->{connections}->{$node} = 0;
		}
	}
}

sub DijkstrasAlgorithm{

}
sub BellmanFordsAlgorithm{
	my ($graph, $countOfVertexes, $sourceVertex) = @_;
	my $doesNegativeCycleExists = 0;
	my $matrixOfPaths = [];
	# prepare matrix for algorithm
	# A[0,source] = 0
	# A[0,node] = +INF if node != source
	for my $node(keys $graph){
		if ($node == $sourceVertex){
			$matrixOfPaths->[0]->[$node] = 0;
		}
		else{
			$matrixOfPaths->[0]->[$node] = undef;
		}
	}
}
sub JohnsonsAlgorithm{

}

# ------- FloydWarshall Algorithm --------- #
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

sub MatrixPlainification{
	my ($matrixOfPaths,$firstDimension,$secondDimension,$countOfVertexes) = @_;
	my $array = [];
	for my $firstIndex (1 .. $firstDimension){
		for my $secondIndex (1 .. $secondDimension){
			push @$array, $matrixOfPaths->[$firstIndex]->[$secondIndex]->[$countOfVertexes];
		}
	}
}

sub doesNegativeCycleExists{
	my($matrixOfPaths,$countOfVertexes) = @_;
	my $count = grep{$_<0}map{$matrixOfPaths->[$_]->[$_]->[$countOfVertexes]}(1 .. $countOfVertexes);
	return $count!=0?"YES":"NO";
}

sub FloydWarshallAlgorithm{
	my ($graph,$countOfVertexes) = @_;
	my $matrixOfPaths = [];
	# prepare for algorithm.
	# A[i,j,0] = 
	# 				0 		if i = j
	# 				c_{ij}	if (i,j) from E
	#				+INF 	if i!=j and (i,j) NOT from E
	for my $firstIndex (1 .. $countOfVertexes){
		for my $secondIndex (1 .. $countOfVertexes){
			if ($firstIndex == $secondIndex){
				$matrixOfPaths->[$firstIndex]->[$secondIndex]->[0] = 0;
			}
			elsif(exists $graph->{$firstIndex}->{connections}->{$secondIndex}){
				$matrixOfPaths->[$firstIndex]->[$secondIndex]->[0] = 
				$graph->{$firstIndex}->{connections}->{$secondIndex};
			}
			else{
				$matrixOfPaths->[$firstIndex]->[$secondIndex]->[0] = undef;
			}			
		}
	}

	# next, algorithm here
	my $totalWork = $countOfVertexes * $countOfVertexes;
	for my $firstIndex (1 .. $countOfVertexes){
		for my $secondIndex (1 .. $countOfVertexes){
			for my $restrictionOfInternalLabels (1 .. $countOfVertexes){
				my $previousValue = 
				$matrixOfPaths->[$firstIndex]->[$secondIndex]->[$restrictionOfInternalLabels - 1];
				my $optimalLeftValue = 
				$matrixOfPaths->[$firstIndex]->[$restrictionOfInternalLabels]->[$restrictionOfInternalLabels - 1];
				my $optimalRightValue = 
				$matrixOfPaths->[$restrictionOfInternalLabels]->[$secondIndex]->[$restrictionOfInternalLabels - 1];
				
				$matrixOfPaths->[$firstIndex]->[$secondIndex]->[$restrictionOfInternalLabels] 
				= minUndefAsInf($previousValue,$optimalLeftValue + $optimalRightValue);
			}
			sayTimer($firstIndex * $countOfVertexes + $secondIndex, $totalWork);
		}
	}
	return $matrixOfPaths;
}