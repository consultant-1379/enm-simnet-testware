#!/bin/bash
#!/usr/bin/perl

#######################################################################
#Created by : Harika Gouda
#Created on : 23rd Aug 2017
#Purpose : Performs ProductData check on nodes
##########################################################################
#Variables
#########################################################################
simName=$1
if [[ $simName == *"TSP"* || $simName == *"CISCO"* || $simName == *"ML"* || $simName == *"JUNIPER"* || $simName == *"SIU02"*  || $simName == *"TCU02"*
  || $simName == *"ECM"* || $simName == *"SSR"* || $simName == *"vBNG"* || $simName == *"ESC"* || $simName == *"Router8801"* || $simName == *"IS55"* || $simName == *"WMG"* || $simName == *"vWMG"* || $simName == *"UPGIND"* || $simName == *"CUDB"* || $simName == *"EPG"* ]]
then
echo -e "ProductData doesnt exist for this nodes\n"
exit 0
fi

if [[ $simName == *"BSC"* ]]
then
exit 0
fi


echo -e "\nStarting ProductData check on $simName-------------------- \n"
$PWD/CORE/bin/extractNeNames.pl $simName
neNames=( $( cat $PWD/dumpNeName.txt ) )
definedProductData=$($PWD/CORE/bin/AssignProductData.sh $simName)
definedProductNumber=`echo $definedProductData | cut -d ":" -f1`
definedProductRevision=`echo $definedProductData | cut -d ":" -f2`

###########################################################################
#Checking ProductData on MGw nodes
###########################################################################

if [[ $simName == *"MGw"* ]]
then
echo -e "definedProductNumber is $definedProductNumber"
echo -e "definedProductRevision is $definedProductRevision\n"
  for ne in ${neNames[@]}
  do

new=$(echo -e ".open $simName \n .select $ne \n .start \n e X= csmo:ldn_to_mo_id(null,[\"ManagedElement=1\",\"SwManagement=1\",\"UpgradePackage=1\"]). \n e csmo:get_attribute_value(null,X,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )
 productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
   productRevision=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )
    echo -e "ProductNumber on $ne is $productNumber and ProductRevision is $productRevision\n"
         if [[ "$definedProductNumber" == "$productNumber" && "$definedProductRevision" == "$productRevision" ]]
         then
             echo -e "PASSED: ProductData is correctly loaded on $ne \n"
         else
             echo -e "FAILED: ProductData is not correctly loaded on $ne \n"
         fi


  done
exit 0
fi
###########################################################################
#Checking ProductData on TCU04 and c608 nodes
###########################################################################
if [[ $simName == *"TCU04"* || $simName == *"C608"* ]]
then
echo -e "definedProductNumber is $definedProductNumber"
echo -e "definedProductRevision is $definedProductRevision\n"
  for ne in ${neNames[@]}
  do

new=$(echo -e ".open $simName \n .select $ne \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=1\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )
 productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d ' ' | cut -d '"' -f 2)
   productRevision=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )
   echo -e "ProductNumber on $ne is $productNumber and ProductRevision is $productRevision\n"
         if [[ "$definedProductNumber" == "$productNumber" && "$definedProductRevision" == "$productRevision" ]]
         then
             echo -e "PASSED: ProductData is correctly loaded on $ne \n"
         else
             echo -e "FAILED: ProductData is not correctly loaded on $ne \n"
         fi


  done
  exit 0
  fi

###########################################################################
#Checking ProductData on SpitFire nodes
###########################################################################

if [[ $simName == *"Spit"* || $simName == *"Router"* ]]
then
echo -e "definedProductNumber is $definedProductNumber"
echo -e "definedProductRevision is $definedProductRevision\n"
  for ne in ${neNames[@]}
  do

new=$(echo -e ".open $simName \n .select $ne \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=p01_RP1_SPR2-${definedProductRevision}-Release\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )

 productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
   productRevision=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )
    echo -e "ProductNumber on $ne is $productNumber and ProductRevision is $productRevision\n"
         if [[ "$definedProductNumber" == "$productNumber" && "$definedProductRevision" == "$productRevision" ]]
         then
             echo -e "PASSED: ProductData is correctly loaded on $ne \n"
         else
             echo -e "FAILED: ProductData is not correctly loaded on $ne \n"
         fi


  done
exit 0
fi

#########################################################################
#Checking productdata on HLR nodes
#########################################################################
if [[ $simName == *"HLR"* ]]
then
new=$(echo -e ".open $simName \n .select ${neNames[@]} \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=ERIC-HLRFE_GSNH-APR10159/4-R1A\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )

   productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
   productRevision=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )

new1=$(echo -e ".open $simName \n .select ${neNames[@]} \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=APG43L-3.4.3-R5E\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )

 productNumber1=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
   productRevision1=$(echo "${new[*]}" | grep "productrevision" | cut -d '"' -f 2 | tr -d ' ' )

 if [[ $productNumber == *"null"* || $productNumber1 == *"null"*  || $productRevision == *"null"* || $productRevision1 == *"null"* ]]
         then
             echo -e "FAILED: ProductData is not correctly loaded on ${neNames[@]}  \n"
         else
             echo -e "PASSED: ProductData is correctly loaded on ${neNames[@]} \n"
         fi
exit 0
fi

###########################################################################
#Checking ProductData on com/ecim nodes
###########################################################################
rm -rf  b.txt Pdcheck.mml
echo -e "definedProductNumber is $definedProductNumber"
echo -e "definedProductRevision is $definedProductRevision\n"
  for ne in ${neNames[@]}
    do
      new=$(echo -e ".open $simName \n .select $ne \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwInventory=1,SwVersion=1\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )
      productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
      productRevision=$(echo "${new[*]}" | grep "productrevision" | tr -d 'productrevision{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
      echo -e "ProductNumber on $ne is $productNumber and ProductRevision is $productRevision\n"
        if [[ "$definedProductNumber" == "$productNumber" && "$definedProductRevision" == "$productRevision" ]]
         then
           echo -e "PASSED: ProductData is correctly loaded on $ne \n"
        else
           echo -e "FAILED: ProductData is not correctly loaded on $ne \n"
        fi

    done


if [[ $simName == *"SGSN"* ]]
then
for ne in ${neNames[@]}
    do
      new=$(echo -e ".open $simName \n .select $ne \n .start \n e csmo:get_attribute_value(null, csmo:ldn_to_mo_id(null,string:tokens(cs_ker_parse:get_ldn_with_namespace(\"ManagedElement=\"++csmo:get_attribute_value(null,1,managedElementId)++\",SystemFunctions=1,SwM=1,UpgradePackage=1\"),\",\")) ,administrativeData). " | sudo su -l netsim -c /netsim/inst/netsim_shell )
      productNumber=$(echo "${new[*]}" | grep "productnumber" | tr -d 'productnumber{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
      productRevision=$(echo "${new[*]}" | grep "productrevision" | tr -d 'productrevision{,' | tr -d '}' | tr -d ' ' | cut -d '"' -f 2 )
        if [[ "$definedProductNumber" == "$productNumber" && "$definedProductRevision" == "$productRevision" ]]
         then
           echo -e "PASSED: administratove data is configured properly on UP mo of $ne \n"
        else
           echo -e "FAILED: administratove data is not properly configured  on UP mo of $ne \n"
        fi

    done
    fi

