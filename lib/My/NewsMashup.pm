#!/usr/bin/perl5.22.1
package My::NewsMashup;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(rt toi hacker_news mumbai_mirror wsj verge);

#variables used in split_string to print the content of a string before or after a deliminator, or
#to include/exclude deliminators.
my $BEFORE = 1;
my $AFTER = 0;
my $EXCL = 1;
my $INCL = 0;
# my %hacker_news_links = ();
# my %mumbai_mirror_links = ();
# my %toi_links = ();
# my %rt_links = ();

# PARAMS: $string: the string to split, $marker: the marker (string) at which to split $string, $desired: 1 and 0 for before and after the marker respectively, $type: 1 and 0 for excluding and including the marker in the split string
# DESCRIPTION: returns a string before or after a delineator
# RETURNS : substring before or after the marker
sub split_string {
    my ($string,$marker,$desired,$type) = (shift,lc(shift),shift,shift);
    my $lc_str = lc($string);
    my ($split_here,$parsed_string);
    if ($desired == $BEFORE) {
            $split_here = index($lc_str,$marker) if ($type == $EXCL);
            $split_here = index($lc_str,$marker)+length($marker) if ($type == $INCL);
        $parsed_string = substr($string,0,$split_here);
    }
    else {
            $split_here = index($lc_str,$marker) + length($marker) if ($type == $EXCL);
            $split_here = index($lc_str,$marker) if ($type == $INCL);
        $parsed_string = substr($string,$split_here,length($string));
    }
    return $parsed_string;
}

#PARAMS : $string, $start: starting deliminator, $stop: ending deliminator, $type: 1 for including and 0 for excluding deliminators
#DESCRIPTION: returns a substring between two delineators
#RETURNS : the subtring between $start and $stop in $string
sub return_between {
    my ($string,$start,$stop,$type) = (shift,shift,shift,shift);
    my $temp = split_string($string,$start,$AFTER,$type);
    return &split_string($temp,$stop,$BEFORE,$type);
}

#PARAMS : 
#DESCRIPTION : returns a tag's given attribute
sub get_attribute {
    my ($tag,$attribute) = @_;
    if ($tag =~ m/$attribute(.*?)=(.*?)\"(.*?)\"/) {
        return $3;
    }
}

#returns an array of all strings that start and end with 2 given tags
sub parse_array {
    my ($string,$beg_tag,$end_tag) = @_;
    my @array = ($string =~ m/($beg_tag.+?$end_tag)/sig);
    return @array;
}

#Removes all content between all tags $beg_tag and $end_tag
sub remove_tags {
    my ($string,$beg_tag,$end_tag) = @_;
    $string =~ s/\R//g;
    my @remove_array = parse_array($string,$beg_tag,$end_tag);
    foreach my $remove (@remove_array) {
        $string =~ s/\Q$remove//ig;
    }
    return $string;
}

sub mumbai_mirror {
    my $target = "https://mumbaimirror.indiatimes.com";
    my $mumbai_mirror = `curl $target`;
    $mumbai_mirror =~ s/\R//g;
    my %mumbai_mirror_links = ();
    if ($mumbai_mirror =~ m/<(.*)>top stories<\/(.*)/i) {
        my $top_stories = return_between($mumbai_mirror,"top stories","<\/ul>",$INCL);
        my @links = parse_array($top_stories,"<a","<\/a>");
        foreach my $link (@links) {
            my $title = get_attribute($link,"title");
            my $href = $target.get_attribute($link,"href");
            $mumbai_mirror_links{$title} = $href;
        }
    }
    return %mumbai_mirror_links;
}

sub rt {
    my $target = "https://www.rt.com";
    my $rt = `curl $target`;
    $rt =~ s/\R//g;
    my @rt_divs = parse_array($rt,"<div","</div>");
    my %rt_links = ();
    for my $div (@rt_divs) {
        if ($div =~ m/(.*?)class="main-promobox(.*?)heading(.*)"/) {
            my $link = return_between($div,"<a","</a>",$INCL);
            my $title = return_between($link,">","</a>",$EXCL);
            $title =~ s/^\s+|\s+$|\s+(?=\s)//g;
            my $href = $target.get_attribute($link,"href");
            $rt_links{$title} = $href;
        }        
    }
    return %rt_links;
}

sub toi {
    my $target = "https://timesofindia.indiatimes.com";
    my $toi = `curl -A "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" $target`;
    my %toi_links = ();
    if ($toi =~ m/top news stories/i) {
        $toi = remove_tags($toi,"<script","<\/script>");
        my $top_stories = return_between($toi,"top news stories","<\/ul>",$INCL);
        my @links = parse_array($top_stories,"<a",">");
        foreach my $link (@links) {
            my $title = get_attribute($link,"title");
            my $href = $target.get_attribute($link,"href");
            $toi_links{$title} = $href;
        }
    }   
    return %toi_links;
}

sub hacker_news {
    my $target = "https://news.ycombinator.com/";
    my $hackernews = `curl $target`;
    $hackernews =~ s/\R//g;
    my %hacker_news_links = ();
    my @hacker_links = parse_array($hackernews,"<a","</a>");
    foreach my $link (@hacker_links) {
        if (get_attribute($link,"class") =~ m/(.*)storylink(.*)/i) {
            my $title = return_between($link,">","</a>",$EXCL);
            my $href = get_attribute($link,"href");
            $hacker_news_links{$title} = $href;
        }        
    }
    return %hacker_news_links;
}

sub wsj {
    my $target = "https://www.wsj.com/india";
    my $wsj = `curl $target`;
    $wsj = remove_tags($wsj,"<script","</script>");
    my %wsj_links = ();
    #print $wsj;
    my @alinks = parse_array($wsj,"<a class=\"wsj-headline-link\"","</a>");
    foreach my $a (@alinks) {
        my $href = get_attribute($a,"href");
        my $title = return_between($a,">","</a>",$EXCL);
        $wsj_links{$title} = $href;
    }    
    return %wsj_links;
}

sub verge {
    my $target = "https://www.theverge.com";
    my $verge = `curl $target`;
    my %verge_links = ();
    $verge = remove_tags($verge,"<script","</script>");
    my @h2 = parse_array($verge,"<h2 class=\"c-entry-box--compact__title","</h2>");
    foreach my $h (@h2) {
        my $link = return_between($h,"<a","</a>",$INCL);
        my $title = return_between($link,">","</a>",$EXCL);
        my $href = get_attribute($link,"href");
        $verge_links{$title} = $href;
    }
    return %verge_links;
}

1;