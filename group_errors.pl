#!/usr/bin/perl

use strict;
use warnings;

my $directory = $ARGV[0];

opendir(DIR, $directory) or die $!;

my @log_files;
my $count=0;

while(my $file = readdir(DIR)){

	if($file =~ m/autopkg-(fail|tmpfail).log/){
		push(@log_files, $file);
	}
}

print join "\n", @log_files;

close(DIR);

print "\n\nNumber of files: " . $count . "\n";

