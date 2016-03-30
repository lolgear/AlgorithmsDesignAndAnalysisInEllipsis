my $number = 2000;

my $min = 10000;
my $current;
for (0..$number){
	($current = qx(perl homework.pl)) =~ s/I have crossing edges count is: (\d+)\s+/$1/;
	print "I have now <$current> and min <$min> \n";
	$min = $current if $min>$current;
	print $_/$number, "%","\n";
}

print uc "finnaly, I have <$min>\n";


