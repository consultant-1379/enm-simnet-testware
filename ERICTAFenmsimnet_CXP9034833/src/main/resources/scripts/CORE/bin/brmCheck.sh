 #!/bin/bash
#!/usr/bin/perl
#######################################################################
#Created by : Harika Gouda
#Created on : 23rd Aug 2017
#Purpose : Performs Brm checks
##########################################################################
#Variables
#########################################################################
simName=$1
$PWD/CORE/bin/extractNeNames.pl $simName
neNames=( $( cat $PWD/dumpNeName.txt ) )
###########################################################################
#Checking Brm fragments
###########################################################################
rm -rf  a.txt brm.mml

if [[ $simName == *"TSP"* || $simName == *"HLR"* ]]
then
exit 0
fi

if [[ $simName == *"IPWORKS"* || $simName == *"HSS-FE"* || $simName == *"SBG"*
    || $simName == *"vEME"* || $simName == *"BSP"* || $simName == *"MTAS"* ]]
then
echo -e "Starting Brm check on $simName------------------------------------ \n"
for ne in ${neNames[@]}
       do
nodeBrmTypevalue=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,BrM=1,BrmBackupManager=1\"),\",\")) ,backupType). " | sudo su -l netsim -c /netsim/inst/netsim_shell)

nodeBrmTypeattribute=$(echo ${nodeBrmTypevalue##* } | tr -d ' ' | cut -d '"' -f 2 )
echo "brmType attribute on $ne is $nodeBrmTypeattribute"
if [[ $nodeBrmTypeattribute == *"LocalData"* ]]
              then
                 echo -e "PASSED: brmType is correctly loaded on $ne \n"
              else
                 echo "FAILED: brmType is not correclty loaded on $ne"
              fi
nodeBrmDomainvalue=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,BrM=1,BrmBackupManager=1\"),\",\")) ,backupDomain). " | sudo su -l netsim -c /netsim/inst/netsim_shell)

nodeBrmDomaineattribute=$(echo ${nodeBrmDomainvalue##* } | tr -d ' ' | cut -d '"' -f 2 )
echo "brmDomain attribute on $ne is $nodeBrmDomaineattribute"
if [[ $nodeBrmDomaineattribute == *"Local"* ]]
              then
                 echo -e "PASSED: brmDomain is correctly loaded on $ne\n"
              else
                 echo -e "FAILED: brmDomain is not correclty loaded on $ne\n"
              fi

done
fi
