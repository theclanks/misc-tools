#!/usr/bin/perl

use strict;
use Socket;

my $sin;

socket(SOCK,PF_INET,SOCK_STREAM,getprotobyname('tcp'));
$sin = sockaddr_in($ARGV[1], inet_aton("$ARGV[0]"));

if( connect(SOCK,$sin) ) { 
    close(SOCK);
    print "OK \n";
    #exit 0;
} else {
   print "OFF \n"; 
   # exit -1;
}
