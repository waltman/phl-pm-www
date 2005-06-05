#!/usr/bin/perl

# Perl Mongers Calendar
# Robert Spier <rspier@seas.upenn.edu>
# Revision Log at end
# date\twhat

use Time::Local;
use strict;

my %events;
my $homedir = "/home/groupleaders/philly/";
my $eventfile = "$homedir/bin/events.dat";
my $upcoming_near = "$homedir/www_docs/comingsoon.html";
my $upcoming_far = "$homedir/www_docs/cominglater.html";

my @months = qw{Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec};
my @days   = qw{Sun Mon Tue Wed Thu Fri Sat};
sub one_day () { 60*60*24; }

open(IN,"<$eventfile") ||
  die "can't open $eventfile $!\n";

my $today = timelocal( 0,0,0,  (localtime())[3..5] );

my $prev;

while(<IN>) {
  my ($year,$month,$day,$what);

  chomp;
  next if /^\#/;		# skip comments
  next if /^-/;		        # skip other things
  next if /^\s*$/;              # blank lines

  if  (/^\s+(.*)/) {
      $events{$prev} .= "<BR>\n\t" . $1 if length($prev);
    next;
  }

  die "invalid format in $_" unless
    ($year,$month,$day,$what) = /^(\d{4})(\d{2})(\d{2})\s*(.*)$/;

  my $time = timelocal(0,0,0,$day,$month-1,$year-1900);

  if ($time > ( time() - one_day() )) { # it's in the future
    $events{$time} = $what;
    $prev = $time;
  } else {
    undef $prev;
  }
}

close IN;

my @eventlist = sort {$a <=> $b} keys %events;



open(OUT,">$upcoming_near")
  || die "can't open [$upcoming_near] $!";

print OUT "No scheduled upcoming events.<BR>\n" unless @eventlist;

do { 
    print OUT "<table bgcolor=\"#EEEEEE\" WIDTH=\"100%\" CELLSPACING=0 BORDER=0 CELLPADDING=2>";
    foreach (@eventlist[0..1]) { # this will autoviv eventlist
	print OUT &formatevent( $_ ) if $_;
    }
    print OUT "</table>";
} if @eventlist;



close OUT;

open(OUT,">$upcoming_far")
  || die "can't open [$upcoming_far] $!";

print OUT<<EOF;
  <TITLE>phl.pm: Upcoming Events</TITLE>
  <H1>phl.pm: Upcoming Events</H1>
EOF
  ;

print OUT "No scheduled upcoming events.<BR>\n" unless @eventlist;

print OUT "<TABLE CELLSPACING=2 CELLPADDING=2 WIDTH=\"100%\">\n";
foreach (@eventlist) {
  print OUT  &formatevent( $_ )  if $_;
}
print OUT "</TABLE>\n";
close OUT;



sub formatevent {
  my $key = shift;

  my $data = $events{$key};

  my ($dy,$mo,$yr,$wday) = (localtime($key))[3..6];
  $yr += 1900;
  return "<TR><TD VALIGN=\"TOP\"><B>$days[$wday]&nbsp;$dy&nbsp;$months[$mo]&nbsp;$yr</B></TD><TD width=10>&nbsp;</TD><TD>$data<BR></TD></TR>";
}

# 19990806 - fixed bug where i was using localtime instead of time, so even expire iddn't work
# 19990816 - if the header for an event was in the past, the continuation lines weren't getting recognized as part of it, so the program was dying with an error.  All continuation lines are now parsed, but are only added to the hash if there is an active header.















