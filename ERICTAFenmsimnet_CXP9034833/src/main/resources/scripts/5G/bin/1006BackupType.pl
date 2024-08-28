#!/usr/bin/perl

##########################################################################################################################
# Created by  : Mitali Sinha
# Created on  : 20.09.2017
# Purpose     : Check Backup Type and Domain on Nodes.
###########################################################################################################################

####################
# Env
####################
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Cwd;
use General;
################################
# Usage
################################
local @helpinfo=qq(
ERROR : need to pass 3 parameter to ${0}

Usage : ${0} <simulation name> <number of nodes> <sim type>

Example1 : ${0} LTE17B-V1x2-FT-vSD-SNMP-LTE01 2 vSD

Example2 : ${0} LTE17B-V1x5-FT-vSD-TLS-LTE01 5 vSD

); # end helpinfo

################################
# Vars
################################
local $netsimserver=`hostname`;
local $username=`/usr/bin/whoami`;
$username=~s/^\s+//;$username=~s/\s+$//;
local $NETSIM_INSTALL_PIPE="/netsim/inst/netsim_pipe";
local @netsim_output=();
local $dir=cwd;
local $currentdir=$dir."/";
local $scriptpath="$currentdir";
local $MMLSCRIPT="$scriptpath".${0}.".mml";
local $SIMNAME=$ARGV[0];
local $SIMNUMBER=substr($SIMNAME, -2);
local $NUMOFNODE=$ARGV[1];
local $SIMTYPE=$ARGV[2];
local $NODECOUNT=1;
local @MMLCmds=();
local $NODENAME;
local $NETSIMMMLSCRIPT;
local @netsim_output=();

####################
# Integrity Check
####################

#-----------------------------------------
# ensure script being executed by netsim
#-----------------------------------------
if ($username ne "root"){
        print "FATAL ERROR : ${0} needs to be executed as user : root\n It is executed with user : $username\n";exit(1);
}# end if
#-----------------------------------------
# ensure netsim inst in place
#-----------------------------------------
if (!(-e "$NETSIM_INSTALL_PIPE")){# ensure netsim installed
       print "FATAL ERROR : $NETSIM_INSTALL_PIPE does not exist on $netsimserver\n";exit(1);
}# end if
#############################
# verify script params
#############################
if (!( @ARGV==3)){
      print "@helpinfo\n";exit(1);
}# end if

################################
# MAIN
################################

print "\n############### Checking $SIMNAME ##############\n";

while ($NODECOUNT<=$NUMOFNODE){# start outer while



if ($NODECOUNT<10) { $NODENAME="LTE${SIMNUMBER}${SIMTYPE}0000${NODECOUNT}";
} elsif ($NODECOUNT>=10 && $NODECOUNT<100){ $NODENAME="LTE${SIMNUMBER}${SIMTYPE}000${NODECOUNT}";
} else { $NODENAME="LTE${SIMNUMBER}${SIMTYPE}00${NODECOUNT}"; }

print "\nSTATUS: $NODENAME\n";


#############################
# verify BackupType and Domain
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e X= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsBrM:BrM=1\",\"RcsBrM:BrmBackupManager=1\"]).",
            "e csmo:get_attribute_value(null,X,backupType).",
            "e csmo:get_attribute_value(null,X,backupDomain).", 
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

if ("$netsim_output[9]" =~ "Systemdata") {
        print "PASSED: fileLocation is $netsim_output[9]";
}
else {
        print "FAILED: fileLocation is not set to Systemdata";
}

if ("$netsim_output[11]" =~ "System") {
        print "PASSED: fileLocation is $netsim_output[11]";
}
else {
        print "FAILED: fileLocation is not set to System";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#############################
# verify backupName 
#############################

@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e X= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsBrM:BrM=1\",\"RcsBrM:BrmBackupManager=1\",\"RcsBrM:BrmBackup=1\"]).",
            "e csmo:get_attribute_value(null,X,backupName).",
            "e csmo:get_attribute_value(null,X,creationType).", 
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

@BackupName=split( /"/, $netsim_output[9] );
$BackupName=$BackupName[1];

if ("$netsim_output[9]" =~ "1") {
        print "PASSED: BackupName is $netsim_output[9]";
}
else {
        print "FAILED: BackupName is not set to 1";
}

if ("$netsim_output[11]" =~ "3") {
        print "PASSED: creationType is $netsim_output[11]";
}
else {
        print "FAILED: creationType is not set to 3";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#############################

#############################
#############################
#Counter Variable
$NODECOUNT++;
} # while close

print "\n########### End checking for $SIMNAME ##########\n";
print "\n";