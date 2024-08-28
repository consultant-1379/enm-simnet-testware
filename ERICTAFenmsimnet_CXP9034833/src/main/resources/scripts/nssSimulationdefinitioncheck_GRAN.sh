#!/bin/sh
masterServer=$1
nrm=$2
startTime=`date`
PWD=`pwd`
workPath=$PWD"/Simstats"
serverName=`hostname`
gsmStatsFile=$serverName"_GsmStats.txt"
workSpace=/netsim/Gsm_CheckForRV
if [ -d "$workPath" ]
then
   rm -rf $workPath
fi
mkdir $workPath
cd $workPath
simList=`ls /netsim/netsimdir | grep ".*-GSM" | grep -v .zip`
simulations=(${simList// / })
######################################################################################
## SubRoutines
######################################################################################
#### Search and count the generated MOS ####
getStats()
{
moFile=$1
moType=$2
if [ "$moType" == "ALL" ]
then
   moCount=`cat $moFile | grep -wi "moType" |wc -l`
else
   moCount=`cat $moFile | grep -wi "moType BscM:$moType" |wc -l`
fi
echo $moCount
}
#### Merge the data into a File #####
dumpStats()
{
 simName=$1
 nodeName=$2
 moFile=/netsim/$nodeName".mo"
 numOfCells=`getStats $moFile "GeranCell"`
 gsmInternalRelations=`getStats $moFile "GeranCellRelation"`
 gsmExternalRelations=`getStats $moFile "ExternalGeranCellRelation"`
 gsmUtranCellRelations=`getStats $moFile "UtranCellRelation"`
 gsmExtUtranCells=`getStats $moFile "ExternalUtranCell"`
# gsmTrx=`getStats $moFile "G12Trxc"`
 if [[ $nodeName == "M48B96" ]] && [[ "$simName" == *"8000"* ]]
 then
     sectorTg=`getStats $moFile "G31Tg"`
 else
     Stg=`getStats $moFile "G31Tg"`
     sectorTg=$(($Stg/3))
 fi
 numOfOtg=`getStats $moFile "G12Tg"`
# overLaidSubCells=`getStats $moFile "OverlaidSubcell"`
 totalMos=`getStats $moFile "ALL"`
# totalNodeMos=`getStats $FILE "ALL"`
# totalSimMos=`expr $totalSimMos + $totalNodeMos`
 #echo "$numOfCells,$gsmInternalRelations,$gsmExternalRelations,$gsmTrx,$sectorTg,$numOfOtg,$overLaidSubCells,$totalMos"
 echo "$numOfCells,$gsmInternalRelations,$gsmExternalRelations,$gsmUtranCellRelations,$gsmExtUtranCells,$numOfOtg,$sectorTg,$totalMos"
}
dumpCsvStats()
{
simName=$1
NODENAME=$2
statsFile="/netsim/netsimdir/$simName/SimNetRevision/NetworkStats.csv"
moCount=`echo -e '.open '$simName' \n .select '$NODENAME' \n .start \n dumpmotree:count;' |  sudo su -l netsim -c /netsim/inst/netsim_shell | cut -d' ' -f1 | tail -n+8 | head -n-1`
#moCount=0
numOfCells=`cat $statsFile |  grep $NODENAME | grep "NumOfGsmCells" | awk -F"NumOfGsmCells=" '{print $2}'`
gsmInternalRelations=`cat $statsFile |  grep $NODENAME | grep "GsmInternalCellRelations" | awk -F"GsmInternalCellRelations=" '{print $2}'`
gsmExternalRelations=`cat $statsFile |  grep $NODENAME | grep "GsmExternalRelations" | awk -F"GsmExternalRelations=" '{print $2}'`
gsmIntraCellRelations=`cat $statsFile |  grep $NODENAME | grep "GsmIntraCellRelations" | awk -F"GsmIntraCellRelations=" '{print $2}'`
externalGsmRelations=`cat $statsFile |  grep $NODENAME | grep "ExternalGsmRelations" | awk -F"ExternalGsmRelations=" '{print $2}'`
gsmInternalCellRelations=$(($gsmInternalRelations+$gsmIntraCellRelations))
gsmExtCellRelations=$(($gsmExternalRelations+$externalGsmRelations))
utranCellRelations=`cat $statsFile |  grep $NODENAME | grep "UtranRelations" | awk -F"UtranRelations=" '{print $2}'`
externalUtranCells=`cat $statsFile |  grep $NODENAME | grep "ExternalUtranCells" | awk -F"ExternalUtranCells=" '{print $2}'`
numOfOtg=`cat $statsFile |  grep $NODENAME | grep "NumOfG1Bts" | awk -F"NumOfG1Bts=" '{print $2}'`
if [[ $NODENAME == "M48B96" ]] && [[ "$simName" =~ *"8000"* ]]
then
    numOfStg=`cat $statsFile |  grep $NODENAME | grep "NumOfG2Bts" | awk -F"NumOfG2Bts=" '{print $2}'`
else
    Stg=`cat $statsFile |  grep $NODENAME | grep "NumOfG2Bts" | awk -F"NumOfG2Bts=" '{print $2}'`
    numOfStg=$(($Stg/3))
fi
#echo "$numOfCells,$gsmInternalRelations,$gsmExternalRelations,$gsmIntraCellRelations,$externalGsmRelations,$utranCellRelations,$externalUtranCells,$numOfOtg,$numOfStg,$moCount"
echo "$numOfCells,$gsmInternalCellRelations,$gsmExtCellRelations,$utranCellRelations,$externalUtranCells,$numOfOtg,$numOfStg,$moCount"
}
#######################################################################################
#MAIN
#######################################################################################
### Checking the MO statistics ###
echo "SimName,NumOfCells,NumOfGeranCellRelation,NumOfExtGeranCellRelations,UtranCellRelations,ExternalUtranCells,NumOfG1BTS,NumofG2BTS,TotalBscMos" >> $gsmStatsFile
echo "Simulation,BscNodes,MscNodes,LanSwitchNodes,MSRBSNodes,NumOfIpv6Nes,numOfIpv4Nes,TotalNumOfNodes" >> $serverName"_NodeIpData.txt"
for simName in ${simulations[@]}
do
   ## Num Of Ipv6 and Ipv4 nodes ##
   if [[ $simName == *"-02-"* ]] || [[ $simName == *"-03-"* ]] || [[ $simName == *"-04-"* ]] || [[ $simName == *"-05-"* ]] || [[ $simName == *"-06-"* ]] || [[ $simName == *"-07-"* ]] || [[ $simName == *"-08-"* ]] || [[ $simName == *"-09-"* ]] || [[ $simName == *"-10-"* ]]
   then
        numOfBscNodes=0
	numOfMscNodes=0
	numOfLanSwitchNes=0
	numOFMSRBSNodes=`echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "LTE MSRBS-V2" | cut -d' ' -f1 | wc -l`
	ipv6NesList=()
	ipv6NesList+=($(echo -e ".open $simName\n .show simnes" | sudo su -l netsim -c /netsim/inst/netsim_shell | grep -vE "LTE BSC|LTE MSC|GSM LANSWITCH|CP|SX|IPLB|IS" | grep "::" | sort | awk -F" " '{print $1}'))
	numOfIpv6Nes=${#ipv6NesList[@]}
	numOfSimNes=`echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "LTE MSRBS-V2" | cut -d' ' -f1 | wc -l`
	numOfIpv4Nes=`expr $numOfSimNes - $numOfIpv6Nes`
   else

   ipv6NesList=()
   ipv6NesList+=($(echo -e ".open $simName\n .show simnes" | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "::" | sort | awk -F" " '{print $1}'))
   numOfIpv6Nes=${#ipv6NesList[@]}
   numOfSimNes=`echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | cut -d' ' -f1 | tail -n+5 | head -n-1 | wc -l`
   numOfBscNodes=`echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "LTE BSC" | cut -d' ' -f1 | wc -l`
#   numOfBscLegacyNodes=`echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "GSM BSC" | cut -d' ' -f1 | wc -l`
   numOfMscNodes=`echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "LTE MSC" | cut -d' ' -f1 | wc -l`
   numOfLanSwitchNes=`echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "GSM LANSWITCH" | cut -d' ' -f1 | wc -l`
   numOFMSRBSNodes=`echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "LTE MSRBS-V2" | cut -d' ' -f1 | wc -l`
   numOfIpv4Nes=`expr $numOfSimNes - $numOfIpv6Nes`
   fi
   echo "$simName,$numOfBscNodes,$numOfMscNodes,$numOfLanSwitchNes,$numOFMSRBSNodes,$numOfIpv6Nes,$numOfIpv4Nes,$numOfSimNes" >> $serverName"_NodeIpData.txt"
   echo "$simName,$numOfBscNodes,$numOfMscNodes,$numOfLanSwitchNes,$numOFMSRBSNodes,$numOfIpv6Nes,$numOfIpv4Nes,$numOfSimNes" >> $serverName"_gsmNodeStats.txt"
   #numOfCells=0;gsmInternalRelations=0;gsmExternalRelations=0;gsmTrx=0;sectorTg=0;numOfOtg=0;overLaidSubCells=0;totalMos=0
   numOfCells=0;numOfGsmCellRelations=0;numOfExtGeranCellRelations=0;numOfUtranCellRelations=0;
   numOfExternalUtranCells=0;numOfG1BTS=0;numOfG2BTS=0;totalMos=0;
   if [[ $simName == *"-02-"* ]] || [[ $simName == *"-03-"* ]] || [[ $simName == *"-04-"* ]] || [[ $simName == *"-05-"* ]] || [[ $simName == *"-06-"* ]] || [[ $simName == *"-07-"* ]] || [[ $simName == *"-08-"* ]] || [[ $simName == *"-09-"* ]] || [[ $simName == *"-10-"* ]]
   then
	 echo "No need to Check the Relation Data for this Simulation $simName"
   else
   statsFile="/netsim/netsimdir/"$simName"/SimNetRevision/networkStats.csv"
   echo -e '.open '$simName' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep "LTE BSC" | cut -d' ' -f1 > dumpNeName.txt
   if [ -e $statsFile ]
   then
 #     numOfCells=0;gsmInternalRelations=0;gsmExternalRelations=0;gsmIntraCellRelations=0;externalGsmRelations=0;
  #    utranCellRelations=0;externalUtranCells=0;numOfOtg=0;numOfStg=0;totalMos=0;
      numOfCells=0;numOfGsmCellRelations=0;numOfExtGeranCellRelations=0;numOfUtranCellRelations=0;
      numOfExternalUtranCells=0;numOfG1BTS=0;numOfG2BTS=0;totalMos=0;
      while read -r node; do
      NODENAME=$node
      statsData=`dumpCsvStats $simName $NODENAME`
      mosList=(${statsData//,/ })
      numOfCells=$(($numOfCells+${mosList[0]}))
      numOfGsmCellRelations=$(($numOfGsmCellRelations+${mosList[1]}))
      numOfExtGeranCellRelations=$(($numOfExtGeranCellRelations+${mosList[2]}))
      numOfUtranCellRelations=$(($numOfUtranCellRelations+${mosList[3]}))
      numOfExternalUtranCells=$(($numOfExternalUtranCells+${mosList[4]}))
      numOfG1BTS=$(($numOfG1BTS+${mosList[5]}))
      numOfG2BTS=$(($numOfG2BTS+${mosList[6]}))
      totalMos=$(($totalMos+${mosList[7]}))
#      gsmInternalRelations=$(($gsmInternalRelations+${mosList[1]}))
#      gsmExternalRelations=$(($gsmExternalRelations+${mosList[2]}))
#      gsmIntraCellRelations=$(($gsmIntraCellRelations+${mosList[3]}))
#      externalGsmRelations=$(($externalGsmRelations+${mosList[4]}))
#      utranCellRelations=$(($utranCellRelations+${mosList[5]}))
#      externalUtranCells=$(($externalUtranCells+${mosList[6]}))
#      numOfOtg=$(($numOfOtg+${mosList[7]}))
#      numOfStg=$(($numOfStg+${mosList[8]}))
#      totalMos=$(($totalMos+${mosList[9]}))
      done < dumpNeName.txt
      SIMNUM="${simName:(-2)}"
#      echo "GSM$SIMNUM,$numOfCells,$gsmInternalRelations,$gsmIntraCellRelations,$gsmExternalRelations,$externalGsmRelations,$utranCellRelations,$externalUtranCells,$numOfOtg,$numOfStg,$totalMos" >> $gsmStatsFile
#      echo "$simName,$numOfCells,$gsmInternalRelations,$gsmIntraCellRelations,$gsmExternalRelations,$externalGsmRelations,$utranCellRelations,$externalUtranCells,$numOfOtg,$numOfStg,$totalMos" >> $serverName"_gsmMoStats.txt"
      echo "GSM$SIMNUM,$numOfCells,$numOfGsmCellRelations,$numOfExtGeranCellRelations,$numOfUtranCellRelations,$numOfExternalUtranCells,$numOfG1BTS,$numOfG2BTS,$totalMos" >> $gsmStatsFile
      echo "$simName,$numOfCells,$numOfGsmCellRelations,$numOfExtGeranCellRelations,$numOfUtranCellRelations,$numOfExternalUtranCells,$numOfG1BTS,$numOfG2BTS,$totalMos" >> $serverName"_gsmMoStats.txt"
   else
        numOfCells=0;numOfGsmCellRelations=0;numOfExtGeranCellRelations=0;numOfUtranCellRelations=0;
	numOfExternalUtranCells=0;numOfG1BTS=0;numOfG2BTS=0;totalMos=0;
        while read -r node; do
        NODENAME=$node
        MOSCRIPT=/netsim/$NODENAME".mo"
        MMLSCRIPT=$NODENAME".mml"
        touch $MOSCRIPT
        chmod 777 $MOSCRIPT
        echo '.open '$simName >> $MMLSCRIPT
        echo '.select '$NODENAME >> $MMLSCRIPT
        echo '.start ' >> $MMLSCRIPT
        echo 'dumpmotree:moid=1,ker_out,outputfile="'$MOSCRIPT'";' >> $MMLSCRIPT
        sudo su -l netsim -c /netsim/inst/netsim_shell < $MMLSCRIPT 2>&1 >/dev/null
        if [ $? != 0 ]; then
           echo "ERROR: Failed to start the nodes in the simulation $simName"
           exit -1
        fi
        nodeDataList=`dumpStats $simName $NODENAME`
        nodeData=(${nodeDataList//,/ })
        numOfCells=`expr $numOfCells + ${nodeData[0]}`
        numOfGsmCellRelations=`expr $numOfGsmCellRelations + ${nodeData[1]}`
        numOfExtGeranCellRelations=`expr $numOfExtGeranCellRelations + ${nodeData[2]}`
	numOfUtranCellRelations=`expr $numOfUtranCellRelations + ${nodeData[3]}`
	numOfExternalUtranCells=`expr $numOfExternalUtranCells + ${nodeData[4]}`
	numOfG1BTS=`expr $numOfG1BTS + ${nodeData[5]}`
	numOfG2BTS=`expr $numOfG2BTS + ${nodeData[6]}`
        totalMos=`expr $totalMos + ${nodeData[7]}`
#        gsmTrx=`expr $gsmTrx + ${nodeData[3]}`
#        sectorTg=`expr $sectorTg + ${nodeData[4]}`
#        numOfOtg=`expr $numOfOtg + ${nodeData[5]}`
#        overLaidSubCells=`expr $overLaidSubCells + ${nodeData[6]}`
#        totalMos=`expr $totalMos + ${nodeData[7]}`
        rm $MOSCRIPT
        rm $MMLSCRIPT
      done < dumpNeName.txt
      SIMNUM="${simName:(-2)}"
    #echo "$simName,$numOfCells,$gsmInternalRelations,$gsmExternalRelations,$gsmTrx,$sectorTg,$numOfOtg,$overLaidSubCells,$totalMos" >> $gsmStatsFile
    #echo "$simName,$numOfCells,$gsmInternalRelations,$gsmExternalRelations,$gsmTrx,$sectorTg,$numOfOtg,$overLaidSubCells,$totalMos" >> $serverName"_gsmMoStats.txt"
    echo "GSM$SIMNUM,$numOfCells,$numOfGsmCellRelations,$numOfExtGeranCellRelations,$numOfUtranCellRelations,$numOfExternalUtranCells,$numOfG1BTS,$numOfG2BTS,$totalMos" >> $gsmStatsFile
    echo "$simName,$numOfCells,$numOfGsmCellRelations,$numOfExtGeranCellRelations,$numOfUtranCellRelations,$numOfExternalUtranCells,$numOfG1BTS,$numOfG2BTS,$totalMos" >> $serverName"_gsmMoStats.txt"
   fi
   fi
#######################################################################################
### Copying Data ###
#######################################################################################
rm dumpNeName.txt
done

moStatsFile=$serverName"_gsmMoStats.txt"
nodeStatsFile=$serverName"_gsmNodeStats.txt"

yum -y install sshpass


simsList=`ls /netsim/netsimdir | grep ".*-GSM" | grep -vE ".zip|-02-|-03-|-04-|-05-|-06-|-07-|-08-|-09-|-10-"`

if [ -n "$simsList" ]
then
     sshpass -p shroot ssh -o StrictHostKeyChecking=no root@$masterServer.athtem.eei.ericsson.se "mkdir -p $workSpace"
     sshpass -p shroot scp -o StrictHostKeyChecking=no $workPath/$moStatsFile root@$masterServer.athtem.eei.ericsson.se:$workSpace
fi

sshpass -p shroot scp -o StrictHostKeyChecking=no $workPath/$nodeStatsFile root@$masterServer.athtem.eei.ericsson.se:$workSpace


: <<'END'
#cat >> copyData << SCR
/usr/bin/expect<<EOF
    set timeout -1
    spawn ssh -o StrictHostKeyChecking=no -p 22 netsim@$masterServer.athtem.eei.ericsson.se mkdir $workSpace
    expect {
            -re Are {send "yes\r";exp_continue}
        -re assword: {send "shroot\r";exp_continue}
    }
    sleep 1
    spawn scp -o StrictHostKeyChecking=no $workPath/$nodeStatsFile netsim@$masterServer.athtem.eei.ericsson.se:$workSpace
    expect {
        -re Password: {send "shroot\r";exp_continue}
    }
    sleep 1

    spawn scp -o StrictHostKeyChecking=no $workPath/$moStatsFile netsim@$masterServer.athtem.eei.ericsson.se:$workSpace
    expect {
        -re Password: {send "shroot\r";exp_continue}
    }
    sleep 1
EOF
#SCR

#/usr/bin/expect < copyData &> /dev/null
END

echo "############################ GSM CheckList on $serverName #####################################" >> $serverName"_FinalSummary.txt"
column -t -s',' $serverName"_NodeIpData.txt" >> $serverName"_FinalSummary.txt"
echo "------------------------------------------------------------------------------------------------" >> $serverName"_FinalSummary.txt"
column -t -s',' $gsmStatsFile >> $serverName"_FinalSummary.txt"
echo "#################################################################################################" >> $serverName"_FinalSummary.txt"
cat $serverName"_FinalSummary.txt"
