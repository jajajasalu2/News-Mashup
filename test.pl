#!"C:\xampp\perl\bin\perl5.16.3.exe"

$string = "the time is: 12:31:02 on 4/12/00";
$colon = ":";
$string =~ s/$colon//g;
print $string;