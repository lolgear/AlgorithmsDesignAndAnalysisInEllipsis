my $number = 2000;
my $min = 10000;

$, = " ";
$" = " ";
for (0..$number){
	my $command = qq(perl homework.pl @ARGV);

	my $result = qx($command);
	my $current = (split(/\n/, $result))[-1];
	print "I have now <$current> and min <$min> \n";
	$min = $current if $min > $current;
	print $_/$number * 100 , "%","\n";
}

print ucfirst "finnaly, I have min <$min>\n";


