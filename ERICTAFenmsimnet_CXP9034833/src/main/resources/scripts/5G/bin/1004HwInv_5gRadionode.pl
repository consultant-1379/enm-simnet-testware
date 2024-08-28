#!/usr/bin/perl

##########################################################################################################################
# Created by  : Mitali Sinha
# Created on  : 20.09.2017
# Purpose     : Checks Hw Inventory and Pm File location on 5G RadioNodes.
###########################################################################################################################

##########################################################################################################################
# Created by  : Yamuna Kanchireddygari
# Created on  : 14.05.2018
# Purpose     : Checks Enrollment Support on 5G RadioNodes
###############################################################################

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

##############################TEST#########################
##############Checking for 5G RadioNodes###################

if  ($ARGV[2] !~m/^5G/i)
{
print " Skipping this script as I am not a 5G Radio Node.  \n";
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
# Print HwInventory Details.
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e X= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsHwIM:HwInventory=1\",\"RcsHwIM:HwItem=1\"]).",
            "e csmo:get_attribute_value(null,X,productData).",
            "e csmo:get_attribute_value(null,X,serialNumber).",
            "e csmo:get_attribute_value(null,X,hwUnitLocation).",
            "e csmo:get_attribute_value(null,X,hwType)."
            
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

@productNumberFromNode=split( /"/, $netsim_output[10] );
@productRevisionFromNode=split( /"/, $netsim_output[11] );
$productNumberFromNode=$productNumberFromNode[1];
$productRevisionFromNode=$productRevisionFromNode[1];
@serialNo=split( /"/, $netsim_output[16] );
$serialNo=$serialNo[1];
@hwUnitLocation=split( /"/, $netsim_output[18]);
$hwUnitLocation=$hwUnitLocation[1];
@hwType=split( /"/, $netsim_output[20]);
$hwType=$hwType[1];
$serialNo_Value="D821781334";
$hwUnitLocation_Value="slot:1";
$hwType_Value="Card";



if ($productNumberFromNode eq $productNumber) {
	print "PASSED: Product Number on $NODENAME is $productNumberFromNode \n";
}
else {
	print "FAILED: Product Number on $NODENAME is $productNumberFromNode ; It should be $productNumber \n";
}

if ($productRevisionFromNode eq $productRevision) {
	print "PASSED: Product Revision on $NODENAME is $productRevisionFromNode \n";
}
else {
	print "FAILED: Product Revision on $NODENAME is $productRevisionFromNode ; It should be $productRevision \n";
}

if ($serialNo eq $serialNo_Value) {
	print "PASSED: Serial Number on $NODENAME is $serialNo \n";
}
else {
	print "FAILED: Serial Number on $NODENAME is $serialNo ; It should be $serialNo_Value \n";
}

if ($hwUnitLocation eq $hwUnitLocation_Value ) {
	print "PASSED: HwUnitLocation on $NODENAME is $hwUnitLocation \n";
}
else {
	print "FAILED: HwUnitLocation on $NODENAME is $hwUnitLocation ; It should be $hwUnitLocation_Value \n";
}

if ($hwType eq $hwType_Value ) {
	print "PASSED: HwType on $NODENAME is $hwType \n";
}
else {
	print "FAILED: HwType on $NODENAME is $hwType ; It should be $hwType_Value \n";
}


unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

######################################################
#############################
# verify CERTM enrollmentsupport 
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e F= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsSecM:SecM=1\",\"RcsCertM:CertM=1\",\"RcsCertM:CertMCapabilities=1\"]).",
            "e csmo:get_attribute_value(null,F,enrollmentSupport)."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

#########################
@EnrollmentSupport=split( /"/, $netsim_output[9] );
if ("$netsim_output[9]" =~ 0) {
        print "PASSED: EnrollmentSupport is OFFLINE_CSR\n";
}
else {
        print "FAILED: EnrollmentSupport is not set to 0\n";
}
if ("$netsim_output[9]" =~ 1) {
        print "PASSED: EnrollmentSupport is OFFLINE_PKCS12\n";
}
else {
        print "FAILED: EnrollmentSupport is not set to 1\n";
}
if ("$netsim_output[9]" =~ 3) {
        print "PASSED: EnrollmentSupport is ONLINE_CMP\n";
}
else {
        print "FAILED: EnrollmentSupport is not set to 3\n";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#########################

#Counter Variable
$NODECOUNT++;
} # while close

print "\n########### End checking for $SIMNAME ##########\n";
print "\n";
