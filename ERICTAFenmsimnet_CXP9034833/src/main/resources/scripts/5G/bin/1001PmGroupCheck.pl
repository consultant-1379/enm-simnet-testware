#!/usr/bin/perl

##########################################################################################################################
# Created by  : Kathak Mridha
# Created on  : 03.08.2017
# Purpose     : Check simulations for PM file location and PM MOs
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
# verify PMGroup
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e length(csmo:get_mo_ids_by_type(null, \"RcsPm:PmGroup\"))."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

if (int($netsim_output[-1]) ge 45) {
        print "PASSED: PMGroup MO count is $netsim_output[-1]";
}
else {
        print "FAILED: Check if all the PMGroups are loaded or not, MO count is $netsim_output[-1]";
}

unlink "$NETSIMMMLSCRIPT";

#############################
# verify EventGroup
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e length(csmo:get_mo_ids_by_type(null, \"RcsPMEventM:EventGroup\"))."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

if (int($netsim_output[-1]) ge 15) {
        print "PASSED: EventGroup MO count is $netsim_output[-1]";
}
else {
        print "FAILED: Check if all the EventGroups are loaded or not, MO count is $netsim_output[-1]";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#############################
# verify EventJob
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e length(csmo:get_mo_ids_by_type(null, \"RcsPMEventM:EventJob\"))."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

if (int($netsim_output[-1]) ge 6) {
        print "PASSED: EventJob MO count is $netsim_output[-1]";
}
else {
        print "FAILED: Check if all the EventJobs are loaded or not, MO count is $netsim_output[-1]";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#############################
# verify PM File location
#############################
if  ($ARGV[2] =~m/^VTF/i)
{
print " Skipping this script \n";
exit;
}

#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e X= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsPm:Pm=1\",\"RcsPm:PmMeasurementCapabilities=1\"]).",
            "e csmo:get_attribute_value(null,X,fileLocation)."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

if ("$netsim_output[-1]" =~ "/c/pm_data/") {
        print "PASSED: fileLocation is $netsim_output[-1]";
}
else {
        print "FAILED: fileLocation is not set to /c/pm_data/";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#############################
# Calculate total MOs
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "dumpmotree:count;"
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

print "TOTAL MO count is $netsim_output[7]";

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#Counter Variable
$NODECOUNT++;
}

print "\n########### End checking for $SIMNAME ##########\n";
print "\n";
