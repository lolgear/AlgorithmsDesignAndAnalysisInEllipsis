use Data::Dumper;
# use lib qq($ENV{HOME}/Documents/Projects/Perls/);
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
# count of visited nodes
our $visitedNodes = 0;
# last node (leader) 
our $lastNode = 0;

# ---------- Main ---------- #
sub Main{
	my ($inputFile,$outputFile) = @_;

	say "read data begin";
	my ($graph,$countOfVertexes) = readData($inputFile);
	say "read data end";
	# say Dumper $graph;
	say "algorithm begin";
	$graph = RunReverseDFSLoop($graph,$countOfVertexes);
	say "algorithm end";
	$satisfy = AlgorithmFor2SAT($graph,$countOfVertexes);
	# say Dumper $graph;
	# say Dumper filterOnlyClusters($graph);

	my $totalTime = time() - $^T;
	sayToFile 
	"out$inputFile", "
	\n and Satisfy: $satisfy
	\n and total Time: $totalTime";
	# print "this is source $sourceVertex";
	# need some clear here

}


Main($input,$output);

# -------- Functions -------- #
# ------- Data Correcting --- #
sub CorrectDataStructureForGraph{
	my ($graph) = @_;
	for (keys %$graph){
		delete $graph->{$_}->{connections};
	}
}
# ---- Data Manipulation ---- # 
sub createGraphForCountOfVertexes{
	my ($graph,$countOfVertexes) = @_;

	my $indexes = getReverseIndexesForGraph($graph,$countOfVertexes);
	for my $index(@$indexes){
		createNode($graph,$index);
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
		do{$countOfVertexes = [split(/\s+/)]->[0];
		   createGraphForCountOfVertexes($graph,$countOfVertexes);
		   next
		} if $.==1;
		insertToGraph($graph,$_);
	}
	return ($graph,$countOfVertexes);
}


sub createNode{
	my ($graph,$node) = @_;
		unless(exists $graph->{$node}){
		$graph->{$node} = {
			connections => {}, # I would store {connect => ward}
			label => "",
			visited => 0,
			leader => 0,
			name => $node,
		};
	}
}

sub implicationInsert{
	my ($graph,$first,$second) = @_;

	# create needed nodes:
	# i, -i , j, -j
	createNode($graph,$first);
	createNode($graph,$second);
	createNode($graph,0 - $first);
	createNode($graph,0 - $second);
	# (-i, j) and (-j, i)
	addConnection($graph,0 - $first,$second);
	addConnection($graph,0 - $second, $first);
}

sub insertToGraph{
	my ($graph, $lineToBreak) = @_;
	my @pieces = split /\s+/, $lineToBreak;
	# now check, if node < 0, then use implication transform
	# implication transform
	# @pieces = sort {$a<=>$b} @pieces;
	# $pieces[0] = 0 - $pieces[0];

	my ($first,$second) = @pieces;
	implicationInsert($graph,$first,$second);

	# createNode($graph,$first);
	# createNode($graph,$second);
	# addConnection($graph,$first,$second,$weight);
}

# now we have labels.
# we must remove all previous "labels" and put our new labels
sub reverseGraphToLabel{
	my ($graph) = shift;
	my $newGraph = {};

	# I will recreate graph
	for my $node (keys %$graph){
		my $label = $graph->{$node}->{label};
		createNode($newGraph,$label);
		$newGraph->{$label}->{name} = $node;
		# label is my key now for new graph
		$newGraph->{$label}->{connections} = {};
		# choose old connections as hash
		my $oldConnections = chooseConnectionsHashRef($graph,$node);

		# for every connection
		for my $eachConnection(keys %$oldConnections){
			# take it's new label name
			my $newLabelName = $graph->{$eachConnection}->{label};
			# and put it into new graph
			$newGraph->{$label}->{connections}->{$newLabelName} = $oldConnections->{$eachConnection};
		}
	}

	# for my $node(keys %$graph){
	# 	my %hash = chooseConnectionsHash($graph,$node);
	# 	delete $graph->{$node}->{connections};
	# 	$graph->{$node}->{connections} = {};
	# 	for (keys %hash){
	# 		my $label = $graph->{$_}->{label};
	# 		$graph->{$node}->{connections}->{$label} = $hash{$_};
	# 	}
	# }	
	# map{
	# 	$newGraph->{$_->{label}} = $_;
	# 	}map{$graph->{$_}} keys%$graph;
	undef($graph);
	return $newGraph;
}
sub addConnection{
	my ($graph,$node,$connect) = @_;
	my $ward = 1;
		# 
	if (exists $graph->{$node}->{connections}->{$connect}){
		# if I have connection, than, it should be zero. all wards :)
		$graph->{$node}->{connections}->{$connect} = 0;
	}
	else {
		$graph->{$node}->{connections}->{$connect} = $ward;
	}

	# make reverse connection. (j know about i, j know about 'i->j')
	$ward = -1;
	if (exists $graph->{$connect}->{connections}->{$node}){
		$graph->{$connect}->{connections}->{$node} = 0;
	}
	else {
		$graph->{$connect}->{connections}->{$node} = $ward;
	}
}

# ---- Algorithm Realization ---- # 

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

sub RenameLeadersToRealNames{
	my ($graph) = @_;
	for my $node(keys %$graph) {
		my $leader = $graph->{$node}->{leader};
		$graph->{$node}->{leader} = $graph->{$leader}->{name};
	}
}

sub RenameVertexesToRealNamesInNewGraph{
	my ($graph,$sccGraph) = @_;
	undef ($sccGraph);
	$sccGraph = {};
	for my $node (keys %$graph){
		my $name = $graph->{$node}->{name};
		my $leader = $graph->{$node}->{leader};
		$sccGraph->{$name} = $leader;
	}
	return $sccGraph;
}

sub RemoveUnnecessaryFieldsFromGraph{
	my ($graph,$unnecessaryFields) = @_;
	for my $node (keys %$graph){
		for my $field (@$unnecessaryFields){
			delete $graph->{$node}->{$field};
		}
	}
	return $graph;
}

sub SearchFor2SAT{
	my ($sccGraph,$countOfVertexes) = @_;
	my $satisfy = 1;

	for my $satVar (-$countOfVertexes .. -1) {
		my $backVar = 0 - $satVar;
		if ($sccGraph->{$satVar} == $sccGraph->{$backVar}){
			$satisfy = 0;
			say "Bad Compare: $satVar and $backVar because $sccGraph->{$satVar} EQ $sccGraph->{$backVar}";
			last;
		}
	}
	return $satisfy;
}

sub AlgorithmFor2SAT{
	my ($graph,$countOfVertexes) = @_;
	my $unnecessaryFields = [qw(connections label visited)];
	# clear graph objects from unnecessary stuff
	$graph = RemoveUnnecessaryFieldsFromGraph($graph, $unnecessaryFields);
	# take all leaders
	# say "I have graph without fields";
	# say Dumper $graph;
	# now we must rename them!
	# first, rename all leaders
	RenameLeadersToRealNames($graph,$countOfVertexes);
	# say "I have graph after rename leaders";
	# say Dumper $graph;
	# and create hash for satisfy search
	my $sccGraph = undef;
	$sccGraph = RenameVertexesToRealNamesInNewGraph($graph,$sccGraph);
	# say "I have graph for 2 sat search";
	# say Dumper $sccGraph;
	my $satisfy = SearchFor2SAT($sccGraph,$countOfVertexes);
	return $satisfy;
}

sub getReverseIndexesForGraph{
	my ($graph,$countOfVertexes) = @_;
	my $indexes = [reverse(-$countOfVertexes .. -1 , 1 .. $countOfVertexes)];
	return $indexes;
}

sub RunReverseDFSLoop{
	my ($graph,$countOfVertexes) = @_;	
	my $nodeCount = scalar keys %$graph;
	say "backward part";
	# fuck ;<(
	my $indexes = getReverseIndexesForGraph($graph,$countOfVertexes);
	# say "I have indexes: @$indexes";
	for my $index (@$indexes){
		# say "$index have connections", chooseBackwardConnections($graph,$index);
		# say "$index visited? ", $graph->{$index}->{visited};
		 unless($graph->{$index}->{visited}){
		 	# $lastNode = $index;
		 	DFSLoopBackward($graph,$index);
		 }
	}

	# say Dumper $graph;
	# # ok, let's do second part
	for (keys %$graph){
		$graph->{$_}->{visited} = 0;
	}

	my @labels = sort{$b<=>$a} map {$graph->{$_}->{label}} keys %$graph;	
	# say "I have labels ", @labels;
	# say "I have leaders ", @leaders;
	# 
	# needed labels as keys
	say "reverse part";
	$graph = reverseGraphToLabel($graph);
	# say "I have graph before second path: ", Dumper $graph;
	$lastNode = 0;
	say "forward part";
	for my $label(reverse(1..$nodeCount)){
	 	# say "$label have connections", chooseForwardConnections($graph,$label);
	 	# say "$index visited? ", $graph->{$label}->{visited};
	 	unless($graph->{$label}->{visited}){
	 		$lastNode = $label;
	 		# say "leader now: $lastNode";
	 	 	DFSLoopForward($graph,$label);
	 	}
	 }

	 # last part - count leaders
	 my %leaders = ();

	 # say "leaders: ", map{$graph->{$_}->{leader}}@labels;
	 for my $leader(map{$graph->{$_}->{leader}}@labels){
	 	$leaders{$leader}++;
	 }
	 # say "MY LEADERS: ", sort {$a<=>$b}values %leaders;
	 # return (sort {$b<=>$a} values %leaders)[0..4];
	 return $graph;
}

sub chooseConnectionsHashRef{
	my ($graph,$index) = @_;
	return $graph->{$index}->{connections};
}

sub chooseConnectionsHash{
	my ($graph,$index) = @_;
	return %{$graph->{$index}->{connections}};
}
sub chooseBackwardConnections{
	my ($graph,$index) = @_;
	return grep{$graph->{$index}->{connections}->{$_} <= 0} keys %{$graph->{$index}->{connections}};
}
sub chooseForwardConnections{
	my ($graph,$index) = @_;
	return grep{$graph->{$index}->{connections}->{$_} >= 0} keys %{$graph->{$index}->{connections}};
}

sub DFSLoopForward{
	my ($graph,$index) = @_;
	# set $index as visited
	$graph->{$index}->{visited} = 1;
	# set leader as $lastNode
	$graph->{$index}->{leader} = $lastNode;
	# I need only backward connections (or zero-allway connections)
	for my $supportedWard(chooseForwardConnections($graph,$index)){
		# say "for index $index supportedWard : $supportedWard";
		unless ($graph->{$supportedWard}->{visited}){
			DFSLoopForward($graph, $supportedWard);
		}
	}
	# $visitedNodes++;
	# $graph->{$index}->{label} = $visitedNodes;
}
sub DFSLoopBackward{
	my ($graph,$index) = @_;
	# set $index as visited
	$graph->{$index}->{visited} = 1;
	# set leader as $lastNode
	# $graph->{$index}->{leader} = $lastNode;
	# I need only backward connections (or zero-allway connections)
	for my $supportedWard(chooseBackwardConnections($graph,$index)){
		unless ($graph->{$supportedWard}->{visited}){
			DFSLoopBackward($graph, $supportedWard);
		}
	}
	$visitedNodes++;
	$graph->{$index}->{label} = $visitedNodes;
}
