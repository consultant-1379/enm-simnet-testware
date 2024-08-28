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
a=${#tempSimName[@]}


#Get mimVersion from simname for each version

if [[ $simName == *"MGw"* ]]
then
mimVersion=${tempSimName[a-3]}
elif [[ $simName == *"MRS"* ]]
then
mimVersion=${tempSimName[a-3]}-${tempSimName[a-2]}

elif [[ $simName == *"CONTROLLER6610"* ]]
then
mimVersion=CONTROLLER`echo $simName | awk -F"CONTROLLER" '{print $2}' | awk -F"x" '{print $1}'`

elif [[ $simName == *"SGSN"* ]]
then
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}

elif [[ $simName == *"NELS"* ]]
then
mim=`echo ${tempSimName[a-2]} | awk -F"x" '{print $1}'`
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-$mim

elif [[ $simName == *"DSC-18"* ]]
then
mimVersion=DSC`echo $simName | awk -F"DSC" '{print $2}' | awk -F"x" '{print $1}'`


elif [[ $simName == *"EPG"* || $simName == *"vEPG"* ]]
then
if [[ $simName == *"vEPG"* ]] && [[ $simName == *"OI"* ]]
then
mimVersion=vEPG`echo $simName | awk -F"vEPG" '{print $2}' | awk -F"x" '{print $1}'`
elif [[ $simName == *"EPG"* && $simName == *"OI"* ]]
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

elif [[ $simName == *"Spit"* || $simName == *"Router6672"* || $simName == *"Router6673"* || $simName == *"Router6675"* || $simName == *"Router6676"* || $simName == *"Router6678"* || $simName == *"Router6671"* || $simName == *"Router6274"* || $simName == *"Router6371"* || $simName == *"Router6273"* || ( $simName == *"SCU"* && $simName != *"SN-SCU"* ) || $simName == *"ESC"* ]]
then
if [[ $simName == *"SCU"* ]]
then
mimVersion=SCU`echo $simName | awk -F "SCU" '{print $2}' | awk -F"x" '{print $1}'`

elif [[ $simName == *"ESC"* ]]
then
mimVersion=ESC`echo $simName | awk -F "ESC" '{print $2}' | awk -F"x" '{print $1}'`

elif [[ $simName == *"Router6672-19"* || $simName == *"Router6675-19"* || $simName == *"Router6274-19"* || $simName == *"Router6371-19"* || $simName == *"Router6672-18"* || $simName == *"Router6675-18"* || $simName == *"Router6274-18"* || $simName == *"Router6371-18"* || $simName == *"Router6672-20"* || $simName == *"Router6675-20"* || $simName == *"Router6274-20"* || $simName == *"Router6371-20"* || $simName == *"Router6273-20"* || $simName == *"Router6673-"* || $simName == *"Router6371-21"* || $simName == *"Router6672-21"* || $simName == *"Router6273-21"* || $simName == *"Router6274-22"* || $simName == *"Router6675-22"* || $simName == *"Router6676-23"* || $simName == *"Router6678-23"* || $simName == *"Router6671-24"* || $simName == *"Router6675-23"* || $simName == *"Router6274-23"* || $simName == *"Router6371-23"* || $simName == *"Router6672-23"* || $simName == *"Router6273-23"* ]]
then
mimVersion=Router`echo $simName | awk -F"Router" '{print $2}' | awk -F"x" '{print $1}'`
else
mimVersion=${tempSimName[2]}-${tempSimName[3]}
fi

elif [[ $simName == *"Router6471-1"* || $simName == *"Router6471-2"* ]]
then
if [[ $simName == *"Router6471-1-18"* || $simName == *"Router6471-2-18"* || $simName == *"Router6471-1-19"* || $simName == *"Router6471-2-19"* || $simName == *"Router6471-1-20"* || $simName == *"Router6471-2-20"* || $simName == *"Router6471-1-21"* || $simName == *"Router6471-2-21"* || $simName == *"Router6471-1-23"* || $simName == *"Router6471-2-23"* ]]
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
     || $simName == *"HSS-FE"* || $simName == *"vNSDS"* ]]
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
elif [[ $simName == *"RI"* ]] && [[ $simName == *"HSS-FE"* ]]
then
mimVersion=${tempSimName[a-4]}-${tempSimName[a-3]}-${tempSimName[a-2]}
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

if [[ $simName == *"EPG-OI"* ]] || [[ $simName == *"vEPG-OI"* ]]
then
    grep -i ^$mimVersion"=" /$path/../bin/ProdData.env > $path/ProductData.txt
else
    grep -i $mimVersion"=" /$path/../bin/ProdData.env > $path/ProductData.txt    
fi

mimLine=$(cat $path/ProductData.txt);
if [[ $mimVersion == "C1355" ]] || [[ $mimVersion == "C1370" ]]
then
    for i in ${mimLine[@]}
    do
        val=`echo $i|grep -i "mrs"`
        if [[ -z $val ]]
        then
                
                 number=`echo "$i" | grep -o -P '(?<==).*(?=:)'`
                revision=`echo "$i" | cut -d ":" -f2`
                echo "$number:$revision"

       fi
        done
 
else
#grep -i $mimVersion"=" /$path/../bin/ProductData.env > $path/ProductData.txt
mimLine=`cat $path/ProductData.txt`
#echo "$mimLine"
number=`echo "$mimLine" | grep -o -P '(?<==).*(?=:)'`
revision=`echo "$mimLine" | cut -d ":" -f2`
echo "$number:$revision"
fi

rm -rf *.txt







