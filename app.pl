use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use JSON;

my $url = 'https://swapi-graphql.netlify.app/graphql'; # GraphQL endpoint

#GraphQL query
my $query = '{
  allFilms {
    films {
      title
      director
      releaseDate
    }
  }
}';

#Set up HTTP client
my $ua = LWP::UserAgent->new;
$ua->agent("StarWarsExplorer/1.0");

#Build request
my $req = HTTP::Request->new(POST => $url);
$req->header('Content-Type' => 'application/json');
$req->content(encode_json({ query => $query }));

#Send request
my $res = $ua->request($req);
die "Failed to fetch data: " . $res->status_line unless $res->is_success;

#Parse response
my $data = decode_json($res->decoded_content);
my @films = @{ $data->{data}->{allFilms}->{films} };

#Ask user for a search term
print "Enter a keyword to search for Star Wars films: ";
chomp(my $search = <STDIN>);
$search = lc($search);  # lowercase for case-insensitive match

#Filter matching films
my @matches = grep {
    index(lc($_->{title}), $search) >= 0
} @films;

#Show results
if (@matches) {
    print "\nFound " . scalar(@matches) . " matching film(s):\n";
    foreach my $film (@matches) {
        print "-------------------------\n";
        print "Title   : $film->{title}\n";
        print "Director: $film->{director}\n";
        print "Released: $film->{releaseDate}\n";
    }
    print "-------------------------\n";
} else {
    print "\nNo matching films found.\n";
}

#Theoretical Post request to log query and results to a server
sub log_search_to_server {
    my ($query, $results_ref) = @_;
    my $endpoint = 'https://example.com/api/log';

    my $ua = LWP::UserAgent->new;
    $ua->agent("StarWarsExplorer/1.0");

    # Prepare data to send
    my $payload = {
        query   => $query,
        results => [ map { $_->{title} } @$results_ref ],
        timestamp => time,
    };

    # Create HTTP request
    my $req = HTTP::Request->new(POST => $endpoint);
    $req->header('Content-Type' => 'application/json');
    $req->content(encode_json($payload));

    # Send request
    my $res = $ua->request($req);

    if ($res->is_success) {
        print "Search log sent successfully.\n";
    } else {
        warn "Failed to send search log: " . $res->status_line . "\n";
    }
}
