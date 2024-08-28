#!/bin/bash

##########################################################################################################################
# Created by  : Mitali Sinha
# Created on  : 30.11.2018
# Purpose     : Gets Product Data on CORE nodes
###########################################################################################################################

usage (){

echo "Usage  : $0 <sim name> "

echo "Example: $0 SGSN-WPP-14B-V6x30 "

}
######################################################
#To check whether commands are passed as they should#
######################################################
if [ $# -ne 1 ]
then
usage
exit
fi
simName=$1
path=`pwd`

tempSimName=(${simName//-/ })

#find length of tempSimName
Length=${#tempSimName[@]}


#Get mimVersion from simname for each version

if [[ $simName == *"MGw"* ]]
then
mimVersion=${tempSimName[a-2]}
#echo "mimVersion=$mimVersion"

elif [[ $simName == *"MRS"* ]]
then
mimVersion=${tempSimName[a-3]}-${tempSimName[a-2]}

elif [[ $simName == *"SGSN"* ]]
then
mimVersion=${tempSimName[Length-3]}-${tempSimName[Length-2]}

elif [[ $simName == *"DSC-18"* ]]
then
mimVersion=DSC`echo $simName | awk -F"DSC" '{print $2}' | awk -F"x" '{print $1}'`


elif [[ $simName == *"EPG"* || $simName == *"vEPG"* ]]
then
if [[ $simName == *"OI-2-0-V1"* ]]
then
mimVersion=EPG`echo $simName | awk -F"EPG" '{print $2}' | awk -F"x" '{print $1}'`
else
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-${tempSimName[a-2]}
fi

elif [[ $simName == *"RI"* ]] && [[ $simName == *"Router6371"* ]]
then
mimVersion=${tempSimName[a-5]}-${tempSimName[a-4]}-${tempSimName[a-3]}

elif [[ $simName == *"RI"* ]] && [[ $simName == *"Router6274"* ]]
then
mim=`echo ${tempSimName[a-2]} | awk -F"x" '{print $1}'`
mimVersion=${tempSimName[a-6]}-${tempSimName[a-5]}-${tempSimName[a-4]}-${tempSimName[a-3]}-$mim

elif [[ $simName == *"UPGIND"* ]]
then
if [[ $simName == *"MTAS"* || $simName == *"ESAPC"* || $simName == *"SBG"* || $simName == *"CSCF"* 
  || $simName == *"TCU04"* || $simName == *"EPG"* || $simName == *"Router6672"* || $simName == *"Router6675"* || $simName == *"DSC"* ]]
then
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-${tempSimName[a-2]}
fi

elif [[ $simName == *"Spit"* || $simName == *"Router6672"* || $simName == *"Router6675"* || $simName == *"Router6274"* || $simName == *"Router6371"* ]]
then
if [[ $simName == *"Router6672-18"* || $simName == *"Router6675-18"* || $simName == *"Router6274-18"* || $simName == *"Router6371-18"* || $simName == *"Router6672-20"* || $simName == *"Router6675-20"* || $simName == *"Router6274-20"* || $simName == *"Router6371-20"* ]]
then
mimVersion=Router`echo $simName | awk -F"Router" '{print $2}' | awk -F"x" '{print $1}'`
else
mimVersion=${tempSimName[2]}-${tempSimName[3]}
fi

elif [[ $simName == *"Router6471-1"* || $simName == *"Router6471-2"* ]]
then
if [[ $simName == *"Router6471-1-18"* || $simName == *"Router6471-2-18"* || $simName == *"Router6471-1-20"* || $simName == *"Router6471-2-20"* ]]
then
mimVersion=Router`echo $simName | awk -F"Router" '{print $2}' | awk -F"x" '{print $1}'`
else
mimVersion=${tempSimName[2]}-${tempSimName[3]}-${tempSimName[4]}
fi

elif [[ $simName == *"TCU"* ]]
then
if [[ $simName == *"TCU04"* ]]
then
mimVersion=TCU04`echo $simName | awk -F"TCU04" '{print $2}' | awk -F"x" '{print $1}'`
fi

elif [[ $simName == *"ESAPC"* || $simName == *"VSAPC"* || $simName == *"MTAS"*
     || $simName == *"CSCF"* || $simName == *"UPG"*
     || $simName == *"DSC"* || $simName == *"BSP"* ||  $simName == *"SBG"* || $simName == *"vWMG"* || $simName == *"vWCG"* || $simName == *"vEME"* || $simName == *"IPWORKS"* || $simName == *"vBGF"*  || $simName == *"MRFv"*
     || $simName == *"HSS-FE"* ]]
then
if [[ $simName == *"RI"* ]] && [[ $simName == *"vBGF"* ]]
then
mimVersion=vBGF`echo $simName | awk -F"vBGF" '{print $2}' | awk -F"x" '{print $1}'`
elif [[ $simName == *"RI"* ]] && [[ $simName == *"MRFv"* ]]
then
mimVersion=MRFv`echo $simName | awk -F"MRFv" '{print $2}' | awk -F"x" '{print $1}'`
elif [[ $simName == *"RI"* ]] && [[ $simName == *"BSP"* ]]
then
mimVersion=BSP`echo $simName | awk -F"BSP" '{print $2}' | awk -F"x" '{print $1}'`
elif [[ $simName == *"RI"* ]] && [[ $simName == *"IPWORKS"* ]]
then
mimVersion=IPWORKS`echo $simName | awk -F"IPWORKS" '{print $2}' | awk -F"x" '{print $1}'`

elif [[ $simName == *"RI"* ]] && [[ $simName == *"vEME"* ]]
then
mimVersion=vEME`echo $simName | awk -F"vEME" '{print $2}' | awk -F"x" '{print $1}'`
else
mimVersion=${tempSimName[a-3]}-${tempSimName[a-2]}
fi

elif [[ $simName == *"WMG"* ]]
then
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-${tempSimName[a-2]}

elif [[ $simName == *"FrontHaul"* ]]
then
mimVersion=${tempSimName[3]}-${tempSimName[4]}-${tempSimName[5]}

else
exit 1
fi

#extract Product number and product version using mimversion from productdata.env
#ProdData.env
grep -i $mimVersion"=" /$path/ProdData.env > $path/ProductData.txt
mimLine=`cat $path/ProductData.txt`
number=`echo "$mimLine" | grep -o -P '(?<==).*(?=:)'`
revision=`echo "$mimLine" | cut -d ":" -f2`
#rm -rf *.txt
echo "$number:$revision"
