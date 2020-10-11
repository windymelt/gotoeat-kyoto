#perl
use strict;
use warnings;
use utf8;
use Encode qw(encode_utf8 decode_utf8);

use XML::XPath;
use XML::XPath::XMLParser;
use JSON::XS qw(encode_json);
use File::Slurp;
use Digest::SHA1  qw(sha1_hex);

my $buf;

if ($ARGV[0]) {
    local $/;
    $buf = read_file($ARGV[0]);
} else {
    local $/;
    $buf = <>;
}

my $xml     = XML::XPath->new($buf);
my $nodeset = $xml->find('/html/body/div[1]/form/main/div/div[2]/div/section/div[3]/div/div');

foreach my $nd ($nodeset->get_nodelist()) {
    my $hash = {};
    $hash->{name} = $xml->find('h3', $nd)->string_value();
    print(sprintf "processing %s\n", encode_utf8($hash->{name}));
    $hash->{category} = $xml->find('p[1]', $nd)->string_value();
    $hash->{address} = $xml->find('table/tbody/tr[1]/td', $nd)->string_value();
    $hash->{tel} = $xml->find('table/tbody/tr[2]/td', $nd)->string_value();
    my $uri = $xml->find('table/tbody/tr[3]/td', $nd)->string_value();
    chomp $uri;
    $uri =~ s/\s*(.+)\s*/$1/;
    $hash->{uri} = $uri;

    if ($uri ne '-' && $uri ne '') {
        my $description;
        if (! -e "html/pages/" . sha1_hex(encode_utf8 $uri)) {
            print(sprintf("downloading description from %s\n", encode_utf8($uri)));
            my $cmd0 = sprintf("curl --silent --max-time 1 -o html/pages/%s %s", sha1_hex($uri), $uri);
            my $code = system $cmd0;
            warn "curl failed" if $code;
        }
        my $cmd = sprintf("cat html/pages/%s | grep -e 'description'", sha1_hex($uri));
        $description = `$cmd`;
        $description =~ s!<meta name="description" content="(.+?)"/></meta>!$1!;
        $hash->{description} = decode_utf8 $description;
    }
    eval {
        my $file = $hash->{name};
        write_file("result/" . $file . ".json", encode_json($hash));
    };
}
