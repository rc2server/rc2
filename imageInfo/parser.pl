#!/usr/bin/env perl

use strict;
use LWP::Simple;
use Cpanel::JSON::XS qw(decode_json encode_json);
use Digest::SHA qw(sha256_hex);
use Getopt::Long;
use Date::Format;
use DateTime::Format::RFC3339 qw();

#the following changes all http handling to be performed over unix domain sockets
use LWP::Protocol::http::SocketUnixAlt;
LWP::Protocol::implementor( http => 'LWP::Protocol::http::SocketUnixAlt' );

my $baseUrl = "http:/var/run/docker.sock/";

my $dbver, my $appver, my $compver;
GetOptions(	#"dbserver=s" => \$dbver, 
#			"appserver=s" => \$appver,
			"combined=s" => \$compver);

#($dbver && $appver && $compver) || die "must supply -d -a -c with versions";
($compver) || die "must supply -c with version";

my $text = get("$baseUrl/images/json");
my $ilist = decode_json $text;

my %layerMap = ();
my %images = ();
foreach my $anImage (@$ilist) {
	my $tag = $$anImage{'RepoTags'}[0];
	if ($tag =~ m#^rc2server/(\w+):([.0-9]+)#) {
		my $name = $1;
		my $version = $2;
		my $id = $$anImage{'Id'};
		my $size = $$anImage{'Size'};
		my $tag = "rc2server/$name:$version";
		my %obj = (
			'name' => $name,
			'version' => $version,
			'id' => $id,
			'size' => $size,
			'tag' => $tag,
			'layers' => getLayers($tag),
		);
#		$obj{'total'} = addSizes(\%obj);
		$images{$tag} = \%obj;
	}
}

#my $dbserver = $images{"rc2server/dbserver:$dbver"} || die "dbserver:$dbver not found";
#my $appserver = $images{"rc2server/appserver:$appver"} || die "appserver:$appver not found";
my $compute = $images{"rc2server/combined:$compver"} || die "combined:$compver not found";

my %layers = ();
my $appskip = 0;
my $compskip = 0;
#store all layers from dbserver
my $layerArray = $$compute{'layers'};
for my $aLayer (@$layerArray) {
	my $hash = &digestLayer($aLayer);
	$layers{$hash} = 1;
}
$$compute{'estSize'} = $$compute{'size'};

delete $$compute{'layers'};
my %finalImages = ( 'combined' => $compute);

#my $version = time2str("%Y%m%d01", time);
my $dtFormatter = DateTime::Format::RFC3339->new();
my $datestamp = $dtFormatter->format_datetime(DateTime->now);

my %wrapper = ( 'version' => 2, 'lastCompatibleVersion' => 2, 'timestamp' => $datestamp, 'images' => \%finalImages );
print encode_json(\%wrapper) . "\n";


sub addSizes {
	my ($array) = @_;
	my $total = 0;
	for my $sz ($array) {
		$total += $$sz{'size'};
	}
	return $total;
}

sub getLayers {
	my ($name) = @_;
	my $url = "$baseUrl/images/$name/history";
	my $text = get($url);
	my $json = decode_json $text;
	my @layers;
	foreach my $entry (@$json) {
		my $id = $$entry{'Id'};
		my %hash = (
			'id' => $id,
			'size' => $$entry{'Size'},
			'createdBy' => $$entry{'CreatedBy'},
			'created' => $$entry{'Created'}
		);
		$hash{'checksum'} = &digestLayer(\%hash);
		if ($hash{'size'} > 0) {
			push(@layers, \%hash);
			$layerMap{$id} = 1 + int($layerMap{$id});
		}
	}
	return \@layers;
}

sub digestLayer {
	my ($layer) = @_;
	unless (ref $layer eq "HASH") {
		die "bad type";
	}
	my $cby = $$layer{'createdBy'};
	my $cb = $$layer{'created'};
	my $sz = int($$layer{'size'});
	$cby && $cb && defined $sz || die "invalid layer";
	my $val = join("/;/", $cby, $cb, $sz);
	return sha256_hex($val);
}
