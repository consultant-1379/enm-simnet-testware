#!/bin/bash

hostname=`hostname`
simList1=`ls /netsim/netsimdir | grep NR | grep -v zip`
simList=( ${simList1[@]} )

logFile="/netsim/$hostname-5Gtotal.log"
totalFile="/netsim/$hostname-5GTotal.txt"
allNodesCsv="/netsim/$hostname-5G.csv"

if [[ -f $logFile ]]; then
    rm $logFile
fi

if [[ -f $totalFile ]]; then
    rm $totalFile
fi

if [[ -f $allNodesCsv ]]; then
    rm $allNodesCsv
fi

counter=0

for sim in ${simList[@]};
do
    echo "*$sim*" | tee -a "$logFile" 
            
   
    summaryFile="/netsim/netsimdir/${sim}/SimNetRevision/Summary_${sim}.csv"
    summaryScript="/netsim/netsimdir/${sim}/SimNetRevision/generateSummary_5G-1.0.1.sh"
    numOfNodes=`echo -e "printf \".open $sim \n .show simnes\" | /netsim/inst/netsim_shell | grep -v \"OK\" | grep -v \">>\" | grep -v \"NE\" | grep \"LTE\" | wc -l" | sudo su netsim`
    
    if [[ ! -f $summaryFile ]];
	then
	
        cd /netsim/netsimdir/${sim}/SimNetRevision/
        wget https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/content/repositories/nss/com/ericsson/nss/generateSummary_5G/1.0.1/generateSummary_5G-1.0.1.sh
        sudo su netsim $summaryScript $sim
        summaryFile="/netsim/netsimdir/${sim}/SimNetRevision/Summary_${sim}.csv"    
    
    fi
    cat $summaryFile | head -n-1 | tail -n+2 >> $allNodesCsv  
    lastLine=`cat $summaryFile | tail -n -1`
    IFS=',' read -r -a csvElements <<< "$lastLine"
    csvElements=(`echo "${csvElements[@]:1}"`)
####################################
#echo "${NodeName[$counter]},${NRCellRelation[$counter]},${ExternalGNBCUCPFunction[$counter]},${ExternalNRCellCU[$counter]},${TermPointToGNodeB[$counter]},${EUtranCellRelation[$counter]},${EUtranFreqRelation[$counter]},${NRFreqRelation[$counter]},${TotalMO[$counter]}" | tee -a "$summaryFile"
####################################    
    echo "Total Nodes = $numOfNodes" | tee -a "$logFile"
    echo "Total NRCellCU = ${csvElements[0]}" | tee -a "$logFile"
    echo "Total NRCellRelation = ${csvElements[1]}" | tee -a "$logFile"
    echo "Total ExternalGNBCUCPFunction = ${csvElements[2]}" | tee -a "$logFile"
    echo "Total ExternalNRCellCU = ${csvElements[3]}" | tee -a "$logFile"
    echo "Total TermPointToGNodeB = ${csvElements[4]}" | tee -a "$logFile"
    echo "Total EUtranCellRelation = ${csvElements[5]}" | tee -a "$logFile"
    echo "Total EUtranFreqRelation = ${csvElements[6]}" | tee -a "$logFile"
    echo "Total NRFreqRelation = ${csvElements[7]}" | tee -a "$logFile"
    echo "Total NRCellDU = ${csvElements[8]}" | tee -a "$logFile"
    echo "Total TermPointToENodeB = ${csvElements[9]}" | tee -a "$logFile"
    echo "Total ExternalBroadcastPLMNInfo = ${csvElements[10]}" | tee -a "$logFile"
    echo "Total ExternalENodeBFunction = ${csvElements[11]}" | tee -a "$logFile"
    echo "Total ExternalEUtranCell = ${csvElements[12]}" | tee -a "$logFile"
    echo "Total EUtranFrequency = ${csvElements[13]}" | tee -a "$logFile"
    echo "Total NRSectorCarrier = ${csvElements[14]}" | tee -a "$logFile"
    echo "Total NonPmMO = ${csvElements[15]}" | tee -a "$logFile"
    echo "Total MOs = ${csvElements[16]}" | tee -a "$logFile"
    echo " " | tee -a "$logFile"
    
    TotalNodes[$counter]=$numOfNodes
    TotalNRCellCU[$counter]=${csvElements[0]}
    TotalNRCellRelation[$counter]=${csvElements[1]}
    TotalExternalGNBCUCPFunction[$counter]=${csvElements[2]}
    TotalExternalNRCellCU[$counter]=${csvElements[3]}
    TotalTermPointToGNodeB[$counter]=${csvElements[4]}
    TotalEUtranCellRelation[$counter]=${csvElements[5]}
    TotalEUtranFreqRelation[$counter]=${csvElements[6]}
    TotalNRFreqRelation[$counter]=${csvElements[7]}
    TotalNRCellDU[$counter]=${csvElements[8]}
    TotalTermPointToENodeB[$counter]=${csvElements[9]}
    TotalExternalBroadcastPLMNInfo[$counter]=${csvElements[10]}
    TotalExternalENodeBFunction[$counter]=${csvElements[11]}
    TotalExternalEUtranCell[$counter]=${csvElements[12]}
    TotalEUtranFrequency[$counter]=${csvElements[13]}
    TotalNRSectorCarrier[$counter]=${csvElements[14]}
    TotalNonPmMO[$counter]=${csvElements[15]}
    TotalMOs[$counter]=${csvElements[16]}
    
    counter=$[counter+1]
    
done

TotalNodes=`echo "${TotalNodes[@]/%/+}0" | bc`
TotalNRCellCU=`echo "${TotalNRCellCU[@]/%/+}0" | bc`
TotalNRCellRelation=`echo "${TotalNRCellRelation[@]/%/+}0" | bc`
TotalExternalGNBCUCPFunction=`echo "${TotalExternalGNBCUCPFunction[@]/%/+}0" | bc`
TotalExternalNRCellCU=`echo "${TotalExternalNRCellCU[@]/%/+}0" | bc`
TotalTermPointToGNodeB=`echo "${TotalTermPointToGNodeB[@]/%/+}0" | bc`
TotalEUtranCellRelation=`echo "${TotalEUtranCellRelation[@]/%/+}0" | bc`
TotalEUtranFreqRelation=`echo "${TotalEUtranFreqRelation[@]/%/+}0" | bc`
TotalNRFreqRelation=`echo "${TotalNRFreqRelation[@]/%/+}0" | bc`
TotalNRCellDU=`echo "${TotalNRCellDU[@]/%/+}0" | bc`
TotalTermPointToENodeB=`echo "${TotalTermPointToENodeB[@]/%/+}0" | bc`
TotalExternalBroadcastPLMNInfo=`echo "${TotalExternalBroadcastPLMNInfo[@]/%/+}0" | bc`
TotalExternalENodeBFunction=`echo "${TotalExternalENodeBFunction[@]/%/+}0" | bc`
TotalExternalEUtranCell=`echo "${TotalExternalEUtranCell[@]/%/+}0" | bc`
TotalEUtranFrequency=`echo "${TotalEUtranFrequency[@]/%/+}0" | bc`
TotalNRSectorCarrier=`echo "${TotalNRSectorCarrier[@]/%/+}0" | bc`
TotalNonPmMO=`echo "${TotalNonPmMO[@]/%/+}0" | bc`
TotalMOs=`echo "${TotalMOs[@]/%/+}0" | bc`

echo "TotalNodes,NRCellCU,NRCellRelation,ExternalGNBCUCPFunction,ExternalNRCellCU,TermPointToGNodeB,EUtranCellRelation,EUtranFreqRelation,NRFreqRelation,NRCellDU,TermPointToENodeB,ExternalBroadcastPLMNInfo,ExternalENodeBFunction,ExternalEUtranCell,EUtranFrequency,NRSectorCarrier,TotalNonPmMO,TotalMO from the netsim box $hostname are as follows:" | tee -a "$totalFile"
echo "$TotalNodes,$TotalNRCellCU,$TotalNRCellRelation,$TotalExternalGNBCUCPFunction,$TotalExternalNRCellCU,$TotalTermPointToGNodeB,$TotalEUtranCellRelation,$TotalEUtranFreqRelation,$TotalNRFreqRelation,$TotalNRCellDU,$TotalTermPointToENodeB,$TotalExternalBroadcastPLMNInfo,$TotalExternalENodeBFunction,$TotalExternalEUtranCell,$TotalEUtranFrequency,$TotalNRSectorCarrier,$TotalNonPmMO,$TotalMOs" | tee -a "$totalFile"
#echo "" | tee -a "$totalFile"
#mv /root/$totalFile /netsim/

