#!/usr/bin/perl -w
use strict;
use warnings;
###################################################################################
#
#     File Name : readSimData.pl
#
#     Version : 2.00
#
#     Author : Harika Gouda
#
#     Description : Reads the following data from the simuation, nodeName, NeType.
#     Syntax : ./readSimData.pl <simName>
#
###################################################################################
#
#----------------------------------------------------------------------------------
#Variables
my $NETSIM_INSTALL_SHELL = "/netsim/inst/netsim_pipe";

#
#----------------------------------------------------------------------------------
#Check if the scrip is executed as netsim user
#----------------------------------------------------------------------------------
#
my $user = `whoami`;
chomp($user);

#
#----------------------------------------------------------------------------------
#Check if the script usage is right
#----------------------------------------------------------------------------------
my $USAGE =
  "Usage: $0 <simName> \n  E.g. $0 CORE-K-FT-M-MGwB15215-FP2x1-vApp.zip\n";

# HELP
if ( @ARGV != 1 ) {
    print "ERROR: $USAGE";
    exit(202);
}

#
#----------------------------------------------------------------------------------
#Env variable
#----------------------------------------------------------------------------------
my $simNameTemp = "$ARGV[0]";
my @tempSimName = split( '\.zip', $simNameTemp );
my $simName     = $tempSimName[0];

my $PWD = `pwd`;
chomp($PWD);

#----------------------------------------------------------------------------------
#Define NETSim MO file and Open file in append mode
#----------------------------------------------------------------------------------
my $MML_MML = "MML.mml";
open MML, "+>>$MML_MML";

#----------------------------------------------------------------------------------
#Open the Simulation and read data into an array.
#----------------------------------------------------------------------------------
print MML ".open $simName\n";
print MML ".selectnocallback network\n";
print MML ".show simnes\n";
my @simNesArrTemp = `sudo su -l netsim -c $NETSIM_INSTALL_SHELL < $MML_MML`;
close MML;
system("rm $MML_MML");
if ($? != 0)
{
    print "INFO: Failed to execute system command (rm $MML_MML)\n";
}

#
#----------------------------------------------------------------------------------
#Extract the Node name and the NE Type
#----------------------------------------------------------------------------------
#print "INFO: Read data(simnes) is @simNesArrTemp\n";

my @simNeTypeFullArr = ();
my @simNeNameArr     = ();
my $count             = 0;
for my $line (@simNesArrTemp) {
    next if ++$count < 7;        # after lineNo=7, just after NeName,Type line
    next if $line =~ /^\s*$/;    # no any space
    next if $line =~ /^OK/;      # no line start with OK

    #print "-------$line" . "\n";

    $line =~ /^(.+?)\s+(.+?)\s+[netsim|?+]/;
    my $neName     = $1;
    my $neTypeFull = $2;

    push( @simNeNameArr, "$neName\n" );
    push( @simNeTypeFullArr, "$neTypeFull\n" );
}

#-----------------------------------------------------------------------------------
#Write inot a file the NeName and NeTypes
#----------------------------------------------------------------------------------
open dumpNeName, ">$PWD/dumpNeName.txt";
open dumpNeType, ">$PWD/dumpNeType.txt";
open listNeName, "+>>$PWD/listNeName.txt";
open listNeType, "+>>$PWD/listNeType.txt";
print dumpNeName @simNeNameArr;
print dumpNeType @simNeTypeFullArr;
print listNeName @simNeNameArr;
print listNeType $simNeTypeFullArr[0];
close dumpNeName;
close dumpNeType;
close listNeName;
close listNeType;
