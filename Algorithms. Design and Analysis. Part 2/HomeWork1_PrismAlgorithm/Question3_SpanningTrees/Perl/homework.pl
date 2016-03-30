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
	my $graph = readData($inputFile);
	my $sourceVertex = chooseSourceVertex($graph);
	print "this is source $sourceVertex";
	my $spanningTree = PrimsAlgorithmForSpanningTree($graph,$sourceVertex);
	sayToFile $outputFile, Dumper $spanningTree;
	sayToFile $outputFile, " I have total length: ", computeTotalLengthOfSpanningTree($spanningTree);
	sayToFile $outputFile, "and total edges: ", scalar keys %{$spanningTree->{edges}};
	# sayToFile 'outputHelp2.txt', Dumper $graph;
	# now, I have a first element as 
	# sayToFile "median is $median";
	# sayToFile "Total time: ".(time() - $^T);
}
Main($input,$output);
# ------- Data Input -------- #
sub readData {
	my $graph = {};
	my $inputFile = shift;
	open $fh, '<', $inputFile or die "can't open file on read! $inputFile! $!";
	while (<$fh>){
		next if $.==1;
		chomp;
		insertToTree($graph,$_);
	}
	return $graph;
}
sub createNode{
	my ($graph,$node) = @_;
	unless (exists $graph->{$node}){
		$graph->{$node} = {
			connections => {},
			visited => 0,
		};
	}
}

sub insertToTree{
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

# ------- Algorithm --------- #
# algorithm have several parts.
# first, uniformaly choose first source vertex.
sub chooseSourceVertex{
	my $graph = shift;
	return [keys %{$graph}]->[0];
}

sub computeTotalLengthOfSpanningTree{
	my ($spanningTree) = @_;
	my $sum = 0;
	for (keys %{$spanningTree->{edges}}){
		$sum += $spanningTree->{edges}->{$_};
	}
	return $sum;
}

sub PrimsAlgorithmForSpanningTree{
	my ($graph,$sourceVertex) = @_;
	my $spanningTree = {edges => {}, vertexes => {} };
	# my $minimumEdgesHash = initMinimumEdgesHash();
	my $countOfVertexes = countOfVertexes($graph);
	say "count: ", $countOfVertexes;
	addNewVertexWithFriendToSpanningTree($graph,$spanningTree,$sourceVertex,undef);
	# first, add source vertex to spanning tree
	#for (1..$countOfVertexes-1){
	for (1..$countOfVertexes-1){
		# now, we have new hash with new edges 
		# (that are min path to all vertexes in spanning tree)

		addNewMinEdgeToSpanningTree($graph,$spanningTree);
		# min edges hash have all vertexes except vertexes in spanning tree
	}
	return $spanningTree;
}

sub removeUnnecessaryEdgesFromSpanningTreeExpectFriend{
	my ($graph,$spanningTree, $newVertex, $friendVertex) = @_;
	my $spanningTreeVertexes = [keys %{$spanningTree->{vertexes}}];
	# take all vertexes connections
	for (keys %{$graph->{$newVertex}->{connections}}){
		# we need to skip our friend vertex
		# next if $_ == $friendVertex;
		# and check if these connections exists in tree
		if ($_ ~~ $spanningTreeVertexes){
			# remove connection from $newVertex and from vertex in spanningTree
			say 'outputHelp3.txt', "I will remove connection: $newVertex | $_";
			removeConnection($graph,$newVertex,$_);
		}
	}
}

sub addNewVertexWithFriendToSpanningTree{
	my ($graph,$spanningTree, $vertex, $friendVertex) = @_;
	unless (exists $spanningTree->{vertexes}->{$friendVertex}){
		# this is first vertex
		# so, add only this vertex
		$spanningTree->{vertexes}->{$vertex} = 1; 
		return;
	}
	unless (exists $spanningTree->{vertexes}->{$vertex}){
		
		# sayToFile 'outputHelp2.txt',qq'VERTEX: $vertex', Dumper $graph;
		$spanningTree->{vertexes}->{$vertex} = 1;
		# suppose, that all edges have DISTINCT WEIGHT
		my $weight = $graph->{$friendVertex}->{connections}->{$vertex};
		$spanningTree->{edges}->{$friendVertex.'|'.$vertex} = $weight;
		removeUnnecessaryEdgesFromSpanningTreeExpectFriend($graph,$spanningTree,$vertex,$friendVertex);
	}
}

sub addNewMinEdgeToSpanningTree{
	my ($graph,$spanningTree) = @_;
	# first, find smallest edge and vertex
	my $smallNode = undef;
	my $smallConnect = undef;
	my $smallWeight = undef;
	# for every node in tree
	for my $treeNode(keys %{$spanningTree->{vertexes}}){
		# take all connections
		for my $treeNodeConnect(keys %{$graph->{$treeNode}->{connections}}){
			# and find minimum weight
			my $weight = $graph->{$treeNode}->{connections}->{$treeNodeConnect};
			if ($weight < $smallWeight || !defined($smallWeight) ){
				$smallWeight = $weight;
				$smallNode = $treeNode;
				$smallConnect = $treeNodeConnect;
			}
		}
	}
	# then, add it to 
	addNewVertexWithFriendToSpanningTree($graph,$spanningTree,
		$smallConnect,$smallNode);
}