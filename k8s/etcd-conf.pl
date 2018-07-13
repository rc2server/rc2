#!/usr/bin/env perl

# this script generates the etcd.service files for 3 ip addresses

use Path::Tiny qw( path);
use Getopt::Long;

my $template = path("etcd.service.template")->slurp_utf8 || die "failed to read template";

my $baseName = "cloud", my $ips = ("");
GetOptions(	"baseName=s" => \$baseName, 
			"ips=s" => \$ips);
($baseName) || die "name must be provided";
my @ipAddrs = split(/,/, $ips);
$#ipAddrs == 2 || die "must have 3 ip addresses";

for (my $i=0; $i < 3; $i++) {
	my $num = $i + 1; 
	my $name = "$baseName$num";
	print("$name\n---\n");
	my $string = $template;
	$string =~ s#<MYNAME>#$name#g;
	$string =~ s#<NAME1>#${baseName}1#g;
	$string =~ s#<NAME2>#${baseName}2#g;
	$string =~ s#<NAME3>#${baseName}3#g;
	$string =~ s#<MYIP>#$ipAddrs[$i]#g;
	$string =~ s#<IP1>#$ipAddrs[0]#g;
	$string =~ s#<IP2>#$ipAddrs[1]#g;
	$string =~ s#<IP3>#$ipAddrs[2]#g;
	print($string);
	print "\n";
}
