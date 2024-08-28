#!/bin/sh
# Created by  : Harish Dunga
# Created in  : 12 05 2018
##
### VERSION HISTORY
####################################################
# Ver1        : Modified for ENM
# Purpose     : To validate non-RAN Checklist with NSSO
# Description :
# Date        : 12 05 2018
# Who         : Harish Dunga
###################################################
networkType=$1
nrm=$2
networkSize=$3
jsonLink="https://nss.seli.wh.rnd.internal.ericsson.com/NetworkConfiguration/rest/config/nrm/${nrm}/"
workSpace=/netsim/CoreCheckForRv/
supportLog=TotalNodeSupport.txt

if [ "$#" -ne 3  ]
then
 echo
 echo "Usage: $0 <networkType> <NRM> <networkSize>"
 echo
 echo "-------------------------------------------------------------------"
 echo "# Please give proper inputs to the script $0 !!!! #"
 echo "###################################################################"
 exit 1
fi

if [ -d $workSpace ]
then
   cd $workSpace
   cp * /var/simnet/enm-simnet/scripts/
   cd /var/simnet/enm-simnet/scripts/
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
#  NodeLine=$( tail -n+2 $summaryFile )
  declare -a myarray
 myarray=(`cat $summaryFile`)
#  NodeLine=$( tail -n+2 $summaryFile )
        length=${#myarray[@]}
#       echo "length is $length"
        for (( i=1; i<$length ; i++ ))
        do
        NodeLine=${myarray[i]}
  totalCount=(${NodeLine//,/ })
  totalNumberOfNodes[$counter]=${totalCount[2]}
  totalNumberOfIPV4nodes[$counter]=${totalCount[3]}
  totalNumberOfIPV6Nodes[$counter]=${totalCount[4]}
  totalNumberOfMos[$counter]=${totalCount[5]}
  counter=$[counter+1]
  done
done < servers.list
totalNumberOfNodes=`echo "${totalNumberOfNodes[@]/%/+}0" | bc`
totalNumberOfIPV4nodes=`echo "${totalNumberOfIPV4nodes[@]/%/+}0" | bc`
totalNumberOfIPV6Nodes=`echo "${totalNumberOfIPV6Nodes[@]/%/+}0" | bc`
echo "$totalNumberOfNodes,$totalNumberOfIPV4nodes,$totalNumberOfIPV6Nodes"
}


for i in `echo /var/simnet/enm-simnet/scripts/*simulationSummary.txt`; do
   #echo "file is $i"
    sed '1d' $i >> /var/simnet/enm-simnet/scripts/mergedOutputFile.txt
done

getNodeData() {
neType=$1

counter=0
#while IFS= read serverName ; 
NodeData=$( cat /var/simnet/enm-simnet/scripts/mergedOutputFile.txt | grep -i "$neType" )
NodeList=(${NodeData// / })
totalNumberOfNodes=()
for NodeLine in ${NodeList[@]}

do 
  #summaryFile=$serverName"_simulationSummary.txt"
  #NodeLine=$( tail -n+2 $summaryFile | grep -i "$neType" )
  #if [[ "$NodeLine" == "" ]]
  #then
  #   NodeLine="0,0,0,0,0,0"
  #fi
  totalCount=(${NodeLine//,/ })
  totalNumberOfNodes[$counter]=${totalCount[2]}
  totalNumberOfIPV4nodes[$counter]=${totalCount[3]}
  totalNumberOfIPV6Nodes[$counter]=${totalCount[4]}
  totalNumberOfMos[$counter]=${totalCount[5]}
  counter=$[counter+1]
done 
#< servers.list
totalNumberOfNodes=`echo "${totalNumberOfNodes[@]/%/+}0" | bc`
#totalNumberOfNodes=`dc <<< '[+]sa[z2!>az2!>b]sb'"${totalNumberOfNodes[*]}lbxp"`
totalNumberOfIPV4nodes=`echo "${totalNumberOfIPV4nodes[@]/%/+}0" | bc`
#totalNumberOfIPV4nodes=`dc <<< '[+]sa[z2!>az2!>b]sb'"${totalNumberOfIPV4nodes[*]}lbxp"`
totalNumberOfIPV6Nodes=`echo "${totalNumberOfIPV6Nodes[@]/%/+}0" | bc`
#totalNumberOfIPV6Nodes=`dc <<< '[+]sa[z2!>az2!>b]sb'"${totalNumberOfIPV6Nodes[*]}lbxp"`
totalNumberOfMos=`echo "${totalNumberOfMos[@]/%/+}0" | bc`
#totalNumberOfMos=`dc <<< '[+]sa[z2!>az2!>b]sb'"${totalNumberOfMos[*]}lbxp"`
echo "$totalNumberOfNodes,$totalNumberOfIPV4nodes,$totalNumberOfIPV6Nodes,$totalNumberOfMos"
}

#Gives total node data and stores in an array.
nodeData=`getNodeData TCU02`
tcuCount=(${nodeData//,/ })
nodeData=`getNodeData ERSN`
ersnCount=(${nodeData//,/ })
nodeData=`getNodeData MLTN6`
mltn6Count=(${nodeData//,/ })
echo "***********************mltn6Count=$mltn6Count*****"
nodeData=`getNodeData SIU02`
siuCount=(${nodeData//,/ })
nodeData=`getNodeData ML6352`
minilinkCount=(${nodeData//,/ })
#echo "mini link count (sim data) array= ${minilinkCount[@]}"
nodeData=`getNodeData Router6672`
Router6672Count=(${nodeData//,/ })
#echo "Router6672 count (sim data) array= ${Router6672Count[@]}"
nodeData=`getNodeData Router6274`
Router6274Count=(${nodeData//,/ })
#echo "Router6274 count (sim data) array= ${Router6274Count[@]}"
#nodeData=`getNodeData MINI-LINK TN\(Indoor\)`
#mlIndoorCount=(${nodeData//,/ })
#echo "minilink indoor array sim data Is=${mlIndoorCount[@]}"
#nodeData=`getNodeData MINI-LINK 6352`
#ml6352Count=(${nodeData//,/ })
#echo "mini link 6352 count (sim data) array= ${ml6352Count[@]}"
nodeData=`getNodeData CISCO-ASR900`
ciscoCount=(${nodeData//,/ })
#echo "CISCO count (sim data) array= ${ciscoCount[@]}"
nodeData=`getNodeData Fronthaul-6080`
frontHaulCount=(${nodeData//,/ })
#echo "frontHaulCount Array sim data=${frontHaulCount[@]}"
nodeData=`getNodeData ESC`
escCount=(${nodeData//,/ })
nodeData=`getNodeData SCU`
scuCount=(${nodeData//,/ })
#echo "ESC Array sim data=${escCount[@]}"
nodeData=`getNodeData MLTN5-4FP`
miniTnCount=(${nodeData//,/ })
#echo "MINILINK INDOOR Array sim data=${miniTnCount[@]}"
nodeData=`getNodeData SpitFire`
spitFireCount=(${nodeData//,/ })
nodeData=`getNodeData SGSN`
sgsnCount=(${nodeData//,/ })
nodeData=`getNodeData 100K-ST-MGw`
MGW100KCount=(${nodeData//,/ })
nodeData=`getNodeData 3K-ST-MGw`
MGW3KCount=(${nodeData//,/ })
nodeData=`getNodeData EPG`
epgCount=(${nodeData//,/ })
nodeData=`getNodeData MTAS`
mtasCount=(${nodeData//,/ })
nodeData=`getNodeData DSC`
dscCount=(${nodeData//,/ })
nodeData=`getNodeData SBG-IS`
sbgIsCount=(${nodeData//,/ })
nodeData=`getNodeData ML6691`
ml6691Count=(${nodeData//,/ })
nodeData=`getNodeData FrontHaul-6020`
frontHaul6020Count=(${nodeData//,/ })
nodeData=`getNodeData Router6675`
router6675Count=(${nodeData//,/ })
nodeData=`getNodeData Juniper`
juniperCount=(${nodeData//,/ })
nodeData=`getNodeData CUDB`
cudbCount=(${nodeData//,/ })
nodeData=`getNodeData PCG`
pcgCount=(${nodeData//,/ })
nodeData=`getNodeData CCDM`
ccdmCount=(${nodeData//,/ })
#nodeData=`getNodeData EPG-OI`
#epgoiCount=(${nodeData//,/ })



##########Gives count of total number of nodes ##############
totalnOfTCU02=${tcuCount[0]}
totalnOfMLTN6=${mltn6Count[0]}
totalnOfERSN=${ersnCount[0]}

totalnOfSIU02=${siuCount[0]}
totalnOfML6352=${minilinkCount[0]}
#echo "total no of minilink nodes=$totalnOfML6352"
totalnOfR6672=${Router6672Count[0]}
#echo "total no of nodes Of R6672=$totalnOfR6672"
totalnOfR6274=${Router6274Count[0]}
#echo "total no of nodes Of R6274=$totalnOfR6274"
totalnOfmlIndoor=${mlIndoorCount[0]}
#echo "total no of nodes Of minilink indoor=$totalnOfmlIndoor"
#totalnOfmlink6352=${ml6352Count[0]}
totalnOfcisco=${ciscoCount[0]}
#echo "total no of mo cisco=$totalnOfcisco"
totalnOfrontHaul=${frontHaulCount[0]}
#echo "total no of NE Of frontHaul=$totalnOfrontHaul"
totalnOfESC=${escCount[0]}
totalnOfSCU=${scuCount[0]}
totalnOfMLTN54FP=${miniTnCount[0]}
#echo "TOTAL NO of mini tn nodes=$totalnOfMLTN54FP"
totalnOfSpitFire=${spitFireCount[0]}
totalnOfSGSN=${sgsnCount[0]}
totalnOfMGW100k=${MGW100KCount[0]}
#echo "SIMULATION_MGW100K=$totalnOfMGW100k"
#echo "SIMULATION MGW100K ARRAY=${MGW100KCount[@]}"
#echo "SIMULATION MGW3K ARRAY=${MGW3KCount[@]}"
totalnOfMGW3k=${MGW3KCount[0]}
#echo "SIMULATION_MGW3K=$totalnOfMGW3k"
totalnOfEPG=${epgCount[0]}
totalnOfMTAS=${mtasCount[0]}

totalnOfDSC=${dscCount[0]}
totalnOfSBGIS=${sbgIsCount[0]}
totalnOfML6691=${ml6691Count[0]}
totalnOf6020=${frontHaul6020Count[0]}
totalnOfR6675=${router6675Count[0]}
totalnOfJuniper=${juniperCount[0]}
totalnOfCUDB=${cudbCount[0]}
totalnOfPCG=${pcgCount[0]}
totalnOfCCDM=${ccdmCount[0]}
#totalnOfEPGOI=${epgoiCount[0]}

totalMoTCU02=${tcuCount[3]}
totalMoMLTN6=${mltn6Count[3]}
totalMoERSN=${ersnCount[3]}
totalMoSIU02=${siuCount[3]}
totalMoML6352=${minilinkCount[3]}
totalMoR6672=${Router6672Count[3]}
totalYangMoR6274="0"
#totalYangMoR6274="1386000"
totalMoR6274=`expr ${Router6274Count[3]} + $totalYangMoR6274`
totalMomlIndoor=${mlIndoorCount[3]}
#echo "totalMomlIndoor=$totalMomlIndoor"
#totalMomlink6352=${ml6352Count[3]}
totalMocisco=${ciscoCount[3]}
totalMofrontHaul=${frontHaulCount[3]}
#echo "total Mo frontHaul=$totalMofrontHaul"
totalMoESC=${escCount[3]}
totalMoSCU=${scuCount[3]}
totalMoMLTN54FP=${miniTnCount[3]}
#echo "TOTAL NO OF MOs=$totalMoMLTN54FP"
totalMoSpitFire=${spitFireCount[3]}
totalMoSGSN=${sgsnCount[3]}
totalMoMGW100k=${MGW100KCount[3]}
totalMoMGW3k=${MGW3KCount[3]}
totalMoEPG=${epgCount[3]}
totalMoMTAS=${mtasCount[3]}
totalMoDSC=${dscCount[3]}
totalMoSBGIS=${sbgIsCount[3]}
totalMoML6691=${ml6691Count[3]}
totalMo6020=${frontHaul6020Count[3]}
totalMoR6675=${router6675Count[3]}
totalMoJuniper=${juniperCount[3]}
totalMoCUDB=${cudbCount[3]}
totalMoPCG=${pcgCount[3]}
totalMoCCDM=${ccdmCount[3]}
#totalMoEPGOI=${epgoiCount[3]}



totalnetworkData=`getTotalData`
totalData=(${totalnetworkData//,/ })
totalNumberOfNodes=${totalData[0]}
totalNumberOfIPV4nodes=${totalData[1]}
totalNumberOfIPV6Nodes=${totalData[2]}
Ipv4Percent=`echo "100*$totalNumberOfIPV4nodes/$totalNumberOfNodes" | bc -l`
Ipv6Percent=`echo "100*$totalNumberOfIPV6Nodes/$totalNumberOfNodes" | bc -l`

echo "###############    DOWNLOADING JSON DATA ....   ###############"

echo "#######   Downloading jq script   #######"
curl -O "https://arm1s11-eiffel004.eiffel.gic.ericsson.se:8443/nexus/content/repositories/nss/com/ericsson/nss/scripts/jq/1.0.1/jq-1.0.1.tar"  ; tar -xvf jq-1.0.1.tar ; chmod +x ./jq

echo "#######   Calling REST CALL   #######"
wget -q -O - --no-check-certificate $jsonLink > Data.json

### Fetch Node Type wise data from json ###

getNSSOdata() {

networkType=$2
netype=$1
node_Count=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."NE Count")' coreData.json)
if [[ "$node_Count" == "" ]] || [[ "$node_Count" == "NA" ]] || [[ "$node_Count" =~ "N" ]]
then
   node_Count=0
fi
mo_Count=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."MO Count")' coreData.json)
if [[ "$mo_Count" == "" ]] || [[ "$mo_Count" == "NA" ]] || [[ "$mo_Count" =~ "N" ]]
then
   mo_Count=0
fi
pmFileSize=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."PM File Size")' coreData.json)
if [[ "$pmFileSize" == "" ]] || [[ "$pmFileSize" == "NA" ]] || [[ "$pmFileSize" =~ "N" ]]
then
   pmFileSize=0
fi
pmCounterVolume=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."PM Counter Volume")' coreData.json)
if [[ "$pmCounterVolume" == "" ]] || [[ "$pmCounterVolume" == "NA" ]] || [[ "$pmCounterVolume" =~ "N" ]]
then
   pmCounterVolume=0
fi
echo "$node_Count,$mo_Count,$pmFileSize,$pmCounterVolume"
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

#if [ "$networkType" == "nssModuleTransport_5KNodes" ] || [ "$networkType" == "rvModuleTransport_10KNodes" ] || [  "$networkType" == "rvModuleTransport_7.5KNodes" ] || [ "$networkType" == "rvModuleTransport_20KNodes" ] || [ "$networkType" == "nssModuleCore_360Nodes" ] || [ "$networkType" == "rvModuleTransport_5KNodes_19.3" ] || [ "$networkType" == "rvModuleTransport_MiniLink_5KNodes" ]
#then
#    ./jq --raw-output '.[]."network size" | .[] | select (.type=="vLarge (60k)") | (."Non-RAN Node Split Table")' Data.json > coreData.json   
   
#elif [ "$networkType" == "rvModuleTransport_Small" ] || [ "$networkType" == "rvModuleCore_Small" ] || [ "$networkType" == "rvModuleCore_Small_NRM5" ] || [ "$networkType" == "rvModuleTransport_Small_NRM5" ]
#then
#    ./jq --raw-output '.[]."network size" | .[] | select (.type=="Small (5k)") | (."Non-RAN Node Split Table")' Data.json > coreData.json
#fi
 ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'")  | (."Non-RAN Node Split Table")' Data.json > coreData.json
if [[ "$networkType" =~ "Transport" ]]
then
   NssoDataOfTcuSiu=`getNSSOdata "SIU/TCU" $networkType`
   NssoDataOfMLTN6=`getNSSOdata "MLTN6-0-1" $networkType`
   NssoDataOfERSN=`getNSSOdata "ERS" $networkType`
   NssoDataOfML6352=`getNSSOdata "MINI-LINK" $networkType`
   NssoDataOfR6672=`getNSSOdata "Router6672" $networkType`
   NssoDataOfR6274=`getNSSOdata "Router6274" $networkType`
   #NssoDataOfmlIndoor=`getNSSOdata "MINI-LINK TN(Indoor)" $networkType`
   NssoDataOfmlink6352=`getNSSOdata "MINI-LINK 6352" $networkType`
   #echo "6352=$NssoDataOfmlink6352"
   NssoDataOfcisco=`getNSSOdata "CISCO ASR 900" $networkType`
   NssoDataOffronHaul=`getNSSOdata "Fronthaul 6080" $networkType`
   NssoDataOfESC=`getNSSOdata "ESC" $networkType`
   NssoDataOfSCU=`getNSSOdata "SCU" $networkType`
   NssoDataOfMLTN54FP=`getNSSOdata "MINI-LINK TN(Indoor)" $networkType`
   NssoDataOfSpitFire=`getNSSOdata "R6672" $networkType`
   NssoDataOfML6691=`getNSSOdata "MINI-LINK 6691" $networkType`
   NssoDataOfRouter6675=`getNSSOdata "Router6675" $networkType`
   NssoDataOfJuniper=`getNSSOdata "Juniper MX" $networkType`
   NssoDataOfFronHaul6020=`getNSSOdata "Fronthaul 6020" $networkType`
   
   NssoListOfTcuSiu=(${NssoDataOfTcuSiu//,/ })
   NssoListOfMLTN6=(${NssoDataOfMLTN6//,/ })
   echo "NssoListOfMLTN6=$NssoListOfMLTN6*************"
   NssoListOfERSN=(${NssoDataOfERSN//,/ })
   NssoListOfML6352=(${NssoDataOfML6352//,/ })
   #echo "ML6352_ARRAY=${NssoListOfML6352[@]}"
   NssoListOfR6672=(${NssoDataOfR6672//,/ })
   NssoListOfR6274=(${NssoDataOfR6274//,/ })
   NssoListOfmlindoor=(${NssoDataOfmlIndoor//,/ })
   #echo "NSSO_DATA mini link indoor =${NssoListOfmlindoor[0]},${NssoListOfmlindoor[1]},${NssoListOfmlindoor[2]}"
   NssoListOfmlink6352=(${NssoDataOfmlink6352//,/ })
   NssoListOfcisco=(${NssoDataOfcisco//,/ })
   #echo "NSSO_DATA_CISCO_ARRAY=${NssoListOfcisco[@]}"
   NssoListOfFrontHaul=(${NssoDataOffronHaul//,/ })
   #echo "NSSO_DATA_FRONTHAUL_array=${NssoListOfFrontHaul[@]}"
   NssoListOfESC=(${NssoDataOfESC//,/ })
   NssoListOfSCU=(${NssoDataOfSCU//,/ })
   NssoListOfMLTN54FP=(${NssoDataOfMLTN54FP//,/ })
   #echo "NSSO_DATA_MLTN54FP = ${NssoListOfMLTN54FP[@]}"
   NssoListOfSpitFire=(${NssoDataOfSpitFire//,/ })
   NssoListOfML6691=(${NssoDataOfML6691//,/ })
   NssoListOfR6675=(${NssoDataOfRouter6675//,/ })
   NssoListOfJuniper=(${NssoDataOfJuniper//,/ })
   NssoListOfFrontHaul6020=(${NssoDataOfFronHaul6020//,/ })
   
elif [[ "$networkType" =~ "Core" ]]
then
   NssoDataOfSGSN=`getNSSOdata "SGSN MME" $networkType`
   NssoDataOfMGW100k=`getNSSOdata "100K-ST-MGW" $networkType`
   NssoDataOfMGW3k=`getNSSOdata "3K-ST-MGW" $networkType`
   NssoDataOfMGW=`getNSSOdata "MGW" $networkType`
   NssoDataOfEPG=`getNSSOdata "EPG" $networkType`
   NssoDataOfMTAS=`getNSSOdata "MTAS" $networkType`
   NssoDataOfDSC=`getNSSOdata "DSC" $networkType`
   NssoDataOfSBGIS=`getNSSOdata "SBG-IS" $networkType`
   NssoDataOfCUDB=`getNSSOdata "CUDB" $networkType`
   NssoDataOfPCG=`getNSSOdata "PCG" $networkType`
   NssoDataOfCCDM=`getNSSOdata "CCDM" $networkType`
   NssoDataOfEPGOI=`getNSSOdata "EPG-OI" $networkType`
   
   NssoListOfSGSN=(${NssoDataOfSGSN//,/ })
   #NssoListOfMGW100k=(${NssoDataOfMGW100k//,/ })
   #NssoListOfMGW3k=(${NssoDataOfMGW3k//,/ })
   NssoListOfMGW=(${NssoDataOfMGW//,/ })
  #echo "NSSSSO MGW ARRAY SIZEEEEE=${#NssoListOfMGW[@]}"
  #echo "NSSSSSSO FIRST ELEMENT=${NssoListOfMGW[0]}"
  #echo "NSSSSSSO SECOND ELEMENT=${NssoListOfMGW[1]}"
   NssoListOfEPG=(${NssoDataOfEPG//,/ })
   NssoListOfMTAS=(${NssoDataOfMTAS//,/ })
   NssoListOfDSC=(${NssoDataOfDSC//,/ })
   NssoListOfSBGIS=(${NssoDataOfSBGIS//,/ })
   NssoListOfCUDB=(${NssoDataOfCUDB//,/ })
   NssoListOfPCG=(${NssoDataOfPCG//,/ })
   NssoListOfCCDM=(${NssoDataOfCCDM//,/ })
   NssoListOfEPGOI=(${NssoDataOfEPGOI//,/ })
   
   TotalNssoListOfEPGNode=`expr ${NssoListOfEPG[0]} + ${NssoListOfEPGOI[0]}`
   TotalNssoListOfEPGMO=`expr ${NssoListOfEPG[1]} + ${NssoListOfEPGOI[1]}`
fi

#######################    WEIRD LOGIC :P    ################################
if [[ "$networkType" =~ "Core" ]]
then
MGwTypeCount=`cat NodeType.conf | grep -i MGw | wc -l`
MGwNSSOListSize=${#NssoListOfMGW[@]}
for (( i = 0; i < $MGwNSSOListSize; i=$((MGwTypeCount+i)) ))
do
	MGw1+=(${NssoListOfMGW[$i]})
done
for (( i = 1; i < $MGwNSSOListSize; i=$((MGwTypeCount+i)) ))
do
        MGw2+=(${NssoListOfMGW[$i]})
done

#echo -e "\nMGw1 is ${MGw1[@]}\nMGw2 is ${MGw2[@]}\n"
MGwNodeCount1=${MGw1[0]}
MGwNodeCount2=${MGw2[0]}
MGwMoCount1=${MGw1[1]}
MGwMoCount2=${MGw2[1]}
AvgMoCount1=$((MGwMoCount1 / MGwNodeCount1))
AvgMoCount2=$((MGwMoCount2 / MGwNodeCount2))

if [[ $AvgMoCount1 -eq 3000 ]]
then
	NssoListOfMGW3k=(${MGw1[@]})
	NssoListOfMGW100k=(${MGw2[@]})
else
	NssoListOfMGW3k=(${MGw2[@]})
        NssoListOfMGW100k=(${MGw1[@]})
fi
fi
#echo -e "NssoListOfMGW3k= is ${NssoListOfMGW3k[@]}\nNssoListOfMGW100k= is ${NssoListOfMGW100k[@]}"

#############################################################################

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
if [ $actualNodeData -ne 0 ]
then
   if [ $nssoNodeData -le $actualNodeData ] && [ $nssoMoData -le $actualMoData ]
   then
      if [ $nssoNodeData -eq 0 ] && [ $actualNodeData -ne 0 ]
      then
         status="FAILED"
      elif [ $nssoMoData -eq 0 ] && [ $actualMoData -ne 0 ]
      then
         status="FAILED"
      else
         status="PASSED"
      fi
   else
      status="FAILED"
   fi
 #  `checkNodePopulatorSupport $neType $supportLog`
   echo "$neType,$actualNodeData,$nssoNodeData,$actualMoData,$nssoMoData,$status" >> NonRanFinalSummary.txt
fi
}
echo "NETYPE,NUM_OF_NODES(Obtained),NUM_OF_NODES(Target),NUM_OF_MOS(Obtained),NUM_OF_MOS(Target),STATUS" >> NonRanFinalSummary.txt
if [[ "$networkType" =~ "Transport" ]]
then
 #  `compareData "TCU02" $totalnOfTCU02 ${NssoListOfTcuSiu[0]} $totalMoTCU02 ${NssoListOfTcuSiu[1]} $supportLog`           
   `compareData "MLTN6" $totalnOfMLTN6 ${NssoListOfMLTN6[0]} $totalMoMLTN6 ${NssoListOfMLTN6[1]} $supportLog`           
   `compareData "ERSN" $totalnOfERSN ${NssoListOfERSN[0]} $totalMoERSN ${NssoListOfERSN[1]} $supportLog`           
 # `compareData "SIU02" $totalnOfSIU02 ${NssoListOfTcuSiu[0]} $totalMoSIU02 ${NssoListOfTcuSiu[1]} $supportLog`
  `compareData "ML6352" $totalnOfML6352 ${NssoListOfmlink6352[0]} $totalMoML6352 ${NssoListOfmlink6352[1]} $supportLog`
 # echo -e "\n\n\nML6352,\n$totalnOfML6352,\n ${NssoListOfmlink6352[0]},\n $totalMoML6352,\n${NssoListOfmlink6352[1]}\n\n\n\n"
  `compareData "Router6672" $totalnOfR6672 ${NssoListOfR6672[0]} $totalMoR6672 ${NssoListOfR6672[1]} $supportLog`
  `compareData "Router6274" $totalnOfR6274 ${NssoListOfR6274[0]} $totalMoR6274 ${NssoListOfR6274[1]} $supportLog`
  #`compareData "MINI-LINK TN(Indoor)" $totalnOfmlIndoor ${NssoListOfmlindoor[0]} $totalMomlIndoor ${NssoListOfmlindoor[1]} $supportLog`
  # echo "MINI-LINK TN(Indoor), $totalnOfmlIndoor, ${NssoListOfmlindoor[0]}, $totalMomlIndoor ,${NssoListOfmlindoor[1]}"
 #`compareData "MINI-LINK 6352" $totalnOfmlink6352 ${NssoListOfmlink6352[1]} $totalMomlink6352 ${NssoListOfmlink6352[2]} $supportLog`
  `compareData "CISCO ASR 900" $totalnOfcisco ${NssoListOfcisco[0]} $totalMocisco ${NssoListOfcisco[1]} $supportLog`
  `compareData "Fronthaul 6080" $totalnOfrontHaul ${NssoListOfFrontHaul[0]} $totalMofrontHaul ${NssoListOfFrontHaul[1]} $supportLog`
  # echo "Fronthaul 6080, $totalnOfrontHaul, ${NssoListOfFrontHaul[0]},$totalMofrontHaul, ${NssoListOfFrontHaul[1]}"
  `compareData "ESC" $totalnOfESC ${NssoListOfESC[0]} $totalMoESC ${NssoListOfESC[1]} $supportLog`
  `compareData "SCU" $totalnOfSCU ${NssoListOfSCU[0]} $totalMoSCU ${NssoListOfSCU[1]} $supportLog`
  `compareData "MINI-LINK TN(Indoor)" $totalnOfMLTN54FP ${NssoListOfMLTN54FP[0]} $totalMoMLTN54FP ${NssoListOfMLTN54FP[1]} $supportLog`
   #echo "MINI-LINK TN(Indoor),$totalnOfMLTN54FP, ${NssoListOfMLTN54FP[0]}, $totalMoMLTN54FP ,${NssoListOfMLTN54FP[1]}"
  `compareData "SpitFire" $totalnOfSpitFire ${NssoListOfSpitFire[0]} $totalMoSpitFire ${NssoListOfSpitFire[1]} $supportLog`
   `compareData "Router6675" $totalnOfR6675 ${NssoListOfR6675[0]} $totalMoR6675 ${NssoListOfR6675[1]} $supportLog`
   `compareData "ML6691" $totalnOfML6691 ${NssoListOfML6691[0]} $totalMoML6691 ${NssoListOfML6691[1]} $supportLog`
   `compareData "Fronthaul 6020" $totalnOf6020 ${NssoListOfFrontHaul6020[0]} $totalMo6020 ${NssoListOfFrontHaul6020[1]} $supportLog`
   `compareData "Juniper" $totalnOfJuniper ${NssoListOfJuniper[0]} $totalMoJuniper ${NssoListOfJuniper[1]} $supportLog`
elif [[ "$networkType" =~ "Core" ]]
then
   `compareData "SGSN" $totalnOfSGSN ${NssoListOfSGSN[0]} $totalMoSGSN ${NssoListOfSGSN[1]} $supportLog`
#  `compareData "MGW" $totalnOfMGW100k ${NssoListOfMGW[0]} $totalMoMGW100k ${NssoListOfMGW[1]} $supportLog`
   `compareData "MGW" $totalnOfMGW100k ${NssoListOfMGW100k[0]} $totalMoMGW100k ${NssoListOfMGW100k[1]} $supportLog`
   `compareData "MGW" $totalnOfMGW3k ${NssoListOfMGW3k[0]} $totalMoMGW3k ${NssoListOfMGW3k[1]} $supportLog`
   #echo "MGW, $totalnOfMGW100k ${NssoListOfMGW[0]} $totalMoMGW100k ${NssoListOfMGW[1]}"
   `compareData "EPG" $totalnOfEPG $TotalNssoListOfEPGNode $totalMoEPG $TotalNssoListOfEPGMO $supportLog`
  #echo "EPG, $totalnOfEPG ,${NssoListOfEPG[0]}, $totalMoEPG, ${NssoListOfEPG[1]}, $supportLog"
  `compareData "MTAS" $totalnOfMTAS ${NssoListOfMTAS[0]} $totalMoMTAS ${NssoListOfMTAS[1]} $supportLog`
 `compareData "DSC" $totalnOfDSC ${NssoListOfDSC[0]} $totalMoDSC ${NssoListOfDSC[1]} $supportLog`
  `compareData "SBG-IS" $totalnOfSBGIS ${NssoListOfSBGIS[0]} $totalMoSBGIS ${NssoListOfSBGIS[1]} $supportLog`
  `compareData "CUDB" $totalnOfCUDB ${NssoListOfCUDB[0]} $totalMoCUDB ${NssoListOfCUDB[1]} $supportLog`
  `compareData "PCG" $totalnOfPCG ${NssoListOfPCG[0]} $totalMoPCG ${NssoListOfPCG[1]} $supportLog`
  `compareData "CCDM" $totalnOfCCDM ${NssoListOfCCDM[0]} $totalMoCCDM ${NssoListOfCCDM[1]} $supportLog`
 # `compareData "EPG-OI" $totalnOfEPGOI ${NssoListOfEPGOI[0]} $totalMoEPGOI ${NssoListOfEPGOI[1]} $supportLog`
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

rm -rf /var/simnet/enm-simnet/scripts/mergedOutputFile.txt
