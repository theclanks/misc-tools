#!/usr/bin/perl

#
#       This program is free software; you can redistribute it and/or
#       modify it under the terms of the GNU General Public License
#       as published by the Free Software Foundation; either version
#       2 of the License, or (at your option) any later version.
#
#       Authors : Stef Coene (stef.coene@docum.org)
#                 http://www.docum.org
#	          Bjarke Johannesen (bjarke@copyparty.dk)
#
# This is a rewritten version of Stef Coenens monitor_tc, into a program that
# displays traffic on the different classes on tc in a top program like fasion.
#
# Version 0.1 Tested and supports HTB
#
# At the top of the display uptime is showen.
#   Dev - Device name where the tc class is
#   Classid - is the class identifier name
#   Tokens - The tokens of the specific class
#   Ctokens - is the ctokens of the specific class
#   Rate - the send bytes pr. second that the class it self gives(htb)
#   Interval Speed - Is the bytes/sec messurement in this interval
#   Cumulated Send - Is the amount of data that has been send while this 
#                    program has been running.
#   Total Send - Is the total send amount sence the tc class have been started
#
#   The parent class is highlighted
#
#
# Input parameters:
#
# dev=eth3   for getting tc on device eth3
# dev="eth2" for a list of devices
#sleep=1000000  the sleeping period between sdreen updates.

use Time::HiRes qw(gettimeofday usleep);
$arg{sleep} = "3000000" ;	# milli seconds between readings (3 sec)
$arg{dev} = "eth0" ; #default devices to listen to
$tc = "/sbin/tc";

foreach my $arg (@ARGV) {
  @split = split ( "=", $arg) ;
  if ( $split[1] eq "" ) {
     print "Error : argument $arg ignored\n  Enter to continue ... " ;
     <STDIN>;
  }
  $arg{$split[0]} = $split[1] ;
}

#system ("rm /tmp/tc_monitor.log 2>/dev/null" ) ;

main () ;

sub main {
  $clear = `tput clear` ;
  $bold = `tput bold` ;
  $reverse = `tput rev` ;
  $attroff = `tput sgr0 `; 
  print $clear ;
  print $attroff;
  print "Updating...\n"; 

  my %acc_vorige = get_counters () ;
  #my %acc_start = %acc_vorige ;
  @start = gettimeofday () ;
  @old_time = gettimeofday () ;
  $time = 0 ;
format STDOUT =
@<<< @<<<<<<<< @<<<<<<<<@<<<<<< @<<<<<<<< @<<<<<<<<<< @<<<<<<<< @<<<<<<<<
$device $classid  $tokens  $ctokens $Sent  "$speed/s"  $cumsend $send
.

system ("tput cup 1 0");
print "                                          Interval    Cumulated Total\n";
print "Dev  Classid   Tokens   Ctokens Rate      Speed       Send      Send\n";
print "-------------------------------------------------------------------------\n";

while (1) {
	my %acc = get_counters () ;
	#making more precise messurement of data sent
	%acc_next = %acc ;

	@time = gettimeofday () ;

	my $diff_time = ( ($time[0]-$old_time[0]) + ($time[1]-$old_time[1])/1000000 );
	#my $diff_start = ( ($time[0]-$start[0]) + ($time[1]-$start[1])/1000000 );
	@old_time = @time ;

	#show bling bling
	system ("tput cup 0 0");
	system ("uptime");
	system ("tput cup 4 0");

	#open (FILE, ">>/tmp/tc_monitor.log" ) ;

	foreach $key (sort (keys(%acc))) {
		#skaerm output
		$device = $acc{$key}{dev};
		$classid = $key;
		$tokens = $acc{$key}{tokens} ;
		$ctokens = $acc{$key}{ctokens} ;
		$Sent{$key} = $acc{$key}{Sent} - $acc_vorige{$key}{Sent} ;
		$speed = $Sent{$key} / $diff_time ;
		$speed = conv ("$speed") ;
		$ocumsend{$key}+=$Sent{$key};
		$cumsend= conv ("$ocumsend{$key}");
		#$Sent = conv ("$Sent{$key}") ;
		$Sent = conv ( $acc{$key}{rate});
		$send= conv ("$acc{$key}{Sent}");
		#highlight the master classid
		if ($acc{$key}{master} == 1) {
			print $bold;
			write;
			print $attroff;
		} else {	
			write ;
		}
		#logfil output
		#print FILE "$diff_start " ;
		#print FILE "$acc{$key}{bytes} " ;
		#print FILE "$acc{$key}{packets} " ;
		#print FILE "$speed " ;
		#print FILE "$acc{$key}{tokens} " ;
		#print FILE "$acc{$key}{ctokens} " ;
		#print FILE "$acc{$key}{Sent} " ;

		#print FILE "\n" ;
	}
	%acc_vorige = %acc_next ;
	#print "\n" ;
	#close FILE ;
} }

sub get_counters {
	my %ACC ;
	my @class ; # Get all class info array
	my $first=0; #this is to find the master classid
	my @devices=split (" ",$arg{dev}); #all devices to get tc stats from
	my $ratect=0; # countring sub values of rate

	foreach my $devs (@devices) {
	$first=0;
        @class = `$tc -s -d class show dev $devs` ; 
	foreach my $ele (@class) {
		chomp ($ele) ;
		my @temp = split(" ",$ele) ;
		my $i = 0 ;
		foreach my $temp (@temp) {
			$i ++ ;
			if ( $temp eq "htb" ) { #set classid
				$classid = $temp[$i] ;	
				#master classid
				if ( $first == 0 ) {
					$ACC{$classid}{master}=1;
					$first=1;
				}
				else {
					$ACC{$classid}{master}=0;
				}
				#set device name
        			$ACC{$classid}{dev}=$devs;
				$ratect=0;
			} elsif ( $temp =~ /\d/ ) { # set value of key
				#print "classid $classid $name $temp\n" ;
				if ( $name eq "rate" ) { #find sub val of rate
					$ratect++;
					if ( $ratect == 1) {
						$ACC{$classid}{ratec} = $temp ;
					} elsif ( $ratect == 2 ) {
						$ACC{$classid}{rate} = $temp ;
					} elsif ( $ratect == 3 ) {
						$ACC{$classid}{ratep} = $temp ;
					} elsif ( $ratect == 4 ) {
						$ACC{$classid}{rateb} = $temp ;
						}
				} else {
					$ACC{$classid}{$name} = $temp ;
				}
			} else { # set key
				$temp =~ s/://g ;
				$temp =~ s/\(//g ;
				$name = $temp ;
			}
		}
	}
	}
	usleep ($arg{sleep}) ;
	return  %ACC ;
}

#convert to human readable numbers
sub conv {
  my $nr = $_[0] ;
  my @prefix = ( "","kB","MB","GB","TB","PB","EB","ZB","YB" );
  my $counter =0;
  my $ret;
  if ( $nr <= 1024 )
  {
	$ret=sprintf ("%.0fB",$nr) ;
  }
  else
  {
  	while ($nr > 1024)
  	{
		$counter++;
		$nr = $nr / 1024 ;
  	}
  	#printf "fixed nr = %.2f%s\n",$nr,$prefix[$counter]
  	$ret=sprintf ("%.2f%s",$nr,$prefix[$counter]) ;
  }
  return "$ret" ;
}
