#!/usr/bin/perl

##########################################################################################################################
# Created by  : Kathak Mridha
# Created on  : 15.08.2017
# Purpose     : Checks parameter passed and runs different modules
###########################################################################################################################

####################
# Env
####################
use FindBin qw($Bin);
use Getopt::Long();
use Cwd 'abs_path';

#
#---------------------------------------------------------------------------------
#variables
#---------------------------------------------------------------------------------
$dateVar = `date +%F`;
chomp($dateVar);
$timeVar = `date +%T`;
chomp($timeVar);
$logFileName = "initiateCheckLogs_$dateVar\_$timeVar.log";
if (! open LOGFILEHANDLER, "+>>", "log/$logFileName") {
    print "ERROR: Could not open log file.\n";
    exit(1);
}
#
#----------------------------------------------------------------------------------
#SubRoutine to capture Logs
#----------------------------------------------------------------------------------
#
sub LogFiles {
    $dateVar = `date +%F`;
    chomp($dateVar);
    $timeVar = `date +%T`;
    chomp($timeVar);
    my $hostName = `hostname`;
    chomp($hostName);
    $LogVar = $_[0];
    chomp($LogVar);
    $substring = "ERROR:";
    if (index("$LogVar", $substring) != -1) {
        print LOGFILEHANDLER "$timeVar:<$hostName>: $LogVar in module $0\n";
        print "$timeVar:<$hostName>: $LogVar in module $0 \n";
    }
    else {
        print LOGFILEHANDLER "$timeVar:<$hostName>: $LogVar\n";
        print "$timeVar:<$hostName>: $LogVar\n";
    }

}
#
#---------------------------------------------------------------------------------
#Function call to read config file
#---------------------------------------------------------------------------------
sub readConfig {
    my $path = $_[0];
    if (! -e $path) {
        LogFiles "ERROR: File $path doesn't exist.\n";
        exit(1);
    }
    LogFiles("INFO: Reading config file from $path \n");
    if (! open CONF, "<", "$path") {
        LogFiles "ERROR: Could not open file $path.\n";
        exit(1);
    }
    my @conf = <CONF>;
    close(CONF);
    foreach (@conf) {
        next if /^#/;
        if ( "$_" =~ "check5G" ) {
            @check5G = split( /=/, $_ );
        }
        elsif ( $_ =~ "checkTransport" ) {
            @checkTransport = split( /=/, $_ );
        }
        elsif ( $_ =~ "checkCORE" ) {
            @checkCORE = split( /=/, $_ );
        }
        elsif ( $_ =~ "checkWRAN" ) {
            @checkWRAN = split( /=/, $_ );
        }
        elsif ( $_ =~ "checkGRAN" ) {
            @checkGRAN = split( /=/, $_ );
        }
        elsif ( $_ =~ "checkLTE" ) {
            @checkLTE = split( /=/, $_ );
        }
    }
    chomp( $check5G[1] );
    my $check5G = $check5G[1];
    chomp( $checkTransport[1] );
    my $checkTransport = $checkTransport[1];
    chomp( $checkCORE[1] );
    my $checkCORE = $checkCORE[1];
    chomp( $checkWRAN[1] );
    my $checkWRAN = $checkWRAN[1];
    chomp( $checkGRAN[1] );
    my $checkGRAN = $checkGRAN[1];
    chomp( $checkLTE[1] );
    my $checkLTE = $checkLTE[1];
    
    return (
        $check5G, $checkTransport, $checkCORE, $checkWRAN, $checkGRAN, $checkLTE,
    );
}

#--------------------------------------------------------------------------------
#Function call to start test on 5G
#--------------------------------------------------------------------------------
sub test5G {
	my $flag = $_[0];

		LogFiles "Executing $Bin/5G/startCheck.sh $flag";
		system("$Bin/5G/startCheck.sh $flag");

    	if ($? != 0)
    	{
        LogFiles "ERROR: Failed to execute system command ($Bin/5G/startCheck.sh $flag) \n";
        exit(0);
    	}
    	else {
    		LogFiles "INFO: Test ran on 5G simulations";
    		LogFiles "INFO: Please check check5G logs for details";
    	}

}
#--------------------------------------------------------------------------------
#Function call to start test on CORE
#--------------------------------------------------------------------------------
sub testCORE {
        my $flag = $_[0];

                LogFiles "Executing $Bin/CORE/startCoreCheck.sh $flag";
                system("$Bin/CORE/startCoreCheck.sh $flag");

        if ($? != 0)
        {
        LogFiles "ERROR: Failed to execute system command ($Bin/CORE/startCoreCheck.sh $flag) \n";
        exit(0);
        }
        else {
                LogFiles "INFO: Test ran on CORE simulations";
                LogFiles "INFO: Please check checkCORE logs for details";
        }

}

#
##################################################################################
#   Main
##################################################################################
#
LogFiles("INFO: Starting SimNET Acceptance Test.\n");

#
#----------------------------------------------------------------------------------
#Check if the script is executed as root user
#----------------------------------------------------------------------------------
#
my $root  = 'root';
my $user  = `whoami`;
my $USAGE =<<USAGE;

    HELP:
        <Add Descriptions here>

    Usage:
        ./initiateCheck.pl -overwrite
            -check5G <YES/NO>
            -checkTransport <YES/NO>
            -checkCORE <YES/NO>
            -checkWRAN <YES/NO>
            -checkGRAN <YES/NO>
            -checkLTE <YES/NO>

        where all are madatory parameters/flags
        
    Usage examples:

        ./initiateCheck.pl -overwrite -check5G YES -checkTransport YES -checkCORE YES -checkWRAN YES -checkGRAN YES -checkLTE YES
        ./initiateCheck.pl -overwrite -check5G YES -checkTransport NO -checkCORE NO -checkWRAN NO -checkGRAN NO -checkLTE NO                                                                             

USAGE

chomp($user);
if ( $user ne $root ) {
    LogFiles("ERROR: Not a root user. Please execute the script as a root user \n");
    exit(1);
}

#
#----------------------------------------------------------------------------------
#Check if the script usage is right
#----------------------------------------------------------------------------------
#
if ( @ARGV > 15 ) {
    LogFiles("WARNING: $USAGE");
    exit(1);
}
our $overwrite = '';
our $check5Gflag;
our $checkTransportflag;
our $checkCOREflag;
our $checkWRANflag;
our $checkGRANflag;
our $checkLTEflag;

Getopt::Long::GetOptions(
	'overwrite' => \$overwrite,
    'check5Gflag=s' => \$check5Gflag,
    'checkTransportflag=s' => \$checkTransportflag,
    'checkCOREflag=s' => \$checkCOREflag,
    'checkWRANflag=s' => \$checkWRANflag,
    'checkGRANflag=s' => \$checkGRANflag,
    'checkLTEflag=s' => \$checkLTEflag
);

#
#----------------------------------------------------------------------------------
#Opening a file to register log
#----------------------------------------------------------------------------------
LogFiles("INFO: You can find real time execution logs of this script at log/$logFileName\n");

#
#---------------------------------------------------------------------------------
#Function call to read configuration file.
#---------------------------------------------------------------------------------
#
my $confPath = 'conf/CONFIG.env';
(
	my $check5Gvar,
	my $checkTransportvar,
	my $checkCOREvar,
	my $checkWRANvar,
	my $checkGRANvar,
	my $checkLTEvar

) = &readConfig($confPath);

	LogFiles "INFO: The parameters/flags read are as follows:- \n";
	LogFiles "INFO: check5G = $check5Gvar\n";
	LogFiles "INFO: checkTransport = $checkTransportvar\n";
	LogFiles "INFO: checkCORE = $checkCOREvar\n";
	LogFiles "INFO: checkWRAN = $checkWRANvar\n";
	LogFiles "INFO: checkGRAN = $checkGRANvar\n";
	LogFiles "INFO: checkLTE = $checkLTEvar\n";

if ($overwrite) {
    LogFiles "INFO: -overwrite flag is activated. Cmd line args has precedence over config file args.\n";
    $check5Gvar = $check5Gflag;
    $checkTransportvar = $checkTransportflag;
    $checkCOREvar = $checkCOREflag;
    $checkWRANvar = $checkWRANflag;
    $checkGRANvar = $checkGRANflag;
    $checkLTEvar = $checkLTEflag;
}

#
#---------------------------------------------------------------------------------
# start TEST
#---------------------------------------------------------------------------------
#

	&test5G($check5Gvar);
    &testCORE($checkCOREvar);
    
LogFiles "INFO: SimNET Acceptance Test ended";

##########################################END##################################################
