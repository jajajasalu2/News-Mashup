#!/usr/bin/perl5.22.1
package My::PullNews;
use strict;
use warnings;
use Exporter qw(import);
use NewsMashup qw(parse_array return_between get_attribute $BEFORE $AFTER $INCL $EXCL);
our @EXPORT_OK = qw(rt toi mumbai_mirror hacker_news);
my @hacker_news_links = ();
my @mumbai_mirror_links = ();
my @toi_links = ();
my @rt_links = ();

sub mumbai_mirror {
    my $target = "https://mumbaimirror.indiatimes.com";
    my $mumbai_mirror = `curl $target`;
    $mumbai_mirror =~ s/\R//g;
    @mumbai_mirror_links = ();
    if ($mumbai_mirror =~ m/<(.*)>top stories<\/(.*)/i) {
        my $top_stories = My::NewsMashup::return_between($mumbai_mirror,"top stories","<\/ul>",0);
        my @links = My::NewsMashup::parse_array($top_stories,"<a","<\/a>");
        foreach my $link (@links) {
            my $title = My::NewsMashup::get_attribute($link,"title");
            my $href = $target.My::NewsMashup::get_attribute($link,"href");
            push(@mumbai_mirror_links,$href,$title);
        }
    }
    return @mumbai_mirror_links;
}

sub rt {
    my $target = "https://www.rt.com";
    my $rt = `curl $target`;
    $rt =~ s/\R//g;
    my @rt_divs = My::NewsMashup::parse_array($rt,"<div","</div>");
    @rt_links = ();
    for my $div (@rt_divs) {
        if ($div =~ m/(.*?)class="main-promobox(.*?)heading(.*)"/) {
            my $link = My::NewsMashup::return_between($div,"<a","</a>",0);
            my $title = My::NewsMashup::return_between($link,">","</a>",1);
            $title =~ s/^\s+|\s+$|\s+(?=\s)//g;
            my $href = $target.My::NewsMashup::get_attribute($link,"href");
            print $title,"\t",$href,"\n";
            push(@rt_links,$href,$title);
        }        
    }
    return @rt_links;
}

sub toi {
    my $target = "https://timesofindia.indiatimes.com";
    my $toi = `curl -A "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" $target`;
    @toi_links = ();
    if ($toi =~ m/top news stories/i) {
        $toi = My::NewsMashup::remove_tags($toi,"<script","<\/script>");
        my $top_stories = My::NewsMashup::return_between($toi,"top news stories","<\/ul>",0);
        my @links = My::NewsMashup::parse_array($top_stories,"<a",">");
        foreach my $link (@links) {
            my $title = My::NewsMashup::get_attribute($link,"title");
            my $href = $target.My::NewsMashup::get_attribute($link,"href");
            push(@toi_links,$href,$title);
        }
    }   
    return @toi_links;
}

sub hacker_news {
    my $target = "https://news.ycombinator.com/";
    my $hackernews = `curl $target`;
    $hackernews =~ s/\R//g;
    @hacker_news_links = ();
    my @hacker_links = My::NewsMashup::parse_array($hackernews,"<a","</a>");
    foreach my $link (@hacker_links) {
        if (My::NewsMashup::get_attribute($link,"class") =~ m/(.*)storylink(.*)/i) {
            my $title = My::NewsMashup::return_between($link,">","</a>",1);
            my $href = My::NewsMashup::get_attribute($link,"href");
            push(@hacker_news_links,$href,$title);
        }        
    }
    return @hacker_news_links;
}

my @a = rt();
foreach my $a (@a) {
    print $a,"\n\n\n";
}