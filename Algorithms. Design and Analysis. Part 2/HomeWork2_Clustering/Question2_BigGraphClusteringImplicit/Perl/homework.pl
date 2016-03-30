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

	my ($graph,$countOfVertexes) = readData($inputFile);
	# now sort array in edge-ascending order of element #
	# sayToFile $outputFile, "count of elements in array: ", scalar @$array;
	# print "this is source $sourceVertex";
	# need some clear here
	CorrectDataStructureForGraph($graph);
	# main algorithm
	ClusteringAlgorithm($graph,$countOfVertexes);
	
	my $leaders = filterOnlyLeaders($graph);
	sayToFile $outputFile, "I have count of leaders: ", scalar keys %$leaders;
	# sayToFile $outputFile,"count of elements in array: ", scalar @$array;
	# sayToFile $outputFile,Dumper $graph;
	# my $leaders = filterOnlyClusters($graph);
	# sayToFile $outputFile, "this is leaders!";
	# say "leaders count is: ", scalar @$leaders;
	# sayToFile $outputFile, Dumper(map{ {$_ => $graph->{$_}} }@$leaders);
	
}
Main($input,$output);

# ------- Data Correcting --- #
sub CorrectDataStructureForGraph{
	my ($graph) = @_;
	for (keys %$graph){
		# delete $graph->{$_}->{connections};
	}

	$graph->{leaders} = {};
}

sub createLeader{
	my ($graph,$leader) = @_;
	my $normalName = $graph->{$leader}->{name};
	unless (exists $graph->{leaders}->{$normalName}){
		$graph->{leaders}->{$normalName} = {
			leader_vertexes => {},
			leader => $normalName,
			bitName => $leader,
		};
		$graph->{$leader}->{leader} = $normalName;
	}
}

sub mergeLeaderWithLeader{
	my ($graph,$leader, $mergeToLeader) = @_;
	my $normalName = $graph->{$leader}->{name};
	delete $graph->{leaders}->{$normalName};
	addVertexBelongToLeader($graph,$graph->{leaders}->{$mergeToLeader}->{bitName},$leader);
}

sub addVertexBelongToLeader{
	my ($graph,$leader,$vertex) = @_;
	# createLeader($graph,$leader);	
	my $leaderName = $graph->{$leader}->{name};
	my $belongName = $graph->{$vertex}->{name};
	$graph->{leaders}->{$leaderName}->{leader_vertexes}->{$belongName} = 1;
	$graph->{$vertex}->{leader} = $leaderName;	
}

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
	my $graph = {}; # needed in algorithm for min computing
	my $countOfVertexes = undef;
	my $inputFile = shift;
	open $fh, '<', $inputFile or die "can't open file on read! $inputFile! $!";
	while (<$fh>){
		chomp;
		do{$countOfVertexes = (split/\s+/)[0]; next} if $.==1;
		insertToGraph($graph,"${\($. - 1)}",$_);
		say "I read $. !";
	}
	return ($graph,$countOfVertexes);
}

sub createNode{
	my ($graph,$nodeName,$nodeReal) = @_;
	unless (exists $graph->{$nodeReal}){
		$graph->{$nodeReal} = {
			leader => undef,
			name => $nodeName,
		};
	}
}
sub removeVertexFromGraph{
	my ($graph, $vertex) = @_;
	delete $graph->{$vertex};
}

sub insertToGraph{
	my ($graph,$nodeName,$lineToChange) = @_;
	$lineToChange =~ s/\s+$//;
	$lineToChange =~ s/\s/_/g;
	createNode($graph,$nodeName,$lineToChange);
}

# ------- Algorithm --------- #
# First, we must sort all edges in ascending order. #
# ok, I need proper data structure #
# I took every node. # 
# if node not in cluster, I will find cluster for this node #
# what I will do? #
# I will go through all vertices. for each vertex I will do spread out of possible vertices in cluster. #

sub ClusteringAlgorithm{
	my ($graph,$countOfVertexes) = @_;
	my $array = [sort {$a<=>$b} keys %$graph];
	my $nextNode = undef;
	while ($countOfVertexes!=0){
		# choose next vertex
		say "Count of nodes: $countOfVertexes";
		$nextNode = shift @$array;
		# if this node already has leader, we know, that this node already be in her cluster
		next if doesNodeHasLeader($graph,$nextNode);
		# if not, we need to use mask
		addPossibleValuesOfNodesInClusterForNode($graph,$nextNode);
		$countOfVertexes--;
		$possibleNodesInCluster = undef;
	}
}

sub doesNodeHasLeader{
	my ($graph,$node) = @_;
	return defined($graph->{$node}->{leader});
}

sub addPossibleValuesOfNodesInClusterForNode{
	my ($graph,$node) = @_;
	createLeader($graph,$node);
	my $possibleNodes = {};
	my $arrayOfBits = [split(/_/,$node)];
	my $countOfBits = scalar @$arrayOfBits;
	for (my $i = 0; $i<($countOfBits-1);++$i){

		my @newBitsArray = @{$arrayOfBits};
		$newBitsArray[$i] = ($newBitsArray + 1) % 2;
		my $oneBitChangedName = join('_',@newBitsArray);
		if (doesNodeHasLeader($graph,$oneBitChangedName)){
			mergeLeaderWithLeader($graph,$node,$graph->{$oneBitChangedName}->{leader});
			return;
		}
		addVertexToClusterWithLeader($graph,$node,$oneBitChangedName);

		for (my $j = $i + 1; $j<$countOfBits; ++$j){
			my @newNewBitsArray = @newBitsArray;
			$newNewBitsArray[$j] = ( $newNewBitsArray[$j] + 1 ) % 2;
			my $twoBitsChangedName = join('_',@newNewBitsArray);

		if (doesNodeHasLeader($graph,$twoBitsChangedName)){
			mergeLeaderWithLeader($graph,$node,$graph->{$twoBitsChangedName}->{leader});
			return;
		}
			addVertexToClusterWithLeader($graph,$node,$twoBitsChangedName);
		}
	}	
	$arrayOfBits = undef;
}

sub createClusterForNodeWithPossibleNodes{
	my ($graph,$node,$possibleNodes) = @_;
	# is there any chance that possible node will belong to other cluster? #
	# no, because of algorithm #
	# we take all possible values of bitmask, so they belong to one cluster together #
	# also! graph have structure leaders!!! #
	createLeader($graph,$node);
	for (keys %$possibleNodes){
		# unless exists - next
		# say "possible nodes: ", Dumper $possibleNodes;
		next unless (exists $graph->{$_});
		# say "I add vertex: $_";
		# say "to leader: $node";
		addVertexBelongToLeader($graph,$node,$_);
		# removeVertexFromGraph($graph,$_);
	}
	# removeVertexFromGraph($graph,$node);
}

sub addVertexToClusterWithLeader{
	my ($graph,$leader,$vertex) = @_;
	return undef unless exists $graph->{$vertex};
	addVertexBelongToLeader($graph,$leader,$vertex);
}