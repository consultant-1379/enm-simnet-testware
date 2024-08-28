#!/bin/bash
#################################################
#NonRAN-CheckList
################################################
###############################################
#Check number of startednodes in a server
###############################################
#cd /netsim/inst
masterServer=$1
nrm=$2
serverName=`hostname`
numOfStartedNesmml=$(echo ".show numstartednes" | sudo su -l netsim -c /netsim/inst/netsim_shell)
numOfStartedNes=$(echo ${numOfStartedNesmml##* } | tr -dc '0-9' )
echo -e "Executing RVchecklist in server $serverName********************************************************"
echo -e "$numOfStartedNes" >> $serverName"_summary.log"
cd $PWD

#################################################
#Finding count of IPV4 and IPV6 nodes
#################################################
numOfIpv4=0
numOfIpv6=0
#################################################
nes=`echo -e ".show simulations" | sudo su -l netsim -c /netsim/inst/netsim_shell`
for sim in $nes
do
  if [[ "$sim" != ">>" ]] && [[ "$sim" != ".show" ]] && [[ "$sim" != "simulations" ]] && [[ "$sim" != "default" ]] &&  [[ $sim != *"zip"* ]]; then
  echo -e ".open $sim \n .show simnes \n" |  sudo su -l netsim -c /netsim/inst/netsim_shell >> $PWD/a.txt
  ipaddress=$(echo -e "$(cat $PWD/a.txt | grep -oP "$serverName\K.*" | awk '{print $1}')")
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
echo "$numOfIpv4" >> $serverName"_summary.log"
echo "$numOfIpv6 " >> $serverName"_summary.log"
#### List Of netypes which are to verified ####
#arrayNe1=( "TCU02" "SIU02" "ML6352" "MLTN5-4FP" "SpitFire" "SGSN" "100K-ST-MGw" "3K-ST-MGw" "EPG" "MTAS" "DSC" "GSM" "FrontHaul-6080" "JUNIPER" "CISCO-ASR900" "ESC" "Router6672" "Router6274")
dos2unix NodeType.conf
while read nodeType; do arrayNe1+=("$nodeType"); done<NodeType.conf
#### Subroutine for getting the number of nodes ####
nodeCount()
{
sim=$1
$PWD/readSimData.pl $sim
IFS=$'\n'
for neTypeSingle in $(cat $PWD/dumpNeType.txt)
do
neCountTotal=$((neCountTotal+1))
done
echo $neCountTotal
}
#### Subroutine for getting the number of mos ####
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
echo $totalsimMoCount
}
#########################################################
#Nodecount and NodePopulator support for each nodeType
#########################################################
echo "Simulation,NodeType,NumOfNodes,NumOfIpv4Nes,NumOfIpv6Nes,TotalMos" >> $serverName"_simulationSummary.txt"
for node in ${arrayNe1[@]}
do
   neCountTotal=0
   totalsimMoCount=0
   for sim in $nes
   do
      if [[ "$sim" != ">>" ]] && [[ "$sim" != ".show" ]] && [[ "$sim" != "simulations" ]] && [[ "$sim" != "default" ]] && [[ $sim != *"zip"* ]]; then
         if [[ $sim == *"$node"* ]]
         then
            if [ -f count.txt ] ; then
               rm -rf $PWD/count.txt
            fi
            numOfNodes=`nodeCount $sim`
            numOfMos=`moCount $sim`
            numOfIpv6Nes=$(echo -e '.open '$sim' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "::" | sort | awk -F" " '{print $1}' | wc -l)
            numOfNes=$(echo -e '.open '$sim' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | cut -d' ' -f1 | tail -n+5 | head -n-1 | wc -l)
            if [ "$numOfNes" -ne "0" ]
            then
               echo "INFO: node Populator is supported for $node in $sim" >> $serverName"_support.log"
            fi
            numOfIpv4Nes=`expr $numOfNes - $numOfIpv6Nes`
            echo "$sim,$node,$numOfNodes,$numOfIpv4Nes,$numOfIpv6Nes,$numOfMos" >> $serverName"_simulationSummary.txt"
         fi
      fi
   done
   if [ -f count.txt ] ; then
      rm -rf $PWD/count.txt
   fi
   echo "$neCountTotal" >> $serverName"_neCount.log"
   echo "$totalsimMoCount" >> $serverName"_moCount.log"
done

##### Copying the files to the master server #####
summaryFile=$serverName"_simulationSummary.txt"
supportFile=$serverName"_support.log"
if [ -f /etc/centos-release ]
then
    sshpass -p shroot ssh -q -o StrictHostKeyChecking=no root@$masterServer.athtem.eei.ericsson.se "mkdir -p /netsim/CoreCheckForRv/"
    curl --retry 5 -k -fsS -T $summaryFile -u root:shroot scp://$masterServer.athtem.eei.ericsson.se/netsim/CoreCheckForRv/
    curl --retry 5 -k -fsS -T $supportFile -u root:shroot scp://$masterServer.athtem.eei.ericsson.se/netsim/CoreCheckForRv/
else
cat >> copyData <<EOF
    spawn ssh -o StrictHostKeyChecking=no -p 22 root@$masterServer.athtem.eei.ericsson.se mkdir /netsim/CoreCheckForRv/
    expect {
        -re assword: {send "shroot\r";exp_continue}
    }
    sleep 1
    spawn scp -o StrictHostKeyChecking=no $summaryFile root@$masterServer.athtem.eei.ericsson.se:/netsim/CoreCheckForRv/
    expect {
        -re Password: {send "shroot\r";exp_continue}
    }
    sleep 1
    spawn scp -o StrictHostKeyChecking=no $supportFile root@$masterServer.athtem.eei.ericsson.se:/netsim/CoreCheckForRv/
    expect {
        -re Password: {send "shroot\r";exp_continue}
    }
    sleep 1
EOF

/usr/bin/expect < copyData &> /dev/null
fi
echo
echo "############################ Non-RAN CheckList on $serverName #####################################" >> $serverName"_FinalSummary.txt"
cat $serverName"_support.log" >> $serverName"_FinalSummary.txt"
echo "------------------------------------------------------------------------------------------------" >> $serverName"_FinalSummary.txt"
column -t -s',' $serverName"_simulationSummary.txt" >> $serverName"_FinalSummary.txt"
echo "#################################################################################################" >> $serverName"_FinalSummary.txt"
cat $serverName"_FinalSummary.txt"
