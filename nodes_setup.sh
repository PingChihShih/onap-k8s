#!/bin/bash

if [ $1 ] && [ $2 ]; then 
	PREFIX=$1 
	KEY=$2
else 
	echo "Please enter the prefix and key of the cluster!" 
	echo "e.g. bash node_setup.sh hank hankskey " 
	exit 1 
fi 

#SCRIPT="echo ----------; echo hi; echo ----------"
M_SCRIPT="wget https://raw.githubusercontent.com/onap/oom/master/docs/openstack-k8s-controlnode.sh; 
sudo bash openstack-k8s-controlnode.sh; 
sudo chown -R ubuntu:ubuntu .docker .vim .viminfo"
W_SCRIPT="wget https://raw.githubusercontent.com/onap/oom/master/docs/openstack-k8s-workernode.sh; 
sudo bash openstack-k8s-workernode.sh;
sudo chown -R ubuntu:ubuntu .docker .vim .viminfo"
M_NODES=$(twccli ls vcs | grep "$PREFIX-control"  | awk '{print $8}')
W_NODES=$(twccli ls vcs | grep "$PREFIX-k8s"  | awk '{print $8}')

echo "Start to connect to master nodes..." 
for node in ${M_NODES}; do
	#echo "ssh to ubuntu@${node}"
	ssh -i ${KEY}.pem -o StrictHostkeyChecking=no ubuntu@$node "${M_SCRIPT}"
done

echo "Start to connect to worker nodes..." 
for node in ${W_NODES}; do
	#echo "ssh to ubuntu@${node}"
	ssh -i ${KEY}.pem -o StrictHostkeyChecking=no ubuntu@$node "${W_SCRIPT}"
done

echo "================================"
echo "Please check if there are errors"
echo "================================"
