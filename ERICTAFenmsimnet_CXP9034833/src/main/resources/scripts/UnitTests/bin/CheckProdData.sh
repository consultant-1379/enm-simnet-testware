#!/bin/bash
#!/usr/bin/perl

##########################################################################################################################
# Created by  : Mitali Sinha
# Created on  : 30.11.2018
# Purpose     : Checks Product Data on CORE nodes
###########################################################################################################################
# Version     : 2
# Created by  : Harish Dunga
# Created on  : 30.01.2020
# Purpose     : Checks ConfigChange Attribute for SIU02 nodes
###########################################################################################################################
#Variable Declaration
#########################################################################
simName=$1

if [[ $simName == *"TSP"* || $simName == *"CISCO"* || $simName == *"ML"* || $simName == *"JUNIPER"* || $simName == *"TCU02"*
  || $simName == *"ECM"* || $simName == *"SSR"* || $simName == *"vBNG"* || $simName == *"Router8801"* || $simName == *"IS55"* || $simName == *"WMG"* || $simName == *"vWMG"* || $simName == *"UPGIND"* || $simName == *"CUDB"* || $simName == *"EPG"* ]]
 then
   echo -e "ProductData doesnt exist for this nodes\n"
   exit 0
fi

#GSM Nodes
#if [[ $simName == *"BSC"* ]]
# then
#   exit 0
#fi


echo -e "\nStarting ProductData check on $simName \n"

ProductDataFromEnv=$($PWD/getProdDataFromENV.sh $simName)
ProductNumberFromEnv=`echo $ProductDataFromEnv | cut -d ":" -f1 | tr -cd "[:print:]\n"`
ProductRevisionFromEnv=`echo $ProductDataFromEnv | cut -d ":" -f2 | tr -cd "[:print:]\n"`
if [[ $simName != *"SIU02"* ]]
then
   echo "ProductDataFromEnv=$ProductDataFromEnv"
   echo "ProductNumberFromEnv=$ProductNumberFromEnv"
   echo "ProductRevisionFromEnv=$ProductRevisionFromEnv"
fi

echo "####################################################################"
###Storing Node names into a text file
echo netsim | sudo -S -H -u netsim bash -c "echo -e '.open '$simName' \n .show simnes' | /netsim/inst/netsim_shell | grep -v \">>\" | grep -v \"OK\" | grep -v \"NE\"" > NodeData.txt
cat NodeData.txt | awk '{print $1}' > NodeData1.txt
IFS=$'\n' read -d '' -r -a node < NodeData1.txt
Length=${#node[@]}
#echo "---------node length=$Length---------"

if [[ $simName == *"SGSN"* ]]
 then
 for ne in ${node[@]}
     do
       new=$(echo -e ".open $simName \n .select $ne \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwM=1,UpgradePackage=1\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )
       #echo "new =$new"
       productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
       productRevision=$(echo "${new[*]}" | grep "productrevision" | tr -d 'productrevision{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
         if [[ "$ProductNumberFromEnv" == "$productNumber" && "$ProductRevisionFromEnv" == "$productRevision" ]]
          then
            echo -e "PASSED: administratove data is configured properly on UP mo of $ne \n" >> $PWD/Result.txt
         else
            echo -e "FAILED: administratove data is not properly configured  on UP mo of $ne \n" >> $PWD/Result.txt
            exit 3
         fi

     done
     fi

###########################################################################
#Checking ProductData on MGw nodes
###########################################################################

if [[ $simName == *"MGw"* ]]
then
  for ne in ${node[@]}
  do

new=$(echo -e ".open $simName \n .select $ne \n .start \n e X= csmo:ldn_to_mo_id(null,[\"ManagedElement=1\",\"SwManagement=1\",\"UpgradePackage=1\"]). \n e csmo:get_attribute_value(null,X,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )
 productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
   productRevision=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )
    echo -e "ProductNumber on $ne is $productNumber and ProductRevision is $productRevision\n"
         if [[ "$ProductNumberFromEnv" == "$productNumber" && "$ProductRevisionFromEnv" == "$productRevision" ]]
         then
             echo -e "PASSED: ProductData is correctly loaded on $ne \n" >> $PWD/Result.txt
         else
             echo -e "FAILED: ProductData is not correctly loaded on $ne \n" >> $PWD/Result.txt
	     exit 3
         fi


  done
exit 0
fi

###########################################################################
#Checking ProductData on TCU04 and c608 nodes
###########################################################################
if [[ $simName == *"TCU04"* || $simName == *"C608"* || ( $simName == *"SCU"* && $simName == *"ERS-SN"* ) || ( $simName == *"ESC"* && $simName == *"ERS-SN"* ) ]]
then
echo -e "ProductNumberFromEnv is $ProductNumberFromEnv"
echo -e "ProductRevisionFromEnv is $ProductRevisionFromEnv\n"
  for ne in ${node[@]}
  do

new=$(echo -e ".open $simName \n .select $ne \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=1\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )
 productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d ' ' | cut -d '"' -f 2)
   productRevision=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )
   echo -e "ProductNumber on $ne is $productNumber and ProductRevision is $productRevision\n"
         if [[ "$ProductNumberFromEnv" == "$productNumber" && "$ProductRevisionFromEnv" == "$productRevision" ]]
         then
             echo -e "PASSED: ProductData is correctly loaded on $ne \n" >> $PWD/Result.txt
         else
             echo -e "FAILED: ProductData is not correctly loaded on $ne \n" >> $PWD/Result.txt
             exit 3
         fi


  done
  exit 0
  fi

###########################################################################
#Checking ProductData on SpitFire nodes
###########################################################################

if [[ $simName == *"Spit"* || $simName == *"Router"* ]]
then
echo -e "ProductNumberFromEnv is $ProductNumberFromEnv"
echo -e "ProductRevisionFromEnv is $ProductRevisionFromEnv\n"
  for ne in ${node[@]}
  do

new=$(echo -e ".open $simName \n .select $ne \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=p01_RP1_SPR2-${ProductRevisionFromEnv}-Release\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )

   productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
   productRevision=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )
   echo -e "ProductNumber on $ne is $productNumber and ProductRevision is $productRevision\n"
         if [[ "$ProductNumberFromEnv" == "$productNumber" && "$ProductRevisionFromEnv" == "$productRevision" ]]
         then
             echo -e "PASSED: ProductData is correctly loaded on $ne \n" >> $PWD/Result.txt
         else
             echo -e "FAILED: ProductData is not correctly loaded on $ne \n" >> $PWD/Result.txt
             exit 3
         fi


  done
exit 0
fi

#########################################################################
#Checking productdata on HLR nodes
#########################################################################
if [[ $simName == *"HLR"* ]]
then
new=$(echo -e ".open $simName \n .select ${node[@]} \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=ERIC-HLRFE_GSNH-APR10159/4-R1A\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )

   productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
   productRevision=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )

new1=$(echo -e ".open $simName \n .select ${node[@]} \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=APG43L-3.4.3-R5E\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )

 productNumber1=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
 productRevision1=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )

 if [[ $productNumber == *"null"* || $productNumber1 == *"null"*  || $productRevision == *"null"* || $productRevision1 == *"null"* ]]
         then
             echo -e "FAILED: ProductData is not correctly loaded on ${node[@]}  \n" >> $PWD/Result.txt
	     exit 3
         else
             echo -e "PASSED: ProductData is correctly loaded on ${node[@]} \n" >> $PWD/Result.txt
         fi
exit 0
fi

###########################################################################
#Checking ProductData on com/ecim nodes
###########################################################################
#rm -rf  b.txt Pdcheck.mml
echo -e "ProductNumberFromEnv is $ProductNumberFromEnv"
echo -e "ProductRevisionFromEnv is $ProductRevisionFromEnv\n"
  for ne in ${node[@]}
    do
      new=$(echo -e ".open $simName \n .select $ne \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=1\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )
      productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
      productRevision=$(echo "${new[*]}" | grep "productrevision" | tr -d 'productrevision{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
      echo -e "ProductNumber on $ne is $productNumber and ProductRevision is $productRevision\n"
        if [[ "$ProductNumberFromEnv" == "$productNumber" && "$ProductRevisionFromEnv" == "$productRevision" ]]
         then
           echo -e "PASSED: ProductData is correctly loaded on $ne \n" >> Result.txt
        else
           echo -e "FAILED: ProductData is not correctly loaded on $ne \n" >> Result.txt
           exit 3
        fi

    done

###########################################################################
# Checking LastConfigchange attribute in SIU02 nodes
############################################################################

if [[ $simName == *"SIU02"* ]]
then
    for ne in ${node[@]}
    do
      attrValue=$(echo -e ".open $simName \n .select $ne \n .start \n e: csmo:get_attribute_value(null,csmo:ldn_to_mo_id(null,[\"STN=0\"]),lastConfigChange). " | sudo su -l netsim -c /netsim/inst/netsim_shell | tail -n+8)
      var=$(sudo su -l netsim -c 'date -d "'$attrValue'"' > /dev/null 2>&1)
      if [ $? != 0 ]
      then
         echo -e "FAILED: LastConfigChange  attribute of $ne has invalid data \n" >> $PWD/Result.txt
      else
         if [[ -z $attrValue ]]
         then
            echo -e "FAILED: LastConfigChange attribute of $ne has null data \n" >> $PWD/Result.txt
         else
            echo -e "PASSED: LastConfigChange  attribute of $ne is correctly configured \n" >> $PWD/Result.txt
         fi
      fi
    done
fi

##############################################################################
PWD=`pwd`
cat $PWD/Result.txt
Failure=`cat $PWD/Result.txt | grep -i "failed"`
if [[ -z $Failure ]]
then
echo "CHeck done on $simName" 
else 
echo " Check Product Data , It failed on few nodes "
exit 1
fi
