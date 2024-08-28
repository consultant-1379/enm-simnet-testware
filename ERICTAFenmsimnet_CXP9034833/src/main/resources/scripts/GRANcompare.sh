#!/bin/sh
networkSize=$1
nrm=$2
jsonLink="https://nss.seli.wh.rnd.internal.ericsson.com/NetworkConfiguration/rest/config/nrm/${nrm}"
workSpace=/netsim/Gsm_CheckForRV
#logsDir=/var/simnet/enm-simnet/scripts/Simstats
logsDir=`pwd`
nodeDetailsFile=$workSpace"/GsmTotalNodesSummary.txt"
moDetailsFile=$workSpace"/GsmTotalMoSummary.txt"
##########################################################
if [ "$#" -ne 2  ]
then
 echo
 echo "Usage: $0 <networkSize> <nrm>"
 echo
 echo "-------------------------------------------------------------------"
 echo "# Please give proper inputs to the script $0 !!!! #"
 echo "###################################################################"
 exit 1
fi

cd $workSpace
###### check if old stats files exist #######
if [[ -f $nodeDetailsFile ]]; then
rm -rf $nodeDetailsFile
fi

if [[ -f $moDetailsFile ]]; then
rm -rf $moDetailsFile
fi

if [[ -f totalGsmNetworkReport.txt ]]; then
rm -rf totalGsmNetworkReport.txt
fi

if [[ -f $logsDir/GsmFinalNetworkReport.txt ]]; then
rm -rf $logsDir/GsmFinalNetworkReport.txt
fi

##### Fetching the servers list ########
ls | grep "gsmMoStats" | cut -d'_' -f1 > Moservers.list
ls | grep "gsmNodeStats" | cut -d'_' -f1 > NodeServers.list

while IFS= read serverName ;
do
cat $serverName"_gsmMoStats.txt" >> $moDetailsFile
cat $serverName"_gsmMoStats.txt"
done < Moservers.list

echo "****************************************"

while IFS= read serverName ;
do
cat $serverName"_gsmNodeStats.txt" >> $nodeDetailsFile
cat $serverName"_gsmNodeStats.txt"
done < NodeServers.list

#rm servers.list

counter=0
while IFS= read line ;
do
    nodeStats=(${line//,/ })
    numOfBscNodes[$counter]=${nodeStats[1]}
  #  numOfBscLegacyNodes[$counter]=${nodeStats[2]}
    numOfMscNodes[$counter]=${nodeStats[2]}
    numOfLanSwitchNes[$counter]=${nodeStats[3]}
    numOfMSRBSNodes[$counter]=${nodeStats[4]}
    numOfIpv6Nes[$counter]=${nodeStats[5]}
    numOfIpv4Nes[$counter]=${nodeStats[6]}
    numOfSimNes[$counter]=${nodeStats[7]}
    counter=$[counter+1]
done < $nodeDetailsFile

counter=0
while IFS= read Line ;
do
    moStats=(${Line//,/ })
    numOfCells[$counter]=${moStats[1]}
    numOfGsmInternalRelations[$counter]=${moStats[2]}
    numOfGsmExtRelations[$counter]=${moStats[3]}
    numOfUtranCellRelations[$counter]=${moStats[4]}
    numOfExternalUtranCells[$counter]=${moStats[5]}
    numOfG1BTS[$counter]=${moStats[6]}
    numOfG2BTS[$counter]=${moStats[7]}
    totalMos[$counter]=${moStats[8]}
    counter=$[counter+1]
done < $moDetailsFile

####### Aggregating all the data from the network ###############
totalNumOfBscNodes=`echo "${numOfBscNodes[@]/%/+}0" | bc`
#totalNumOfBscLegacyNodes=`echo "${numOfBscLegacyNodes[@]/%/+}0" | bc`
totalNumOfMscNodes=`echo "${numOfMscNodes[@]/%/+}0" | bc`
totalNumOfLanSwitchNes=`echo "${numOfLanSwitchNes[@]/%/+}0" | bc`
totalNumOfMSRBSNodes=`echo "${numOfMSRBSNodes[@]/%/+}0" | bc`
totalNumOfIpv6Nes=`echo "${numOfIpv6Nes[@]/%/+}0" | bc`
totalNumOfIpv4Nes=`echo "${numOfIpv4Nes[@]/%/+}0" | bc`
totalNumOfSimNes=`echo "${numOfSimNes[@]/%/+}0" | bc`
ipv4Percent=`echo "100*$totalNumOfIpv4Nes/$totalNumOfSimNes" | bc -l`
ipv6Percent=`echo "100*$totalNumOfIpv6Nes/$totalNumOfSimNes" | bc -l`
totalNumOfCells=`echo "${numOfCells[@]/%/+}0" | bc`
totalGsmInternalRelations=`echo "${numOfGsmInternalRelations[@]/%/+}0" | bc`
totalGsmExtRelations=`echo "${numOfGsmExtRelations[@]/%/+}0" | bc`
totalUtranCellRelations=`echo "${numOfUtranCellRelations[@]/%/+}0" | bc`
totalExternalUtranCells=`echo "${numOfExternalUtranCells[@]/%/+}0" | bc`
totalG1BTS=`echo "${numOfG1BTS[@]/%/+}0" | bc`
totalG2BTS=`echo "${numOfG2BTS[@]/%/+}0" | bc`
totalGsmMos=`echo "${totalMos[@]/%/+}0" | bc`
totalGsmRelations=`expr $totalGsmInternalRelations + $totalGsmExtRelations`

##### Downloading Json Data ####################
#curl -O "https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/service/local/repositories/nss/content/com/ericsson/nss/scripts/jq/1.0.1/jq-1.0.1.tar"  ; tar -xvf jq-1.0.1.tar ; chmod +x ./jq

cd $logsDir
chmod 777 jq-1.0.1.tar
tar -xvf jq-1.0.1.tar
chmod +x ./jq

#### Extracting NSSO Data from json file #######
wget -q -O - --no-check-certificate $jsonLink > Data.json
./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."GRAN Node Split")' Data.json > gsmData.json
#### SubRoutines ###############################
#### Extracting Nsso Attributes ####
extractNssoData() {
moAttribute=$1
attributeValue=$(./jq --raw-output '.[] | select (.name=="'"$moAttribute"'") | (."value")' gsmData.json)
if [[ "$attributeValue" == "" ]]
then
   attributeValue=0
fi
echo $attributeValue
}
#### Compare the network data with nsso Data ############
compareData() {
attributeName=$1
actualData=$2
nssoData=$3
if [ "$nssoData" -le "$actualData" ]
then
   if [ "$nssoData" -eq "0" ] && [ "$actualData" -ne "0" ]
   then
      status="FAILED"
   else
      status="PASSED"
   fi
else
   status="FAILED"
fi
echo "$attributeName $actualData $nssoData $status" >> totalGsmNetworkReport.txt
}
nssoGsmCells=$(extractNssoData "GSM Cell")
nssoGsmInternalRelations=$(extractNssoData "GSM Internal Cell Relations")
nssoGsmExternalRelations=$(extractNssoData "GSM External Cell Relations")
nssoUtranCellRelations=$(extractNssoData "UtranRelations")
nssoExternalUtranCells=$(extractNssoData "ExternalUtranCells")
nssoG1BTS=$(extractNssoData "G1 BTS Count")
nssoG2BTS=$(extractNssoData "G2 BTS Count")
nssoTotalMOs=$(extractNssoData "Total BSC MOs")
nssoGsmRelations=$(extractNssoData "GSM Cell Relations")

#nssoBscMoCount=$(extractNssoData "ExternalUtranCells")
#### Comparing the stats with NSSO data ####################

echo "Field Obtained_Value NSSO_Value Status" >> totalGsmNetworkReport.txt
`compareData "Total_Gsm_Cells" $totalNumOfCells $nssoGsmCells`
`compareData "GsmInternalRelations" $totalGsmInternalRelations $nssoGsmInternalRelations`
`compareData "GsmExternalRelations" $totalGsmExtRelations $nssoGsmExternalRelations`
`compareData "UtranCellRelations" $totalUtranCellRelations $nssoUtranCellRelations`
`compareData "ExternalUtranCells" $totalExternalUtranCells $nssoExternalUtranCells`
`compareData "G1BTS" $totalG1BTS $nssoG1BTS`
`compareData "G2BTS" $totalG2BTS $nssoG2BTS`
`compareData "TotalRelations" $totalGsmRelations $nssoGsmRelations`
#`compareData "TotalMOs" $totalGsmMos $nssoTotalMOs`
cat >> $logsDir/GsmFinalNetworkReport.txt << STATS
##################################################################
#        TOTAL NETWORK REPORT                                     #
###################################################################

Summary of Nodes in network
############################################################\n
Total number of BSC Nodes in Network are $totalNumOfBscNodes
Total number of MSC Nodes in Network are $totalNumOfMscNodes
Total number of Lanswitch Nodes in Network are $totalNumOfLanSwitchNes
Total number of MSRBS Nodes in Network are $totalNumOfMSRBSNodes
Total number of Nodes in Network are $totalNumOfSimNes
Total IPV4 nodes in Network are $totalNumOfIpv4Nes
IPV4 percentage in Network is $ipv4Percent%
Total IPV6 nodes in Network are $totalNumOfIpv6Nes
IPV6 percent in Network is $ipv6Percent%
Total number of BSC MOs Count in Network is $totalGsmMos\n
####################################################################
*******  COMPARING NETWORK WITH NSSO DATA  *************************

STATS
###### Displaying END  Result #########

if [ -s "totalGsmNetworkReport.txt" ]
then
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  totalGsmNetworkReport.txt >> $logsDir/GsmFinalNetworkReport.txt
fi
echo "####### END OF THE REPORT #####################################" >> $logsDir/GsmFinalNetworkReport.txt
cat $logsDir/GsmFinalNetworkReport.txt
buildStatus=`cat totalGsmNetworkReport.txt | grep -i "FAILED" |wc -l`
#rm -rf /netsim/Gsm_CheckForRV
if [ "$buildStatus" != "0" ]
then
echo "GsmHealthCheck Failed ...!!!"
exit 901
fi
