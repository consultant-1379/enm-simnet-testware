#!/bin/sh
#################################################################################
##     Version     : 1.7
##     Revision    : CXP 903 4833-1-3
##     Author      : Saivikas Jaini
##     JIRA        : NSS-46403
##     Description : Added support for getting the minor and major values for the NRM
##     Date        : 30th Nov 2023
##################################################################################
##     Version     : 1.6
##     Revision    : CXP 903 4833-1-3
##     Author      : Saivikas Jaini
##     JIRA        : NSS-46009
##     Description : Added TermPointtoMme 
##     Date        : 13th Oct 2023
##################################################################################
##     Version     : 1.5
##     Revision    : CXP 903 4833-1-3
##     Author      : Saivikas Jaini
##     JIRA        : NSS-44956
##     Description : Added ExternalGeranCell,TotalNonPmMO mos
##     Date        : 14th Sep 2023
###################################################################################
##     Version     : 1.4
##
##     Revision    : CXP 903 4833-1-3
##
##     Author      : Jagan Nampally     
##
##     JIRA        : NSS-41320
##
##     Description : HC design support to generate average values as part of HC report
##
##     Date        : 14th Feb 2023
##
###################################################################################
##     Version     : 1.3
##
##     Revision    : CXP 903 4833-1-3
##
##     Author      : Jagan Nampally	
##
##     JIRA        : NA
##
##     Description : HC design Support for NRM6.3 80K network
##
##     Date        : 7th Mar 2022
##
###################################################################################
##     Version     : 1.2
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
##################################################################

#Name of Script :LRANcompare.sh
#Author: Mitali Sinha
#Description:The Script merges different log files
#into one and compares the data with the one present in NSSO.

###################################################################
#Moving Simulations data from each box of network to path
#'/var/simnet/enm-simnet/scripts/'
networkSize=$1
nrm=$2
echo "networkSize=$networkSize"
#Moving Simulations data from each box of network to path
PWD="/var/simnet/enm-simnet/scripts/"
mv /netsim/ieatnetsimv*.txt /var/simnet/enm-simnet/scripts/
mv /netsim/ieatnetsimv*.log /var/simnet/enm-simnet/scripts/
mv /netsim/ieatnetsimv*.csv /var/simnet/enm-simnet/scripts/

#mv /netsim/ieatnetsimv*.txt /var/simnet/enm-simnet/scripts/
#Declaring Array
declare -a arr=()
declare -a arr1=()
declare -a arr2=()

echo -e "TotalNodes,EUtranCellFDD,EUtranCellRelation,EUtranFreqRelation,ExternalENodeBFunction,ExternalEUtranCellFDD,UtranCellRelation,UtranFreqRelation,ExternalUtranCellFDD,GeranCellRelation,GeranFreqGroupRelation,GeranFrequency,TermPointToENB,TermPointToMme,SectorCarrier,ExternalGeranCell,RetSubUnit,TotalNonPmMO,TotalMO" >> /var/simnet/enm-simnet/scripts/mergedOutputFile.txt
echo -e "TotalNodes,EUtranCellFDD,EUtranCellRelation,EUtranFreqRelation,ExternalENodeBFunction,ExternalEUtranCellFDD,UtranCellRelation,UtranFreqRelation,ExternalUtranCellFDD,GeranCellRelation,GeranFreqGroupRelation,GeranFrequency,TermPointToENB,TermPointToMme,SectorCarrier,ExternalGeranCell,RetSubUnit,TotalNonPmMO,TotalMO" >> /var/simnet/enm-simnet/scripts/mergedOutputFile1.txt
echo -e "TotalNodes,EUtranCellFDD,EUtranCellRelation,EUtranFreqRelation,ExternalENodeBFunction,ExternalEUtranCellFDD,UtranCellRelation,UtranFreqRelation,ExternalUtranCellFDD,GeranCellRelation,GeranFreqGroupRelation,GeranFrequency,TermPointToENB,TermPointToMme,SectorCarrier,ExternalGeranCell,RetSubUnit,TotalNonPmMO,TotalMO" >> /var/simnet/enm-simnet/scripts/mergedOutputFile2.txt

#echo -e "\n" >> /var/simnet/enm-simnet/scripts/mergedOutputFile.txt
##################################################################
######Merging the LRAN text files across all vFarms into one######
##################################################################
for i in `echo /var/simnet/enm-simnet/scripts/ieatnetsimv*.txt`; do
    #echo "file is $i"
    cat $i | tail -n -2 | head -n -1 >> /var/simnet/enm-simnet/scripts/mergedOutputFile.txt
done
for files in `echo /var/simnet/enm-simnet/scripts/ieatnetsimv*.log`; do
 cat $files >> /var/simnet/enm-simnet/scripts/summaryOutputFiles.txt
 done
 for files in `echo /var/simnet/enm-simnet/scripts/ieatnetsimv*.csv`;do
 cat $files >> /var/simnet/enm-simnet/scripts/TotalNodesInfo.txt
 done
  ##################################################################
  cat /var/simnet/enm-simnet/scripts/TotalNodesInfo.txt | sort -V >> /var/simnet/enm-simnet/scripts/TotalNodesOutput.txt
  ##################################################################

LIST=`cat /var/simnet/enm-simnet/scripts/mergedOutputFile.txt | cut -d"," -f2`
cellCounts=(${LIST// / })
cellNum=0
cellIndex=1
#echo "******{cellCounts[@]} = ${cellCounts[1]}"
while [ $cellIndex -lt ${#cellCounts[@]} ]
do
  cellNum=`expr $cellNum + ${cellCounts[$cellIndex]}`
  cellIndex=`expr $cellIndex + 1`
done
##################################################################
##############Storing the values in an array
##################################################################
for i in {1..18}
do
#cat mergedOutputFile.txt | awk -F"," '{print $2}' | sed -n '1!p' | paste -sd+ | bc
Attributes=`cat /var/simnet/enm-simnet/scripts/mergedOutputFile.txt | awk '{split($0,a,","); print a['$i']}'| sed -n '1!p' |paste -sd+ | bc `
arr+=( "$Attributes")
done
##################################################################
##########################Total Data##############################
##################################################################
 
totalNodeCount=${arr[0]}
TotalNodes=${arr[0]}
EUtranCell=${arr[1]}
EUtranCellRelation=${arr[2]}
EUtranFreqRelation=${arr[3]}
ExternalENodeBFunction=${arr[4]}
ExternalEUtranCellFDD=${arr[5]}
UtranCellRelation=${arr[6]}
UtranFreqRelation=${arr[7]}
ExternalUtranCellFDD=${arr[8]}
GeranCellRelation=${arr[9]}
GeranFreqGroupRelation=${arr[10]}
GeranFrequency=${arr[11]}
TermPointToENB=${arr[12]}
TermPointToMme=${arr[13]}
SectorCarrier=${arr[14]}
ExternalGeranCell=${arr[15}
RetSubUnit=${arr[16]}
TotalNonPmMO=${arr[17]}
TotalMO=${arr[18]}

AvgEUtranCellRelation=$(( ${arr[2]} / $EUtranCell ))
AvgEUtranFreqRelation=$(( ${arr[3]} / $EUtranCell ))
AvgExternalENodeBFunction=$(( ${arr[4]} / $TotalNodes ))
AvgExternalEUtranCellFDD=$(( ${arr[5]} / $TotalNodes ))
AvgUtranCellRelation=$(( ${arr[6]} / $EUtranCell ))
AvgUtranFreqRelation=$(( ${arr[7]} / $EUtranCell ))
AvgExternalUtranCellFDD=$(( ${arr[8]} / $TotalNodes ))
AvgGeranCellRelation=$(( ${arr[9]} / $EUtranCell ))
AvgGeranFreqGroupRelation=$(( ${arr[10]} / $EUtranCell ))
AvgGeranFrequency=$(( ${arr[11]} / $EUtranCell ))
AvgTermPointToENB=$(( ${arr[12]} / $TotalNodes ))
AvgTermPointToMme=$(( ${arr[13]} / $TotalNodes ))
AvgSectorCarrier=$(( ${arr[14]} / $EUtranCell ))
AvgExternalGeranCell=$(( ${arr[15]} / $EUtranCell ))
AvgRetSubUnit=$(( ${arr[16]} / $EUtranCell ))
TotalNonPmMo=${arr[17]}
TotalMO=${arr[18]}

##################################################################
minorNodeCount=$(awk "BEGIN { pc=20*${totalNodeCount}/100; i=int(pc); print (pc-i<0.5)?i:i+1 }")
majorNodeCount=$(awk "BEGIN { pc=80*${totalNodeCount}/100; i=int(pc); print (pc-i<0.5)?i:i+1 }")
echo "Total NodeCount = $totalNodeCount \n"
echo "Minor NodeCount = $minorNodeCount \n"
echo "Major NodeCount = $majorNodeCount \n"

##################################################################
######Merging the LTE text files across all Minor and Major vFarms into one######
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
########################## Minor Data from sim ##################
##################################################################
TotalNodes_minor=${arr1[0]}
EUtranCell_minor=${arr1[1]}
EUtranCellRelation_minor=${arr1[2]}
EUtranFreqRelation_minor=${arr1[3]}
ExternalENodeBFunction_minor=${arr1[4]}
ExternalEUtranCellFDD_minor=${arr1[5]}
UtranCellRelation_minor=${arr1[6]}
UtranFreqRelation_minor=${arr1[7]}
ExternalUtranCellFDD_minor=${arr1[8]}
GeranCellRelation_minor=${arr1[9]}
GeranFreqGroupRelation_minor=${arr1[10]}
GeranFrequency_minor=${arr1[11]}
TermPointToENB_minor=${arr1[12]}
TermPointToMme_minor=${arr1[13]}
SectorCarrier_minor=${arr1[14]}
ExternalGeranCell_minor=${arr1[15}
RetSubUnit_minor=${arr1[16]}
TotalNonPmMO_minor=${arr1[17]}
TotalMO_minor=${arr1[18]}

echo "TotalNodes_minor = $TotalNodes_minor"
echo "EUtranCell_minor = $EUtranCell_minor"
echo "EUtranCellRelation_minor = $EUtranCellRelation_minor"
echo "EUtranFreqRelation_minor = $EUtranFreqRelation_minor"
echo "ExternalENodeBFunction_minor = $ExternalENodeBFunction_minor"
echo "ExternalEUtranCellFDD_minor= $ExternalEUtranCellFDD_minor "
echo "UtranCellRelation_minor = $UtranCellRelation_minor"
echo "UtranFreqRelation_minor = $UtranFreqRelation_minor"
echo "ExternalUtranCellFDD_minor = $ExternalUtranCellFDD_minor"
echo "GeranCellRelation_minor = $GeranCellRelation_minor"
echo "GeranFreqGroupRelation_minor = $GeranFreqGroupRelation_minor"
echo "GeranFrequency_minor = $GeranFrequency_minor"
echo "TermPointToENB_minor = $TermPointToENB_minor"
echo "TermPointToMme_minor = $TermPointToMme_minor"
echo "SectorCarrier_minor = $SectorCarrier_minor"
echo "ExternalGeranCell_minor = $ExternalGeranCell_minor"
echo "RetSubUnit_minor = $RetSubUnit_minor"
echo "TotalNonPmMO_minor = $TotalNonPmMO_minor"
echo "TotalMOs_minor = $TotalMOs_minor"

AvgEUtranCellRelation_minor=$(( ${arr1[2]} / $EUtranCell ))
AvgEUtranFreqRelation_minor=$(( ${arr1[3]} / $EUtranCell ))
AvgExternalENodeBFunction_minor=$(( ${arr1[4]} / $TotalNodes ))
AvgExternalEUtranCellFDD_minor=$(( ${arr1[5]} / $TotalNodes ))
AvgUtranCellRelation_minor=$(( ${arr1[6]} / $EUtranCell ))
AvgUtranFreqRelation_minor=$(( ${arr1[7]} / $EUtranCell ))
AvgExternalUtranCellFDD_minor=$(( ${arr1[8]} / $TotalNodes ))
AvgGeranCellRelation_minor=$(( ${arr1[9]} / $EUtranCell ))
AvgGeranFreqGroupRelation_minor=$(( ${arr1[10]} / $EUtranCell ))
AvgGeranFrequency_minor=$(( ${arr1[11]} / $EUtranCell ))
AvgTermPointToENB_minor=$(( ${arr1[12]} / $TotalNodes ))
AvgTermPointToMme_minor=$(( ${arr1[13]} / $TotalNodes ))
AvgSectorCarr1ier_minor=$(( ${arr1[14]} / $EUtranCell ))
AvgExternalGeranCell_minor=$(( ${arr1[15]} / $EUtranCell ))
AvgRetSubUnit_minor=$(( ${arr1[16]} / $EUtranCell ))
TotalNonPmMo_minor=${arr1[17]}
TotalMO_minor=${arr1[18]}

##################################################################
########################## Major Data from sim ##################
##################################################################
TotalNodes_major=${arr2[0]}
EUtranCell_major=${arr2[1]}
EUtranCellRelation_major=${arr2[2]}
EUtranFreqRelation_major=${arr2[3]}
ExternalENodeBFunction_major=${arr2[4]}
ExternalEUtranCellFDD_major=${arr2[5]}
UtranCellRelation_major=${arr2[6]}
UtranFreqRelation_major=${arr2[7]}
ExternalUtranCellFDD_major=${arr2[8]}
GeranCellRelation_major=${arr2[9]}
GeranFreqGroupRelation_major=${arr2[10]}
GeranFrequency_major=${arr2[11]}
TermPointToENB_major=${arr2[12]}
TermPointToMme_major=${arr2[13]}
SectorCarr2ier_major=${arr2[14]}
ExternalGeranCell_major=${arr2[15}
RetSubUnit_major=${arr2[16]}
TotalNonPmMO_major=${arr2[17]}
TotalMO_major=${arr2[18]}

echo "TotalNodes_major = $TotalNodes_major"
echo "EUtranCell_major = $EUtranCell_major"
echo "EUtranCellRelation_major = $EUtranCellRelation_major"
echo "EUtranFreqRelation_major = $EUtranFreqRelation_major"
echo "ExternalENodeBFunction_major = $ExternalENodeBFunction_major"
echo "ExternalEUtranCellFDD_major= $ExternalEUtranCellFDD_major "
echo "UtranCellRelation_major = $UtranCellRelation_major"
echo "UtranFreqRelation_major = $UtranFreqRelation_major"
echo "ExternalUtranCellFDD_major = $ExternalUtranCellFDD_major"
echo "GeranCellRelation_major = $GeranCellRelation_major"
echo "GeranFreqGroupRelation_major = $GeranFreqGroupRelation_major"
echo "GeranFrequency_major = $GeranFrequency_major"
echo "TermPointToENB_major = $TermPointToENB_major"
echo "TermPointToMme_major = $TermPointToMme"
echo "SectorCarrier_major = $SectorCarrier_major"
echo "ExternalGeranCell_major = $ExternalGeranCell_major"
echo "RetSubUnit_major = $RetSubUnit_major"
echo "TotalNonPmMO_major = $TotalNonPmMO_major"
echo "TotalMOs_major = $TotalMOs_major"

AvgEUtranCellRelation_major=$(( ${arr2[2]} / $EUtranCell ))
AvgEUtranFreqRelation_major=$(( ${arr2[3]} / $EUtranCell ))
AvgExternalENodeBFunction_major=$(( ${arr2[4]} / $TotalNodes ))
AvgExternalEUtranCellFDD_major=$(( ${arr2[5]} / $TotalNodes ))
AvgUtranCellRelation_major=$(( ${arr2[6]} / $EUtranCell ))
AvgUtranFreqRelation_major=$(( ${arr2[7]} / $EUtranCell ))
AvgExternalUtranCellFDD_major=$(( ${arr2[8]} / $TotalNodes ))
AvgGeranCellRelation_major=$(( ${arr2[9]} / $EUtranCell ))
AvgGeranFreqGroupRelation_major=$(( ${arr2[10]} / $EUtranCell ))
AvgGeranFrequency_major=$(( ${arr2[11]} / $EUtranCell ))
AvgTermPointToENB_major=$(( ${arr2[12]} / $TotalNodes ))
AvgTermPointToMme_major=$(( ${arr2[13]} / $TotalNodes ))
AvgSectorCarr2ier_major=$(( ${arr2[14]} / $EUtranCell ))
AvgExternalGeranCell_major=$(( ${arr2[15]} / $EUtranCell ))
AvgRetSubUnit_major=$(( ${arr2[16]} / $EUtranCell ))
TotalNonPmMo_major=${arr2[17]}
TotalMO_major=${arr2[18]}
###################################################################
###################JSON PART######################################
###################################################################
#echo "###############################################################################"
#echo "###########****************DATA FROM JSON FILE**********************###########"
#echo "###############################################################################"

# "#######   Downloading jq script   #######"
curl -O "https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/content/repositories/nss-releases/com/ericsson/nss/scripts/jq/1.0.1/jq-1.0.1.tar"  ; tar -xvf jq-1.0.1.tar ; chmod +x ./jq

# "#######   Calling REST CALL [NRM4.1]  #######"
wget -q -O - --no-check-certificate "https://nss.seli.wh.rnd.internal.ericsson.com/NetworkConfiguration/rest/config/nrm/${nrm}" > Data1.json

sed -i 's/ExternalEcellBFunction/ExternalENodeBFunction/g' Data1.json
# "#######   When Network = Small (5k)  #######"
#if [ "$networkSize" == "Small" ]; then
#./jq --raw-output '.[] | (."network size") | .[] | select (.type=="Small (5k)") | (."LRAN Node Split Table_2") | .[]| select (.name=="total network")' Data1.json > Data
#elif [ "$networkSize" == "vLarge (60k)" ]; then
# "#######   When Network = vLarge (60k) #######"
#./jq --raw-output '.[] | (."network size") | .[] | select (.type=="vLarge (60k)") | (."LRAN Node Split Table_2") | .[]| select (.name=="total network")' Data1.json > Data
#else
# "#######   When Network = Large (30k) #######"
#./jq --raw-output '.[] | (."network size") | .[] | select (.type=="Large (40k)") | (."LRAN Node Split Table_2") | .[]| select (.name=="total network")' Data1.json > Data
#fi
./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."LRAN Node Split Table_2") | .[]| select (.name=="total network")' Data1.json > Data
#echo "##################################"
#echo "  1. EUtranFreqRelation Count "
#echo "##################################"

EUtranFreqRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFreqRelation")|(.total)'  Data)
EUtranFreqRelation_Avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranFreqRelation")|(.avg)'  Data)
#echo "EUtranFreqRelation_Total =$EUtranFreqRelation_Total"

#echo "##################################"
#echo "  2. RetSubUnit Count "
#echo "##################################"
RetSubUnit_Total=$(./jq --raw-output '(.value[])| select(."name"=="RetSubUnit")|(.total)'  Data)
RetSubUnit_Avg=$(./jq --raw-output '(.value[])| select(."name"=="RetSubUnit")|(.avg)'  Data)
#echo "RetSubUnit_Total =$RetSubUnit_Total"

#echo "##################################"
#echo "  3. SectorCarrier Count "
#echo "##################################"
SectorCarrier_Total=$(./jq --raw-output '(.value[])| select(."name"=="SectorCarrier")|(.total)'  Data)
SectorCarrier_Avg=$(./jq --raw-output '(.value[])| select(."name"=="SectorCarrier")|(.avg)'  Data)
#echo "SectorCarrier_Total =$SectorCarrier_Total"

#echo "##################################"
#echo "  4. ExternalENodeBFunction Count"
#echo "##################################"
ExternalENodeBFunction_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalENodeBFunction")|(.total)'  Data)
ExternalENodeBFunction_Avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalENodeBFunction")|(.avg)'  Data)
#echo "ExternalENodeBFunction_Total =$ExternalENodeBFunction_Total"

#echo "##################################"
#echo "  5. TermPointToENB Count"
#echo "##################################"
TermPointToENB_Total=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToENB")|(.total)'  Data)
TermPointToENB_Avg=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToENB")|(.avg)'  Data)
#echo "TermPointToENB_Total =$TermPointToENB_Total"

#echo "##################################"
#echo "  6. ExternalEUtranCellFDD/ ExternalEUtranCellTDD Count"
#echo "##################################"
ExternalEUtranCellFDD_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalEUtranCellFDD/TDD")|(.total)'  Data)
ExternalEUtranCellFDD_Avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalEUtranCellFDD/TDD")|(.avg)'  Data)
#echo "ExternalEUtranCellFDD_Total =$ExternalEUtranCellFDD_Total"

#echo "##################################"
#echo "  7. EUtranCellRelation Count"
#echo "##################################"
EUtranCellRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="EUtranCellRelation")|(.total)'  Data)
EUtranCellRelation_Avg=$(./jq --raw-output '(.value[])| select(."name"=="EUtranCellRelation")|(.avg)'  Data)
#echo "EUtranCellRelation_Total =$EUtranCellRelation_Total"
#echo "##################################"
#echo "  8. GeranFreqGroupRelation Count"
#echo "##################################"
GeranFreqGroupRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="GeranFreqGroupRelation")|(.total)'  Data)
GeranFreqGroupRelation_Avg=$(./jq --raw-output '(.value[])| select(."name"=="GeranFreqGroupRelation")|(.avg)'  Data)
#echo "GeranFreqGroupRelation_Total =$GeranFreqGroupRelation_Total"

#echo "##################################"
#echo "  9. GeranCellRelation Count"
#echo "##################################"
GeranCellRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="GeranCellRelation")|(.total)'  Data)
GeranCellRelation_Avg=$(./jq --raw-output '(.value[])| select(."name"=="GeranCellRelation")|(.avg)'  Data)
#echo "GeranCellRelation_Total =$GeranCellRelation_Total"

#echo "##################################"
#echo "  10. GeranFrequency Count"
#echo "##################################"
GeranFrequency_Total=$(./jq --raw-output '(.value[])| select(."name"=="GeranFrequency")|(.total)'  Data)
GeranFrequency_Avg=$(./jq --raw-output '(.value[])| select(."name"=="GeranFrequency")|(.avg)'  Data)
#echo "GeranFrequency_Total =$GeranFrequency_Total"

#echo "##################################"
#echo "  11. UtranCellRelation Count"
#echo "##################################"
UtranCellRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="UtranCellRelation")|(.total)'  Data)
UtranCellRelation_Avg=$(./jq --raw-output '(.value[])| select(."name"=="UtranCellRelation")|(.avg)'  Data)
#echo "UtranCellRelation_Total =$UtranCellRelation_Total"

#echo "##################################"
#echo "  12. UtranFreqRelation Count"
#echo "##################################"
UtranFreqRelation_Total=$(./jq --raw-output '(.value[])| select(."name"=="UtranFreqRelation")|(.total)'  Data)
UtranFreqRelation_Avg=$(./jq --raw-output '(.value[])| select(."name"=="UtranFreqRelation")|(.avg)'  Data)
#echo "UtranFreqRelation_Total =$UtranFreqRelation_Total"

#echo "##################################"
#echo "  13. ExternalUtranCellFDD/ ExternalUtranCellTDD Count"
#echo "##################################"
ExternalUtranCellFDD_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalUtranCellFDD/ ExternalUtranCellTDD")|(.total)'  Data)
ExternalUtranCellFDD_Avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalUtranCellFDD/ ExternalUtranCellTDD")|(.avg)'  Data)
#echo "ExternalUtranCellFDD_Total =$ExternalUtranCellFDD_Total"

#echo "##################################"
#echo "  14. TermPointToMme Count"
#echo "##################################"
TermPointToMme_Total=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToMme")|(.total)'  Data)
TermPointToMme_Avg=$(./jq --raw-output '(.value[])| select(."name"=="TermPointToMme")|(.avg)'  Data)
#echo "TermPointToMme_Total =$TermPointToMme_Total"

#echo "##################################"
#echo "  15. ExternalGeranCell Count "
#echo "##################################"
ExternalGeranCell_Total=$(./jq --raw-output '(.value[])| select(."name"=="ExternalGeranCell")|(.total)'  Data)
ExternalGeranCell_Avg=$(./jq --raw-output '(.value[])| select(."name"=="ExternalGeranCell")|(.avg)'  Data)
#echo "ExternalGeranCell_Total =$ExternalGeranCell_Total"


echo "######################################################"
echo "##########************-COMPARISON******###############"
echo "######################################################"

echo "arr2=${arr[2]} $EUtranCellRelation_Total"

if [ "${arr[2]}" -ge  "$EUtranCellRelation_Total" ]; then
#echo "PASSED"
TotalEUtranCellRelations_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalEUtranCellRelations_Result="FAILED"
fi

#####Display 3
echo "MO_Name Sim_Total Sim_Avg	NSSO_Total NSSO_Avg Result " >> Result.txt
echo "EUtranCellRelations_Count "${arr[2]}" $AvgEUtranCellRelation	 $EUtranCellRelation_Total $EUtranCellRelation_Avg	$TotalEUtranCellRelations_Result " >> Result.txt


#echo "Total EUtranFreqRelations = $TotalEUtranFreqRelations"
#echo "EUtranFreqRelation_Max =$EUtranFreqRelation_Max"

if [ "${arr[3]}" -ge  "$EUtranFreqRelation_Total" ]; then
#echo "PASSED"
TotalEUtranFreqRelations_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalEUtranFreqRelations_Result="FAILED"
fi

#####Display 4######
echo "TotalEUtranFreqRelations_Count ${arr[3]} $AvgEUtranFreqRelation	 $EUtranFreqRelation_Total $EUtranFreqRelation_Avg	$TotalEUtranFreqRelations_Result " >> Result.txt
####################


#echo "Total ExternalENodeBFunctions = $TotalExternalENodeBFunctions"
#echo "ExternalENodeBFunction_Max =$ExternalENodeBFunction_Max"

if [ "${arr[4]}" -ge  "$ExternalENodeBFunction_Total" ]; then
#echo "PASSED"
TotalExternalENodeBFunctions_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalExternalENodeBFunctions_Result="FAILED"
fi


#####Display 5 ######
echo "TotalExternalENodeBFunctions_Count ${arr[4]} $AvgExternalENodeBFunction	 $ExternalENodeBFunction_Total $ExternalENodeBFunction_Avg	$TotalExternalENodeBFunctions_Result " >> Result.txt
####################

#echo "Total ExternalEUtranCellFDDs = $TotalExternalEUtranCellFDDs"
#echo "ExternalEUtranCellFDD_Max =$ExternalEUtranCellFDD_Max"

if [ "${arr[5]}" -ge  "$ExternalEUtranCellFDD_Total" ]; then
#echo "PASSED"
TotalExternalEUtranCellFDDs_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalExternalEUtranCellFDDs_Result="FAILED"
fi

#####Display 6 ######
echo "TotalExternalEUtranCellFDDs_Count ${arr[5]}  $AvgExternalEUtranCellFDD	$ExternalEUtranCellFDD_Total $ExternalEUtranCellFDD_Avg	$TotalExternalEUtranCellFDDs_Result " >> Result.txt
####################

#echo "Total UtranCellRelations = $TotalUtranCellRelations"
#echo "UtranCellRelation_Max =$UtranCellRelation_Max"

if [ "${arr[6]}" -ge  "$UtranCellRelation_Total" ]; then
#echo "PASSED";
TotalUtranCellRelations_Result="PASSED"
else
#echo "FAILED"
TotalUtranCellRelations_Result="FAILED"
fi

#####Display 7 ######
echo "TotalUtranCellRelations_Count ${arr[6]} $AvgUtranCellRelation	 $UtranCellRelation_Total $UtranCellRelation_Avg	$TotalUtranCellRelations_Result " >> Result.txt
####################

#echo "Total UtranFreqRelations = $TotalUtranFreqRelations"
#echo "UtranFreqRelation_Max =$UtranFreqRelation_Max"

if [ "${arr[7]}" -ge  "$UtranFreqRelation_Total" ]; then
#echo "PASSED";
TotalUtranFreqRelations_Result="PASSED"
else
#echo "FAILED"
TotalUtranFreqRelations_Result="FAILED"
fi

#####Display 8 ######
echo "TotalUtranFreqRelations_Count ${arr[7]} $AvgUtranFreqRelation	 $UtranFreqRelation_Total $UtranFreqRelation_Avg	$TotalUtranFreqRelations_Result " >> Result.txt
####################

#echo "Total ExternalUtranCellFDD = $TotalExternalUtranCellFDDs"
#echo "ExternalUtranCellFDD_Max =$ExternalUtranCellFDD_Max"

if [ "${arr[8]}" -ge  "$ExternalUtranCellFDD_Total" ]; then
#echo "PASSED";
TotalExternalUtranCellFDDs_Result="PASSED"
else
#echo "FAILED "
TotalExternalUtranCellFDDs_Result="FAILED"
fi

#####Display 9 ######
echo "TotalExternalUtranCellFDDs_Count ${arr[8]} $AvgExternalUtranCellFDD	 $ExternalUtranCellFDD_Total $ExternalUtranCellFDD_Avg	$TotalExternalUtranCellFDDs_Result " >> Result.txt
####################


#echo "Total GeranCellRelations = $TotalGeranCellRelations"
#echo "GeranCellRelation_Max =$GeranCellRelation_Max"

if [ "${arr[9]}" -ge  "$GeranCellRelation_Total" ]; then
#echo "PASSED"
TotalGeranCellRelations_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalGeranCellRelations_Result="FAILED"
fi

#####Display 10 ######
echo "TotalGeranCellRelations_Count ${arr[9]} $AvgGeranCellRelation	 $GeranCellRelation_Total $GeranCellRelation_Avg	$TotalGeranCellRelations_Result " >> Result.txt
####################

#echo "Total GeranFreqGroupRelations = $TotalGeranFreqGroupRelations"
#echo "GeranFreqGroupRelation_Max =$GeranFreqGroupRelation_Max"

if [ "${arr[10]}" -ge  "$GeranFreqGroupRelation_Total" ]; then
#echo "PASSED"
TotalGeranFreqGroupRelations_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalGeranFreqGroupRelations_Result="FAILED"
fi

#####Display 11 ######
echo "TotalGeranFreqGroupRelations_Count ${arr[10]} $AvgGeranFreqGroupRelation	 $GeranFreqGroupRelation_Total $GeranFreqGroupRelation_Avg	$TotalGeranFreqGroupRelations_Result " >> Result.txt
####################


#echo "Total GeranFrequencies = $TotalGeranFrequencies"
#echo "GeranFrequency_Max =$GeranFrequency_Max"

if [ "${arr[11]}" -ge  "$GeranFrequency_Total" ]; then
#echo "PASSED"
TotalGeranFrequencies_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalGeranFrequencies_Result="FAILED"
fi

#####Display 12 ######
echo "TotalGeranFrequencies_Count ${arr[11]} $AvgGeranFrequency		 $GeranFrequency_Total $GeranFrequency_Avg	$TotalGeranFrequencies_Result " >> Result.txt
####################

#echo "Total TermPointToENBs = $TotalTermPointToENBs"
#echo "TermPointToENB_Max =$TermPointToENB_Max"

if [ "${arr[12]}" -ge  "$TermPointToENB_Total" ]; then
#echo "PASSED"
TotalTermPointToENBs_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalTermPointToENBs_Result="FAILED"
fi

#####Display 13 ######
echo "TotalTermPointToENBs_Count ${arr[12]} $AvgTermPointToENB		$TermPointToENB_Total $TermPointToENB_Avg	$TotalTermPointToENBs_Result " >> Result.txt
####################

if [ "${arr[13]}" -ge  "$TermPointToMme_Total" ]; then
    #echo "PASSED"
    TotalTermPointToMmes_Result="PASSED"
else
    #echo "FAILED"
    #exit 1
    TotalTermPointToMmes_Result="FAILED"
fi

#####Display 14 ######
echo "TotalTermPointToMmes_Count ${arr[13]} $AvgTermPointToMme          $TermPointToMme_Total $TermPointToMme_Avg       $TotalTermPointToMmes_Result " >> Result.txt
####################
#echo "Total SectorCarriers = $TotalSectorCarriers"
#echo "SectorCarrier_Max =$SectorCarrier_Max"

if [ "${arr[14]}" -ge  "$SectorCarrier_Total" ]; then
#echo "PASSED"
TotalSectorCarriers_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalSectorCarriers_Result="FAILED"
fi

#####Display 15 ######
echo "TotalSectorCarriers_Count ${arr[14]} $AvgSectorCarrier	 $SectorCarrier_Total $SectorCarrier_Avg	$TotalSectorCarriers_Result " >> Result.txt
####################

if [ "${arr[15]}" -ge  "$ExternalGeranCell_Total" ]; then
    #echo "PASSED";
    ExternalGeranCell_Result="PASSED"
else
    #echo "FAILED"
    ExternalGeranCell_Result="FAILED"
fi

#####Display 16 ######
echo "ExternalGeranCell_Count ${arr[15]} $AvgExternalGeranCell      $ExternalGeranCell_Total $ExternalGeranCell_Avg        $ExternalGeranCell_Result " >> Result.txt
####################
#echo "Total RetSubUnits = $TotalRetSubUnits"
#echo "RetSubUnit_Max =$RetSubUnit_Max"

if [ "${arr[16]}" -ge  "$RetSubUnit_Total" ]; then
#echo "PASSED"
TotalRetSubUnits_Result="PASSED"
else
#echo "FAILED"
#exit 1
TotalRetSubUnits_Result="FAILED"
fi

#####Display 17 ######
echo "TotalRetSubUnits_Count ${arr[16]} $RetSubUnit_Avg 	 $RetSubUnit_Total $RetSubUnit_Avg	$TotalRetSubUnits_Result " >> Result.txt
####################

echo "Total MO Count  in the network: ${arr[18]}"

awk '{printf "%-35s|%-15s|%-20s|%-15s|%-15s|%-15s\n",$1,$2,$3,$4,$5,$6}'  Result.txt
####################

#read /var/simnet/enm-simnet/scripts/FailedData.txt
if  grep -q FAILED "Result.txt"
then
echo "INFO: There are some Failures"
exit 903
else
echo "INFO :No Errors"
fi

####################


rm -rf /netsim/ieatnetsimv*.txt
if [[ $? -ne 0 ]]
then
        echo "Removing of text files from netsim failed"
        exit 901
 fi
rm -rf /var/simnet/enm-simnet/scripts/mergedOutputFile.txt Result.txt
if [[ $? -ne 0 ]]
then
        echo "Removing of Result.txt and mergedOutputFile.txt from netsim failed"
        exit 902
 fi
 rm -rf /netsim/ieatnetsimv*.log
 if [[ $? -ne 0 ]]
 then
  echo "Removing of text files from netsim failed"
  exit 901
  fi
  rm -rf  /var/simnet/enm-simnet/scripts/mergedOutputFile1.txt /var/simnet/enm-simnet/scripts/mergedOutputFile2.txt 
  if [[ $? -ne 0 ]]
 then
     echo "Removing of  mergedOutputFile1.txt &2.txt TotalNodesInfo.txt TotalNodesOutput.txt from netsim failed"
     exit 902
   fi

