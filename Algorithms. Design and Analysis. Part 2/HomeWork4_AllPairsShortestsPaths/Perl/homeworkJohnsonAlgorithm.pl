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
	CorrectDataStructureForGraph($graph);
	say "algorithm begin";
	my ($structure, $doesNegativeCycleExists) = JohnsonsAlgorithm($graph,$countOfVertexes);
	say "algorithm end";

	my $shortestPath = -1;
	if ($doesNegativeCycleExists eq "NO"){
		my $plainShortestPathMatrixArray = [map{$structure->{$_}}keys %$structure];
		$shortestPath = minUndefAsInf(@$plainShortestPathMatrixArray);
	}
	my $totalTime = time() - $^T;
	sayToFile 
	"out$inputFile", "I have min path length: $shortestPath 
	\n and negative cycle exists: $doesNegativeCycleExists
	\n and total Time: $totalTime";
	# print "this is source $sourceVertex";
	# need some clear here
	
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

sub sayAboutMatrix{
	my ($matrix) = @_;
	for my $array (@$matrix) {
		say '| '."@$array".' |';
	}
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
			heads => {},
			tails => {},
			shortest_path_from_zero_vertex => undef,
			# needed for Dijkstra's algorithm
			path => undef,
			visited => 0,
		};
	}
}

sub insertToGraph{
	my ($graph, $lineToBreak) = @_;
	my @pieces = split /\s+/, $lineToBreak;
	my ($first,$second,$weight) = @pieces;
	createNode($graph,$first);
	createNode($graph,$second);
	addConnection($graph,$first,$second,$weight);
}

sub addConnection{
	my ($graph,$first,$second,$weight) = @_;
	if ($first!=$second){
		unless(exists $graph->{$first}->{heads}->{$second}){
			$graph->{$first}->{heads}->{$second} = $weight;
		}
		unless(exists $graph->{$second}->{tails}->{$first}){
			$graph->{$second}->{tails}->{$first} = $weight;
		}
		# unless(exists $graph->{$first}->{connections}->{$second}){
		# 	$graph->{$first}->{connections}->{$second} = $weight;
		# }
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

sub removeZeroVertexWithNoTails{
	my ($graph, $vertex) = @_;
	if (exists $graph->{$vertex}){
		if (keys %{$graph->{$vertex}->{tails}} == 0){
			delete $graph->{$vertex};
		}
	}
	for my $node(keys %$graph){
		if (exists $graph->{$node}->{tails}->{$vertex}){
			delete $graph->{$node}->{tails}->{$vertex};
		}
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
	my $label = 0;
	createNode($graph,$label);
	for my $node (keys %$graph){
		next if ($node == $label);
		unless(exists $graph->{$label}->{heads}->{$node}){
			$graph->{$label}->{heads}->{$node} = 0;
		}
		unless(exists $graph->{$node}->{tails}->{$label}){
			$graph->{$node}->{tails}->{$label} = 0;
		}
	}
	return $label;
}

sub addShortestPathToStructure{
	my ($structure,$sourceVertex,$node,$shortestPath) = @_;
	$structure->{"$sourceVertex,$node"} = $shortestPath;
}

sub restoreShortestPathInStructure{
	my ($graph,$structure,$tail,$head) = @_;
	say "$tail and $head";
	if (exists $structure->{"$tail,$head"}){
		# substract tail and add head
		$structure->{"$tail,$head"} += ($graph->{$head}->{shortest_path_from_zero_vertex} - $graph->{$tail}->{shortest_path_from_zero_vertex});
	}
}
sub GatherShortestPaths{
	my ($graph, $sourceVertex, $structure) = @_;
	for my $node(keys %$graph){
		my $shortestPath = $graph->{$node}->{path};
		addShortestPathToStructure($structure,$sourceVertex,$node,$shortestPath);
	}
}


sub RestoreDijkstrasValues{
	my $defaultMaxValue = 1000000;
	my ($graph) = @_;
	for my $node(keys %$graph){
		$graph->{$node}->{path} = $defaultMaxValue;
		$graph->{$node}->{visited} = 0;
	}
}

sub changeNodeWeight{
	my ($graph,$index,$connect) = @_;
	my $old_weight = $graph->{$connect}->{path};
	my $source_weight = $graph->{$index}->{path};
	# say " I have old weight: $old_weight and connect: $connect";
	# say " I have $graph->{$index}->{heads}->{$connect}";
	my $new_weight = $source_weight + $graph->{$index}->{heads}->{$connect};
	if ($new_weight < $old_weight){
		# @{$graph->{$connect}->{paths}} = (@{$graph->{$index}->{paths}},$index);
		$graph->{$connect}->{path} = $new_weight;
		# do{print "this is $connect    ";
		   # print "this is new weight $new_weight   ";
		   # print "from index $index\n";
		#    print "and I have path is @{$graph->{$connect}->{paths}}\n";
		#    } if $connect ~~ [7,37,59,82,99,115,133,165,188,197];		
	}
}

sub DijkstraAlgorithm{
	my ($graph,$index) = @_;
	# try to change weight
	$graph->{$index}->{path} = 0;
	DijkstraAlgorithmStepOne($graph,$index);
	# next, choose index with minimal weight
	$index = DijkstraAlgorithmStepTwo($graph,$index);
	# say "next vertex: $index";
	if (defined $index){
		DijkstraAlgorithm($graph,$index);	
	}	
}

sub DijkstraAlgorithmStepOne{
	my ($graph,$index) = @_;
	$graph->{$index}->{visited} = 1;
	# sorting array of connections by weight
	return if (scalar keys %{$graph->{$index}->{heads}} == 0);
	my @keys = sort {$graph->{$a}->{path} <=> $graph->{$b}->{path} }keys %{$graph->{$index}->{heads}};
	# say "for $index i have keys: @keys";
	for my $connect (@keys){
		unless ($graph->{$connect}->{visited}){
			changeNodeWeight($graph,$index,$connect);
		}
	}
}

# choosing vertex with minimal weight
sub DijkstraAlgorithmStepTwo{
	my ($graph,$index) = @_;
	return 
		   (grep{!$graph->{$_}->{visited}}
		   sort {$graph->{$a}->{path}<=>$graph->{$b}->{path}} 
		   keys %{$graph->{$index}->{heads}})[0];
}

sub BellmanFordsAlgorithm{
	my ($graph, $countOfVertexes, $sourceVertex) = @_;
	my $doesNegativeCycleExists = 0;
	my $matrixOfPaths = [];
	# prepare matrix for algorithm
	# A[0,source] = 0
	# A[0,node] = +INF if node != source
	# say "I have graph:", Dumper $graph; exit(0);
	my @allNodes = sort{$a<=>$b}(keys %$graph);
	my $allNodesCount = scalar @allNodes;
	$matrixOfPaths->[0]->[$sourceVertex] = 0;
	for my $node(@allNodes){
		next if ($node == $sourceVertex);
		$matrixOfPaths->[0]->[$node] = undef;
	}
	# sayAboutMatrix($matrixOfPaths);
	# algorithm
	# for i in 1 .. n-1
	# for v from V
	# A[i,v] = min(A[i - 1,v],  min_{(w,v)from E} (A[i - 1, w] + c_{wv}))

	# my @allNodes = sort{$a<=>$b}grep{$_!=$sourceVertex}(keys %$graph);
	
	# here - additional iteration for check if exists cycle
	my $endPoint = $countOfVertexes;
	# say "@allNodes";
	for my $firstIndex (1 .. $endPoint){
		for my $node (@allNodes){
			# say " for $node: $matrixOfPaths->[$firstIndex - 1]->[$node]";
			# my $previousValue = $matrixOfPaths->[$firstIndex - 1]->[$node];
			# my @tailsValues = 
			# map{
			# 	$matrixOfPaths->[$firstIndex - 1]->[$_] + $graph->{$_}->{heads}->{$node}
			# }(keys %{$graph->{$node}->{tails}});

			$matrixOfPaths->[$firstIndex]->[$node] = 
			minUndefAsInf(
				# $previousValue,@tailsValues
				$matrixOfPaths->[$firstIndex - 1]->[$node],
			map{
				$matrixOfPaths->[$firstIndex - 1]->[$_] + $graph->{$_}->{heads}->{$node}
			}(keys %{$graph->{$node}->{tails}}),
			);
		}
		sayTimer($firstIndex, $allNodesCount);
	}
	# if negative cycle not exists:
	# A[n - 1, v] == A[n, v] for all v from V (not included source vertex? yes :3)
	my $countOfEqual = grep{
		$matrixOfPaths->[$countOfVertexes - 1]->[$_] == 
		$matrixOfPaths->[$countOfVertexes]->[$_]
	}(@allNodes);
	# sayAboutMatrix($matrixOfPaths);
	# exit(0) ;
	$doesNegativeCycleExists = $allNodesCount == $countOfEqual? 0:1;
	return ($matrixOfPaths,$doesNegativeCycleExists);
}
sub JohnsonsAlgorithm{
	my ($graph,$countOfVertexes) = @_;
	say "step 1. add zero vertex";
	# step 1. - add zero vertex to graph
	my $sourceVertex = addZeroConnectedVertexToGraph($graph);

	say "step 2. run BellmanFord algorithm";
	# step 2. - run BellmanFord Algorithm on new graph with sourceVertex
	my ($matrixOfPaths, $doesNegativeCycleExists) = BellmanFordsAlgorithm($graph,$countOfVertexes,$sourceVertex);
	return ($matrixOfPaths,"YES") if $doesNegativeCycleExists == 1;

	# step 2.1. - remove added zero-vertex
	removeZeroVertexWithNoTails($graph,$sourceVertex);

	say "step 3. shortest path to zero";
	# step 3.
	# for every v from V
	# define new value: shortest path from s to v (s,v)
	# I can find them in A[n-1,v] after BellmanFords algorithm shortest path matrix
	for my $node(keys %$graph){
		$graph->{$node}->{shortest_path_from_zero_vertex} = 
		$matrixOfPaths->[$countOfVertexes - 1]->[$node];
	}

	# before step 3.
	# remove matrix of paths
	undef $matrixOfPaths;

	say "step 3.1. reweight graph";
	# step 3.1 
	# for each edge (u,v) from G, define c_{e}' = c_{e} + shortestPathFromZeroVertex_{u} - shortestPathFromZeroVertex{v}
	for my $tail(keys %$graph){
		for my $head(keys %{$graph->{$tail}->{heads}}){
			$graph->{$tail}->{heads}->{$head} = 
			$graph->{$tail}->{heads}->{$head} - 
			$graph->{$head}->{shortest_path_from_zero_vertex} +
			$graph->{$tail}->{shortest_path_from_zero_vertex};
		}
	}
	# say Dumper $graph;
	say "step 4. run Dijkstras algorithm";
	# step 4.
	# for every vertex in graph
	# run Dijkstra's Algorithm for every node of graph
	# compute shortests paths to all vertexes
	my $shortestPathStructure = {};
	for my $index(1 .. $countOfVertexes){
		sayTimer($index,$countOfVertexes);
		RestoreDijkstrasValues($graph);
		# say Dumper $graph;
		# return;
		my $node = $index;
		# say "current index $index";
		DijkstraAlgorithm($graph,$node);
		# say Dumper $graph;
		GatherShortestPaths($graph,$node,$shortestPathStructure);
		
	}

	say "step 5. restore old weights of edges";
	# step 5.
	# return previous shortest paths for every edge in G
	# for each edge (u,v) from G', define c_{e} = c_{e}' - shortestPathFromZeroVertex_{u} + shortestPathFromZeroVertex{v}
	for my $tail(keys %$graph){
		for my $head(keys %{$graph->{$tail}->{heads}}){
			$graph->{$tail}->{heads}->{$head} = 
			$graph->{$tail}->{heads}->{$head} + 
			$graph->{$head}->{shortest_path_from_zero_vertex} -
			$graph->{$tail}->{shortest_path_from_zero_vertex};
		}
	}

	for my $tail(keys %$graph){
		for my $head(keys %{$graph}){
			restoreShortestPathInStructure($graph,$shortestPathStructure,$tail,$head);
		}
	}
	# say Dumper $shortestPathStructure;
	return ($shortestPathStructure, "NO");
}

# ------- FloydWarshall Algorithm --------- #
# First, we must sort all edges in ascending order. #

# really, we need quicksort here :\ #

sub minUndefAsInf{
	my (@array) = @_;
	
	my $result = (sort{$a<=>$b}grep{defined}@array)[0];
	# say "I have: @array and result: $result";
	return $result;
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