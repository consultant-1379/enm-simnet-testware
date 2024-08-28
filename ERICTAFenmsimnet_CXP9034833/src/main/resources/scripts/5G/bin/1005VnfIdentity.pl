#!/usr/bin/perl

##########################################################################################################################
# Created by  : Mitali Sinha
# Created on  : 20.09.2017
# Purpose     : Check Vnf Identity on vRC vPP and vSD Nodes.
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

#Checking for vRC/vPP/vSD Nodes#

print "value: $ARGV[2] \n ";

if ( (($ARGV[2]) =~m/^RNN/i) or (($ARGV[2]) =~m/^VNFM/i) or (($ARGV[2]) =~m/^VTF/i) or (($ARGV[2]) =~m/^5G/i))
{
print " Skipping this script as I am not a vSD/vPP/vRC Node.  \n";
exit;
}

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
# Print Vnf Identity Details.
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e X= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"RmeSupport:NodeSupport=1\",\"RmeExeR:ExecutionResource=1\"]).",
            "e csmo:get_attribute_value(null,X,vnfIdentity)."
            
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

@vnfId=split( /"/, $netsim_output[9] );
$vnfId=$vnfId[1];


$vnfId_value="49282996-ffff-11e6-a47e-fa163e1fee7c";

if ($vnfId eq $vnfId_value) {
	print "PASSED: Vnf Id on $NODENAME is $vnfId_value \n";
}
else {
	print "FAILED: Vnf Id on $NODENAME is $vnfId ; It should be $vnfId_value \n";
}


unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();



##############################

#Counter Variable
$NODECOUNT++;
} # while close

print "\n########### End checking for $SIMNAME ##########\n";
print "\n";