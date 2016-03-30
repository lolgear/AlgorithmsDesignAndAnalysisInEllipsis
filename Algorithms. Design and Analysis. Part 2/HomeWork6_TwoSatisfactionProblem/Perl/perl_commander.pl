die "not enough arguments" unless @ARGV;

my $inputFiles = [qw(one two three four five six)];
my $count = shift @ARGV;
my @chosenFiles = @$inputFiles[0..($count-1)];
@chosenFiles = map{ucfirst}@chosenFiles;

for my $chosenFile(@chosenFiles){
	print qq(Start: $chosenFile\n);
	print qx(perl homework.pl input$chosenFile.txt &1>1),"\n";
	print qq(End: $chosenFile\n);
}