#!/bin/sh

### VERSION HISTORY
####################################################################################
##     Version     : 1.3
##
##     Revision    : CXP 903 4833-1-4
##
##     Author      : Nainesha Chilakala.
##
##     JIRA        : No jira
##
##     Description : HC design Support for NRM6.3
##
##     Date        : 23rd feb 2022
##
#####################################################################################
####################################################################################
##     Version     : 1.2
##
##     Revision    : CXP 903 4833-1-1
##
##     Author      : Yamuna Kanchireddygari
##
##     JIRA        : NSS-32936
##
##     Description : HC design Support for all NRMs
##
##     Date        : 12th Oct 2020
##
#####################################################################################

echo "##################################"
echo "$0 script started"
echo "##################################"


#wget https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/content/repositories/nss/com/ericsson/nss/5G_Checker/1.0.4/5G_Checker-1.0.4.sh -O 5G_Checker.sh
#mv 5G_Checker.sh  /var/simnet/enm-simnet/scripts/5G_Checker.sh
chmod 777 /var/simnet/enm-simnet/scripts/5G_Checker.sh
sh /var/simnet/enm-simnet/scripts/5G_Checker.sh

wget https://arm901-eiffel004.athtem.eei.ericsson.se:8443/nexus/content/repositories/simnet/com/ericsson/simnet/scripts/local/NR_CBRS_check.sh
mv NR_CBRS_check*.sh /var/simnet/enm-simnet/scripts
chmod 777 /var/simnet/enm-simnet/scripts/NR_CBRS_check.sh
sh /var/simnet/enm-simnet/scripts/NR_CBRS_check.sh
cp /netsim/cbrs_* /var/simnet/enm-simnet/scripts/

####################
echo "Copying File to `hostname`"
echo "First server=$1"
#echo `ls /var/simnet/enm-simnet/scripts `
/usr/bin/expect  <<EOF
spawn scp -rp -o StrictHostKeyChecking=no /netsim/`hostname`-5GTotal.txt /netsim/`hostname`-5Gtotal.log /netsim/`hostname`-5G.csv /var/simnet/enm-simnet/scripts/cbrs_`hostname`.txt root@$1.athtem.eei.ericsson.se:/netsim/
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
