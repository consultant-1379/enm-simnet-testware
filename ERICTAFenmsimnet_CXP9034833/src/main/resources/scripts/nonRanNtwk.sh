#!/bin/sh
# Created by  : Harish Dunga
# Created in  : 12 05 2018
##
### VERSION HISTORY
###################################################
# Ver1        : Modified for ENM
# Purpose     : To validate non-RAN Checklist with NSSO
# Description :
# Date        : 12 05 2018
# Who         : Harish Dunga
###################################################
networkType=$1
jsonLink="http://nss.lmera.ericsson.se/NetworkConfiguration/rest/config/nrm/ENM18.1-NRM4.1"
workSpace=/netsim/CoreCheckForRv
supportLog=TotalNodeSupport.txt

if [ "$#" -ne 1  ]
then
 echo
 echo "Usage: $0 <networkType>"
 echo
 echo "-------------------------------------------------------------------"
 echo "# Please give proper inputs to the script $0 !!!! #"
 echo "###################################################################"
 exit 1
fi

if [ -d $workSpace ]
then
   cd $workSpace
else
   echo "ERROR: The directory $workSpace does not exist ...!!!!"
   exit 1
fi

if [ -e NonRanNetworkReport.txt ]
then
   rm NonRanNetworkReport.txt
   rm NonRanFinalSummary.txt
fi
########################################################
#Deleting and creating files
########################################################

if [[ -f $supportLog ]]; then
rm -rf $supportLog
fi

getTotalData() {
counter=0
supportLog=TotalNodeSupport.txt
ls | grep "_simulationSummary.txt" | cut -d'_' -f1 > servers.list
while IFS= read serverName ; 
do 
  cat $serverName"_support.log" >> $supportLog
  summaryFile=$serverName"_simulationSummary.txt"
  NodeLine=$( tail -n+2 $summaryFile )
  totalCount=(${NodeLine//,/ })
  totalNumberOfNodes[$counter]=${totalCount[2]}
  totalNumberOfIPV4nodes[$counter]=${totalCount[3]}
  totalNumberOfIPV6Nodes[$counter]=${totalCount[4]}
  totalNumberOfMos[$counter]=${totalCount[5]}
  counter=$[counter+1]
done < servers.list
totalNumberOfNodes=`echo "${totalNumberOfNodes[@]/%/+}0" | bc`
totalNumberOfIPV4nodes=`echo "${totalNumberOfIPV4nodes[@]/%/+}0" | bc`
totalNumberOfIPV6Nodes=`echo "${totalNumberOfIPV6Nodes[@]/%/+}0" | bc`
echo "$totalNumberOfNodes,$totalNumberOfIPV4nodes,$totalNumberOfIPV6Nodes"
}

getNodeData() {
neType=$1
counter=0
ls | grep "_simulationSummary.txt" | cut -d'_' -f1 > servers.list
while IFS= read serverName ; 
do 
  summaryFile=$serverName"_simulationSummary.txt"
  NodeLine=$( tail -n+2 $summaryFile | grep -i "$neType" )
  if [[ "$NodeLine" == "" ]]
  then
     NodeLine="0,0,0,0,0,0"
  fi
  totalCount=(${NodeLine//,/ })
  totalNumberOfNodes[$counter]=${totalCount[2]}
  totalNumberOfIPV4nodes[$counter]=${totalCount[3]}
  totalNumberOfIPV6Nodes[$counter]=${totalCount[4]}
  totalNumberOfMos[$counter]=${totalCount[5]}
  counter=$[counter+1]
done < servers.list
totalNumberOfNodes=`echo "${totalNumberOfNodes[@]/%/+}0" | bc`
totalNumberOfIPV4nodes=`echo "${totalNumberOfIPV4nodes[@]/%/+}0" | bc`
totalNumberOfIPV6Nodes=`echo "${totalNumberOfIPV6Nodes[@]/%/+}0" | bc`
totalNumberOfMos=`echo "${totalNumberOfMos[@]/%/+}0" | bc`
echo "$totalNumberOfNodes,$totalNumberOfIPV4nodes,$totalNumberOfIPV6Nodes,$totalNumberOfMos"
}

nodeData=`getNodeData TCU02`
tcuCount=(${nodeData//,/ })
nodeData=`getNodeData SIU02`
siuCount=(${nodeData//,/ })
nodeData=`getNodeData ML6352`
minilinkCount=(${nodeData//,/ })
nodeData=`getNodeData MLTN54FP`
miniTnCount=(${nodeData//,/ })
nodeData=`getNodeData SpitFire`
spitFireCount=(${nodeData//,/ })
nodeData=`getNodeData SGSN`
sgsnCount=(${nodeData//,/ })
nodeData=`getNodeData MGW`
mgwCount=(${nodeData//,/ })
nodeData=`getNodeData EPG`
epgCount=(${nodeData//,/ })
nodeData=`getNodeData MTAS`
mtasCount=(${nodeData//,/ })
nodeData=`getNodeData DSC`
dscCount=(${nodeData//,/ })

totalnOfTCU02=${tcuCount[0]}
totalnOfSIU02=${siuCount[0]}
totalnOfML6352=${minilinkCount[0]}
totalnOfMLTN54FP=${miniTnCount[0]}
totalnOfSpitFire=${spitFireCount[0]}
totalnOfSGSN=${sgsnCount[0]}
totalnOfMGw=${mgwCount[0]}
totalnOfEPG=${epgCount[0]}
totalnOfMTAS=${mtasCount[0]}
totalnOfDSC=${dscCount[0]}

totalMoTCU02=${tcuCount[3]}
totalMoSIU02=${siuCount[3]}
totalMoML6352=${minilinkCount[3]}
totalMoMLTN54FP=${miniTnCount[3]}
totalMoSpitFire=${spitFireCount[3]}
totalMoSGSN=${sgsnCount[3]}
totalMoMGw=${mgwCount[3]}
totalMoEPG=${epgCount[3]}
totalMoMTAS=${mtasCount[3]}
totalMoDSC=${dscCount[3]}

totalnetworkData=`getTotalData`
totalData=(${totalnetworkData//,/ })
totalNumberOfNodes=${totalData[0]}
totalNumberOfIPV4nodes=${totalData[1]}
totalNumberOfIPV6Nodes=${totalData[2]}
Ipv4Percent=`echo "100*$totalNumberOfIPV4nodes/$totalNumberOfNodes" | bc -l`
Ipv6Percent=`echo "100*$totalNumberOfIPV6Nodes/$totalNumberOfNodes" | bc -l`

echo "###############    DOWNLOADING JSON DATA ....   ###############"

#echo "#######   Downloading jq script   #######"
curl -O "https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/service/local/repositories/nss/content/com/ericsson/nss/scripts/jq/1.0.1/jq-1.0.1.tar"  ; tar -xvf jq-1.0.1.tar ; chmod +x ./jq

#echo "#######   Calling REST CALL   #######"
wget -q -O - --no-check-certificate $jsonLink > Data.json

### Fetch Node Type wise data from json ###

getNSSOdata() {

networkType=$2
netype=$1
Node_Count=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."NE Count")' coreData.json)
MO_Count=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."MO Count")' coreData.json)
PMFileSize=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."PM File Size")' coreData.json)
PMCounterVolume=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."PM Counter Volume")' coreData.json)
echo "$Node_Count,$MO_Count,$PMFileSize,$PMCounterVolume"
}

checkNodePopulatorSupport() {
netype=$1
supportLog=$2
Check=`cat $supportLog | grep -i "node Populator is supported for $netype" |wc -l`
if [ "$Check" -gt "0" ]
then
   echo "INFO: Node Populator is supported for $netype" >> NonRanNetworkReport.txt
else
   echo "INFO: Node Populator is supported for $netype" >> NonRanNetworkReport.txt
fi
}

if [ "$networkType" == "rvModuleTransport_5KNodes" ] || [ "$networkType" == "rvModuleTransport_10KNodes" ] || [  "$networkType" == "rvModuleTransport_7.5KNodes" ] || [ "$networkType" == "rvModuleTransport_20KNodes" ] || [ "$networkType" == "rvModuleCore_340Nodes" ]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="vLarge (60k)") | (."Non-RAN Node Split Table")' Data.json > coreData.json   
   
elif [ "$networkType" == "rvModuleTransport_Small" ] || [ "$networkType" == "rvModuleCore_Small" ]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="Small (5k)") | (."Non-RAN Node Split Table")' Data.json > coreData.json
    
fi

if [[ "$networkType" =~ "Transport" ]]
then
   NssoDataOfTcuSiu=`getNSSOdata "TCU/SIU" $networkType`
   NssoDataOfML6352=`getNSSOdata "MINI-LINK" $networkType`
   NssoDataOfMLTN54FP=`getNSSOdata "MINI-LINK TN" $networkType`
   NssoDataOfSpitFire=`getNSSOdata "R6672" $networkType`
   
   NssoListOfTcuSiu=(${NssoDataOfTcuSiu//,/ })
   NssoListOfML6352=(${NssoDataOfML6352//,/ })
   NssoListOfMLTN54FP=(${NssoDataOfMLTN54FP//,/ })
   NssoListOfSpitFire=(${NssoDataOfSpitFire//,/ })

   
elif [[ "$networkType" =~ "Core" ]]
then
   NssoDataOfSGSN=`getNSSOdata "SGSN MME" $networkType`
   NssoDataOfMGw=`getNSSOdata "MGW" $networkType`
   NssoDataOfEPG=`getNSSOdata "EPG" $networkType`
   NssoDataOfMTAS=`getNSSOdata "MTAS" $networkType`
   NssoDataOfDSC=`getNSSOdata "DSC" $networkType`
   
   NssoListOfSGSN=(${NssoDataOfSGSN//,/ })
   NssoListOfMGw=(${NssoDataOfMGw//,/ })
   NssoListOfEPG=(${NssoDataOfEPG//,/ })
   NssoListOfMTAS=(${NssoDataOfMTAS//,/ })
   NssoListOfDSC=(${NssoDataOfDSC//,/ })
fi

if [ -e NonRanNetworkReport.txt ]
then
   rm NonRanNetworkReport.txt
fi

cat >> NonRanNetworkReport.txt << TXT
##################################################################
#        NON-RAN TOTAL NETWORK REPORT                                     #
###################################################################

Summary of Nodes in network
############################################################\n
Total number of Nodes in Network are $totalNumberOfNodes
Total IPV4 nodes in Network are $totalNumberOfIPV4nodes
Total IPV6 nodes in Network are $totalNumberOfIPV6Nodes
IPV4 percentage in Network is $Ipv4Percent%
IPV6 percent in Network is $Ipv6Percent%\n
####################################################################
###############        COMPARING WITH NSSO        ##################
TXT

#### Compare the network data with nsso Data ############
compareData() {
neType=$1
actualNodeData=$2
nssoNodeData=$3
actualMoData=$4
nssoMoData=$5
supportLog=$6
if [ "$actualNodeData" -ne "0" ]
then
   if [ "$nssoNodeData" -le "$actualNodeData" ] && [ "$nssoMoData" -le "$actualNodeData" ]
   then
      if [ "$nssoNodeData" -eq "0" ] && [ "$actualNodeData" -ne "0" ]
      then
         status="FAILED"
      elif [ "$nssoMoData" -eq "0" ] && [ "$actualMoData" -ne "0" ]
      then
         status="FAILED"
      else
         status="PASSED"
      fi
   else
      status="FAILED"
   fi
   `checkNodePopulatorSupport $neType $supportLog`
   echo "$neType,$actualNodeData,$nssoNodeData,$actualMoData,$nssoMoData,$status" >> NonRanFinalSummary.txt
fi
}
echo "NETYPE,NUM_OF_NODES(Obtained),NUM_OF_NODES(Target),NUM_OF_MOS(Obtained),NUM_OF_MOS(Target),STATUS" >> NonRanFinalSummary.txt
if [[ "$networkType" =~ "Transport" ]]
then
  `compareData "TCU02" $totalnOfTCU02 ${NssoListOfTcuSiu[0]} $totalMoTCU02 ${NssoListOfTcuSiu[1]} $supportLog`           
  `compareData "SIU02" $totalnOfSIU02 ${NssoListOfTcuSiu[0]} $totalMoSIU02 ${NssoListOfTcuSiu[1]} $supportLog`
  `compareData "ML6352" $totalnOfML6352 ${NssoListOfML6352[0]} $totalMoML6352 ${NssoListOfML6352[1]} $supportLog`
  `compareData "MLTN5-4FP" $totalnOfMLTN54FP ${NssoListOfMLTN54FP[0]} $totalMoMLTN54FP ${NssoListOfMLTN54FP[1]} $supportLog`
  `compareData "SpitFire" $totalnOfSpitFire ${NssoListOfSpitFire[0]} $totalMoSpitFire ${NssoListOfSpitFire[1]} $supportLog`
elif [[ "$networkType" =~ "Core" ]]
then
  `compareData "SGSN" $totalnOfSGSN ${NssoListOfSGSN[0]} $totalMoSGSN ${NssoListOfSGSN[1]} $supportLog`
  `compareData "MGW" $totalnOfMGW ${NssoListOfMGW[0]} $totalMoMGW ${NssoListOfMGW[1]} $supportLog`
  `compareData "EPG" $totalnOfEPG ${NssoListOfEPG[0]} $totalMoEPG ${NssoListOfEPG[1]} $supportLog`
  `compareData "MTAS" $totalnOfMTAS ${NssoListOfMTAS[0]} $totalMoMTAS ${NssoListOfMTAS[1]} $supportLog`
  `compareData "DSC" $totalnOfDSC ${NssoListOfDSC[0]} $totalMoDSC ${NssoListOfDSC[1]} $supportLog`
fi 

###### Displaying END  Result #########
echo "--------------------------------------------------------------------" >> NonRanNetworkReport.txt
column -t -s',' NonRanFinalSummary.txt >> NonRanNetworkReport.txt
cat NonRanNetworkReport.txt
buildStatus=`cat NonRanNetworkReport.txt | grep -i "FAILED" |wc -l`
if [ "$buildStatus" != "0" ]
then
echo "FAILED: There are some fields which did not meet the requirement ...!!!"
exit 901
fi
