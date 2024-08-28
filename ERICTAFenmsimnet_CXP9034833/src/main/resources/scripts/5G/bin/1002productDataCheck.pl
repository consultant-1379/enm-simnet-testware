#!/usr/bin/perl

##########################################################################################################################
# Created by  : Kathak Mridha
# Created on  : 03.08.2017
# Purpose     : Check Product Data on sims
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
##############
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

if ( ($ARGV[2] =~m/^RAN/i) or ($ARGV[2] =~m/^vTF/i))
{
print " Skipping this script as I am not RAN-VNFM Simulation  \n";
exit;
}
################################
# MAIN
################################

print "\n############### Checking $SIMNAME ##############\n";

while ($NODECOUNT<=$NUMOFNODE){# start outer while

$ProductDatafile="productData.env";
@MIM=split( /x/, $SIMNAME );
@MIMVERSION=split( /E/, $MIM[0] );
$MIMVERSION=$MIMVERSION[1];
$ProductData=&getENVfilevalue($ProductDatafile,"${MIMVERSION}:${SIMTYPE}");
@productData = split( /:/, $ProductData );
$productNumber=$productData[0];
$productRevision=$productData[1];

if ($NODECOUNT<10) { $NODENAME="LTE${SIMNUMBER}${SIMTYPE}0000${NODECOUNT}";
} elsif ($NODECOUNT>=10 && $NODECOUNT<100){ $NODENAME="LTE${SIMNUMBER}${SIMTYPE}000${NODECOUNT}";
} else { $NODENAME="LTE${SIMNUMBER}${SIMTYPE}00${NODECOUNT}"; }

print "\nSTATUS: $NODENAME\n";

#############################
# Print Product Data
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e X= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsSwIM:SwInventory=1\",\"RcsSwIM:SwItem=1\"]).",
            "e csmo:get_attribute_value(null,X,administrativeData)."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

@productNumberFromNode=split( /"/, $netsim_output[10] );
@productRevisionFromNode=split( /"/, $netsim_output[11] );
$productNumberFromNode=$productNumberFromNode[1];
$productRevisionFromNode=$productRevisionFromNode[1];

if ($productNumberFromNode eq $productNumber) {
	print "PASSED: Product Number on $NODENAME is $productNumberFromNode";
}
else {
	print "FAILED: Product Number on $NODENAME is $productNumberFromNode ; It should be $productNumber";
}

if ($productRevisionFromNode eq $productRevision) {
	print "PASSED: Product Revision on $NODENAME is $productRevisionFromNode";
}
else {
	print "FAILED: Product Revision on $NODENAME is $productRevisionFromNode ; It should be $productRevision";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#Counter Variable
$NODECOUNT++;
}

print "\n########### End checking for $SIMNAME ##########\n";
print "\n";