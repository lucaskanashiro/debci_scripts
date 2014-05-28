#!/usr/bin/perl

use strict;
use warnings;
use List::MoreUtils qw(uniq);

my $directory = $ARGV[0];

opendir(DIR, $directory) or die $!;

my @log_files;
my $count=0;

while(my $file = readdir(DIR)){
	if($file =~ m/autopkg-(fail|tmpfail).log/){
		push(@log_files, $file);
		$count++;
	}
}

close(DIR);

my @all_permission_error;

foreach my $file (@log_files){
	my $log_file_path = $directory . $file;

	open(FILE, "<" . $log_file_path) or die $!;

	while(<FILE>){
		if ($_ =~ m/Permission denied/){
			push(@all_permission_error, $file);
		}
	}

	close(FILE);
}

my @permission_error = uniq @all_permission_error;

open(OUTPUT, ">package_error.txt") or die $!;

print OUTPUT "Permission error:\n\n";

foreach (@permission_error){
	print OUTPUT $_ . "\n";
}

close(OUTPUT);

print "Number of permission errors: " . scalar(@permission_error) . "\n";
print "Number of files: " . $count . "\n";

