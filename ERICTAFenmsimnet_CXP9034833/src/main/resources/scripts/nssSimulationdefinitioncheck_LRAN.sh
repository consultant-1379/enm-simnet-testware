#!/bin/sh
echo "I am nssSimulationdefinitioncheck_LRAN script############"
echo "##################################"
echo ""
echo "##################################"
echo ""

##chown netsim:netsim

wget https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/content/repositories/simnet/com/ericsson/simnet/LranChecker.sh
mv LranChecker*.sh  /var/simnet/enm-simnet/scripts
chmod 777 /var/simnet/enm-simnet/scripts/LranChecker.sh
sh /var/simnet/enm-simnet/scripts/LranChecker.sh

wget https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/content/repositories/simnet/com/ericsson/simnet/LTE_CBRS_check.sh
mv LTE_CBRS_check*.sh /var/simnet/enm-simnet/scripts
chmod 777 /var/simnet/enm-simnet/scripts/LTE_CBRS_check.sh
sh /var/simnet/enm-simnet/scripts/LTE_CBRS_check.sh
cp /netsim/cbrs_* /var/simnet/enm-simnet/scripts/
####################
echo "Copying File to `hostname`"
echo "First server=$1"
#echo `ls /var/simnet/enm-simnet/scripts `
/usr/bin/expect  <<EOF
spawn scp -rp -o StrictHostKeyChecking=no /netsim/`hostname`-lranTotal.txt /netsim/cbrs_`hostname`.txt /netsim/`hostname`-LTE.csv /netsim/`hostname`-lranChecker.log root@$1.athtem.eei.ericsson.se:/netsim/
expect {
    -re assword: {send "shroot\r";exp_continue}
}
    sleep 5
EOF

echo ""
echo "##################################"
echo ""
echo "##################################"
echo ""
