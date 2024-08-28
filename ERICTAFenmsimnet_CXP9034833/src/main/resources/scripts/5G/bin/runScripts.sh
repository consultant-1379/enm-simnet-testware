#!/bin/sh
#!/usr/bin/perl

if [ "$#" -ne 3 ]
then
 echo
 echo "Usage: $0 <simname> <numbOfNodes> <type>"
 echo
 echo "Example: $0 LTE18A-V3x2-FT-TLS-vPP-LTE52 2 vPP"
 echo
 exit 1
fi

sim=$1
numbOfNodes=$2
type=$3
PWD=`pwd`

cd $PWD/5G/bin/
SCRIPTLIST=`ls 1*.??`

	for script in $SCRIPTLIST
	do
    echo '****************************************************' 
    echo "$script $sim $numbOfNodes $type" 
    ./$script $sim $numbOfNodes $type
    echo '****************************************************'  
	done