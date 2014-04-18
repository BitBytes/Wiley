#!/usr/bin/perl

print <<EOTEXT;

	 __      __.__.__                
	/  \    /  \__|  |   ____ ___.__.
	\   \/\/   /  |  | _/ __ <   |  |
	 \        /|  |  |_\  ___/\___  |
	  \__/\  / |__|____/\___  > ____|
	       \/               \/\/     
		IRC Bot 1.1-Alpha
		Scripted by TT
		
Loading UP!

EOTEXT

use IO::Socket;
use feature qw/switch/;
use warnings;
use strict;

my $net      = "irc.server.net";		# Server
my $netport  = "6667";				# Port
my $nk       = "Wiley";				# Nick
my $nkalt    = "Coyote";			# AltNick
my $joinchan = "#Channel";			# Channel
my $userinfo = "RoadRunner Can Bite Me";	# Userinfo
my $cvers    = "Coyote IRC 1.1-alpha";		# Client version
my $DEBUG    = "1";                        	# 1 = LOGGING ON
my $trigger  = "%";				# Trigger
my $mode     = "8";  				# Set to 8 = invisible 0 = default server selection
my $fresp    = "Dont Point at me!";		# Finger reply
my $quitmsg  = "That dam roadrunner!";		# Quit msg			

my $con = new IO::Socket::INET(
    PeerAddr => $net,
    PeerPort => $netport,
    Proto    => 'tcp'
) or die "Something bad happened..\n";

$SIG{'INT'} = sub { print $con "QUIT : $quitmsg\r\n" };

print $con "NICK $nk\r\n";
print $con "USER $nk $mode * :$userinfo \r\n";

while ( my $indata = <$con> ) {
    if ( $indata =~ /004/ ) {
        last;
    }
    elsif ( $indata =~ /433/ ) {
        print $con "NICK $nkalt \r\n";
    }
}

print $con "JOIN $joinchan\r\n";

while ( my $indata = <$con> ) {
    my ($innick) = rplace(":", "", split( /\!/, $indata));
    my $inmsg = (split(':', $indata, 3))[2];
    my $chancmd = (split('\s', $inmsg))[0];
    my $xcd = (split('\s', $indata, 4))[2];

            if ( $indata =~ /^PING\s:/ ) {
                my @spr = split(":", $indata);
                my $srn = rplace("\n", "", $spr[1]);               # <--- TODO 
                my $return = "NOTICE " . $srn . "PONG :$spr[1]\r\n";
                print $con $return;
                DEBUG("$return");
            }

            if ($xcd =~ /^[$nk]/) {
    		DEBUG("PRIVMSG from $innick, : $inmsg");
   	    }	
	
            if ( $inmsg =~ /^\001/ ) {
                my $inct = (split("\001", $indata ))[1];
                CTCP($innick, $inct);
            }

            if ( $chancmd =~ /^$trigger/ ) {
                proc_trigger($innick, $chancmd);
                DEBUG("TRIGGER! Data :- $innick -:- $inmsg -:- $chancmd\r\n");
            }

            DEBUG("DEBUG INPUT - $indata\n");
}

sub rplace {
    my ( $a, $b, $c ) = @_;
    $c =~ s/$a/$b/ig;
    return $c;
}

sub DEBUG {
    if ( $DEBUG =~ /^[1]/ ) {
        my ($ddata) = @_;
        print $ddata;
        open( LOGFILE, '>> BOT.log' );
        print LOGFILE $ddata;
        close(LOGFILE);
    }
}

sub proc_trigger {
    my ( $nick, $cmd ) = @_;
    DEBUG( "TRIGGER KICKED with Nick of $nick Command of $cmd" );
    given (rplace($trigger, "", $cmd)) {
        when (/^uptime/) {
            print $con "PRIVMSG $joinchan :$nick My uptime is - " . `uptime` . " \r\n";
            DEBUG("PRIVMSG $joinchan :$nick My uptime is - " . `uptime` . " \r\n");
        }
        when (/^osv/) {
            print $con "PRIVMSG $joinchan :$nick Im Running - " . `uname -ms` . " \r\n";
            DEBUG("PRIVMSG $joinchan :$nick Im Running - " . `uname -ms` . " \r\n");
        }
        
        # Change and uncomment to activate      
        # when (/^osv/) {
        #    print $con "PRIVMSG $joinchan :$nick Im Running - " . `uname -ms` . " \r\n";
        #    DEBUG("PRIVMSG $joinchan :$nick Im Running - " . `uname -ms` . " \r\n");
        # }
        
        default {
            DEBUG("DEBUG Client - NOTICE $nick with actions.. such as $cmd \r\n");
        }
    }
}

sub CTCP {
    my ( $rnick, $act ) = @_;
    given ($act) {
        when (/^VERSION/) {
            print $con "NOTICE $rnick :\001VERSION $cvers \001 \r\n";
            DEBUG( "DEBUG Client - NOTICE $rnick :\001VERSION $cvers \001 \r\n" );
        }
        when (/^PING/) {
            my $utimetmp = `date +%s`;
            my $utime = substr( $utimetmp, 0, -1 );
            print $con "NOTICE $rnick :\001PING $utime \001 \n";
            DEBUG( "DEBUG Client - NOTICE $rnick :\001PING $utime \001 \r\n" );
        }
        when (/^FINGER/) {
            print $con "NOTICE $rnick :\001FINGER Dont Point at me! \001 \r\n";
            DEBUG( "DEBUG Client - NOTICE $rnick :\001FINGER $fresp \001 \r\n" );
        }
        when (/^TIME/) {
            print $con "NOTICE $rnick :\001TIME " . `date` . " \001 \r\n";
            DEBUG( "DEBUG Client - NOTICE $rnick :\001TIME " . `date` . " \001 \r\n" );
        }
        default {
            DEBUG( "DEBUG Client - NOTICE $rnick messing with actions.. such as $act \r\n" );
        }
    }
}











