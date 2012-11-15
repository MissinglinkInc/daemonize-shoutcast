#!/usr/bin/perl --

# process watchdog script
# Keiya Chinen <keiya_21@yahoo.co.jp>

use strict;
use warnings;

$SIG{CHLD} = 'IGNORE';
open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
open STDOUT, '>/dev/null';

# fork for daemonize
my $pid = fork;
 
# Fork failure.
if($pid < 0){
    exit -1;
}
# Fork success.
elsif($pid){
    exit 0;
}
 
# These below are executed in new (forked) process.
$SIG{CHLD} = 'DEFAULT';

write_pid_streamingd($$);

# Shoutcast Server Path & Arg
my $cmd_line = '/streaming-system/shoutcast_server/sc_serv sc_serv_basic.conf';

# Shoutcast Server Path
chdir('/streaming-system/shoutcast_server/');


my $i = 1;
while (1) {
	#print "[$0]<$i>calling fork_exec";
	&fork_exec();
	$i++;
	#exit if $i > 3;
}

sub fork_exec {
	my $pid = fork;
	die "Cannot fork: $!" unless defined $pid;
	write_pid_shoutcast($pid);
	
	if ( $pid ) {
		#print "[$0]parent($$) forked a child($pid)\n";
		waitpid($pid,0);
		#print "[$0]child($pid) died\n";
	}
	else {
		sleep 1;
		# fork-exec
		#print "[$0]child($$) will exec \"$cmd_line\"\n";
		exec($cmd_line) or die "Could not exec";
	}
}

sub write_pid_streamingd {
	if ($_[0]) {
		open my $PIDFH,'>','/var/run/streamingd.pid'
			or die "pid file open failed";
		print $PIDFH $_[0] or warn "failed to write pid";
		close $PIDFH;
	}
}

sub write_pid_shoutcast {
	if ($_[0]) {
		open my $PIDFH,'>','/var/run/shoutcast.pid'
			or die "pid file open failed";
		print $PIDFH $_[0] or warn "failed to write pid";
		close $PIDFH;
	}
}
