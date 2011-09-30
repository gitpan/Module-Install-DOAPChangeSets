package Module::Install::Admin::DOAPChangeSets;

use 5.008;
use base qw(Module::Install::Base);
use strict;

use RDF::DOAP::ChangeSets;
use RDF::Trine;
use File::Slurp qw(slurp);
use URI::file;
use Module::Install::Base;

our $VERSION = '0.103';

sub _make_dcs
{
	my ($self, $in, $fmt, $type) = @_;

	unless (defined $self->{_DOAPChangeSets})
	{
		my @files_to_try = qw[meta/changes.ttl Changes.ttl];
		while (!defined $in)
		{
			my $f = shift @files_to_try;
			$in = $f if -e $f;
		}
		die "meta/changes.ttl not found.\n" unless defined $in;
		
		my $inuri = URI::file->new_abs($in);
		
		if (defined $self->{_RDF})
		{
			$self->{_DOAPChangeSets} = RDF::DOAP::ChangeSets->new($inuri, $self->{_RDF});
		}
		else
		{
			my $data = slurp($in);
			$self->{_DOAPChangeSets} = RDF::DOAP::ChangeSets->new($inuri, undef, $type, $fmt);
		}
	}
	
	return $self->{_DOAPChangeSets};
}

sub write_doap_changes
{
	my $self = shift;
	my $in   = shift || undef;
	my $out  = shift || "Changes";
	my $fmt  = shift || "turtle";
	my $type = shift || "auto";

	_make_dcs($self, $in, $fmt, $type)->to_file($out);
}

sub write_doap_changes_xml
{
	my $self = shift;
	my $in   = shift || undef;
	my $out  = shift || "Changes.xml";
	my $fmt  = shift || "turtle";
	my $type = shift || "auto";
	
	my $changeset = _make_dcs($self, $in, $fmt, $type);
	my $rdfxml    = RDF::Trine::Serializer::RDFXML->new(namespaces => {
		dbug    => 'http://ontologi.es/doap-bugs#',
		dc      => 'http://purl.org/dc/terms/',
		dcs     => 'http://ontologi.es/doap-changeset#',
		doap    => 'http://usefulinc.com/ns/doap#',
		foaf    => 'http://xmlns.com/foaf/0.1/',
		rdfs    => 'http://www.w3.org/2000/01/rdf-schema#',
		});
	open my $fh, '>', $out;
	$rdfxml->serialize_model_to_file($fh, $changeset->{'model'});	
	close $fh;
}

1;
