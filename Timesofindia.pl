#!"C:\xampp\perl\bin\perl5.16.3.exe"
package Mashup;
use strict;

my $toi_main = `curl https://timesofindia.indiatimes.com`;
my $top_news_stories;
$toi_main =~ s/\R//g;
if ($toi_main =~ m/<(.*)>TOP NEWS STORIES<\/(.*)><ul(.*)<\/ul>/) {
    
    # my @links = ($3 =~ m/<a(.*)href=(.*)>/);
    # print $links[0];
    # print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n2";
}
