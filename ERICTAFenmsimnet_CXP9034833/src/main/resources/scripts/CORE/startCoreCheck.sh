#!/bin/bash
#!/usr/bin/perl

##########################################################################################################################
# Created by  : Harika Gouda
# Created on  : 22 Aug 2017
# Purpose     : Performs different kind of Checks for Core sims
#########################################################################################
if [ "$#" -ne 1 ]; 
then
echo "Usage: $0 YES"
echo "Usage: $0 NO"
exit 1
fi

FLAG=$1

if [ "$FLAG" == "NO" ] ; then
echo "Test on CORE simulations is flagged as NO"
exit 1

fi
########################################################################################
DATE=`date +%F`
TIME=`date +%T`
LOGFILE=$PWD/log/checkCORELogs_$DATE\_$TIME.log

#########################################################################################
#getting serverName
#########################################################################################

echo "server is `hostname`"
echo ""
#########################################################################################
#Fetching simulations exist in the server
#########################################################################################
if [ "$NETSIMDIR" = "" ] ; then
NETSIMDIR=/netsim/netsimdir
fi
export NETSIMDIR

if [ -r $NETSIMDIR/simulations ] ; then
SIMULATIONS=`cat $NETSIMDIR/simulations`
else
SIMULATIONS=`ls -1 $NETSIMDIR/*/simulation.netsimdb | sed -e "s/.simulation.netsimdb//g" -e "s/^[^*]*[*\/]//g" |grep -v -E '^default$'`
#SIMULATIONS= `ls -1 $NETSIMDIR/*/simulation.netsimdb | sed -e "s/.simulation.netsimdb//g" -e "s/^[^*]*[*\/]//g" |grep -v -E '^default$'`
				 fi
				 echo "Simulations in server are "
				 echo " "
				 echo "$SIMULATIONS"
#####################################################################################
#Extracting CORE sims
#####################################################################################
if [ -f SimulationListCORE.txt ]; 
then
rm SimulationListCORE.txt
fi

for sim in $SIMULATIONS
do
if ([[ $sim == *"CORE"* || $sim == *"GSM"* ]]  ); then
printf "$sim\n" >> SimulationListCORE.txt
fi
done
echo ""
########################################################################################
#Print CORE sims
#######################################################################################
echo "---------------------------------"
echo "       CORE Simulation List"
echo "---------------------------------"
cat SimulationListCORE.txt
echo ""
############################################################################################
#Start different checks
###########################################################################################
while read sim
do

/usr/bin/perl $PWD/CORE/bin/pmCheckonCore.sh $sim | tee -a $LOGFILE
/usr/bin/perl $PWD/CORE/bin/productDataCheck.sh $sim | tee -a $LOGFILE
/usr/bin/perl $PWD/CORE/bin/brmCheck.sh $sim | tee -a $LOGFILE
done <SimulationListCORE.txt
#/usr/bin/perl $PWD/CORE/bin/rvCheckList.sh | tee -a $LOGFILE
rm -rf *.txt *.mml

