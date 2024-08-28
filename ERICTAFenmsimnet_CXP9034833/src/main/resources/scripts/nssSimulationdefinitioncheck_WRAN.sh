#!/bin/sh
masterServer=$1
STARTTIME=`date`
PWD=`pwd`
WORKPATH=$PWD"/Simstats"
workSpace=/netsim/WranCheckForRv
HOST=`hostname`
Stats_file=$HOST"_Stats_file.txt"
if [ -d "$WORKPATH" ]
then
   rm -rf Simstats
fi
mkdir Simstats
cd $WORKPATH
SIMLIST=`ls /netsim/netsimdir | grep ".*-RNC" | grep -v .zip`
SIMARRAY=(${SIMLIST// / })
######################################################################################
## SubRoutines 
######################################################################################
#### validate Topology File ##########################################################
validateTopology() {
SIMNAME=$1
UTRANCELLFILE="/netsim/netsimdir/"$SIMNAME"/SimNetRevision/UtranCell.txt"
RBSCELLFILE="/netsim/netsimdir/"$SIMNAME"/SimNetRevision/RbsLocalCellData.txt"
if [ -e "$UTRANCELLFILE" -a -e "$RBSCELLFILE" ]
then
  CheckUtranCellErrors=`cat $UTRANCELLFILE | grep -i ".*=," |wc -l`
  CheckRbsLocalErrors=`cat $RBSCELLFILE | grep -i ".*=," |wc -l`
  if [ "$CheckUtranCellErrors" -eq "0" ] && [ "$CheckRbsLocalErrors" -eq "0" ]
     then
     echo "0"
  else
     echo "1"
  fi
else
  echo "-1"
fi
}
######################################################################################

#### Read n lines #####
read_n() {
 for i in $(seq $1);
 do
 read || return; 
 done;
 echo $REPLY;
 }
#### Search and count required MOS generated ####
getStats()
{
 SIMNAME=$1
 RncStr=(${SIMNAME//RNC/ })
 SIMNUM=${RncStr[1]}
 RNCNUM="RNC"$SIMNUM

#MOFILE=$1
MOTYPE=$2
if [ "$MOTYPE" == "ALL" ]
then
   #VALUE=`cat $MOFILE | grep "moType" |wc -l`
   VALUE=($(echo -e '.open '$SIMNAME' \n .select '$RNCNUM' \n dumpmotree:count;' | sudo su -l netsim -c /netsim/inst/netsim_shell | tail -2 | head -1))
else
   if [[ "$MOFILE" =~ "dg2" ]] || [[ "$MOFILE" =~ "MSRBS" ]]
   then
      #VALUE=`cat $MOFILE | grep "moType Lrat:$MOTYPE" |wc -l`
      VALUE=($(echo -e '.open '$SIMNAME' \n .select '$RNCNUM' \n e f(). \n e: length(csmo:get_mo_ids_by_type(null,"Lrat:'$MOTYPE'")).' | sudo su -l netsim -c /netsim/inst/netsim_shell | tail -1))
   else
      #VALUE=`cat $MOFILE | grep "moType $MOTYPE" |wc -l`
      VALUE=($(echo -e '.open '$SIMNAME' \n .select '$RNCNUM' \n e f(). \n e: length(csmo:get_mo_ids_by_type(null,"'$MOTYPE'")).' | sudo su -l netsim -c /netsim/inst/netsim_shell | tail -1))
   fi
fi
echo $VALUE
}
#### Get Node Stats ##################
getTotalMos() {
 VALUE=0
 while read -r $NODENAME ; do
 MOSCRIPT=/netsim/$NODENAME".mo"
 VALUE=`cat $MOFILE | grep "moType" |wc -l`
 VALUE=`expr $VALUE + 1`
 done < dumpNeName.txt
}
#### check Productdata ################
checkProductData() {
SIMNAME=$1
while read -r NODENAME ; do
ProductDataCheck="no"
ProductData=()
if [[ $NODENAME =~ "MSRBS-V2" ]]
then
   ProductData+=($(echo -e '.open '$SIMNAME' \n .select '$NODENAME' \n e X= csmo:ldn_to_mo_id(null,["ComTop:ManagedElement=$NODENAME","ComTop:SystemFunctions=1","RcsSwIM:SwInventory=1","RcsSwIM:SwItem=1"]). \n e csmo:get_attribute_value(null,X,administrativeData).' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep -i product))
else
   ProductData+=($(echo -e '.open '$SIMNAME' \n .select '$NODENAME' \n e X= csmo:ldn_to_mo_id(null,["ManagedElement=1","SwManagement=1","UpgradePackage=1"]). \n e csmo:get_attribute_value(null,X,administrativeData).' | sudo su -l netsim -c /netsim/inst/netsim_shell | grep -i product))
fi
ProductNumberTrim=(${ProductData[0]//'}'/ })
ProductNumber=$(echo $ProductNumberTrim | awk -F"," '{print $2}')

ProductRevisionTrim=(${ProductData[1]//'}'/ })
ProductRevision=$(echo $ProductRevisionTrim | awk -F"," '{print $2}')

if [[ "$ProductNumber" == "[]" ]] || [[ "$ProductRevision" == "[]" ]]
then
    ProductDataCheck="no"
    break;
else
    ProductDataCheck="yes"
fi 
###################################################################################################
done < dumpNeName.txt
if [[ "$ProductDataCheck" =~ "no" ]] ; then
   echo "ERROR($NODENAME)"
else
   echo "yes"
fi
}
#######################################
 
#### Collect the stats in a File #####
dumpStats()
{
 SIMNAME=$1
 TopologyFile=$2
 NumOfIpv6Nes=$3
 NumOfIpv4Nes=$4
 TotalNoOfNodes=$5
 Stats_file=$6
 RncStr=(${SIMNAME//RNC/ })
 SIMNUM=${RncStr[1]}
 RNCNUM="RNC"$SIMNUM
 MOFILE=/netsim/$RNCNUM".mo"
 ProductData=`checkProductData $SIMNAME`
 No_of_cells=`getStats $SIMNAME "UtranCell"`
 UtranCellRelations=`getStats $SIMNAME "UtranRelation"`
 GSMRelations=`getStats $SIMNAME  "GsmRelation"`
 EutranFreqRelations=`getStats $SIMNAME "EutranFreqRelation"`
 CoverageRelations=`getStats $SIMNAME "CoverageRelation"`
 TotalRncMos=`getStats $SIMNAME "ALL"`
 #No_of_cells=`getStats $MOFILE "UtranCell"`
 #UtranCellRelations=`getStats $MOFILE "UtranRelation"`
 #GSMRelations=`getStats $MOFILE "GsmRelation"`
 #EutranFreqRelations=`getStats $MOFILE "EutranFreqRelation"`
 #CoverageRelations=`getStats $MOFILE "CoverageRelation"`
 #TotalRncMos=`getStats $MOFILE "ALL"`
 TotalSimMos=0
  echo -e '.open '$SIMNAME' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | cut -d' ' -f1 | grep "RNC" | head -1 > dumpNes.txt
 while read -r Node; do
    FILE=/netsim/$Node".mo"
    #totalNodeMos=`getStats $FILE "ALL"`
    totalNodeMos=`getStats $SIMNAME "ALL"`
    TotalSimMos=$(($TotalSimMos+$totalNodeMos))
 done < dumpNes.txt
 echo $RNCNUM','$No_of_cells','$UtranCellRelations','$GSMRelations','$EutranFreqRelations','$CoverageRelations','$TotalRncMos','$TotalSimMos','$NumOfIpv4Nes','$NumOfIpv6Nes','$TotalNoOfNodes >> $Stats_file
}

#######################################################################################
#MAIN
#######################################################################################
### Checking the MO statistics ###
#echo "##### Started Running Healthcheck on $HOSTNAME at $STARTTIME #####"
#echo 'Sim,UtranCells,UtranRelations,GSMRelations,EutranFreqRelations,CoverageRelations,TotalRncMos,TotalSimMos,Prod.Data,Topology,IPV4,IPV6' >> $Stats_file
for SIMNAME in ${SIMARRAY[@]}
do
   ErrorCheck=`validateTopology $SIMNAME`
   if [[ "$ErrorCheck" == "0" ]]
   then
      TopologyFile="CLEAN"
   elif [[ "$ErrorCheck" == "1" ]]
   then
      TopologyFile="ERROR(Improper)"
   elif [[ "$ErrorCheck" == "-1" ]]
   then
      TopologyFile="ERROR(NoFile)"
   fi

   echo -e '.open '$SIMNAME' \n .show simnes' | sudo su -l netsim -c /netsim/inst/netsim_shell | cut -d' ' -f1 | grep "RNC" | head -1 > dumpNeName.txt
   ## Num Of Ipv6 and Ipv4 nodes ##
   if [[ $SIMNAME == *"-02-"* ]] || [[ $SIMNAME == *"-03-"* ]] || [[ $SIMNAME == *"-04-"* ]] || [[ $SIMNAME == *"-05-"* ]] || [[ $SIMNAME == *"-06-"* ]] || [[ $SIMNAME == *"-07-"* ]] || [[ $SIMNAME == *"-08-"* ]] || [[ $SIMNAME == *"-09-"* ]] || [[ $SIMNAME == *"-10-"* ]] || [[ $SIMNAME == *"-11-"* ]] || [[ $SIMNAME == *"-12-"* ]] || [[ $SIMNAME == *"-13-"* ]] || [[ $SIMNAME == *"-15-"* ]] || [[ $SIMNAME == *"-16-"* ]]
   then
       Ipv6Nes=()
       Ipv6Nes+=($(echo -e ".open $simName\n .show simnes" | sudo su -l netsim -c /netsim/inst/netsim_shell | grep -v "WCDMA RNC" | grep "::" | sort | awk -F" " '{print $1}'))
       NumOfIpv6Nes=${#Ipv6Nes[@]}
       NumOfSimNes=`cat dumpNeName.txt | wc -l`
       NumOfIpv4Nes=`expr $NumOfSimNes - $NumOfIpv6Nes`
       TotalNoOfNodes=`expr $NumOfIpv4Nes + $NumOfIpv6Nes`
       echo "$TotalNoOfNodes"
   else     
       Ipv6Nes=()
       Ipv6Nes+=($(echo -e ".open $simName\n .show simnes" | sudo su -l netsim -c /netsim/inst/netsim_shell | grep ":" | sort | awk -F" " '{print $1}'))
       NumOfIpv6Nes=${#Ipv6Nes[@]}
       NumOfSimNes=`cat dumpNeName.txt | wc -l`
       NumOfIpv4Nes=`expr $NumOfSimNes - $NumOfIpv6Nes`
       TotalNoOfNodes=`expr $NumOfIpv4Nes + $NumOfIpv6Nes`
       echo "$TotalNoOfNodes"
   fi
   if [[ $SIMNAME == *"-02-"* ]] || [[ $SIMNAME == *"-03-"* ]] || [[ $SIMNAME == *"-04-"* ]] || [[ $SIMNAME == *"-05-"* ]] || [[ $SIMNAME == *"-06-"* ]] || [[ $SIMNAME == *"-07-"* ]] || [[ $SIMNAME == *"-08-"* ]] || [[ $SIMNAME == *"-09-"* ]] || [[ $SIMNAME == *"-10-"* ]] || [[ $SIMNAME == *"-11-"* ]] || [[ $SIMNAME == *"-12-"* ]] || [[ $SIMNAME == *"-13-"* ]] || [[ $SIMNAME == *"-15-"* ]] || [[ $SIMNAME == *"-16-"* ]]
   then
         echo "No need to Check the Relation Data for this Simulation $simName"
   else
   while read -r node; do
      NODENAME=$node
      MOSCRIPT=/netsim/$NODENAME".mo"
      MMLSCRIPT=$NODENAME".mml"
      touch $MOSCRIPT
      chmod 777 $MOSCRIPT
      echo '.open '$SIMNAME >> $MMLSCRIPT
      echo '.select '$NODENAME >> $MMLSCRIPT
      echo '.start ' >> $MMLSCRIPT
     # echo 'dumpmotree:moid=1,ker_out,outputfile="'$MOSCRIPT'";' >> $MMLSCRIPT
      sudo su -l netsim -c /netsim/inst/netsim_shell < $MMLSCRIPT
# 2>&1 >/dev/null
      if [ $? != 0 ]; then
         echo "ERROR: Failed to start the nodes in the simulation $SIMNAME"
      exit -1
      fi
      rm $MMLSCRIPT
    done < dumpNeName.txt
    `dumpStats $SIMNAME $TopologyFile $NumOfIpv6Nes $NumOfIpv4Nes $TotalNoOfNodes $Stats_file`
echo "dumpStats $SIMNAME $NumOfIpv6Nes $NumOfIpv4Nes $TotalNoOfNodes $Stats_file"
    fi
########################################################################################
### Checking for product Data ###
#######################################################################################
rm dumpNeName.txt
done

yum -y install sshpass


simsList=`ls /netsim/netsimdir | grep ".*-RNC" | grep -vE ".zip|-02-|-03-|-04-|-05-|-06-|-07-|-08-|-09-|-10-|-11-|-12-|-13-|-14-|-15-|-16-"`

if [ -n "$simsList" ]
then
     sshpass -p shroot ssh -o StrictHostKeyChecking=no root@$masterServer.athtem.eei.ericsson.se "mkdir -p $workSpace"
     sshpass -p shroot scp -o StrictHostKeyChecking=no $Stats_file root@$masterServer.athtem.eei.ericsson.se:$workSpace
fi

: <<'END'
cat >> copyData << SCR
    spawn ssh -o StrictHostKeyChecking=no -p 22 root@$masterServer.athtem.eei.ericsson.se mkdir $workSpace
    expect {
        -re assword: {send "shroot\r";exp_continue}
    }
    sleep 1
    spawn scp -o StrictHostKeyChecking=no $Stats_file root@$masterServer.athtem.eei.ericsson.se:$workSpace
    expect {
        -re Password: {send "shroot\r";exp_continue}
    }
    sleep 1
SCR
/usr/bin/expect < copyData
END

echo "############################ RNC CheckList on $HOST #####################################" >> $HOST"_FinalSummary.txt"
column -t -s',' $Stats_file >> $HOST"_FinalSummary.txt"
echo "------------------------------------------------------------------------------------------------" >> $HOST"_FinalSummary.txt"
cat $HOST"_FinalSummary.txt"
ENDTIME=`date`
echo "##### Script Ended at $ENDTIME #####"
