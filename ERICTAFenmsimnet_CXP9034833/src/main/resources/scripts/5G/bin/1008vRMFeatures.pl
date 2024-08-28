#!/usr/bin/perl

##########################################################################################################################
# Created by  : Yamuna Kanchireddygari
# Created on  : 23.03.2018
# Purpose     : Check Features on vRM (CAT-M) sims
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

Example1 : ${0} LTE18-Q1-V1x2-FT-vRM-LTE60 2 vRM

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

if  (($ARGV[2] !~m/^vRM/i) || ($ARGV[2] !~m/^vRSM/i))
{
print " Skipping this script as I am not vRM or vRSM Simulation  \n";
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
} else { $NODENAME="LTE${SIMNUMBER}${SIMTYPE}000${NODECOUNT}"; }

print "\nSTATUS: $NODENAME\n";

#############################
# Print Product Data
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e A= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsSwIM:SwInventory=1\",\"RcsSwIM:SwItem=1\"]).",
            "e csmo:get_attribute_value(null,A,administrativeData)."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);



# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

@productNumberFromNode=split( /"/, $netsim_output[10] );
@productRevisionFromNode=split( /"/, $netsim_output[11] );
$productNumberFromNode=$productNumberFromNode[1];
$productRevisionFromNode=$productRevisionFromNode[1];

if ($productNumberFromNode eq $productNumber) {
	print "PASSED: Product Number on $NODENAME is $productNumberFromNode\n";
}
else {
	print "FAILED: Product Number on $NODENAME is $productNumberFromNode ; It should be $productNumber\n";
}

if ($productRevisionFromNode eq $productRevision) {
	print "PASSED: Product Revision on $NODENAME is $productRevisionFromNode\n";
}
else {
	print "FAILED: Product Revision on $NODENAME is $productRevisionFromNode ; It should be $productRevision\n";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#############################
# verify BackupType and Domain
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e B= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsBrM:BrM=1\",\"RcsBrM:BrmBackupManager=1\"]).",
            "e csmo:get_attribute_value(null,B,backupType).",
            "e csmo:get_attribute_value(null,B,backupDomain).",
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

if ("$netsim_output[9]" =~ "Systemdata") {
        print "PASSED: BackupType is $netsim_output[9]";
}
else {
        print "FAILED: BackupType is not set to Systemdata\n";
}

if ("$netsim_output[11]" =~ "System") {
        print "PASSED: BackupDomain is $netsim_output[11]";
}
else {
        print "FAILED: BackupDomain is not set to System\n";
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
            "e C= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsBrM:BrM=1\",\"RcsBrM:BrmBackupManager=1\",\"RcsBrM:BrmBackup=1\"]).",
            "e csmo:get_attribute_value(null,C,backupName).",
            "e csmo:get_attribute_value(null,C,creationType).",
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
        print "FAILED: BackupName is not set to 1\n";
}

if ("$netsim_output[11]" =~ "3") {
        print "PASSED: creationType is $netsim_output[11]";
}
else {
        print "FAILED: creationType is not set to 3\n";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();


#############################
# verify PM File location
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e D= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"ComTop:SystemFunctions=1\",\"RcsPm:Pm=1\",\"RcsPm:PmMeasurementCapabilities=1\"]).",
            "e csmo:get_attribute_value(null,D,fileLocation)."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

if ("$netsim_output[-1]" =~ "/c/pm_data/") {
        print "PASSED: fileLocation is $netsim_output[-1]";
}
else {
        print "FAILED: fileLocation is not set to /c/pm_data/\n";
}

unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

#############################
# verify RMe node support 
#############################
@MMLCmds=(".open ".$SIMNAME,
            ".select ".$NODENAME,
            ".start ",
            "e E= csmo:ldn_to_mo_id(null,[\"ComTop:ManagedElement=$NODENAME\",\"RmeSupport:NodeSupport=1\",\"RmeExeR:ExecutionResource=1\"]).",
            "e csmo:get_attribute_value(null,E,vnfIdentity)."
  );# end @MMLCmds

$NETSIMMMLSCRIPT=&makeMMLscript("write",$MMLSCRIPT,@MMLCmds);

# execute mml script
@netsim_output=`sudo su -l netsim -c $NETSIM_INSTALL_PIPE < $NETSIMMMLSCRIPT`;

if ("$netsim_output[-1]" =~ "49282996-ffff-11e6-a47e-fa163e1fee7c") {
        print "PASSED: vnfIdentity is $netsim_output[-1]";
}
else {
        print "FAILED: vnfIdentity is not set to 49282996-ffff-11e6-a47e-fa163e1fee7c\n";
}


unlink "$NETSIMMMLSCRIPT";
@MMLCmds=();
@netsim_output=();

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


#############################

#############################
#Counter Variable
$NODECOUNT++;
} # while close



print "\n########### End checking for $SIMNAME ##########\n";
print "\n";


############
