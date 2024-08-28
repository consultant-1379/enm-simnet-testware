#!/bin/bash
#!/usr/bin/perl
###############################################################################
# Version     : 1.2
# UserName    : Yamuna Kanchireddygari
# Jira        : NSS-37086
# Description : Skipping Pm fileLocation test SCU nodes
# Date        : 20th Sep 2021
##########################################################################
###############################################################################
# Version     : 1.1
# UserName    : Yamuna Kanchireddygari
# Jira        : NSS-34706
# Description : Adding fileLocation UT for CORE node types 
# Date        : 09th Apr 2021
##########################################################################
#Variables
#########################################################################
simName=$1
echo -e "Starting check on $simName------------------------------------ \n"
$PWD/extractNeNames.pl $simName
neNames=( $( cat $PWD/dumpNeName.txt ) )

if [[ $simName == *"SCU"* ]]
then
    echo -e "###########################################\n"
    echo -e "Pm FileLocation doesnt exist for this nodes\n"
    echo -e "###########################################\n"
    exit 0
fi

##################################################################################
#Checking Pm file location
##################################################################################
echo -e "Checking PmFile location on nodes------------------\n"
       for ne in ${neNames[@]}
       do
           nodePmFileMo=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,Pm=1,PmMeasurementCapabilities=1\"),\",\")) ,fileLocation). " | sudo su -l netsim -c /netsim/inst/netsim_shell)

           nodePmFilePath=$(echo ${nodePmFileMo##* } | tr -d ' ')
           echo  "PmFileLocation on the node is $nodePmFilePath "

              if [[ $nodePmFilePath == *"null"* ]]
              then
                 echo "FAILED: PmFileLocation is not loaded properly on $ne"
              else
                 echo "PASSED: PmFileLocation is  loaded properly on $ne"
              fi
           echo ""
	done

###################################################################################
#Checking Pm attribute values for NNi Nodes
###################################################################################
if [[ $simName == *"MTAS"* || $simName == *"CSCF"* || $simName == *"SBG"* || $simName == *"vEME"*  
    || $simName == *"vWCG"* || $simName == *"vBGF"* || $simName == *"MRFv"* || $simName == *"UPG"* 
    || $simName == *"IPWORKS"* || $simName == *"HSS"* || $simName == *"Router6371"* || $simName == *"Router6471"* ]]
then
if [[ $simName == *"TCU"* ]]
then
exit 0
fi
 echo -e "Checking ProduceUtcRopfiles on nodes------------------\n"

if [[ $simName == *"Router6371"* || $simName == *"Router6471"* ]]
then
 for ne in ${neNames[@]}
       do
           nodePmUtcFiles=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,Pm=1,PmMeasurementCapabilities=1\"),\",\")) ,producesUtcRopFiles). " | sudo su -l netsim -c /netsim/inst/netsim_shell)
nodePmProduceRopfiles=$(echo ${nodePmUtcFiles##* } | tr -d ' ')
           echo "produceropfiles set to $nodePmProduceRopfiles"

               if [[ $nodePmProduceRopfiles != *"true"* ]]
               then
                    echo "PASSED: filegeneration is correctly set on $ne"
               else
                    echo "FAILED:  filegeneration is correctly set on $ne"
               fi
          echo "" 
  realTimejobsupport=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,Pm=1,PmMeasurementCapabilities=1\"),\",\")) ,realTimeJobSupport). " | sudo su -l netsim -c /netsim/inst/netsim_shell)
noderealtime=$(echo ${realTimejobsupport##* } | tr -d ' ')
           echo "produceropfiles set to $nodePmProduceRopfiles"

               if [[ $noderealtime != *"true"* ]]
               then
                    echo "PASSED: realTimeJobsupport is correctly set on $ne"
               else
                    echo "FAILED:  realTimejobsupport  is not correctly set on $ne"
               fi
           echo ""

        done
exit 0
fi


       for ne in ${neNames[@]}
       do
           nodePmUtcFiles=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,Pm=1,PmMeasurementCapabilities=1\"),\",\")) ,producesUtcRopFiles). " | sudo su -l netsim -c /netsim/inst/netsim_shell)
nodePmProduceRopfiles=$(echo ${nodePmUtcFiles##* } | tr -d ' ')
           echo "produceropfiles set to $nodePmProduceRopfiles"

               if [[ $nodePmProduceRopfiles != *"true"* ]]
               then
                    echo "FAILED: filegeneration is wrongly set on $ne"
               else
                    echo "PASSED:  filegeneration is correctly set on $ne"
               fi
          echo "" 
	done
		
echo -e "Checking compressiontype attribute on nodes------------------\n"
       for ne in ${neNames[@]}
       do
           nodeSupportedCompressionType=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,Pm=1,PmMeasurementCapabilities=1\"),\",\")) ,supportedCompressionTypes). " | sudo su -l netsim -c /netsim/inst/netsim_shell)
nodeSupportedAttribute=$(echo ${nodeSupportedCompressionType##* } | tr -d ' ')
           echo "produceropfiles set to $nodeSupportedAttribute"

                if [[ $nodeSupportedAttribute != *"[0]"* ]]
                then
                   echo "FAILED: compressionType is not set on $ne"
                else
                   echo "PASSED: compressionType is correctly set on $ne"
                fi
           echo "" 
       done
if [[ $simName == *"UPGIND"* ]]
then
exit 0
fi
echo -e "Checking RopTimestamp attribute on nodes------------------\n"
       for ne in ${neNames[@]}
       do
        nodeRopFileTimestamp=$(echo -e ".open $simName \n .select $ne \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,Pm=1,PmMeasurementCapabilities=1\"),\",\")) , ropFilenameTimestamp). " | sudo su -l netsim -c /netsim/inst/netsim_shell)
        nodeRopFileTimestampAttribute=$(echo ${nodeRopFileTimestamp##* } | tr -d ' ')
        echo "produceropfiles set to $nodeRopFileTimestampAttribute"

              if [[ $nodeRopFileTimestampAttribute != *"1"* ]]
              then
                  echo "FAILED: RopFileTimestampAttribute is not set  correctly on $ne"
              else
                  echo "PASSED: RopFileTimestampAttribute is correctly set on $ne"
              fi
        echo "" 
      done
fi

   


