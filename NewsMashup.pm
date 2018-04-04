#!"C:\xampp\perl\bin\perl5.16.3.exe"
package Mashup;
$BEFORE = 1;
$AFTER = 0;
$EXCL = 1;
$INCL = 0;
sub trim_trailing_whitespaces {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

sub split_string {
    my ($string,$marker,$desired,$type) = (shift,lc(shift),shift,shift);
    my $lc_str = lc($string);
    my $split_here,$parsed_string;
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

sub return_between {
    my ($string,$start,$stop,$type) = (shift,shift,shift,shift);
    my $temp = split_string($string,$start,$AFTER,$type);
    return $split_string($temp,$stop,$BEFORE,$type);
}
