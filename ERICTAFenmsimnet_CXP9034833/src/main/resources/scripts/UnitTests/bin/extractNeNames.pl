#!/usr/bin/perl

##################################################################################
#Created by : Harika Gouda
#created on : 23rd August 2017
#Purpose : Extracts nodenames of simulation
#####################################################################################

my $MML_MML = "MML.mml";
open MML, "+>>$MML_MML";

#----------------------------------------------------------------------------------
#Open the Simulation and read data into an array.
#----------------------------------------------------------------------------------
my $simName= "$ARGV[0]";
my $NETSIM_SHELL = "/netsim/inst/netsim_pipe";
print MML ".open $simName\n";
print MML ".selectnocallback network\n";
print MML ".show simnes\n";
my @simNesArrTemp = `sudo su -l netsim -c $NETSIM_SHELL < $MML_MML`;
close MML;
my @simNeNameArr     = ();
my $count             = 0;
for my $line (@simNesArrTemp) {
	next if ++$count < 7;        # after lineNo=7, just after NeName,Type line
		next if $line =~ /^\s*$/;    # no any space
		next if $line =~ /^OK/;      # no line start with OK

#print "-------$line" . "\n";

		$line =~ /^(.+?)\s+(.+?)\s+[netsim|?+]/;
	my $neName     = $1;
	push( @simNeNameArr, "$neName\n" );

}
####################################################################################
#Read nodenames into a file
####################################################################################

open dumpNeName, ">dumpNeName.txt";
print dumpNeName @simNeNameArr;
close dumpNeName;
system("rm MML.mml");
