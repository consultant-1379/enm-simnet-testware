mv /netsim/cbrs_* /var/simnet/enm-simnet/scripts/
Total_CBRS=0
echo -e "####### Verifying Total CBRS devices count on the module #######\n"
for File in `echo /var/simnet/enm-simnet/scripts/cbrs_ieatnetsimv*.txt`
do
	while read -r line
	do 
		SIM_name=`echo $line | cut -d ":" -f 1`
		SIM_total=`echo $line | cut -d ":" -f 2`
		Total_CBRS=$((Total_CBRS+SIM_total))
		echo -e "SIM_name: $SIM_name\tCBRS device count: $SIM_total\n"
	done < $File
done
echo -e "**** Total CBRS devices = $Total_CBRS ****\n"