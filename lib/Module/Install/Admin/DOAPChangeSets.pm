package Module::Install::Admin::DOAPChangeSets;

use 5.008;
use base qw(Module::Install::Base);
use strict;

use RDF::DOAP::ChangeSets;
use RDF::Trine;
use File::Slurp qw(slurp);
use URI::file;
use Module::Install::Base;

our $VERSION = '0.100';

sub write_doap_changes
{
	my $self = shift;
	my $in   = shift || "Changes.ttl";
	my $out  = shift || "Changes";
	my $fmt  = shift || "turtle";
	my $type = shift || "auto";

	my $data  = slurp($in);
	my $inuri = URI::file->new_abs($in);

	my $changeset = RDF::DOAP::ChangeSets->new($inuri, undef, $type, $fmt);
	$changeset->to_file($out);
}

sub write_doap_changes_xml
{
	my $self = shift;
	my $in   = shift || "Changes.ttl";
	my $out  = shift || "Changes.xml";
	my $fmt  = shift || "turtle";
	
	my $data  = slurp($in);
	my $inuri = URI::file->new_abs($in);
	
	my $changeset = RDF::DOAP::ChangeSets->new($inuri, undef, 'auto', $fmt);
	my $rdfxml    = RDF::Trine::Serializer::RDFXML->new(namespaces => {
		dbug    => 'http://ontologi.es/doap-bugs#',
		dc      => 'http://purl.org/dc/terms/',
		dcs     => 'http://ontologi.es/doap-changeset#',
		doap    => 'http://usefulinc.com/ns/doap#',
		foaf    => 'http://xmlns.com/foaf/0.1/',
		rdfs    => 'http://www.w3.org/2000/01/rdf-schema#',
		});
	open my $fh, ">$out";
	
	close $fh;
}

1;
