
#-------- Begin ----------#
my $input = 'input.txt';
my $output = 'output.txt';
my ($fh,$oh);

open $fh, '<', $input;
open $oh, '>', $output;

use Data::Dumper;
$,=",";
$"=",";
sub say {
	for(@_){
		print;
		print{$oh}$_;	
	}
	print"\n";
	print{$oh}"\n";
}



my $graph = {};
say "read part";
readData($graph);

# count of visited nodes
our $visitedNodes = 0;
# last node (leader) 
our $lastNode = 0;

# -------- Functions -------- #
# ---- Data Manipulation ---- # 
# data manipulation 
sub readData{
	my $graph = shift;
	my $inputFile = "input.txt";
	open my $fh,"<",$inputFile;
	while (<$fh>){
		chomp;
		my ($a, $b) = split (/ /);
		addNode($graph,$a,$b);
	}
}

sub createNode{
	my ($graph,$node) = @_;
		unless(exists $graph->{$node}){
		$graph->{$node} = {
			connections => {}, # I would store {connect => ward}
			label => "",
			visited => 0,
			leader => 0,
			real_name => $node,
		};		
	}
}

# now we have labels.
# we must remove all previous "labels" and put our new labels
sub reverseGraphToLabel{
	my ($graph) = shift;
	my $newGraph = {};
	for my $node(keys %$graph){
		my %hash = chooseConnectionsHash($graph,$node);
		delete $graph->{$node}->{connections};
		$graph->{$node}->{connections} = {};
		for (keys %hash){
			my $label = $graph->{$_}->{label};
			$graph->{$node}->{connections}->{$label} = $hash{$_};
		}
	}	
	map{
		$newGraph->{$_->{label}} = $_;
		}map{$graph->{$_}} keys%$graph;
	undef($graph);
	return $newGraph;
}
sub addNode{
	my ($graph,$node,$connect) = @_;
	my $ward = 1;
	createNode($graph,$node);
	createNode($graph,$connect);
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

# say "graph is ", Dumper($graph);
my @output = RunReverseDFSLoop($graph);
@output = grep {defined} @output;
my $countOfLeaders = 5;
my $currentLeaders = scalar @output;
my @remains = (0)x($countOfLeaders - $currentLeaders);
say "";
my $output = join',',(@output, @remains);
# remain part

say "output is $output";

#say Dumper $graph;


# ---- Algorithm Realization ---- # 
sub RunReverseDFSLoop{
	my ($graph) = shift;	
	my $nodeCount = scalar keys %$graph;
	say "backward part";
	for my $index (reverse(1..$nodeCount)){
		# say "$index have connections", chooseBackwardConnections($graph,$index);
		# say "$index visited? ", $graph->{$index}->{visited};
		 unless($graph->{$index}->{visited}){
		 	# $lastNode = $index;
		 	DFSLoopBackward($graph,$index);
		 }
	}

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
	 return (sort {$b<=>$a} values %leaders)[0..4];
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


sub sayAbout{
	my $graph = shift;
	my (@vertexs) = @_;
	for my $vertex (@vertexs){	
		# say $vertex, "--->","@{$graph->{$vertex}}" if exists $graph->{$vertex};
	}
}

__DATA__
1 2
2 3
3 1
3 4
5 4
6 4
8 6
6 7
7 8
