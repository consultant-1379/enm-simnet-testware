 #!/bin/bash
#!/usr/bin/perl
#########################################################################
# Version     : 1.3
# UserName    : zjaisai
# Jira        : NSS-41605
# Description : Checks whether the count of BrmBackupManager mo is 1
# Date        : 23th Dec 2022
#########################################################################
#########################################################################
# Version     : 1.2
# UserName    : zsujmad
# Jira        : NSS-36024,NSS-36025
# Description : Adding Brm check for MRF and BGF
# Date        : 06th Jul 2021
#########################################################################
#########################################################################
# Version     : 1.1
# UserName    : Yamuna Kanchireddygari
# Jira        : NSS-34706
# Description : Adding BrmBackManager UT for all CORE node types
# Date        : 09th Apr 2021
#########################################################################
#Variables
#########################################################################
simName=$1
$PWD/extractNeNames.pl $simName
neNames=( $( cat $PWD/dumpNeName.txt ) )
###########################################################################
#Checking Brm fragments
###########################################################################
rm -rf  a.txt brm.mml

if [[ $simName == *"TSP"* || $simName == *"HLR"* ]]
then
exit 0
fi

if [[ $simName == *"vEME"* || $simName == *"BSP"* ]]
then
   brmType="LocalData"
   brmDomain="Local"
elif [[ $simName == *"C608"* || $simName == *"CONTROLLER"* || $simName == *"TCU"* || $simName == *"SCU"* || $simName == *"ESC"* ]] 
then
   brmType="Systemdata"
   brmDomain="System"
elif [[ $simName == *"CSCF"* || $simName == *"NELS"* ]]
then
   brmType="type"
   brmDomain="domain"
elif [[ $simName == *"DSC"* || $simName == *"SAPC"* || $simName == *"HSS"* || $simName == *"MTAS"* || $simName == *"SBG"* || $simName == *"MRF"* || $simName == *"BGF"* ]]
then
   brmType="BRM_SYSTEM_DATA"
   brmDomain="BRM_SYSTEM_DATA"
elif [[ $simName == *"FrontHaul"* ]]
then
   brmType="System Data"
   brmDomain="System"
elif [[ $simName == *"Router"* || $simName == *"SpitFire"* ]]
then
   brmType="Configuration"
   brmDomain="System"
elif [[ $simName == *"IPWORKS"* ]]
then
   brmType="BRM_USER_DATA"
   brmDomain="BRM_USER_DATA"
elif [[ $simName == *"SGSN"* ]]
then
   brmType="System Local Data"
   brmDomain="System Local"
else
    echo "###########################################################"
    echo "There is no backupType and backupDoamin for this $simName"
    echo "###########################################################"
    exit 0
fi

echo "backupType is $brmType"
echo "backupDomain is $brmDomain"
echo -e "Starting Brm check on $simName------------------------------------ \n"
for ne in ${neNames[@]}
       do
nodeBrmTypevalue=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,BrM=1,BrmBackupManager=1\"),\",\")) ,backupType). " | sudo su -l netsim -c /netsim/inst/netsim_shell | tail -n -1)

nodeBrmTypeattribute=$(echo $nodeBrmTypevalue | cut -d '"' -f2 )
echo "brmType attribute on $ne is $nodeBrmTypeattribute"
if [[ $nodeBrmTypeattribute == $brmType ]]
              then
                 echo -e "PASSED: brmType is correctly loaded on $ne \n"
              else
                 echo "FAILED: brmType is not correclty loaded on $ne"
              fi
nodeBrmDomainvalue=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,BrM=1,BrmBackupManager=1\"),\",\")) ,backupDomain). " | sudo su -l netsim -c /netsim/inst/netsim_shell | tail -n -1)

nodeBrmDomaineattribute=$(echo $nodeBrmDomainvalue | cut -d '"' -f2 )
echo "brmDomain attribute on $ne is $nodeBrmDomaineattribute"
if [[ $nodeBrmDomaineattribute == $brmDomain ]]
              then
                 echo -e "PASSED: brmDomain is correctly loaded on $ne\n"
              else
                 echo -e "FAILED: brmDomain is not correclty loaded on $ne\n"
              fi
#  Brm=`"echo  -e -e '.open $simName \n .select $ne \n e csmo:get_mo_ids_by_type(null,\"RcsBrM:BrmBackupManager\").' | /netsim/inst/netsim_shell | sed -n '/csmo:get_mo_ids_by_type/{n;p}'"`
Brm=`echo -e -e ".open $simName \n .select $ne \n e csmo:get_mo_ids_by_type(null,\"BrM:BrmBackupManager\")." | sudo su -l netsim -c  /netsim/inst/netsim_shell | tail -n -1`
  Brm1=$(echo -e $Brm | sed 's/[][]//g')
  Brm_list=(${Brm1//,/ })
  brmsize=${#Brm_list[@]}
if [ $brmsize -ne 1 ]
       then
       echo -e "\033[0;31mFAILED\033[m: This Node $NE doesnot have  1  BrmBackupManager mo" | tee -a ut_result_$SIM.txt;return 1
else
       echo "PASSED on NODE:$ne has only 1 BrmBackupManager mo "
fi
done
