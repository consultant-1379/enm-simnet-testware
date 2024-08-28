#!/bin/bash
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
a=${#tempSimName[@]}

#Get mimVersion from simname for each version

if [[ $simName == *"MGw"* ]]
then
mimVersion=${tempSimName[a-2]}

elif [[ $simName == *"SGSN"* ]]
then
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-${tempSimName[a-2]}

elif [[ ( $simName == *"SCU"* && $simName != *"SN-SCU"* ) ]]
then
    if [[ $simName == *"SCU"* ]]
    then
        mimVersion=SCU`echo $simName | awk -F "SCU" '{print $2}' | awk -F"x" '{print $1}'`
    fi

elif [[ $simName == *"EPG"* || $simName == *"vEPG"* ]]
then
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-${tempSimName[a-2]}

elif [[ $simName == *"RIU"* ]]
then
if [[ $simName == *"Router6371"* ]]
then
mimVersion=${tempSimName[a-5]}-${tempSimName[a-4]}-${tempSimName[a-3]}
fi

elif [[ $simName == *"UPGIND"* ]]
then
if [[ $simName == *"MTAS"* || $simName == *"ESAPC"* || $simName == *"SBG"* || $simName == *"CSCF"* 
   || $simName == *"TCU04"* || $simName == *"EPG"* || $simName == *"Router6672"* || $simName == *"Router6675"* ]]
then
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-${tempSimName[a-2]}
fi

elif [[ $simName == *"Spit"* || $simName == *"Router6672"* || $simName == *"Router6675"* || $simName == *"Router6274"* || $simName == *"Router6371"* ]]
then
mimVersion=${tempSimName[2]}-${tempSimName[3]}

elif [[ $simName == *"Router6471-1"* || $simName == *"Router6471-2"* ]]
then
mimVersion=${tempSimName[2]}-${tempSimName[3]}-${tempSimName[4]}

elif [[ $simName == *"TCU"* ]]
then
if [[ $simName == *"TCU04"* ]]
then
mimVersion=TCU04`echo $simName | awk -F"TCU04" '{print $2}' | awk -F"x" '{print $1}'`
fi

elif [[ $simName == *"ESAPC"* || $simName == *"MTAS"*
     || $simName == *"CSCF"* || $simName == *"UPG"*
     || $simName == *"DSC"* || $simName == *"BSP"* ||  $simName == *"SBG"* || $simName == *"vWMG"* || $simName == *"vWCG"* || $simName == *"vEME"* || $simName == *"IPWORKS"* || $simName == *"vBGF"*  || $simName == *"MRFv"*
     || $simName == *"HSS-FE"* ]]
then
mimVersion=${tempSimName[a-3]}-${tempSimName[a-2]}

elif [[ $simName == *"WMG"* ]]
then
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-${tempSimName[a-2]}

elif [[ $simName == *"FrontHaul"* ]]
then
mimVersion=${tempSimName[a-5]}-${tempSimName[a-4]}-${tempSimName[a-3]}
else
exit 1
fi

#extract Product number and product version using mimversion from productdata.env

#grep -i $mimVersion"=" /$path/../bin/ProductData.env > $path/ProductData.txt
#grep -i $mimVersion"=" $PWD/CORE/bin/ProductData.env > $PWD/ProductData.txt
grep -i $mimVersion"=" $PWD/ProductData.env > $PWD/ProductData.txt
mimLine=`cat $path/ProductData.txt`
number=`echo "$mimLine" | grep -o -P '(?<==).*(?=:)'`
revision=`echo "$mimLine" | cut -d ":" -f2`
echo "$number:$revision"
rm -rf *.txt

