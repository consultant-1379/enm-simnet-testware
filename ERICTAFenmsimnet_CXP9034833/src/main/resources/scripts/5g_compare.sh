#!/bin/sh

### VERSION HISTORY
###################################################################################
##     Version     : 1.6
##
##     Revision    : CXP 903 4833-1-5
##
##     Author      : Vinay Baratam
##
##     JIRA        : No jira
##
##     Description : Updating for displaying correct minor and major data for NRM6.4 100K network
##
##     Date        : 13th Sep 2023
##
###################################################################################
###################################################################################
##     Version     : 1.5
##
##     Revision    : CXP 903 4833-1-4
##
##     Author      : Nainesha Chilakala
##
##     JIRA        : No jira
##
##     Description : HC design (minor/major) Support for NRM6.3 40K network
##
##     Date        : 23rd feb 2022
##
###################################################################################
###################################################################################
##     Version     : 1.4
##
##     Revision    : CXP 903 4833-1-3
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-33937
##
##     Description : HC design Support for NRM6.2 40K network
##
##     Date        : 22nd Jan 2021
##
###################################################################################
###################################################################################
##     Version     : 1.3
##
##     Revision    : CXP 903 4833-1-2
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-33291
##
##     Description : HC design Support to get total MO count on the network
##
##     Date        : 18th Oct 2020
##
#####################################################################################
####################################################################################
##     Version     : 1.2
##
##     Revision    : CXP 903 4833-1-1
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-32936
##
##     Description : HC design Support for all NRMs
##
##     Date        : 12th Oct 2020
##
#####################################################################################
##################################################################

#Name of Script :5g_Compare.sh
#Author: Mitali Sinha
#Description:The Script merges different log files
#into one and compares the data with the one present in NSSO.

############################ Declaring Variables ##################
networkSize=$3
nrm=$2
Module=$1


#Moving Simulations data from each box of network to path
PWD="/var/simnet/enm-simnet/scripts/"
mv /netsim/ieatnetsimv*.txt $PWD
mv /netsim/ieatnetsimv*.log $PWD
mv /netsim/ieatnetsimv*.csv $PWD

#Declaring Array
declare -a arr=()
declare -a arr1=()
declare -a arr2=()

echo -e "TotalNodes,NRCellCU,NRCellRelation,ExternalGNBCUCPFunction,ExternalNRCellCU,TermPointToGNodeB,EUtranCellRelation,EUtranFreqRelation,NRFreqRelation,NRCellDU,TermPointToENodeB,ExternalBroadcastPLMNInfo,ExternalENodeBFunction,ExternalEUtranCell,EUtranFrequency,NRSectorCarrier,TotalNonPmMO,TotalMOs" > $PWD/mergedOutputFile.txt
echo -e "TotalNodes,NRCellCU,NRCellRelation,ExternalGNBCUCPFunction,ExternalNRCellCU,TermPointToGNodeB,EUtranCellRelation,EUtranFreqRelation,NRFreqRelation,NRCellDU,TermPointToENodeB,ExternalBroadcastPLMNInfo,ExternalENodeBFunction,ExternalEUtranCell,EUtranFrequency,NRSectorCarrier,TotalNonPmMO,TotalMOs" > $PWD/mergedOutputFile1.txt
echo -e "TotalNodes,NRCellCU,NRCellRelation,ExternalGNBCUCPFunction,ExternalNRCellCU,TermPointToGNodeB,EUtranCellRelation,EUtranFreqRelation,NRFreqRelation,NRCellDU,TermPointToENodeB,ExternalBroadcastPLMNInfo,ExternalENodeBFunction,ExternalEUtranCell,EUtranFrequency,NRSectorCarrier,TotalNonPmMO,TotalMOs" > $PWD/mergedOutputFile2.txt

##################################################################
######Merging the 5G log files across all vFarms into one######
##################################################################
for files in `echo $PWD/ieatnetsimv*.txt`; do
     cat $files | tail -1 >> $PWD/mergedOutputFile.txt
done
for files in `echo $PWD/ieatnetsimv*.log`; do
     cat $files >> $PWD/summaryOutputFiles.txt
done
for files in `echo $PWD/ieatnetsimv*.csv`;do
     cat $files >> $PWD/TotalNodesInfo.txt
done
##################################################################
cat $PWD/TotalNodesInfo.txt | sort -V >> $PWD/TotalNodesOutput.txt
##################################################################
##############Storing the values in an array
##################################################################
for MOs in {1..18}
do
#cat mergedOutputFile.txt | awk -F"," '{print $2}' | sed -n '1!p' | paste -sd+ | bc
Attributes=`cat $PWD/mergedOutputFile.txt | awk '{split($0,a,","); print a['$MOs']}'| sed -n '1!p' |paste -sd+ | bc `
arr+=( "$Attributes")
done
##################################################################
#echo "########################## Total Data from sim ##############################"
##################################################################
totalNodeCount=${arr[0]}
NRCellCU=${arr[1]}
NRCellRelation=${arr[2]}
ExternalGNBCUCPFunction=${arr[3]}
ExternalNRCellCU=${arr[4]}
TermPointToGNodeB=${arr[5]}
EUtranCellRelation=${arr[6]}
EUtranFreqRelation=${arr[7]}
NRFreqRelation=${arr[8]}
NRCellDU=${arr[9]}
TermPointToENodeB=${arr[10]}
ExternalBroadcastPLMNInfo=${arr[11]}
ExternalENodeBFunction=${arr[12]}
ExternalEUtranCell=${arr[13]}
EUtranFrequency=${arr[14]}
NRSectorCarrier=${arr[15]}
TotalNonPmMO=${arr[16]}
TotalMOs=${arr[17]}

echo "NRCellCU = $NRCellCU"
echo "NRCellRelation = $NRCellRelation"
echo "ExternalGNBCUCPFunction = $ExternalGNBCUCPFunction"
echo "ExternalNRCellCU = $ExternalNRCellCU"
echo "TermPointToGNodeB = $TermPointToGNodeB"
echo "EUtranCellRelation = $EUtranCellRelation"
echo "EUtranFreqRelation = $EUtranFreqRelation"
echo "NRFreqRelation = $NRFreqRelation"
echo "NRCellDU = $NRCellDU"
echo "TermPointToENodeB = $TermPointToENodeB"
echo "ExternalBroadcastPLMNInfo = $ExternalBroadcastPLMNInfo"
echo "ExternalENodeBFunction = $ExternalENodeBFunction"
echo "ExternalEUtranCell = $ExternalEUtranCell"
echo "EUtranFrequency = $EUtranFrequency"
echo "NRSectorCarrier = $NRSectorCarrier"
echo "TotalNonPmMO = $TotalNonPmMO"
echo "TotalMOs = $TotalMOs"


NRCellRelation_avg=$(( $NRCellRelation / $NRCellCU ))
ExternalGNBCUCPFunction_avg=$(( $ExternalGNBCUCPFunction / $totalNodeCount ))
ExternalNRCellCU_avg=$(( $ExternalNRCellCU / $totalNodeCount ))
TermPointToGNodeB_avg=$(( $TermPointToGNodeB / $totalNodeCount ))
EUtranCellRelation_avg=$(( $EUtranCellRelation / $NRCellCU ))
EUtranFreqRelation_avg=$(( $EUtranFreqRelation / $NRCellCU ))
NRFreqRelation_avg=$(( $NRFreqRelation / $NRCellCU ))
TermPointToENodeB_avg=$(( $TermPointToENodeB / $NRCellCU ))
ExternalBroadcastPLMNInfo_avg=$(( $ExternalBroadcastPLMNInfo / $NRCellCU ))
ExternalENodeBFunction_avg=$(( $ExternalENodeBFunction / $NRCellCU ))
ExternalEUtranCell_avg=$(( $ExternalEUtranCell / $NRCellCU ))
EUtranFrequency_avg=$(( $EUtranFrequency / $NRCellCU ))
###################################################################

if [[ "$Module" == *"7.68KNR"* ]]
then
        minorNodeCount=360
        majorNodeCount=1560
elif [[ "$Module" == *"7.04KNR"* ]]
then
        minorNodeCount=400
        majorNodeCount=1360
else
        minorNodeCount=$(awk "BEGIN { pc=20*${totalNodeCount}/100; i=int(pc); print (pc-i<0.5)?i:i+1 }")
        majorNodeCount=$(awk "BEGIN { pc=80*${totalNodeCount}/100; i=int(pc); print (pc-i<0.5)?i:i+1 }")
fi

echo "Total NodeCount = $totalNodeCount \n"
echo "Minor NodeCount = $minorNodeCount \n"
echo "Major NodeCount = $majorNodeCount \n"

##################################################################
######Merging the 5G text files across all Minor and Major vFarms into one######
##################################################################

sed -n "1,$minorNodeCount"p $PWD/TotalNodesOutput.txt >> minorOutputFile.txt
sed -n "$((++minorNodeCount)),$"p $PWD/TotalNodesOutput.txt >> majorOutputFile.txt

cat minorOutputFile.txt | cut -d ',' -f2- >> mergedOutputFile1.txt
sed -i 's/^/1,/g' mergedOutputFile1.txt
sed -i '1s/1/TotalNodes/g' mergedOutputFile1.txt

cat majorOutputFile.txt | cut -d ',' -f2- >> mergedOutputFile2.txt
sed -i 's/^/1,/g' mergedOutputFile2.txt
sed -i '1s/1/TotalNodes/g' mergedOutputFile2.txt

###################################################################
##############Storing the Minor Major values in an array
##################################################################
for MOs in {1..18}
do
MinorAttributes=`cat $PWD/mergedOutputFile1.txt | awk '{split($0,b,","); print b['$MOs']}'| sed -n '1!p' |paste -sd+ | bc `
arr1+=( "$MinorAttributes")
done

for MOs in {1..18}
do
MajorAttributes=`cat $PWD/mergedOutputFile2.txt | awk '{split($0,c,","); print c['$MOs']}'| sed -n '1!p' |paste -sd+ | bc `
arr2+=( "$MajorAttributes")
done

##################################################################
########################## Minor Data from sim ##################"
##################################################################
NRCellCU_minor=${arr1[1]}
NRCellRelation_minor=${arr1[2]}
ExternalGNBCUCPFunction_minor=${arr1[3]}
ExternalNRCellCU_minor=${arr1[4]}
TermPointToGNodeB_minor=${arr1[5]}
EUtranCellRelation_minor=${arr1[6]}
EUtranFreqRelation_minor=${arr1[7]}
NRFreqRelation_minor=${arr1[8]}
NRCellDU_minor=${arr1[9]}
TermPointToENodeB_minor=${arr1[10]}
ExternalBroadcastPLMNInfo_minor=${arr1[11]}
ExternalENodeBFunction_minor=${arr1[12]}
ExternalEUtranCell_minor=${arr1[13]}
EUtranFrequency_minor=${arr1[14]}
NRSectorCarrier_minor=${arr1[15]}
TotalNonPmMO_minor=${arr1[16]}
TotalMOs_minor=${arr1[17]}

echo "Total MinorNodeCount = ${arr1[0]}"
echo "NRCellCU_minor = $NRCellCU_minor"
echo "NRCellRelation_minor = $NRCellRelation_minor"
echo "ExternalGNBCUCPFunction_minor = $ExternalGNBCUCPFunction_minor"
echo "ExternalNRCellCU_minor = $ExternalNRCellCU_minor"
echo "TermPointToGNodeB_minor = $TermPointToGNodeB_minor"
echo "EUtranCellRelation_minor = $EUtranCellRelation_minor"
echo "EUtranFreqRelation_minor = $EUtranFreqRelation_minor"
echo "NRFreqRelation_minor = $NRFreqRelation_minor"
echo "NRCellDU_minor = $NRCellDU_minor"
echo "TermPointToENodeB_minor = $TermPointToENodeB_minor"
echo "ExternalBroadcastPLMNInfo_minor = $ExternalBroadcastPLMNInfo_minor"
echo "ExternalENodeBFunction_minor = $ExternalENodeBFunction_minor"
echo "ExternalEUtranCell_minor = $ExternalEUtranCell_minor"
echo "EUtranFrequency_minor = $EUtranFrequency_minor"
echo "NRSectorCarrier_minor = $NRSectorCarrier_minor"
echo "TotalNonPmMO_minor = $TotalNonPmMO_minor"
echo "TotalMOs_minor = $TotalMOs_minor"

NRCellRelation_minor_avg=$(( $NRCellRelation_minor / $NRCellCU_minor ))
ExternalGNBCUCPFunction_minor_avg=$(( $ExternalGNBCUCPFunction_minor / $minorNodeCount ))
ExternalNRCellCU_minor_avg=$(( $ExternalNRCellCU_minor / $minorNodeCount ))
TermPointToGNodeB_minor_avg=$(( $TermPointToGNodeB_minor / $minorNodeCount ))
EUtranCellRelation_minor_avg=$(( $EUtranCellRelation_minor / $NRCellCU_minor ))
EUtranFreqRelation_minor_avg=$(( $EUtranFreqRelation_minor / $NRCellCU_minor ))
NRFreqRelation_minor_avg=$(( $NRFreqRelation_minor / $NRCellCU_minor ))
TermPointToENodeB_minor_avg=$(( $TermPointToENodeB_minor / $NRCellCU_minor ))
ExternalBroadcastPLMNInfo_minor_avg=$(( $ExternalBroadcastPLMNInfo_minor / $NRCellCU_minor ))
ExternalENodeBFunction_minor_avg=$(( $ExternalENodeBFunction_minor / $NRCellCU_minor ))
ExternalEUtranCell_minor_avg=$(( $ExternalEUtranCell_minor / $NRCellCU_minor ))
EUtranFrequency_minor_avg=$(( $EUtranFrequency_minor / $NRCellCU_minor ))

##################################################################
########################## Major Data from sim ##################"
##################################################################
NRCellCU_major=${arr2[1]}
NRCellRelation_major=${arr2[2]}
ExternalGNBCUCPFunction_major=${arr2[3]}
ExternalNRCellCU_major=${arr2[4]}
TermPointToGNodeB_major=${arr2[5]}
EUtranCellRelation_major=${arr2[6]}
EUtranFreqRelation_major=${arr2[7]}
NRFreqRelation_major=${arr2[8]}
NRCellDU_major=${arr2[9]}
TermPointToENodeB_major=${arr2[10]}
ExternalBroadcastPLMNInfo_major=${arr2[11]}
ExternalENodeBFunction_major=${arr2[12]}
ExternalEUtranCell_major=${arr2[13]}
EUtranFrequency_major=${arr2[14]}
NRSectorCarrier_major=${arr2[15]}
TotalNonPmMO_major=${arr2[16]}
TotalMOs_major=${arr2[17]}

echo "Total MinorNodeCount = ${arr1[0]}"
echo "NRCellCU_major = $NRCellCU_major"
echo "NRCellRelation_major = $NRCellRelation_major"
echo "ExternalGNBCUCPFunction_major = $ExternalGNBCUCPFunction_major"
echo "ExternalNRCellCU_major = $ExternalNRCellCU_major"
echo "TermPointToGNodeB_major = $TermPointToGNodeB_major"
echo "EUtranCellRelation_major = $EUtranCellRelation_major"
echo "EUtranFreqRelation_major = $EUtranFreqRelation_major"
echo "NRFreqRelation_major = $NRFreqRelation_major"
echo "NRCellDU_major = $NRCellDU_major"
echo "TermPointToENodeB_major = $TermPointToENodeB_major"
echo "ExternalBroadcastPLMNInfo_major = $ExternalBroadcastPLMNInfo_major"
echo "ExternalENodeBFunction_major = $ExternalENodeBFunction_major"
echo "ExternalEUtranCell_major = $ExternalEUtranCell_major"
echo "EUtranFrequency_major = $EUtranFrequency_major"
echo "NRSectorCarrier_major = $NRSectorCarrier_major"
echo "TotalNonPmMO_major = $TotalNonPmMO_major"
echo "TotalMOs_major = $TotalMOs_major"

NRCellRelation_major_avg=$(( $NRCellRelation_major / $NRCellCU_major ))
ExternalGNBCUCPFunction_major_avg=$(( $ExternalGNBCUCPFunction_major / $majorNodeCount ))
ExternalNRCellCU_major_avg=$(( $ExternalNRCellCU_major / $majorNodeCount ))
TermPointToGNodeB_major_avg=$(( $TermPointToGNodeB_major / $majorNodeCount ))
EUtranCellRelation_major_avg=$(( $EUtranCellRelation_major / $NRCellCU_major ))
EUtranFreqRelation_major_avg=$(( $EUtranFreqRelation_major / $NRCellCU_major ))
NRFreqRelation_major_avg=$(( $NRFreqRelation_major / $NRCellCU_major ))
TermPointToENodeB_major_avg=$(( $TermPointToENodeB_major / $NRCellCU_major ))
ExternalBroadcastPLMNInfo_major_avg=$(( $ExternalBroadcastPLMNInfo_major / $NRCellCU_major ))
ExternalENodeBFunction_major_avg=$(( $ExternalENodeBFunction_major / $NRCellCU_major ))
ExternalEUtranCell_major_avg=$(( $ExternalEUtranCell_major / $NRCellCU_major ))
EUtranFrequency_major_avg=$(( $EUtranFrequency_major / $NRCellCU_major ))

###################JSON PART######################################
###################################################################
echo "###############################################################################"
echo "###########****************DATA FROM JSON FILE**********************###########"
echo "###############################################################################"

# "#######   Downloading jq script   #######"
curl -O "https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/content/repositories/nss-releases/com/ericsson/nss/scripts/jq/1.0.1/jq-1.0.1.tar"  ; tar -xvf jq-1.0.1.tar ; chmod +x ./jq

# "#######   Calling REST CALL [NRM4.1]  #######"
wget -q -O - --no-check-certificate "https://nss.seli.wh.rnd.internal.ericsson.com/NetworkConfiguration/rest/config/nrm/${nrm}" > Data1.json

if [[ "$Module" == *"7.04KNR"* ]] || [[ "$Module" == *"15KNR_ModuleF_2_3840DG2"* ]]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."NRRAT Node Split Table_2_2") | .[]| select (.name=="total network")' Data1.json > Data
else
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."NRRAT Node Split Table_2") | .[]| select (.name=="total network")' Data1.json > Data
fi

NRCellRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="NRCellRelation")|(.total)'  Data)
ExternalGNBCUCPFunction_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalGNBCUCPFunction")|(.total)'  Data)
ExternalNRCellCU_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalNRCellCU")|(.total)'  Data)
TermPointToGNodeB_Total=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToGNodeB")|(.total)'  Data)
EUtranCellRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="EUtranCellRelation")|(.total)'  Data)
EUtranFreqRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFreqRelation")|(.total)'  Data)
NRFreqRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="NRFreqRelation")|(.total)'  Data)
TermPointToENodeB_Total=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToENodeB")|(.total)'  Data)
ExternalBroadcastPLMNInfo_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalBroadcastPLMNInfo")|(.total)'  Data)
ExternalENodeBFunction_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalENodeBFunction")|(.total)'  Data)
ExternalEUtranCell_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalEUtranCell")|(.total)'  Data)
EUtranFrequency_Total=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFrequency")|(.total)'  Data)

NRCellRelation_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="NRCellRelation")|(.percell)'  Data)
ExternalGNBCUCPFunction_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalGNBCUCPFunction")|(.percell)'  Data)
ExternalNRCellCU_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalNRCellCU")|(.percell)'  Data)
TermPointToGNodeB_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToGNodeB")|(.percell)'  Data)
EUtranCellRelation_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranCellRelation")|(.percell)'  Data)
EUtranFreqRelation_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFreqRelation")|(.percell)'  Data)
NRFreqRelation_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="NRFreqRelation")|(.percell)'  Data)
TermPointToENodeB_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToENodeB")|(.percell)'  Data)
ExternalBroadcastPLMNInfo_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalBroadcastPLMNInfo")|(.percell)'  Data)
ExternalENodeBFunction_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalENodeBFunction")|(.percell)'  Data)
ExternalEUtranCell_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalEUtranCell")|(.percell)'  Data)
EUtranFrequency_Total_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFrequency")|(.percell)'  Data)
############################################################
##                   Minor Count                      ######
############################################################
if [[ "$Module" == *"7.04KNR"* ]]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."NRRAT Node Split Table_2_2") | .[]| select (.name=="total network")' Data1.json > Data1
elif [[ "$Module" == *"15KNR_ModuleF_2_3840DG2"* ]]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."NRRAT Node Split Table_2_2") | .[]| select (.name=="minor network")' Data1.json > Data1
else
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."NRRAT Node Split Table_2") | .[]| select (.name=="minor network")' Data1.json > Data1
fi

NRCellRelation_Minor=$(./jq --raw-output '(.value[])| select(."name"=="NRCellRelation")|(.total)'  Data1)
ExternalGNBCUCPFunction_Minor=$(./jq --raw-output '(.value[])| select(."name"=="ExternalGNBCUCPFunction")|(.total)'  Data1)
ExternalNRCellCU_Minor=$(./jq --raw-output '(.value[])| select(."name"=="ExternalNRCellCU")|(.total)'  Data1)
TermPointToGNodeB_Minor=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToGNodeB")|(.total)'  Data1)
EUtranCellRelation_Minor=$(./jq --raw-output '(.value[])| select(."name"=="EUtranCellRelation")|(.total)'  Data1)
EUtranFreqRelation_Minor=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFreqRelation")|(.total)'  Data1)
NRFreqRelation_Minor=$(./jq --raw-output '(.value[])| select(."name"=="NRFreqRelation")|(.total)'  Data1)
TermPointToENodeB_Minor=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToENodeB")|(.total)'  Data1)
ExternalBroadcastPLMNInfo_Minor=$(./jq --raw-output '(.value[])| select(."name"=="ExternalBroadcastPLMNInfo")|(.total)'  Data1)
ExternalENodeBFunction_Minor=$(./jq --raw-output '(.value[])| select(."name"=="ExternalENodeBFunction")|(.total)'  Data1)
ExternalEUtranCell_Minor=$(./jq --raw-output '(.value[])| select(."name"=="ExternalEUtranCell")|(.total)'  Data1)
EUtranFrequency_Minor=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFrequency")|(.total)'  Data1)

NRCellRelation_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="NRCellRelation")|(.percell)'  Data1)
ExternalGNBCUCPFunction_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalGNBCUCPFunction")|(.percell)'  Data1)
ExternalNRCellCU_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalNRCellCU")|(.percell)'  Data1)
TermPointToGNodeB_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToGNodeB")|(.percell)'  Data1)
EUtranCellRelation_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranCellRelation")|(.percell)'  Data1)
EUtranFreqRelation_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFreqRelation")|(.percell)'  Data1)
NRFreqRelation_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="NRFreqRelation")|(.percell)'  Data1)
TermPointToENodeB_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToENodeB")|(.percell)'  Data1)
ExternalBroadcastPLMNInfo_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalBroadcastPLMNInfo")|(.percell)'  Data1)
ExternalENodeBFunction_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalENodeBFunction")|(.percell)'  Data1)
ExternalEUtranCell_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalEUtranCell")|(.percell)'  Data1)
EUtranFrequency_Minor_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFrequency")|(.percell)'  Data1)

#echo "######################################################"
#echo "################## Minor Count #######################"
#echo "######################################################"
#echo "NRCellRelation_Minor = $NRCellRelation_Minor"
#echo "ExternalGNBCUCPFunction_Minor = $ExternalGNBCUCPFunction_Minor"
#echo "ExternalNRCellCU_Minor = $ExternalNRCellCU_Minor"
#echo "TermPointToGNodeB_Minor = $TermPointToGNodeB_Minor"
#echo "EUtranCellRelation_Minor = $EUtranCellRelation_Minor"
#echo "EUtranFreqRelation_Minor = $EUtranFreqRelation_Minor"
#echo "NRFreqRelation_Minor = $NRFreqRelation_Minor"
#echo "TermPointToENodeB_Minor = $TermPointToENodeB_Minor"
#echo "ExternalBroadcastPLMNInfo_Minor = $ExternalBroadcastPLMNInfo_Minor"
#echo "ExternalENodeBFunction_Minor = $ExternalENodeBFunction_Minor"
#echo "ExternalEUtranCell_Minor = $ExternalEUtranCell_Minor"
#echo "EUtranFrequency_Minor = $EUtranFrequency_Minor"

############################################################

############################################################
##                   Major Count                      ######
############################################################
if [[ "$Module" == *"7.04KNR"* ]]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."NRRAT Node Split Table_2_2") | .[]| select (.name=="total network")' Data1.json > Data2
elif [[ "$Module" == *"15KNR_ModuleF_2_3840DG2"* ]]
then
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."NRRAT Node Split Table_2_2") | .[]| select (.name=="major network")' Data1.json > Data2
else
    ./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."NRRAT Node Split Table_2") | .[]| select (.name=="major network")' Data1.json > Data2
fi

NRCellRelation_Major=$(./jq --raw-output '(.value[])| select(."name"=="NRCellRelation")|(.total)'  Data2)
ExternalGNBCUCPFunction_Major=$(./jq --raw-output '(.value[])| select(."name"=="ExternalGNBCUCPFunction")|(.total)'  Data2)
ExternalNRCellCU_Major=$(./jq --raw-output '(.value[])| select(."name"=="ExternalNRCellCU")|(.total)'  Data2)
TermPointToGNodeB_Major=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToGNodeB")|(.total)'  Data2)
EUtranCellRelation_Major=$(./jq --raw-output '(.value[])| select(."name"=="EUtranCellRelation")|(.total)'  Data2)
EUtranFreqRelation_Major=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFreqRelation")|(.total)'  Data2)
NRFreqRelation_Major=$(./jq --raw-output '(.value[])| select(."name"=="NRFreqRelation")|(.total)'  Data2)
TermPointToENodeB_Major=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToENodeB")|(.total)'  Data2)
ExternalBroadcastPLMNInfo_Major=$(./jq --raw-output '(.value[])| select(."name"=="ExternalBroadcastPLMNInfo")|(.total)'  Data2)
ExternalENodeBFunction_Major=$(./jq --raw-output '(.value[])| select(."name"=="ExternalENodeBFunction")|(.total)'  Data2)
ExternalEUtranCell_Major=$(./jq --raw-output '(.value[])| select(."name"=="ExternalEUtranCell")|(.total)'  Data2)
EUtranFrequency_Major=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFrequency")|(.total)'  Data2)

NRCellRelation_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="NRCellRelation")|(.percell)'  Data2)
ExternalGNBCUCPFunction_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalGNBCUCPFunction")|(.percell)'  Data2)
ExternalNRCellCU_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalNRCellCU")|(.percell)'  Data2)
TermPointToGNodeB_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToGNodeB")|(.percell)'  Data2)
EUtranCellRelation_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranCellRelation")|(.percell)'  Data2)
EUtranFreqRelation_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFreqRelation")|(.percell)'  Data2)
NRFreqRelation_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="NRFreqRelation")|(.percell)'  Data2)
TermPointToENodeB_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToENodeB")|(.percell)'  Data2)
ExternalBroadcastPLMNInfo_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalBroadcastPLMNInfo")|(.percell)'  Data2)
ExternalENodeBFunction_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalENodeBFunction")|(.percell)'  Data2)
ExternalEUtranCell_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalEUtranCell")|(.percell)'  Data2)
EUtranFrequency_Major_avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFrequency")|(.percell)'  Data2)

#echo "######################################################"
#echo "################## Major Count #######################"
#echo "######################################################"
#echo "NRCellRelation_Major = $NRCellRelation_Major"
#echo "ExternalGNBCUCPFunction_Major = $ExternalGNBCUCPFunction_Major"
#echo "ExternalNRCellCU_Major = $ExternalNRCellCU_Major"
#echo "TermPointToGNodeB_Major = $TermPointToGNodeB_Major"
#echo "EUtranCellRelation_Major = $EUtranCellRelation_Major"
#echo "EUtranFreqRelation_Major = $EUtranFreqRelation_Major"
#echo "NRFreqRelation_Major = $NRFreqRelation_Major"
#echo "TermPointToENodeB_Major = $TermPointToENodeB_Major"
#echo "ExternalBroadcastPLMNInfo_Major = $ExternalBroadcastPLMNInfo_Major"
#echo "ExternalENodeBFunction_Major = $ExternalENodeBFunction_Major"
#echo "ExternalEUtranCell_Major = $ExternalEUtranCell_Major"
#echo "EUtranFrequency_Major = $EUtranFrequency_Major"
############################################################

echo "######################################################"
echo "##########************-COMPARISON******###############"
echo "######################################################"

if [[ "$NRCellRelation_avg" -ge  "$NRCellRelation_Total_avg" ]]; then
TotalNRCellRelation_Result="PASSED"
else
TotalNRCellRelation_Result="FAILED"
fi

echo "MO_Name Sim_Data_avg  NSSO_Data_avg Result " >> Result.txt

echo "TotalNRCellRelation_Count $NRCellRelation_avg  $NRCellRelation_Total_avg $TotalNRCellRelation_Result " >> Result.txt


if [ "$ExternalGNBCUCPFunction_avg" -ge  "$ExternalGNBCUCPFunction_Total_avg" ]; then
TotalExternalGNBCUCPFunction_Result="PASSED"
else
TotalExternalGNBCUCPFunction_Result="FAILED"
fi

echo "TotalExternalGNBCUCPFunction_Count $ExternalGNBCUCPFunction_avg  $ExternalGNBCUCPFunction_Total_avg $TotalExternalGNBCUCPFunction_Result " >> Result.txt

if [ "$ExternalNRCellCU_avg" -ge  "$ExternalNRCellCU_Total_avg" ]; then
TotalExternalNRCellCU_Result="PASSED"
else
TotalExternalNRCellCU_Result="FAILED"
fi

echo "TotalExternalNRCellCU_Count $ExternalNRCellCU_avg  $ExternalNRCellCU_Total_avg $TotalExternalNRCellCU_Result " >> Result.txt

if [ "$TermPointToGNodeB_avg" -ge  "$TermPointToGNodeB_Total_avg" ]; then
TotalTermPointToGNodeB_Result="PASSED"
else
TotalTermPointToGNodeB_Result="FAILED"
fi

echo "TotalTermPointToGNodeB_Count $TermPointToGNodeB_avg  $TermPointToGNodeB_Total_avg $TotalTermPointToGNodeB_Result " >> Result.txt

if [ "$EUtranCellRelation_avg" -ge  "$EUtranCellRelation_Total_avg" ]; then
TotalEUtranCellRelation_Result="PASSED"
else
TotalEUtranCellRelation_Result="FAILED"
fi

echo "TotalEUtranCellRelation_Count $EUtranCellRelation_avg  $EUtranCellRelation_Total_avg $TotalEUtranCellRelation_Result " >> Result.txt

if [ "$EUtranFreqRelation_avg" -ge  "$EUtranFreqRelation_Total_avg" ]; then
TotalEUtranFreqRelation_Result="PASSED"
else
TotalEUtranFreqRelation_Result="FAILED"
fi

echo "TotalEUtranFreqRelation_Count $EUtranFreqRelation_avg  $EUtranFreqRelation_Total_avg $TotalEUtranFreqRelation_Result " >> Result.txt

if [ "$NRFreqRelation_avg" -ge  "$NRFreqRelation_Total_avg" ]; then
TotalNRFreqRelation_Result="PASSED"
else
TotalNRFreqRelation_Result="FAILED"
fi

echo "TotalNRFreqRelation_Count $NRFreqRelation_avg  $NRFreqRelation_Total_avg $TotalNRFreqRelation_Result " >> Result.txt
if [ "$TermPointToENodeB_avg" -ge  "$TermPointToENodeB_Total_avg" ]; then
TotalTermPointToENodeB_Result="PASSED"
else
TotalTermPointToENodeB_Result="FAILED"
fi

echo "TotalTermPointToENodeB_Count $TermPointToENodeB_avg  $TermPointToENodeB_Total_avg $TotalTermPointToENodeB_Result " >> Result.txt
if [ "$ExternalBroadcastPLMNInfo_avg" -ge  "$ExternalBroadcastPLMNInfo_Total_avg" ]; then
TotalExternalBroadcastPLMNInfo_Result="PASSED"
else
TotalExternalBroadcastPLMNInfo_Result="FAILED"
fi

echo "TotalExternalBroadcastPLMNInfo_Count $ExternalBroadcastPLMNInfo_avg  $ExternalBroadcastPLMNInfo_Total_avg $TotalExternalBroadcastPLMNInfo_Result " >> Result.txt
if [ "$ExternalENodeBFunction_avg" -ge  "$ExternalENodeBFunction_Total_avg" ]; then
TotalExternalENodeBFunction_Result="PASSED"
else
TotalExternalENodeBFunction_Result="FAILED"
fi

echo "TotalExternalENodeBFunction_Count $ExternalENodeBFunction_avg  $ExternalENodeBFunction_Total_avg $TotalExternalENodeBFunction_Result " >> Result.txt
if [ "$ExternalEUtranCell_avg" -ge  "$ExternalEUtranCell_Total_avg" ]; then
TotalExternalEUtranCell_Result="PASSED"
else
TotalExternalEUtranCell_Result="FAILED"
fi

echo "TotalExternalEUtranCell_Count $ExternalEUtranCell_avg  $ExternalEUtranCell_Total_avg $TotalExternalEUtranCell_Result " >> Result.txt
if [ "$EUtranFrequency_avg" -ge  "$EUtranFrequency_Total_avg" ]; then
TotalEUtranFrequency_Result="PASSED"
else
TotalEUtranFrequency_Result="FAILED"
fi

echo "TotalEUtranFrequency_Count $EUtranFrequency_avg  $EUtranFrequency_Total_avg $TotalEUtranFrequency_Result " >> Result.txt
######################################################
#######************Minor Count COMPARISON******#######
######################################################

if [[ "$NRCellRelation_minor_avg" -ge "$NRCellRelation_Minor_avg" ]]; then
MinorNRCellRelation_Result="PASSED"
else
MinorNRCellRelation_Result="FAILED"
fi

echo "MO_Name Sim_Data_avg  NSSO_Data_avg Result " >> Result.txt
echo "MinorNRCellRelation_Count $NRCellRelation_minor_avg  $NRCellRelation_Minor_avg $MinorNRCellRelation_Result " >> Result.txt

if [[ "$ExternalGNBCUCPFunction_minor_avg" -ge "$ExternalGNBCUCPFunction_Minor_avg" ]]; then
MinorExternalGNBCUCPFunction_Result="PASSED"
else
MinorExternalGNBCUCPFunction_Result="FAILED"
fi

echo "MinorExternalGNBCUCPFunction_count $ExternalGNBCUCPFunction_minor_avg  $ExternalGNBCUCPFunction_Minor_avg $MinorExternalGNBCUCPFunction_Result " >> Result.txt

if [[ "$ExternalNRCellCU_minor" -ge "$ExternalNRCellCU_Minor" ]]; then
MinorExternalNRCellCU_Result="PASSED"
else
MinorExternalNRCellCU_Result="FAILED"
fi

echo "MinorExternalNRCellCU_count $ExternalNRCellCU_minor_avg  $ExternalNRCellCU_Minor_avg $MinorExternalNRCellCU_Result " >> Result.txt

if [[ "$TermPointToGNodeB_minor_avg" -ge "$TermPointToGNodeB_Minor_avg" ]]; then
MinorTermPointToGNodeB_Result="PASSED"
else
MinorTermPointToGNodeB_Result="FAILED"
fi

echo "MinorTermPointToGNodeB_count $TermPointToGNodeB_minor_avg  $TermPointToGNodeB_Minor_avg $MinorTermPointToGNodeB_Result " >> Result.txt

if [[ "$EUtranCellRelation_minor_avg" -ge "$EUtranCellRelation_Minor_avg" ]]; then
MinorEUtranCellRelation_Result="PASSED"
else
MinorEUtranCellRelation_Result="FAILED"
fi

echo "MinorEUtranCellRelation_count $EUtranCellRelation_minor_avg  $EUtranCellRelation_Minor_avg $MinorEUtranCellRelation_Result " >> Result.txt

if [[ "$EUtranFreqRelation_minor_avg" -ge "$EUtranFreqRelation_Minor_avg" ]]; then
MinorEUtranFreqRelation_Result="PASSED"
else
MinorEUtranFreqRelation_Result="FAILED"
fi

echo "MinorEUtranFreqRelation_count $EUtranFreqRelation_minor_avg  $EUtranFreqRelation_Minor_avg $MinorEUtranFreqRelation_Result " >> Result.txt

if [[ "$NRFreqRelation_minor_avg" -ge "$NRFreqRelation_Minor_avg" ]]; then
MinorNRFreqRelation_Result="PASSED"
else
MinorNRFreqRelation_Result="FAILED"
fi

echo "MinorNRFreqRelation_count $NRFreqRelation_minor_avg  $NRFreqRelation_Minor_avg $MinorNRFreqRelation_Result " >> Result.txt

if [[ "$TermPointToENodeB_minor_avg" -ge "$TermPointToENodeB_Minor_avg" ]]; then
MinorTermPointToENodeB_Result="PASSED"
else
MinorTermPointToENodeB_Result="FAILED"
fi

echo "MinorTermPointToENodeB_count $TermPointToENodeB_minor_avg  $TermPointToENodeB_Minor_avg $MinorTermPointToENodeB_Result " >> Result.txt

if [[ "$ExternalBroadcastPLMNInfo_minor_avg" -ge "$ExternalBroadcastPLMNInfo_Minor_avg" ]]; then
ExternalBroadcastPLMNInfo_Result="PASSED"
else
ExternalBroadcastPLMNInfo_Result="FAILED"
fi

echo "MinorExternalBroadcastPLMNInfo_count $ExternalBroadcastPLMNInfo_minor_avg  $ExternalBroadcastPLMNInfo_Minor_avg $MinorExternalBroadcastPLMNInfo_Result " >> Result.txt

if [[ "$ExternalENodeBFunction_minor_avg" -ge "$ExternalENodeBFunction_Minor_avg" ]]; then
MinorExternalENodeBFunction_Result="PASSED"
else
MinorExternalENodeBFunction_Result="FAILED"
fi

echo "MinorExternalENodeBFunction_count $ExternalENodeBFunction_minor_avg  $ExternalENodeBFunction_Minor_avg $MinorExternalENodeBFunction_Result " >> Result.txt

if [[ "$ExternalEUtranCell_minor_avg" -ge "$ExternalEUtranCell_Minor_avg" ]]; then
MinorExternalEUtranCell_Result="PASSED"
else
MinorExternalEUtranCell_Result="FAILED"
fi

echo "MinorExternalEUtranCell_count $ExternalEUtranCell_minor_avg  $ExternalEUtranCell_Minor_avg $MinorExternalEUtranCell_Result " >> Result.txt

if [[ "$EUtranFrequency_minor_avg" -ge "$EUtranFrequency_Minor_avg" ]]; then
MinorEUtranFrequency_Result="PASSED"
else
MinorEUtranFrequency_Result="FAILED"
fi

echo "MinorEUtranFrequency_count $EUtranFrequency_minor_avg  $EUtranFrequency_Minor_avg $MinorEUtranFrequency_Result " >> Result.txt
######################################################
#######************Major Count COMPARISON******#######
######################################################

if [[ "$NRCellRelation_major_avg" -ge "$NRCellRelation_Major_avg" ]]; then
MajorNRCellRelation_Result="PASSED"
else
MajorNRCellRelation_Result="FAILED"
fi

echo "MO_Name Sim_Data_avg  NSSO_Data_avg Result " >> Result.txt
echo "MajorNRCellRelation_Count $NRCellRelation_major_avg  $NRCellRelation_Major_avg $MajorNRCellRelation_Result " >> Result.txt

if [[ "$ExternalGNBCUCPFunction_major_avg" -ge "$ExternalGNBCUCPFunction_Major_avg" ]]; then
MajorExternalGNBCUCPFunction_Result="PASSED"
else
MajorExternalGNBCUCPFunction_Result="FAILED"
fi

echo "MajorExternalGNBCUCPFunction_count $ExternalGNBCUCPFunction_major_avg  $ExternalGNBCUCPFunction_Major_avg $MajorExternalGNBCUCPFunction_Result " >> Result.txt

if [[ "$ExternalNRCellCU_major_avg" -ge "$ExternalNRCellCU_Major_avg" ]]; then
MajorExternalNRCellCU_Result="PASSED"
else
MajorExternalNRCellCU_Result="FAILED"
fi

echo "MajorExternalNRCellCU_count $ExternalNRCellCU_major_avg  $ExternalNRCellCU_Major_avg $MajorExternalNRCellCU_Result " >> Result.txt

if [[ "$TermPointToGNodeB_major_avg" -ge "$TermPointToGNodeB_Major_avg" ]]; then
MajorTermPointToGNodeB_Result="PASSED"
else
MajorTermPointToGNodeB_Result="FAILED"
fi

echo "MajorTermPointToGNodeB_count $TermPointToGNodeB_major_avg  $TermPointToGNodeB_Major_avg $MajorTermPointToGNodeB_Result " >> Result.txt

if [[ "$EUtranCellRelation_major_avg" -ge "$EUtranCellRelation_Major_avg" ]]; then
MajorEUtranCellRelation_Result="PASSED"
else
MajorEUtranCellRelation_Result="FAILED"
fi

echo "MajorEUtranCellRelation_count $EUtranCellRelation_major_avg  $EUtranCellRelation_Major_avg $MajorEUtranCellRelation_Result " >> Result.txt

if [[ "$EUtranFreqRelation_major_avg" -ge "$EUtranFreqRelation_Major_avg" ]]; then
MajorEUtranFreqRelation_Result="PASSED"
else
MajorEUtranFreqRelation_Result="FAILED"
fi

echo "MajorEUtranFreqRelation_count $EUtranFreqRelation_major_avg  $EUtranFreqRelation_Major_avg $MajorEUtranFreqRelation_Result " >> Result.txt

if [[ "$NRFreqRelation_major_avg" -ge "$NRFreqRelation_Major_avg" ]]; then
MajorNRFreqRelation_Result="PASSED"
else
MajorNRFreqRelation_Result="FAILED"
fi

echo "MajorNRFreqRelation_count $NRFreqRelation_major_avg  $NRFreqRelation_Major_avg $MajorNRFreqRelation_Result " >> Result.txt

if [[ "$TermPointToENodeB_major_avg" -ge "$TermPointToENodeB_Major_avg" ]]; then
MajorTermPointToENodeB_Result="PASSED"
else
MajorTermPointToENodeB_Result="FAILED"
fi

echo "MajorTermPointToENodeB_count $TermPointToENodeB_major_avg  $TermPointToENodeB_Major_avg $MajorTermPointToENodeB_Result " >> Result.txt

if [[ "$ExternalBroadcastPLMNInfo_major_avg" -ge "$ExternalBroadcastPLMNInfo_Major_avg" ]]; then
MajorExternalBroadcastPLMNInfo_Result="PASSED"
else
MajorExternalBroadcastPLMNInfo_Result="FAILED"
fi

echo "MajorExternalBroadcastPLMNInfo_count $ExternalBroadcastPLMNInfo_major_avg  $ExternalBroadcastPLMNInfo_Major_avg $MajorExternalBroadcastPLMNInfo_Result " >> Result.txt

if [[ "$ExternalENodeBFunction_major_avg" -ge "$ExternalENodeBFunction_Major_avg" ]]; then
MajorExternalENodeBFunction_Result="PASSED"
else
MajorExternalENodeBFunction_Result="FAILED"
fi

echo "MajorExternalENodeBFunction_count $ExternalENodeBFunction_major_avg  $ExternalENodeBFunction_Major_avg $MajorExternalENodeBFunction_Result " >> Result.txt

if [[ "$ExternalEUtranCell_major_avg" -ge "$ExternalEUtranCell_Major_avg" ]]; then
MajorExternalEUtranCell_Result="PASSED"
else
MajorExternalEUtranCell_Result="FAILED"
fi

echo "MajorExternalEUtranCell_count $ExternalEUtranCell_major_avg  $ExternalEUtranCell_Major_avg $MajorExternalEUtranCell_Result " >> Result.txt

if [[ "$EUtranFrequency_major_avg" -ge "$EUtranFrequency_Major_avg" ]]; then
MajorEUtranFrequency_Result="PASSED"
else
MajorEUtranFrequency_Result="FAILED"
fi

echo "MajorEUtranFrequency_count $EUtranFrequency_major_avg  $EUtranFrequency_Major_avg $MajorEUtranFrequency_Result " >> Result.txt

awk '{printf "%-40s|%-20s|%-20s|%-20s\n",$1,$2,$3,$4}'  Result.txt
######################################################################
####################

TotalMOs_module=`expr $TotalMOs_minor + $TotalMOs_major`

echo "*******************************************************************"
echo "Total MOS present in this Module is $TotalMOs_module"
echo "*******************************************************************"


#read /var/simnet/enm-simnet/scripts/FailedData.txt
if  grep -q FAILED "Result.txt"
then
echo "INFO: There are some Failures"
exit 903
else
echo "INFO :No Errors"
fi

####################


rm -rf /netsim/ieatnetsimv*.log
if [[ $? -ne 0 ]]
then
        echo "Removing of text files from netsim failed"
        exit 901
 fi
rm -rf /var/simnet/enm-simnet/scripts/mergedOutputFile.txt Result.txt /var/simnet/enm-simnet/scripts/mergedOutputFile1.txt /var/simnet/enm-simnet/scripts/mergedOutputFile2.txt
if [[ $? -ne 0 ]]
then
        echo "Removing of Result.txt and mergedOutputFile.txt from netsim failed"
        exit 902
 fi
