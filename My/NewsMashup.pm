#!/usr/bin/perl5.22.1
package My::NewsMashup;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(split_string return_between get_attribute parse_array remove_tags $BEFORE $AFTER $EXCL $INCL);

#variables used in split_string to print the content of a string before or after a deliminator, or
#to include/exclude deliminators.
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

#returns a tag's given attribute
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

1;