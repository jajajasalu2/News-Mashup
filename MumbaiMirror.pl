#!"C:\xampp\perl\bin\perl5.16.3.exe"
package Mashup;
use strict;
use warnings;
my $BEFORE = 1;
my $AFTER = 0;
my $EXCL = 1;
my $INCL = 0;

#returns a string before or after a delineator
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

#returns a substring between two delineators
sub return_between {
    my ($string,$start,$stop,$type) = (shift,shift,shift,shift);
    my $temp = split_string($string,$start,$AFTER,$type);
    return &split_string($temp,$stop,$BEFORE,$type);
}

sub get_attribute {
    my ($tag,$attribute) = @_;
    if ($tag =~ m/$attribute(.*)=(.*)\"(.*?)\"/) {
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

#prints an array
sub print_array {
    while(@_) {
        print "\n\n";
        print shift;
    }
}

my $target = "https://mumbaimirror.indiatimes.com";
my $mumbai_mirror = `curl $target`;
$mumbai_mirror =~ s/\R//g;
if ($mumbai_mirror =~ m/<(.*)>top stories<\/(.*)/i) {
    my $top_stories = return_between($mumbai_mirror,"top stories","<\/ul>",$INCL);
    my @links = parse_array($top_stories,"<a","<\/a>");
    my @mumbai_mirror_links = ();
    foreach my $link (@links) {
        my $title = get_attribute($link,"title");
        my $href = get_attribute($link,"href");
        push(@mumbai_mirror_links,$title,$href);
    }
    print_array(@mumbai_mirror_links);
}

$target = "https://timesofindia.indiatimes.com";
my $toi = `curl -A "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" $target`;
if ($toi =~ m/top news stories/i) {
    $toi = remove_tags($toi,"<script","<\/script>");
    my $top_stories = return_between($toi,"top news stories","<\/ul>",$INCL);
    my @links = parse_array($top_stories,"<a",">");
    my @toi_links = ();
    foreach my $link (@links) {
        my $title = return_between($link,"title=\"","\"",$EXCL);
        my $href = $target.return_between($link,"href=\"","\"",$EXCL);
        push(@toi_links,$title,$href);
    }
    print_array(@toi_links);
}

