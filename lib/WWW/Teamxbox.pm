package WWW::Teamxbox;

use strict;
# use warnings;
use HTML::TokeParser;
use LWP::UserAgent;
use HTTP::Request;
use URI::URL;


require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use WWW::GameStar ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	HtmlLinkExtractor
	getNews
	Get
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	HtmlLinkExtractor
	getNews
	Get
);

our $VERSION 	= '1.0';
my $Url		= "http://www.teamxbox.com/";
my $Regex	= "\/xbox\/";

######
my $MaxFileSizeOfWebDocument	= (50 * 1024 * 1024);	# 5mb
my $MaxRedirectRequests		= 15;
my $AuthorEmail			= 'yourname@cpan.org';
my $Timeout			= 25;
my $CrawlDelay			= int(rand(3));
my $Referer			= "http://www.google.com/";
my $DEBUG			= 1;
######


sub new(){

	my $class   	= shift;
	my %args 	= ref($_[0])?%{$_[0]}:@_;
	my $self 	= \%args;
	bless $self, $class;
	$self->_init();
	return $self;
		
}; # sub new(){


sub _init(){

	my $self 	= shift;
	my $HashRef 	= $self->Get($Url);	
	my $ArrRef	= $self->HtmlLinkExtractor($HashRef);
	
	$self->{'_CONTENT_ARRAY_REF'} = $ArrRef;
	return $self;

}; # sub _init(){


sub getNews(){

	my $self 		= shift;
	my $ArrRef 		= $self->{'_CONTENT_ARRAY_REF'};
	my %NoDoubleLinks	= {};
	my %ReturnLinks		= {};

	foreach my $entry ( @{$ArrRef} ){

		my ($linkname, $url) = split(' ### ', $entry );
		if ( !exists $NoDoubleLinks{$url} ) {
			$ReturnLinks{$url} = $linkname;	
			$NoDoubleLinks{$url} = 0;
		};
	}; # foreach my $entry ( @{$ArrRef} ){
	
	return \%ReturnLinks;

}; # sub getNews(){


# Preloaded methods go here.

sub HtmlLinkExtractor(){

	my $self			= shift;
	my $HashRef			= shift;
	my $ResponseObj			= $HashRef->{'OBJ'};
	my $PageContent			= $HashRef->{'CNT'};
	
	my @ReturnLinks			= ();
	
	return -1 if ( ref($ResponseObj) ne "HTTP::Response" );

	my $base			= $ResponseObj->base;
	my $TokenParser		= HTML::TokeParser->new( \$PageContent );

	while ( my $token	= $TokenParser->get_tag("a")) {

		my $url		= $token->[1]{href};
		my $linktitle	= $token->[1]{title};
		my $rel		= $token->[1]{rel};
		my $text	= $TokenParser->get_trimmed_text("/a");	# $text = Linktitle
		$url		= url($url, $base)->abs;	# enth�lt die aktuell zu bearbeitende url
	
		chomp($url); chomp($text); 
		push(@ReturnLinks, "$text ### $url") if ( $url =~ /^(http)/i && $url =~ /$Regex/ig );
	
	}; # while ( my $token = $TokenParser->get_tag("a")) {

	return \@ReturnLinks;

}; # sub HtmlLinkExtractor(){


sub Get() {
	
	my $self	= shift;
	my $url		= shift;
	my $referer	= shift || $url;
	
	my $StatusHashRef = {};

	my $UA		= LWP::UserAgent->new( keep_alive => 1 );
	
		$UA->agent("Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; YPC 3.0.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)");
	#	$UA->agent("wget");
		$UA->timeout( $Timeout );
		$UA->max_size( $MaxFileSizeOfWebDocument );
		$UA->from( $AuthorEmail );
		$UA->max_redirect( $MaxRedirectRequests );
		$UA->parse_head( 1 );
		$UA->protocols_allowed( [ 'http', 'https', 'ftp', 'ed2k'] );
		$UA->protocols_forbidden( [ 'file', 'mailto'] );
		$UA->requests_redirectable( [ 'HEAD', 'GET', 'POST'] );

		#	$ua->credentials( $netloc, $realm, $uname, $pass )
		#	$ua->proxy(['http', 'ftp'], 'http://proxy.sn.no:8001/');	# f�r protokollschema http und ftp benutze proxy ...
		# $ua->env_proxy ->  wais_proxy=http://proxy.my.place/ -> export gopher_proxy wais_proxy no_proxy
  
	# sleep $CrawlDelay;

	my $req = HTTP::Request->new( GET => $url );
	$req->referer($referer);

	my $res = $UA->request($req);

	if ( $res->is_success ) {

		$StatusHashRef->{ 'OBJ' } = $res; 
		$StatusHashRef->{ 'CNT' } = $res->content; 
	
  	}; # if ($res->is_success) {

	return $StatusHashRef;

}; # sub GET() {


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

WWW::Teamxbox - Perl extension for getting news http://www.teamxbox.com/

=head1 SYNOPSIS

use WWW::Teamxbox;
my $obj           =  WWW::Teamxbox->new();
my $ResultHashRef = $obj->getNews();

while ( my ($url,$name)=each(%{$ResultHashRef})){

	print "$name => $url\n";

};
  

=head1 DESCRIPTION

WWW::Teamxbox - Perl extension for getting news from http://www.teamxbox.com/


=head2 EXPORT
	
	HtmlLinkExtractor - extraction of links from html document
	getNews - getting news
	Get - http get method

=head2 DEPENDENCIE

use HTML::TokeParser;
use LWP::UserAgent;
use HTTP::Request;
use URI::URL;
use strict;

=head1 SEE ALSO

http://www.zoozle.net
http://www.zoozle.org
http://www.zoozle.biz

NET::IPFilterSimple
NET::IPFilter
WWW::CpanRecent
WWW::Heise
WWW::GameStar
WWW::Popurls
WWW::Golem
WWW::Futurezone
WWW::Teamxbox

=head1 AUTHOR

Sebastian Enger, bigfish82 |ät! gmail?com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Sebastian Enger

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
