#!/bin/bash
#!/usr/bin/perl

##########################################################################################################################
# Created by  : Harika Gouda
# Created on  : 22 Aug 2017
# Purpose     : Performs different kind of Checks for Core sims
#########################################################################################
if [ "$#" -ne 1 ]; 
then
echo "Usage: $0 CORE-FT-SBG-1.6-V2x2"
exit 1
fi
Path=`pwd`
simName=$1
######################################################################
#Deleting existing logs
######################################################################
cd $PWD/log/
rm -rf *.log
cd $Path

########################################################################################
#DATE=`date +%F`
#TIME=`date +%T`
LOGFILE=$PWD/log/checkCORELogs.log

#########################################################################################
#getting serverName
#########################################################################################

echo "server is `hostname`"
echo ""

############################################################################################
#Start different checks
###########################################################################################

/usr/bin/perl $PWD/CORE/bin/pmCheckonCore.sh $simName | tee -a $LOGFILE
/usr/bin/perl $PWD/CORE/bin/productDataCheck.sh $simName | tee -a $LOGFILE
/usr/bin/perl $PWD/CORE/bin/brmCheck.sh $simName | tee -a $LOGFILE

rm -rf *.txt *.mml

