#!/usr/bin/env perl

use strict;
use LWP::Simple;
use Cpanel::JSON::XS qw(decode_json encode_json);
use Digest::SHA qw(sha256_hex);
use Getopt::Long;
use Date::Format;

#the following changes all http handling to be performed over unix domain sockets
use LWP::Protocol::http::SocketUnixAlt;
LWP::Protocol::implementor( http => 'LWP::Protocol::http::SocketUnixAlt' );

my $baseUrl = "http:/var/run/docker.sock/";

my $dbver, my $appver, my $compver;
GetOptions(	"dbserver=s" => \$dbver, 
			"appserver=s" => \$appver,
			"compute=s" => \$compver);

($dbver && $appver && $compver) || die "must supply -d -a -c with versions";

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

my $dbserver = $images{"rc2server/dbserver:$dbver"} || die "dbserver:$dbver not found";
my $appserver = $images{"rc2server/appserver:$appver"} || die "appserver:$appver not found";
my $compute = $images{"rc2server/compute:$compver"} || die "compute:$compver not found";

my %layers = ();
my $appskip = 0;
my $compskip = 0;
#store all layers from dbserver
my $layerArray = $$dbserver{'layers'};
for my $aLayer (@$layerArray) {
	my $hash = &digestLayer($aLayer);
	$layers{$hash} = 1;
}
$$dbserver{'estSize'} = $$dbserver{'size'};
#figure out what we can skip from $appserver
$layerArray = $$appserver{'layers'};
for my $applayer (@$layerArray) {
	my $hash = &digestLayer($applayer);
	my $val = $layers{$hash};
	if (defined $val && $val > 0) {
		$appskip += $$applayer{'size'};
	}
}
my $appremain = $$appserver{'size'} - $appskip;
print STDERR "skipping app: $appskip (remain $appremain)\n";
$$appserver{'estSize'} = $appremain;
#figure out which compute layers can be skipped
$layerArray = $$dbserver{'layers'};
for my $cLayer (@$layerArray) {
	my $hash = &digestLayer($cLayer);
	my $val = $layers{$hash};
	if ($val > 0) {
		$compskip += $$cLayer{'size'};
	}
}
my $compremain = $$compute{'size'} - $compskip;
$$compute{'estSize'} = $compremain;
print STDERR "skipping compute $compskip (remain: $compremain)\n";

delete $$appserver{'layers'};
delete $$dbserver{'layers'};
delete $$compute{'layers'};
my %finalImages = ( 'dbserver' => $dbserver, 'appserver' => $appserver, 'compute' => $compute);

my $version = time2str("%Y%m%d01", time);

my %wrapper = ( 'version' => $version, 'images' => \%finalImages );
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
