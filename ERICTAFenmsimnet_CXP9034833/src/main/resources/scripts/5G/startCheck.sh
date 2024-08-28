#!/bin/bash
#!/usr/bin/perl

##########################################################################################################################
# Created by  : Kathak Mridha
# Created on  : 03.08.2017
# Purpose     : Fetch simnames from netsim and trigger other scripts
###########################################################################################################################

if [ "$#" -ne 1 ]; then
		 echo "Usage: $0 YES"
		echo "Usage: $0 NO"
		 exit 1
fi

FLAG=$1
PWD=`pwd`
DATE=`date +%F`
TIME=`date +%T`
LOGFILE=$PWD/log/check5GLogs_$DATE\_$TIME.log

if [ "$FLAG" == "NO" ] ; then
	echo "Test on 5G simulations is flagged as NO" | tee -a "$LOGFILE"
	echo "The 5G simulations were skipped"         | tee -a "$LOGFILE"
	exit 0
fi

echo "" > $LOGFILE
echo "############################" | tee -a "$LOGFILE"
echo "   `hostname`"                | tee -a "$LOGFILE"
echo "############################" | tee -a "$LOGFILE"

if [ "$NETSIMDIR" = "" ] ; then
    NETSIMDIR=/netsim/netsimdir
fi
export NETSIMDIR

if [ -r $NETSIMDIR/simulations ] ; then
    SIMULATIONS=`cat $NETSIMDIR/simulations`
else
    SIMULATIONS=`ls -1 $NETSIMDIR/*/simulation.netsimdb | sed -e "s/.simulation.netsimdb//g" -e "s/^[^*]*[*\/]//g" |grep -v -E '^default$'`
fi

if [ -f SimulationList5G.txt ]; then
rm SimulationList5G.txt
fi

echo ""                                                 | tee -a "$LOGFILE"
echo "Looping through netsimdir to find 5G Simulations" | tee -a "$LOGFILE"

echo "$SIMULATIONS" | while read sim acts
	do
	
	if ([[ $sim == *"vPP"* ]] || [[ $sim == *"vRC"* ]] || [[ $sim == *"VTFRadioNode"* ]] || [[ $sim == *"vSD"* ]] || [[ $sim == *"RNNODE"* ]] || [[ $sim == *"5GRadioNode"* ]] || [[ $sim == *"vRM"* ]] || [[ $sim == *"vRSM"* ]]); then
		
		echo ""                        | tee -a "$LOGFILE"
		echo "$sim is a 5G Simulation" | tee -a "$LOGFILE"

			type=`printf "$sim" | rev | awk -F "-" '{print $2}' | awk -F "-" '{print $1}' | rev`
			printf ".open $sim \n .show simnes" | sudo su -l netsim -c /netsim/inst/netsim_shell | grep -e "$type" | grep -v ">>" | awk '{print $1}' > listNE.txt
            counter=0
			flag=0
          		
			while read ne
          	do

			simNumb=${sim:(-2)}         
			baseName=`printf "LTE${simNumb}${type}"`
			((counter++))

			if [[ "$counter" -le 9 ]]
    			then
        		baseName+=0000;
        		baseName+=$counter;
        		nodeName=$baseName;
    			elif [[ "$counter" -le 99 ]]
    			then
        		baseName+=000;
        		baseName+=$counter;
        		nodeName=$baseName;
    			else
			baseName+=00;
        		baseName+=$counter;
        		nodeName=$baseName;
    		fi

			if [[ $nodeName != $ne ]]; then
			((flag++))
			echo ""                                            | tee -a "$LOGFILE"
			echo "FAILED: Simulation $sim has nodename as $ne" | tee -a "$LOGFILE"
			echo "FAILED: It should be $nodeName"              | tee -a "$LOGFILE"
			fi

          	done <listNE.txt

			if [[ $flag -eq 0 ]]; then
                  printf "$sim\n" >> SimulationList5G.txt
            fi

	fi
	
	###################################################################
	
	
		
	if ([[ $sim == *"RAN-VNFM"* ]]); then
		
		echo ""                        | tee -a "$LOGFILE"
		echo "$sim is a 5G Simulation" | tee -a "$LOGFILE"

			#type=`printf "$sim" | rev | awk -F "-" '{print $2}' | awk -F "-" '{print $1}' | rev`
			type="RANVNFM"
			printf ".open $sim \n .show simnes" | sudo su -l netsim -c /netsim/inst/netsim_shell | grep -e "$type" | grep -v ">>" | awk '{print $1}' > listNE.txt
            counter=0
			flag=0
          		
			while read ne
          	do

			simNumb=${sim:(-2)}         
			baseName=`printf "LTE${simNumb}${type}"`
			((counter++))

			if [[ "$counter" -le 9 ]]
    			then
        		baseName+=00000;
        		baseName+=$counter;
        		nodeName=$baseName;
    			elif [[ "$counter" -le 99 ]]
    			then
        		baseName+=0000;
        		baseName+=$counter;
        		nodeName=$baseName;
    			else
			baseName+=000;
        		baseName+=$counter;
        		nodeName=$baseName;
    		fi

			if [[ $nodeName != $ne ]]; then
			((flag++))
			echo ""                                            | tee -a "$LOGFILE"
			echo "FAILED: Simulation $sim has nodename as $ne" | tee -a "$LOGFILE"
			echo "FAILED: It should be $nodeName"              | tee -a "$LOGFILE"
			fi

          	done <listNE.txt

			if [[ $flag -eq 0 ]]; then
                  printf "$sim\n" >> SimulationList5G.txt
            fi

	fi
	
	
	#######################################################################

	done

	echo ""                                  | tee -a "$LOGFILE"
	echo "After simname and nodename check " | tee -a "$LOGFILE"
	echo ""                                  | tee -a "$LOGFILE"
	echo "---------------------------------" | tee -a "$LOGFILE"
	echo "       5G Simulation List"         | tee -a "$LOGFILE"
	echo "---------------------------------" | tee -a "$LOGFILE"
	cat SimulationList5G.txt                 | tee -a "$LOGFILE"
	echo ""                                  | tee -a "$LOGFILE"
	echo "---------------------------------" | tee -a "$LOGFILE"
	echo ""                                  | tee -a "$LOGFILE"                           
	
while read sim
do
	numbOfNodes=`printf "$sim" | awk -F "x" '{print $2}' | awk -F "-" '{print $1}'`
	type=`printf "$sim" | rev | awk -F "-" '{print $2}' | awk -F "-" '{print $1}' | rev`
	
	echo "sh $PWD/5G/bin/runScripts.sh $sim $numbOfNodes $type"
	( sh $PWD/5G/bin/runScripts.sh $sim $numbOfNodes $type 2>&1 ) | tee -a "$LOGFILE"
	
done <SimulationList5G.txt
