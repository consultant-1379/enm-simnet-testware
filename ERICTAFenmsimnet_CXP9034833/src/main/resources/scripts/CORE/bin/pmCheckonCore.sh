#!/bin/bash
#!/usr/bin/perl
#######################################################################
#Created by : Harika Gouda
#Created on : 23rd Aug 2017
#Purpose : Performs Pm checks
##########################################################################
#Variables
#########################################################################
simName=$1
echo -e "Starting check on $simName------------------------------------ \n"
$PWD/CORE/bin/extractNeNames.pl $simName
neNames=( $( cat $PWD/dumpNeName.txt ) )
###########################################################################
#Checking PmGroups
###########################################################################
rm -rf  a.txt check.mml

cat >> check.mml << ABC
.open $simName
.select $neNames
.start
e installation:get_neinfo(pm_mib).
ABC

sudo su -l netsim -c /netsim/inst/netsim_pipe < check.mml >> a.txt

cat a.txt

 if grep -q  'no_value' $PWD/a.txt
 then
 echo -e "Pm Fragments do not exist for this node \n"
 else

     mibFileName=$(grep -n "ok" $PWD/a.txt | awk -F  "," '{print $2}' | sed -r 's/^.{1}//' | sed 's/.\{2\}$//')
     cd /netsim/inst/zzzuserinstallation/ecim_pm_mibs
     basicNodePmCount=$(grep -nri "<hasClass name=\"PmGroup"\" $mibFileName | wc -l)

     echo "Basic Node Pm count = $basicNodePmCount"
     echo ""
     echo -e "Checking PMGroups on nodes--------------------\n"

      for ne in ${neNames[@]}
      do
     if [[ $simName != *"EPG"* ]]
       then
      nodePmGroups=$(echo -e ".open $simName \n .select $ne \n .start \n e [PMNS, _ ,_] =string:tokens(lists:last(ecim_netconflib:string_to_ldn(\"ManagedElement=1,SystemFunctions=1,Pm=1\")),\"=:\"). \n e length(csmo:get_mo_ids_by_type(null, PMNS++\":PmGroup\")).  " | sudo su -l netsim -c /netsim/inst/netsim_shell)
      nodePmGroupCount=$(echo ${nodePmGroups##* } | tr -d ' ')
      echo  "PM groups on the $ne = $nodePmGroupCount "

            if [[ "$basicNodePmCount" == "$nodePmGroupCount" ]]
            then
                echo "PASSED: All PmGroup MOs are present on the $ne"
            else
                echo "FAILED: PmGroup MOs are not properly loaded on $ne"
            fi

     echo ""
fi
     done

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

   
 fi


