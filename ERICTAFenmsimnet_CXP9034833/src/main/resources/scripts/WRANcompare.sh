#!/bin/sh
networkSize=$1
nrm=$2
echo "networkSize=$networkSize"
workSpace=/netsim/WranCheckForRv
WORKPATH=`pwd`
#Declaring NetworkDataArray
declare -a arr=()
cd $workSpace
ls | grep "_Stats_file.txt" | cut -d'_' -f1 > servers.list
while IFS= read serverName ;
do
cat $serverName"_Stats_file.txt" >> mergedOutputFile.txt
done < servers.list
rm servers.list
    ###################################################################
    ##############Storing the values in an array
    ##################################################################
    for i in {1..11}
    do
    if [ "$i" -eq "1" ]
    then
       continue;
    else
    Attributes=`cat mergedOutputFile.txt | awk '{split($0,a,","); print a['$i']}'| paste -sd+ | bc `
    arr+=( "$Attributes")
    fi
    done
    ##################################################################
    ##########################Total Data##############################
    ##################################################################
 echo "Arraycount=${#arr[@]}"
    echo "TotalNoOfNodes=${arr[9]}"
    echo "TotalNumberofcells=${arr[0]}"
    echo "UtranCellRelations=${arr[1]}"
    echo "GSMRelations=${arr[2]}"
    echo "EutranFreqRelations=${arr[3]}"
    echo "CoverageRelations=${arr[4]}"
    echo "MOCount=${arr[6]}"
	
    
    
    ###################################################################
    ###################JSON PART######################################
    ###################################################################
    echo "###############################################################################"
    echo "###########****************DATA FROM JSON FILE**********************###########"
    echo "###############################################################################"

    #echo "#######   Downloading jq script   #######"
    #curl -O "https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/service/local/repositories/nss/content/com/ericsson/nss/scripts/jq/1.0.1/jq-1.0.1.tar"  ; tar -xvf jq-1.0.1.tar ; chmod +rwx ./jq

cd $WORKPATH
chmod 777 jq-1.0.1.tar
tar -xvf jq-1.0.1.tar
chmod +x ./jq


    #echo "#######   Calling REST CALL   #######"
    wget -q -O - --no-check-certificate "https://nss.seli.wh.rnd.internal.ericsson.com/NetworkConfiguration/rest/config/nrm/${nrm}" > Data1.json

./jq --raw-output '.[]."network size" | .[] | select (.type=="'"$networkSize"'") | (."WRAN Node Split")' Data1.json > Data
    
    #echo "##################################"
    #echo " 1 Total Number of nodes "
    #echo "##################################"

    TotalNumberofNodes_Total=$(./jq --raw-output '(.[])| select(."name"=="Total Number of nodes")|(.value)'  Data)
   if [[ "$TotalNumberofNodes_Total" == "" ]] || [[ "$TotalNumberofNodes_Total" == "NA" ]]
   then
      TotalNumberofNodes_Total=0
   fi
   echo "TotalNumberofNodes_Total =$TotalNumberofNodes_Total"

    #echo "##################################"
    #echo " 2 Total Number of cells "
    #echo "##################################"

    TotalNumberofcells_Total=$(./jq --raw-output '(.[])| select(."name"=="UtranCell")|(.value)'  Data)
   if [[ "$TotalNumberofcells_Total" == "" ]] || [[ "$TotalNumberofcells_Total" == "NA" ]]
   then
      TotalNumberofcells_Total=0
   fi
   echo "TotalNumberofcells_Total =$TotalNumberofcells_Total"

    #echo "##################################"
    #echo " 3 UtranCellRelations "
    #echo "##################################"
    UtranCellRelations_Total=$(./jq --raw-output '(.[])| select(."name"=="UtranCellRelations")|(.value)'  Data)
    if [[ "$UtranCellRelations_Total" == "" ]] || [[ "$UtranCellRelations_Total" == "NA" ]]
    then
       UtranCellRelations_Total=0
    fi
    echo "UtranCellRelations_Total =$UtranCellRelations_Total"

    #echo "##################################"
    #echo " 4 GSMRelations "
    #echo "##################################"
    GSMRelations_Total=$(./jq --raw-output '(.[])| select(."name"=="GSMRelations")|(.value)'  Data)
    if [[ "$GSMRelations_Total" == "" ]] || [[ "$GSMRelations_Total" == "NA" ]]
    then
       GSMRelations_Total=0
    fi

    echo "GSMRelations_Total =$GSMRelations_Total"
    
    #echo "##################################"
    #echo " 5 EutranFreqRelations "
    #echo "##################################"
    EutranFreqRelations_Total=$(./jq --raw-output '(.[])| select(."name"=="EutranFreqRelations")|(.value)'  Data)
    if [[ "$EutranFreqRelations_Total" == "" ]] || [[ "$EutranFreqRelations_Total" == "NA" ]]
    then
       EutranFreqRelations_Total=0
    fi
    echo "EutranFreqRelations_Total =$EutranFreqRelations_Total"

    #echo "##################################"
    #echo " 6 CoverageRelations "
    #echo "##################################"
    CoverageRelations_Total=$(./jq --raw-output '(.[])| select(."name"=="CoverageRelations")|(.value)'  Data)
    if [[ "$CoverageRelations_Total" == "" ]] || [[ "$CoverageRelations_Total" == "NA" ]]
    then
       CoverageRelations_Total=0
    fi
    echo "CoverageRelations_Total =$CoverageRelations_Total"

    #echo "##################################"
    #echo " 7 MO Count"
    #echo "##################################"
    MOCount_Total=$(./jq --raw-output '(.[])| select(."name"=="MO Count")|(.value)'  Data)
    if [[ "$MOCount_Total" == "" ]] || [[ "$MOCount_Total" == "NA" ]]
    then
       MOCount_Total=0
    fi
    echo "MOCount_Total =$MOCount_Total"
    

   echo "######################################################"
    echo "##########************-COMPARISON******###############"
    echo "######################################################"
    
    echo "Field  ObtainedValue NssoValue Status" >> Result.txt
    if [ "${arr[9]}" -ge  "$TotalNumberofNodes_Total" ]; then
    TotalNumberofNodes_Result="PASSED"
    else
    TotalNumberofNodes_Result="FAILED"
    fi
    echo "TotalNumberofNodes_Count ${arr[9]}  $TotalNumberofNodes_Total $TotalNumberofNodes_Result " >> Result.txt


    if [ "${arr[0]}" -ge  "$TotalNumberofcells_Total" ]; then
    TotalNumberofcells_Result="PASSED"
    else
    TotalNumberofcells_Result="FAILED"
    fi

    echo "TotalNumberofcells_Count ${arr[0]}  $TotalNumberofcells_Total $TotalNumberofcells_Result " >> Result.txt

    if [ "${arr[1]}" -ge  "$UtranCellRelations_Total" ]; then
    TotalUtranCellRelations_Result="PASSED"
    else
    TotalUtranCellRelations_Result="FAILED"
    fi

    #####Display 4######
    echo "TotalUtranCellRelations_Count ${arr[1]}  $UtranCellRelations_Total $TotalUtranCellRelations_Result " >> Result.txt
    ####################


    if [ "${arr[2]}" -ge  "$GSMRelations_Total" ]; then
    TotalGSMRelations_Result="PASSED"
    else
    TotalGSMRelations_Result="FAILED"
    fi


    #####Display 5 ######
    echo "TotalGSMRelations_Count ${arr[2]}  $GSMRelations_Total $TotalGSMRelations_Result " >> Result.txt
    ####################

    #echo "Total ExternalEUtranCellFDDs = $TotalExternalEUtranCellFDDs"
    #echo "ExternalEutranCellFDD_Max =$ExternalEutranCellFDD_Max"

    if [ "${arr[3]}" -ge  "$EutranFreqRelations_Total" ]; then
    TotalEutranFreqRelations_Result="PASSED"
    else
    TotalEutranFreqRelations_Result="FAILED"
    fi

    #####Display 6 ######
    echo "TotalEutranFreqRelations_Count ${arr[3]}  $EutranFreqRelations_Total $TotalEutranFreqRelations_Result " >> Result.txt
    ####################

    #echo "Total UtranCellRelations = $TotalUtranCellRelations"
    #echo "UtranCellRelation_Max =$UtranCellRelation_Max"

    if [ "${arr[4]}" -ge  "$CoverageRelations_Total" ]; then
    #echo "PASSED";
    TotalCoverageRelations_Result="PASSED"
    else
    #echo "FAILED"
    TotalCoverageRelations_Result="FAILED"
    fi

    #####Display 7 ######
    echo "TotalCoverageRelations_Count ${arr[4]}  $CoverageRelations_Total $TotalCoverageRelations_Result " >> Result.txt
    ####################

    #echo "Total UtranFreqRelations = $TotalUtranFreqRelations"
    #echo "UtranFreqRelation_Max =$UtranFreqRelation_Max"

    

    #echo "Total ExternalUtranCellFDD = $TotalExternalUtranCellFDDs"
    #echo "ExternalUtranCellFDD_Max =$ExternalUtranCellFDD_Max"

   if [ "${arr[6]}" -ge  "$MOCount_Total" ]; then
  #  echo "PASSED";
    TotalMOCount_Result="PASSED"
   else
   # echo "FAILED "
   TotalMOCount_Result="FAILED"
    fi
echo "MOCount_Total=$MOCount_Total"
    #####Display 9 ######
    echo "TotalMOCount_Count ${arr[6]}  $MOCount_Total $TotalMOCount_Result " >> Result.txt
    ####################


    echo "*****************Last Statement*****************"
    awk '{printf "%-30s|%-30s|%-30s|%-30s\n",$1,$2,$3,$4}'  Result.txt
    echo "##############################################################"

    ####################

rm -rf mergedOutputFile.txt
rm -rf Result.txt

