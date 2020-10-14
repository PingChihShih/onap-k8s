#!/bin/bash

if [ $1 ]; then 
	PREFIX=$1 
else 
	echo "Please enter the prefix of the nodes!" 
	echo "e.g. onap-k8s-3, onap-k8s-12, ..., then you should type:"
	echo "./nfs_setup.sh onap" 
	exit 1 
fi 

# Key Setting
KEY=$PREFIX
if [ $2 ]; then
	KEY=$2 
else 
	echo "We use your prefix $1.pem as default key." 
	echo "If you have a customized key name, please type it after the prefix."
	echo "e.g. ./nfs_setup.sh repro kp1600123456789"
fi

# Create NFS Server
# twccli mk vcs -n $PREFIX-nfs-server -fip -ptype v.super -key $KEY -net "default_network" -img "Ubuntu 18.04"

NFS_SERVER=$(twccli ls vcs | grep "$PREFIX-nfs-server"  | awk '{print $8}') # $8 is fip
SLAVE_NODES=$(twccli ls vcs | grep "$PREFIX-k8s"  | awk '{print $8}') # $8 is fip
SLAVE_LIST=$(echo $SLAVE_NODES | tr $'\n' ' ')
SERVER_SCRIPT="rm openstack-nfs-server.sh master_nfs_node.sh;
wget https://raw.githubusercontent.com/onap/oom/master/docs/openstack-nfs-server.sh; 
wget https://raw.githubusercontent.com/onap/oom/master/docs/master_nfs_node.sh; 
chmod +x openstack-nfs-server.sh;
chmod +x master_nfs_node.sh;
sudo ./openstack-nfs-server.sh; 
sudo rm /etc/exports;
touch /etc/expotrs;
sudo ./master_nfs_node.sh $SLAVE_LIST"
SLAVE_SCRIPT="rm slave_nfs_node.sh;
wget https://raw.githubusercontent.com/onap/oom/master/docs/slave_nfs_node.sh; 
chmod +x slave_nfs_node.sh;
sudo ./slave_nfs_node.sh $NFS_SERVER"

# Setup Script on NFS Server 
echo "Start to connect to NFS Server..." 
echo "###############################"
echo "#ssh to ubuntu@$NFS_SERVER#"
echo "###############################"
ssh -i $KEY.pem -o StrictHostkeyChecking=no ubuntu@$NFS_SERVER "$SERVER_SCRIPT"
# echo $SERVER_SCRIPT
# echo "$SERVER_SCRIPT"

echo "Start to connect to Slave Nodes..." 
for node in ${SLAVE_NODES}; do
	echo "###############################"
	echo "#ssh to ubuntu@${node}#"
	echo "###############################"
	ssh -i $KEY.pem -o StrictHostkeyChecking=no ubuntu@$node "$SLAVE_SCRIPT"
done

# echo "================================"
# echo "Please check if there are errors"
# echo "================================"
