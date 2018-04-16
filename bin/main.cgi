#!/usr/bin/perl5.22.1
use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';
use My::NewsMashup qw(rt toi hacker_news mumbai_mirror wsj);
use CGI qw/:standard/;

sub print_links {
    my %links = @_;
    while (my ($title,$href) = each %links) {
        print qq{<div class="row">
        <a href=$href>$title</a>
        </div>};
    }
}

sub print_news {
    # my %rt = rt();
    # my %toi = toi();
    # my %mumbai_mirror = mumbai_mirror();
    # my %hacker_news = hacker_news();
    print qq{Content-type:text/html

<html>
<head>
<title>NewsMashup</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css" integrity="sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4" crossorigin="anonymous">
</head>
<body>
<header>
    <nav class="navbar navbar-expand-md navbar-dark fixed-top bg-dark">
        <a class="navbar-brand" href="#">Nooz</a>
    </nav>
</header>
<main role="main" class="container" style="margin-top: 100px;">
    <div class="row">
         <div class="col-md-4">
            <div class="container">
                <h3><a href="https://rt.com">Russia Today</a></h3>};
            print_links(rt());
            print qq{
            </div>
        </div>
        <div class="col-md-4">
            <div class="container">
                <h3><a href="https://timesofindia.indiatimes.com">Times of India</a></h3>};
            print_links(toi());
            print qq{
            </div>
        </div>
        <div class="col-md-4">
            <div class="container">
                <h3><a href="https://mumbaimirror.indiatimes.com">Mumbai Mirror</a></h3>};
            print_links(mumbai_mirror());
            print qq{
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-4">
            <div class="container">
            <h3>HackerNews</h3>};
        print_links(hacker_news());
        print qq{
            </div>
        </div>
        <div class="col-md-4">
            <div class="container">
            <h3>Wall Street Journal</h3>};
        print_links(wsj());
        print qq{
            </div>
        </div>
    </div>
</main>
</body>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js" integrity="sha384-cs/chFZiN24E4KMATLdqdvsezGxaGsi4hLGOzlXwp5UZB1LY//20VyM2taTB4QvJ" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js" integrity="sha384-uefMccjFJAIv6A+rW+L4AHf99KvxDjWSu1z9VI8SKNVmz4sk7buKt/6v9KI65qnm" crossorigin="anonymous"></script>  
</html>};
}

print_news();
