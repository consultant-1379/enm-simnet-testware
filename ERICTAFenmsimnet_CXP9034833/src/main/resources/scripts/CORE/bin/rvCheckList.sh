#!/bin/bash
################################################
#RVcheccklist
################################################
numOfIpv4=0
numOfIpv6=0
###############################################
#Check number of startednodes in a server
###############################################
#cd /netsim/inst
HostName=`hostname`
numOfStartedNesmml=$(echo ".show numstartednes" | sudo su -l netsim -c /netsim/inst/netsim_shell)
numOfStartedNes=$(echo ${numOfStartedNesmml##* } | tr -dc '0-9' )
echo -e "Executing RVchecklist in server $HostName********************************************************"
echo -e "$numOfStartedNes" >> summary.log
cd $PWD

#################################################
#Finding count of IPV4 and IPV6 nodes 
#################################################
nes=`echo -e ".show simulations" | sudo su -l netsim -c /netsim/inst/netsim_shell`
for sim in $nes
do
if [[ "$sim" != ">>" ]] && [[ "$sim" != ".show" ]] && [[ "$sim" != "simulations" ]] && [[ "$sim" != "default" ]] &&  [[ $sim != *"zip"* ]]; then

echo -e ".open $sim \n .show simnes \n" |  sudo su -l netsim -c /netsim/inst/netsim_shell >> $PWD/a.txt
ipaddress=$(echo -e "$(cat $PWD/a.txt | grep -oP "$HostName\K.*" | awk '{print $1}')")
rm a.txt
for ip in $ipaddress
do
if [[ $ip == *":"* ]]
	then
numOfIpv6=$((numOfIpv6+1))
	else
numOfIpv4=$((numOfIpv4+1))
	fi
	done
	fi
	done
	echo "$numOfIpv4" >> summary.log
	echo "$numOfIpv6 " >> summary.log
######################################################################
	arrayNe1=( "TCU02" "SIU02" "ML6352" "MLTN5-4FP" "SpitFire" "SGSN" "MGw" "EPG" "MTAS" "DSC" "GSM" "FrontHaul" "JUNIPER" "CISCO" "Router6274" "Router6672" )

nodeCount()
{
	sim=$1
		$PWD/readSimData.pl $sim
		IFS=$'\n' 
		for neTypeSingle in $(cat $PWD/dumpNeType.txt)
			do
				neCountTotal=$((neCountTotal+1))
					done
}

moCount()
{
	sim=$1
		for neName in $(cat $PWD/dumpNeName.txt)
			do
				singleNeCountTemp=$(echo -e ".open $sim \n .select $neName \n dumpmotree:count;" | sudo su -l netsim -c /netsim/inst/netsim_shell)
					echo -e ${singleNeCountTemp##* } | tr -dc '0-9'>> $PWD/count.txt
					echo $'\n' >> $PWD/count.txt
					done
					totalsimMoCount=$(awk '{n += $1}; END{print n}' $PWD/count.txt)
}

#########################################################
#Nodecount and NodePopulator support for each nodeType
########################################################
#neCountTotal=0
for node in ${arrayNe1[@]}
do
neCountTotal=0
totalsimMoCount=0

for sim in $nes
do
if [[ "$sim" != ">>" ]] && [[ "$sim" != ".show" ]] && [[ "$sim" != "simulations" ]] && [[ "$sim" != "default" ]] && [[ $sim != *"zip"* ]]; then

if [[ $sim == *"$node"* ]]
then
nodeCount $sim
moCount $sim
fi

fi

done
if [ -f count.txt ] ; then
rm -rf $PWD/count.txt
fi
echo "$neCountTotal" >> neCount.log
echo "$totalsimMoCount" >> moCount.log

#echo -e "$node MoCount in server is $totalsimMoCount" >> summary.log

if [[ $neCountTotal != "0" ]] 
then
echo "INFO: node Populator is supported for $node" >> support.log

if [[ $node == *"SpitFire"* || $node == *"TCU02"* || $node == *"SIU02"* || $node == *"SGSN"* || $node == *"ML"* || $node == *"MGw"* || $node == *"CISCO"* || $node == *"JUNIPER"* || $node == *"Router6672"* || $node == *"Router6274"* || $node == *"ESC"* ]]
then
echo -e "INFO: Pm file location for $node is /c/pm_data\n" >> support.log

elif [[ $node == *"EPG"* ]]
then
echo -e "INFO: Pm file location for $node is /var/log/services/epg/pm\n" >> support.log

elif [[ $node == *"GSM"* ]]
then
echo -e "INFO: Pm file location for $node is /apfs/cdh/cdhdefault/Ready\n" >> support.log


elif [[ $node == *"MTAS"* ]]
then
echo -e "INFO: Pm file location for $node is /PerformanceManagementReportFiles\n" >> support.log

elif [[ $node == *"DSC"* ]]
then
echo -e "INFO: Pm file location for $node is /var/filem/nbi_root/PerformanceManagementReportFiles\n" >> support.log

elif [[ $node == *"FrontHaul"* ]]
then
echo -e "INFO: Pm file location for $node is  /mnt/sd/ecim/enm_performance\n" >> support.log


fi
fi
done
rm -rf $PWD/*.txt
