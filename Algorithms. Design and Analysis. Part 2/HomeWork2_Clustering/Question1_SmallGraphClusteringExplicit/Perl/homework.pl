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

	my ($array,$graph,$countOfVertexes) = readData($inputFile);
	# now sort array in edge-ascending order of element #
	$array = SortEdgesInAscendingOrder($array,'edge');
	# sayToFile $outputFile, "count of elements in array: ", scalar @$array;
	my $maximumNumberOfClusters = 4;
	# print "this is source $sourceVertex";
	# need some clear here
	CorrectDataStructureForGraph($graph);
	# main algorithm
	ClusteringAlgorithm($array,$graph,$countOfVertexes,$maximumNumberOfClusters);
	
	# sayToFile $outputFile,"count of elements in array: ", scalar @$array;
	# sayToFile $outputFile,Dumper $graph;
	my $leaders = filterOnlyClusters($graph);
	# sayToFile $outputFile, "this is leaders!";
	say "leaders count is: ", scalar @$leaders;
	sayToFile $outputFile, Dumper(map{ {$_ => $graph->{$_}} }@$leaders);
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
	my $array = [];
	my $graph = {}; # needed in algorithm for min computing
	my $countOfVertexes = undef;
	my $inputFile = shift;
	open $fh, '<', $inputFile or die "can't open file on read! $inputFile! $!";
	while (<$fh>){		
		chomp;
		do{$countOfVertexes = $_; next} if $.==1;
		insertToEdgesArray($array,$_);
		insertToGraph($graph,$_);
	}
	return ($array,$graph,$countOfVertexes);
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
			leader => undef,
			leader_vertexes => {},
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
		unless(exists $graph->{$first}->{connections}->{$second}){
			$graph->{$first}->{connections}->{$second} = $weight;
		}
		unless(exists $graph->{$second}->{connections}->{$first}){
			$graph->{$second}->{connections}->{$first} = $weight;
		}
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

# ------- Algorithm --------- #
# First, we must sort all edges in ascending order. #

# really, we need quicksort here :\ #
sub SortEdgesInAscendingOrder{
	my ($array,$propertyName) = @_;
	return [sort{$a->{$propertyName} <=> $b->{$propertyName}}@$array];
}

# ---- Syllabis ---- #
# After that we must run this algorithm and add each vertex to nearest cluster #
# But somehow we need to store min spacing between clusters #
# maybe we must to remove somehow component if node in the same cluster?#
# but how to do it if we don't manipulate data properly? #
# ok, we will store it in graph also #
# and after algorithm we will find min #
# BUT STOP! here we know, that p and q must be from separated clusters #
# so, the current spacing is (p,q) edge! #
# hmm, really great :3 #

# ---- Second Step -- #

# on each iteration we must skip vertexes from the same cluster #
# or with the same leader! # 
sub ClusteringAlgorithm{
	my ($array,$graph,$countOfVertexes,$maximumNumberOfClusters) = @_;
	# this cycle will be really through all {#($countOfVertexes - $maximumNumberOfClusters)} vertexes #
	# not count of vertexes, but count of edges??
	my $countOfEdges = scalar @$array;
	my $totalCount = $countOfVertexes;
	say "number of clusters is: $maximumNumberOfClusters and number of vertexes is: $countOfVertexes";
	while ($totalCount!=$maximumNumberOfClusters){
		# remove one edge from count
		# take first edge from array with separated vertexes
		my ($element) = takeEdgeWithSeparatedVertexes($array,$graph);		
		assignNewLeaderToEdges($graph,@{$element->{nodes}});
		$totalCount--;
		say "total count of clusters is: $totalCount";
		say "real total count of clusters is: ",scalar @{+filterOnlyLeaders($graph)};
	}
	my ($element) = takeEdgeWithSeparatedVertexes($array,$graph);
	say "I have next element: ",Dumper $element;
}

sub takeEdgeWithSeparatedVertexes{
	my ($array,$graph) = @_;
	my $element = undef;
	my ($first,$second);
	do{
		$element = shift @$array;
		($first,$second) = @{$element->{nodes}};
	}
	until (!doesVertexesFromTheSameCluster($graph,$first,$second));
	return $element;
}

sub doesVertexesFromTheSameCluster {
	my ($graph,$first,$second) = @_;
	my $boolResult = 0;
	$boolResult = 
	# if both leaders defined and they are equal #
	defined($graph->{$first}->{leader}) && 
	defined($graph->{$second}->{leader}) &&	
	($graph->{$first}->{leader} == $graph->{$second}->{leader});
	return $boolResult;
}

sub assignNewLeaderToEdges{
	my ($graph,$first,$second) = @_;
	# we need to change all vertices or what?
	if (
		!defined($graph->{$first}->{leader})&&
		!defined($graph->{$second}->{leader})
		){
		# so, choose first as leader
		becomeLeaderToVertex($graph,$first,$second);
		return;
	}
	else{
		# first does not have leader
		if (!defined($graph->{$first}->{leader})){
			becomeLeaderToVertex($graph,$graph->{$second}->{leader},$first);
			return;
		}
		# second does not have leader
		elsif (!defined($graph->{$second}->{leader})){			
			becomeLeaderToVertex($graph,$graph->{$first}->{leader},$second);
			return;
		}
		# both have leaders
		else{
			# say "leaders will be joined: ",$graph->{$first}->{leader}, " and ",$graph->{$second}->{leader};
			becomeLeaderBeyondOthers($graph,$graph->{$first}->{leader},$graph->{$second}->{leader});
			return;
		}
	}
}

sub becomeLeaderBeyondOthers{
	my ($graph,$leader,$otherLeader) = @_;
	for(keys %{$graph->{$otherLeader}->{leader_vertexes}}){
		becomeLeaderToVertex($graph,$leader,$_);
	}
	$graph->{$otherLeader}->{leader_vertexes} = undef;
	becomeLeaderToVertex($graph,$leader,$otherLeader);
}

sub becomeLeaderToVertex{
	my ($graph,$leader,$vertex) = @_;
	$graph->{$leader}->{leader} = $leader;
	$graph->{$vertex}->{leader} = $leader;
	$graph->{$leader}->{leader_vertexes}->{$vertex} = 1;
}
# # NOTE: Spacing is MIN edge weight over all separated vertices, i.e. vertices from separated clusters
# sub SpacingComputingAlgorithm{

# }
