#!/bin/sh

# Created by  : Harish Dunga
# Created in  : 12 05 2018
##
### VERSION HISTORY
###################################################
# Ver1        : Modified for ENM
# Purpose     : To validate the Checklist with NSSO
# Description :
# Date        : 12 05 2018
# Who         : Harish Dunga
###################################################
netsimHostnames=$1
networkType=$2
JSONLINK=$3
SUPPORT_FILE=Total_Network_support.txt

if [ "$#" -ne 3  ]
then
 echo
 echo "Usage: $0 <server names> <networkType> <json link>"
 echo
 echo "-------------------------------------------------------------------"
 echo "# Please give proper inputs to the script $0 !!!!"
 echo "###################################################################"
 exit 1
fi

########################################################
#Deleting and creating files
########################################################

if [[ -f $SUPPORT_FILE ]]; then
rm-rf $SUPPORT_FILE
fi

counter=0
if [ -z "$netsimHostnames" ]
then
      echo " serverName is empty"
      exit 1
fi

serverNamesArray=(${netsimHostnames//,/ })

for serverName in ${netsimHostnames//,/ } 
do 

echo "Server is $serverName"

/usr/bin/expect <<EOF

    ########################################################
    #Copying output file to workspace
    ######################################################## 
    spawn scp -o StrictHostKeyChecking=no netsim@$serverName.athtem.eei.ericsson.se:/netsim/Core_CheckForRV/ERICTAFenmsimnet_CXP9034833/src/main/resources/scripts/CORE/bin/summary.log .
    expect {
        -re Password: {send "netsim\r";exp_continue}
    }
    sleep 1
    
    spawn scp -o StrictHostKeyChecking=no netsim@$serverName.athtem.eei.ericsson.se:/netsim/Core_CheckForRV/ERICTAFenmsimnet_CXP9034833/src/main/resources/scripts/CORE/bin/neCount.log .
    expect {
        -re Password: {send "netsim\r";exp_continue}
    }
    sleep 1
    spawn scp -o StrictHostKeyChecking=no netsim@$serverName.athtem.eei.ericsson.se:/netsim/Core_CheckForRV/ERICTAFenmsimnet_CXP9034833/src/main/resources/scripts/CORE/bin/moCount.log .
    expect {
        -re Password: {send "netsim\r";exp_continue}
    }
    sleep 1
    spawn scp -o StrictHostKeyChecking=no netsim@$serverName.athtem.eei.ericsson.se:/netsim/Core_CheckForRV/ERICTAFenmsimnet_CXP9034833/src/main/resources/scripts/CORE/bin/support.log .
    expect {
        -re Password: {send "netsim\r";exp_continue}
    }
    sleep 1
    

EOF

    cat support.log >> $SUPPORT_FILE

echo "END of execution on $serverName"

Count=$(cat summary.log |tr "\n" " " )
totalCount=(${Count// / })

IFS=$'\n' read -d '' -r -a lines < neCount.log

necount=$(cat neCount.log |tr "\n" " " )
totalNeCountinServer=(${necount// / })

moCount=$(cat moCount.log)
totalmoCountinServer=(${moCount// /})

totalNumberOfNodes[$counter]=${totalCount[0]}
totalNumberOfIPV4nodes[$counter]=${totalCount[1]}
totalNumberOfIPV6Nodes[$counter]=${totalCount[2]}

totalNeCountOfTCU02[$counter]=${totalNeCountinServer[0]}
totalNeCountOfSIU02[$counter]=${totalNeCountinServer[1]}
totalNeCountOfML6352[$counter]=${totalNeCountinServer[2]}
totalNeCountOfMLTN54FP[$counter]=${totalNeCountinServer[3]}
totalNeCountOfSpitFire[$counter]=${totalNeCountinServer[4]}
totalNeCountOfSGSN[$counter]=${totalNeCountinServer[5]}
totalNeCountOfMGw[$counter]=${totalNeCountinServer[6]}
totalNeCountOfEPG[$counter]=${totalNeCountinServer[7]}
totalNeCountOfMTAS[$counter]=${totalNeCountinServer[8]}
totalNeCountOfDSC[$counter]=${totalNeCountinServer[9]}

totalmoCountOfTCU02[$counter]=${totalmoCountinServer[0]}
totalmoCountOfSIU02[$counter]=${totalmoCountinServer[1]}
totalmoCountOfML6352[$counter]=${totalmoCountinServer[2]}
totalmoCountOfMLTN54FP[$counter]=${totalmoCountinServer[3]}
totalmoCountOfSpitFire[$counter]=${totalmoCountinServer[4]}
totalmoCountOfSGSN[$counter]=${totalmoCountinServer[5]}
totalmoCountOfMGw[$counter]=${totalmoCountinServer[6]}
totalmoCountOfEPG[$counter]=${totalmoCountinServer[7]}
totalmoCountOfMTAS[$counter]=${totalmoCountinServer[8]}
totalmoCountOfDSC[$counter]=${totalmoCountinServer[9]}


counter=$[counter+1]
rm summary.log neCount.log moCount.log 

done

totalNumberOfNodes=`echo "${totalNumberOfNodes[@]/%/+}0" | bc`
totalNumberOfIPV4nodes=`echo "${totalNumberOfIPV4nodes[@]/%/+}0" | bc`
totalNumberOfIPV6Nodes=`echo "${totalNumberOfIPV6Nodes[@]/%/+}0" | bc`
Ipv4Percent=`echo "100*$totalNumberOfIPV4nodes/$totalNumberOfNodes" | bc -l`
Ipv6Percent=`echo "100*$totalNumberOfIPV6Nodes/$totalNumberOfNodes" | bc -l`

totalnOfTCU02=`echo "${totalNeCountOfTCU02[@]/%/+}0" | bc`
totalnOfSIU02=`echo "${totalNeCountOfSIU02[@]/%/+}0" | bc`
totalnOfML6352=`echo "${totalNeCountOfML6352[@]/%/+}0" | bc`
totalnOfMLTN54FP=`echo "${totalNeCountOfMLTN54FP[@]/%/+}0" | bc`
totalnOfSpitFire=`echo "${totalNeCountOfSpitFire[@]/%/+}0" | bc`
totalnOfSGSN=`echo "${totalNeCountOfSGSN[@]/%/+}0" | bc`
totalnOfMGw=`echo "${totalNeCountOfMGw[@]/%/+}0" | bc`
totalnOfEPG=`echo "${totalNeCountOfEPG[@]/%/+}0" | bc`
totalnOfMTAS=`echo "${totalNeCountOfMTAS[@]/%/+}0" | bc`
totalnOfDSC=`echo "${totalNeCountOfDSC[@]/%/+}0" | bc`
totalnOfBSC=`echo "${totalNeCountOfBSC[@]/%/+}0" | bc`


totalMoTCU02=`echo "${totalmoCountOfTCU02[@]/%/+}0" | bc`
totalMoSIU02=`echo "${totalmoCountOfSIU02[@]/%/+}0" | bc`
totalMoML6352=`echo "${totalmoCountOfML6352[@]/%/+}0" | bc`
totalMoMLTN54FP=`echo "${totalmoCountOfMLTN54FP[@]/%/+}0" | bc`
totalMoSpitFire=`echo "${totalmoCountOfSpitFire[@]/%/+}0" | bc`
totalMoSGSN=`echo "${totalmoCountOfSGSN[@]/%/+}0" | bc`
totalMoMGw=`echo "${totalmoCountOfMGw[@]/%/+}0" | bc`
totalMoEPG=`echo "${totalmoCountOfEPG[@]/%/+}0" | bc`
totalMoMTAS=`echo "${totalmoCountOfMTAS[@]/%/+}0" | bc`
totalMoDSC=`echo "${totalmoCountOfDSC[@]/%/+}0" | bc`

echo "###############    DOWNLOADING JSON DATA ....   ###############"

#echo "#######   Downloading jq script   #######"
curl -O "https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/service/local/repositories/nss/content/com/ericsson/nss/scripts/jq/1.0.1/jq-1.0.1.tar"  ; tar -xvf jq-1.0.1.tar ; chmod +x ./jq

#echo "#######   Calling REST CALL   #######"
wget -q -O - --no-check-certificate $JSONLINK > Data.json

### Fetch Node Type wise data from json ###

getNSSOdata() {

networkType=$2
netype=$1
Node_Count=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."NE Count")' Data1.json)
MO_Count=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."MO Count")' Data1.json)
PMFileSize=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."PM File Size")' Data1.json)
PMCounterVolume=$(./jq --raw-output '.[] | select (.name=="'"$networkType"'") | .value[] | select (."NE Type"=="'"$netype"'") | (."PM Counter Volume")' Data1.json)

echo "$Node_Count,$MO_Count,$PMFileSize,$PMCounterVolume"
}

checkNodePopulatorSupport() {
netype=$1
SUPPORT_FILE=$2
Check=`cat $SUPPORT_FILE | grep -i "node Populator is supported for $netype" |wc -l`
if [ "$Check" -gt "0" ]
then
   Flag="yes"
else
   Flag="no"
fi
echo $Flag
}

getPmFileLocation() {
netype=$1
SUPPORT_FILE=$2
ResultList=`cat $SUPPORT_FILE | grep -i "Pm file location for $netype" | awk -F"is " '{print $2}'`
Result=(${ResultList// / })
echo ${Result[0]}
}

if [ "$networkType" == "rvModuleTransport_5KNodes" ] || [ "$networkType" == "rvModuleTransport_10KNodes" ] || [  "$networkType" == "rvModuleTransport_7.5KNodes" ] || [ "$networkType" == "rvModuleTransport_20KNodes" ] || [ "$networkType" == "rvModuleCore_340Nodes" ]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="vLarge") | (."Non-RAN Node Split Table")' Data.json > Data1.json   
   
elif [ "$networkType" == "rvModuleTransport_Small" ] || [ "$networkType" == "rvModuleCore_Small" ]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="Small") | (."Non-RAN Node Split Table")' Data.json > Data1.json
    
fi

if [[ "$networkType" =~ "Transport" ]]
then
   NssoDataOfTcuSiu=`getNSSOdata "Transport(SIU/TCU02)" $networkType`
   NssoDataOfML6352=`getNSSOdata "MINI-LINK" $networkType`
   NssoDataOfMLTN54FP=`getNSSOdata "MINI-LINK TN" $networkType`
   NssoDataOfSpitFire=`getNSSOdata "Transport/R6672" $networkType`
   
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

echo ""
echo "##################################################################"
echo "#        TOTAL NETWORK REPORT                                     #"
echo "###################################################################"
echo ""

echo -e "Summary of Nodes in network"
echo -e "############################################################\n"
echo -e "Total Servers checked are ${serverNamesArray[@]}"
echo -e "Total NumberOfServers checked are ${#serverNamesArray[@]}"
echo -e "Total number of Nodes in Network are $totalNumberOfNodes"
echo -e "Total IPV4 nodes in Network are $totalNumberOfIPV4nodes"
echo -e "Total IPV6 nodes in Network are $totalNumberOfIPV6Nodes"
echo -e "IPV4 percentage in Network is $Ipv4Percent%"
echo -e "IPV6 percent in Network is $Ipv6Percent%\n"
echo "####################################################################"
echo "###############        COMPARING WITH NSSO        ##################"


echo "NETYPE Field Obtained_Value NSSO_Value Status" >> Result.txt
#echo "Total Nodes = $TotalNodes"

if [[ "$networkType" =~ "Transport" ]]
then

#### comparing tcu node data"#########
   if [[ $totalnOfTCU02 != "0" ]]
   then
      if [[ "${NssoListOfTcuSiu[0]}" -eq "$totalnOfTCU02" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> TransportTcuResult.txt
      echo "Node_Count $totalnOfTCU02 ${NssoListOfTcuSiu[0]} $CheckFlag" >> TransportTcuResult.txt
         
      if [[ "${NssoListOfTcuSiu[1]}" -le "$totalMoTCU02" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoTCU02 ${NssoListOfTcuSiu[1]} $CheckFlag" >> TransportTcuResult.txt
     
      #if [[ "${NssoListOfTcuSiu[2]}" -eq "$TCU02PmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $TCU02PmFileSize ${NssoListOfTcuSiu[2]} PASSED" >> TransportTcuResult.txt
      
      #if [[ "${NssoListOfTcuSiu[3]}" -eq "$TCU02CounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $TCU02CounterVolume ${NssoListOfTcuSiu[3]} PASSED" >> TransportTcuResult.txt
      
      CheckNodePopulator=`checkNodePopulatorSupport "TCU02" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> TransportTcuResult.txt
      PmPath=`getPmFileLocation "TCU02" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> TransportTcuResult.txt
      cat TransportTcuResult.txt >> FinalNetworkSummary.txt
   fi
   
   
 ### comparing siu node data ######
   if [[ $totalnOfSIU02 != "0" ]]
   then
      if [[ "${NssoListOfTcuSiu[0]}" -eq "$totalnOfSIU02" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> TransportSiuResult.txt
      echo "Node_Count $totalnOfSIU02 ${NssoListOfTcuSiu[0]} $CheckFlag" >> TransportSiuResult.txt
   
      if [[ "${NssoListOfTcuSiu[1]}" -le "$totalMoSIU02" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoSIU02 ${NssoListOfTcuSiu[1]} $CheckFlag" >> TransportSiuResult.txt
     
      #if [[ "${NssoListOfTcuSiu[2]}" -eq "$SIU02PmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $SIU02PmFileSize ${NssoListOfTcuSiu[2]} PASSED" >> TransportSiuResult.txt
      
      #if [[ "${NssoListOfTcuSiu[3]}" -eq "$SIU02CounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $SIU02CounterVolume ${NssoListOfTcuSiu[3]} PASSED" >> TransportSiuResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "SIU02" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> TransportSiuResult.txt
      PmPath=`getPmFileLocation "SIU02" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> TransportSiuResult.txt
      cat TransportSiuResult.txt >> FinalNetworkSummary.txt
   fi
   
 ### comapring  MINILINK ######
   if [[ $totalnOfML6352 != "0" ]]
   then
      if [[ "${NssoListOfML6352[0]}" -eq "$totalnOfML6352" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> TransportMiniLinkResult.txt
      echo "Node_Count $totalnOfML6352 ${NssoListOfML6352[0]} $CheckFlag" >> TransportMiniLinkResult.txt
   
      if [[ "${NssoListOfML6352[1]}" -le "$totalMoML6352" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoML6352 ${NssoListOfML6352[1]} PASSED" >> TransportMiniLinkResult.txt
     
      #if [[ "${NssoListOfML6352[2]}" -eq "$ML6352PmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $ML6352PmFileSize ${NssoListOfML6352[2]} PASSED" >> TransportMiniLinkResult.txt
      
      #if [[ "${NssoListOfML6352[3]}" -eq "$ML6352CounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $ML6352CounterVolume ${NssoListOfML6352[3]} PASSED" >> TransportMiniLinkResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "ML6352" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> TransportMiniLinkResult.txt
      PmPath=`getPmFileLocation "ML6352" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> TransportMiniLinkResult.txt
      cat TransportMiniLinkResult >> FinalNetworkSummary.txt
   fi
  
 ### comparing MINILINK TN ###### 
   if [[ $totalnOfMLTN54FP != "0" ]]
   then
      if [[ "${NssoListOfMLTN54FP[0]}" -eq "$totalnOfMLTN54FP" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> TransportMiniLinkTNResult.txt
      echo "Node_Count $totalnOfMLTN54FP ${NssoListOfMLTN54FP[0]} $CheckFlag" >> TransportMiniLinkTNResult.txt
   
      if [[ "${NssoListOfMLTN54FP[1]}" -le "$totalMoMLTN54FP" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoMLTN54FP ${NssoListOfMLTN54FP[1]} PASSED" >> TransportMiniLinkTNResult.txt
     
      #if [[ "${NssoListOfMLTN54FP[2]}" -eq "$MLTN54FPPmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $MLTN54FPPmFileSize ${NssoListOfMLTN54FP[2]} PASSED" >> TransportMiniLinkTNResult.txt
      
      #if [[ "${NssoListOfMLTN54FP[3]}" -eq "$MLTN54FPCounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $MLTN54FPCounterVolume ${NssoListOfMLTN54FP[3]} PASSED" >> TransportMiniLinkTNResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "MLTN5-4FP" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> TransportMiniLinkTNResult.txt
      PmPath=`getPmFileLocation "MLTN5-4FP" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> TransportMiniLinkTNResult.txt   
   fi
   
 ### comparing  SpitFire #######
   if [[ $totalnOfSpitFire != "0" ]]
   then
      if [[ "${NssoListOfSpitFire[0]}" -eq "$totalnOfSpitFire" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> TransportSpitFireResult.txt
      echo "Node_Count $totalnOfSpitFire ${NssoListOfSpitFire[0]} $CheckFlag" >> TransportSpitFireResult.txt
   
      if [[ "${NssoListOfSpitFire[1]}" -le "$totalMoSpitFire" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoSpitFire ${NssoListOfSpitFire[1]} $CheckFlag" >> TransportSpitFireResult.txt
     
      #if [[ "${NssoListOfSpitFire[2]}" -eq "$SpitFirePmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $SpitFirePmFileSize ${NssoListOfSpitFire[2]} PASSED" >> TransportSpitFireResult.txt
      
      #if [[ "${NssoListOfSpitFire[3]}" -eq "$SpitFireCounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $SpitFireCounterVolume ${NssoListOfSpitFire[3]} PASSED" >> TransportSpitFireResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "SpitFire" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> TransportSpitFireResult.txt
      PmPath=`getPmFileLocation "SpitFire" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> TransportSpitFireResult.txt
      cat TransportSpitFireResult.txt >> FinalNetworkSummary.txt      
   fi
   
#### Comparing Core Node Data ##############
elif [[ "$networkType" =~ "Core" ]]
then 
 ### Comparing SGSN node #######
   if [[ $totalnOfSGSN != "0" ]]
   then
      if [[ "${NssoListOfSGSN[0]}" -eq "$totalnOfSGSN" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> CORESGSNResult.txt
      echo "Node_Count $totalnOfSGSN ${NssoListOfSGSN[0]} $CheckFlag" >> CORESGSNResult.txt
   
      if [[ "${NssoListOfSGSN[1]}" -le "$totalMoSGSN" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoSGSN ${NssoListOfSGSN[1]} $CheckFlag" >> CORESGSNResult.txt
     
      #if [[ "${NssoListOfSGSN[2]}" -eq "$SGSNPmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $SGSNPmFileSize ${NssoListOfSGSN[2]} PASSED" >> CORESGSNResult.txt
      
      #if [[ "${NssoListOfSGSN[3]}" -eq "$SGSNCounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $SGSNCounterVolume ${NssoListOfSGSN[3]} PASSED" >> CORESGSNResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "SGSN" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> CORESGSNResult.txt
      PmPath=`getPmFileLocation "SGSN" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> CORESGSNResult.txt
      cat CORESGSNResult.txt >> FinalNetworkSummary.txt   
      
   fi
   
 ### Comparing MGW Node #######
   if [[ $totalnOfMGW != "0" ]]
   then
      if [[ "${NssoListOfMGW[0]}" -eq "$totalnOfMGW" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> COREMGWResult.txt
      echo "Node_Count $totalnOfMGW ${NssoListOfMGW[0]} $CheckFlag" >> COREMGWResult.txt
   
      if [[ "${NssoListOfMGW[1]}" -le "$totalMoMGW" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoMGW ${NssoListOfMGW[1]} $CheckFlag" >> COREMGWResult.txt
     
      #if [[ "${NssoListOfMGW[2]}" -eq "$MGWPmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $MGWPmFileSize ${NssoListOfMGW[2]} PASSED" >> COREMGWResult.txt
      
      #if [[ "${NssoListOfMGW[3]}" -eq "$MGWCounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $MGWCounterVolume ${NssoListOfMGW[3]} PASSED" >> COREMGWResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "MGW" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> COREMGWResult.txt
      PmPath=`getPmFileLocation "MGW" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> COREMGWResult.txt
      cat COREMGWResult.txt >> FinalNetworkSummary.txt
      
   fi
   
 ### Comparing EPG Node #######
   if [[ $totalnOfEPG != "0" ]]
   then
      if [[ "${NssoListOfEPG[0]}" -eq "$totalnOfEPG" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> COREEPGResult.txt
      echo "Node_Count $totalnOfEPG ${NssoListOfEPG[0]} $CheckFlag" >> COREEPGResult.txt
   
      if [[ "${NssoListOfEPG[1]}" -le "$totalMoEPG" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoEPG ${NssoListOfEPG[1]} $CheckFlag" >> COREEPGResult.txt
     
      #if [[ "${NssoListOfEPG[2]}" -eq "$EPGPmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $EPGPmFileSize ${NssoListOfEPG[2]} PASSED" >> COREEPGResult.txt
      
      #if [[ "${NssoListOfEPG[3]}" -eq "$EPGCounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $EPGCounterVolume ${NssoListOfEPG[3]} PASSED" >> COREEPGResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "EPG" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> COREEPGResult.txt
      PmPath=`getPmFileLocation "EPG" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> COREEPGResult.txt
      cat COREEPGResult.txt >> FinalNetworkSummary.txt
   fi
   
 ### Comparing MTAS Node #######
   if [[ $totalnOfMTAS != "0" ]]
   then
      if [[ "${NssoListOfMTAS[0]}" -eq "$totalnOfMTAS" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> COREMTASResult.txt
      echo "Node_Count $totalnOfMTAS ${NssoListOfMTAS[0]} $CheckFlag" >> COREMTASResult.txt
   
      if [[ "${NssoListOfMTAS[1]}" -le "$totalMoMTAS" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoMTAS ${NssoListOfMTAS[1]} $CheckFlag" >> COREMTASResult.txt
     
      #if [[ "${NssoListOfMTAS[2]}" -eq "$MTASPmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $MTASPmFileSize ${NssoListOfMTAS[2]} PASSED" >> COREMTASResult.txt
      
      #if [[ "${NssoListOfMTAS[3]}" -eq "$MTASCounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $MTASCounterVolume ${NssoListOfMTAS[3]} PASSED" >> COREMTASResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "MTAS" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> COREMTASResult.txt
      PmPath=`getPmFileLocation "MTAS" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> COREMTASResult.txt
      cat COREMTASResult.txt >> FinalNetworkSummary.txt
   fi
   
 ### Comparing DSC Node #######
   if [[ $totalnOfDSC != "0" ]]
   then
      if [[ "${NssoListOfDSC[0]}" -eq "$totalnOfDSC" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi    
      echo "Field Obtained_Value NSSO_Value Status" >> COREDSCResult.txt
      echo "Node_Count $totalnOfDSC ${NssoListOfDSC[0]} $CheckFlag" >> COREDSCResult.txt
   
      if [[ "${NssoListOfDSC[1]}" -le "$totalMoDSC" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "Mo_Count $totalMoDSC ${NssoListOfDSC[1]} $CheckFlag" >> COREDSCResult.txt
     
      #if [[ "${NssoListOfDSC[2]}" -eq "$DSCPmFileSize" ]]
      #then
       #  CheckFlag="PASSED"
      #else
       #  CheckFlag="FAILED"
      #fi
      #echo "PMFileSize $DSCPmFileSize ${NssoListOfDSC[2]} PASSED" >> COREDSCResult.txt
      
      #if [[ "${NssoListOfDSC[3]}" -eq "$DSCCounterVolume" ]]
      #then
      #   CheckFlag="PASSED"
      #else
      #   CheckFlag="FAILED"
      #fi
      #echo "PMCounterVolume $DSCCounterVolume ${NssoListOfDSC[3]} PASSED" >> COREDSCResult.txt
      CheckNodePopulator=`checkNodePopulatorSupport "DSC" $SUPPORT_FILE`
      if [[ "$CheckNodePopulator" == "yes" ]]
      then
         CheckFlag="PASSED"
      else
         CheckFlag="FAILED"
      fi
      echo "NodePopulatorSupport $CheckNodePopulator NA $CheckFlag" >> COREDSCResult.txt
      PmPath=`getPmFileLocation "DSC" $SUPPORT_FILE`
      if [[ "$PmPath" == "" ]]
      then
         CheckFlag="FAILED"
      else
         CheckFlag="PASSED"
      fi
      echo "PM_FileLocation $PmPath NA $CheckFlag" >> COREDSCResult.txt
      cat COREDSCResult.txt >> FinalNetworkSummary.txt
   fi
fi 

###### Displaying END  Result #########

if [ -s "TransportTcuResult.txt" ]
then
echo "*********************     TCU02 Node Data     **********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  TransportTcuResult.txt
####################
fi

if [ -s "TransportSiuResult.txt" ]
then
echo "*********************     SIU02 Node Data     **********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  TransportSiuResult.txt
####################
fi

if [ -s "TransportMiniLinkResult.txt" ]
then
echo "*********************    MiniLink Node Data   **********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  TransportMiniLinkResult.txt
####################
fi

if [ -s "TransportMiniLinkTNResult.txt" ]
then
echo "*********************     MiniLinkTN Data     **********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  TransportMiniLinkTNResult.txt
####################
fi

if [ -s "TransportSpitFireResult.txt" ]
then
echo "*********************     SpitFire Data      **********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  TransportSpitFireResult.txt
####################
fi

if [ -s "CORESGSNResult.txt" ]
then
echo "**********************    SGSN Node Data     ***********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  CORESGSNResult.txt
####################
fi

if [ -s "COREMGWResult.txt" ]
then
echo "**********************    MGW Node Data      ***********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  COREMGWResult.txt
####################
fi

if [ -s "COREEPGResult.txt" ]
then
echo "**********************    EPG Node Data      ***********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  COREEPGResult.txt
####################
fi

if [ -s "COREMTASResult.txt" ]
then
echo "**********************    MTAS Node Data     **********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  COREMTASResult.txt
####################
fi

if [ -s "COREDSCResult.txt" ]
then
echo "**********************     DSC Node Data     ***********************"
awk '{printf "%-40s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  COREDSCResult.txt
####################
fi

echo "####################################################################"
echo "######################    END OF THE RESULT   ######################"

buildStatus=`cat FinalNetworkSummary.txt | grep -i "FAILED" |wc -l`
if [ "$buildStatus" != "0" ]
then
exit 1
fi
