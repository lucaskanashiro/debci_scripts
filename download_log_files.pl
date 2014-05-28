#!/usr/bin/perl

use strict;
use warnings;
use Encode;
use WWW::Mechanize;

my $url = 'http://ci.debian.net/data/unstable-amd64/packages/';

my $finder = WWW::Mechanize->new();

my $totalFails=0;
my $totalTmpFails=0;

$finder->get($url);

my @full_content = split("\n", $finder->content);
my @prefix;

foreach (@full_content){
	if ($_ =~ m/<a href="([^"]+)"/){
		push(@prefix, $1);
	}
}

shift @prefix;

foreach (@prefix){
	my $url_prefix = $url . $_;

	$finder->get($url_prefix);

	my @all_packages = split("\n", $finder->content);
	my @packages;

	foreach (@all_packages){
		if ($_ =~ m/<a href="([^"]+)"/){
			push(@packages, $1);
		}
	}

	shift @packages;

	my $contFail=0;
	my $contTmpFail=0;

	foreach (@packages){
		print ".";
		
		my $url_package = $url_prefix . $_;

		$finder->get($url_package);

		my @package_html = split("\n", $finder->content);
		my @package_file;

		foreach (@package_html){
			if($_ =~ m/<a href="([^"]+)"/){
				push(@package_file, $1);
			}
		}
		
		my @reversed_package_file = reverse(@package_file);
		my $name_autopkg_log="";

		foreach (@reversed_package_file){
			if($_ =~ m/autopkgtest.log/){
				$name_autopkg_log = $_;
				last;
			}
		}

		my $url_autopkg_log_file = $url_package . $name_autopkg_log;

		if($finder->content =~ m/latest.log/){
			my $url_log = $url_package . "latest.log";

			$finder->get($url_log);

			if ($finder->content =~ m/Status: ([^(]+)/g){
				if($1 eq "fail "){
					$contFail = $contFail+1;
					$_ =~ s/\///;
					$_ =~ s/%2b/+/;
					my $filename = $_ . "-fail.log";
					$finder->save_content($filename, binmode => ':raw', decoded_by_headers => 1);

					$finder->get($url_autopkg_log_file);
					$filename = $_ . "-autopkg-fail.log";
					$finder->save_content($filename, binmode => ':raw', decoded_by_headers => 1);

				}elsif($1 eq "tmpfail "){
					$contTmpFail = $contTmpFail+1;
					$_ =~ s/\///;
					$_ =~ s/%2b/+/;
					my $filename = $_ . "-tmpfail.log";
					$finder->save_content($filename, binmode => ':raw', decoded_by_headers => 1);

					$finder->get($url_autopkg_log_file);
					$filename = $_ . "-autopkg-tmpfail.log";
					$finder->save_content($filename, binmode => ':raw', decoded_by_headers => 1);
				}
			}
		}

	}

	$totalFails = $totalFails + $contFail;
	$totalTmpFails = $totalTmpFails + $contTmpFail;
}

print "\n\nFAIL: " . $totalFails . "\n";
print "TMPFAIL: " . $totalTmpFails . "\n";

