#!/bin/bash

if [ $2 ]; then
  PREFIX=$1
  KEY=$2
else
  echo "Please Enter Some Necessary Info for Setting NFS!"

  echo -n "Node Prefix: "
  read PREFIX

  echo -n "Key Name(w/o .pem): "
  read KEY
fi

echo -n "Is your key in ~/.ssh?(y/n): "
read IN_SSH
if [ $IN_SSH != 'y' ]; then
	echo "Please put your key in ~/.ssh then try again."
	exit 1
fi

# Create NFS Server
# twccli mk vcs -n $PREFIX-nfs-server -fip -ptype v.super -key $KEY -net "default_network" -img "Ubuntu 18.04"

echo "確保你已經把NFS啟起來，以及安全性群組設定完畢"

NFS_SERVER=$(twccli ls vcs | grep "$PREFIX-nfs-server"  | awk '{print $8}') # $8 is fip
NFS_SERVER_ID=$(twccli ls vcs | grep "$PREFIX-nfs-server"  | awk '{print $2}') # $2 is id
SLAVE_NODES=$(twccli ls vcs | grep "$PREFIX-k8s"  | awk '{print $8}') # $8 is fip
SLAVE_NODES_ID=$(twccli ls vcs | grep "$PREFIX-k8s"  | awk '{print $2}') # $2 is id
NFS_IIP=$(twccli ls vcs -s $NFS_SERVER_ID | grep $NFS_SERVER_ID | awk '{print $8}') # $8 is iip
SLAVE_IIP_LIST=""
for node_id in $SLAVE_NODES_ID; do
	# echo "$node_id"
	# echo $(twccli ls vcs -s $node_id | grep $node_id | awk '{print $8}')	
	SLAVE_IIP_LIST="$SLAVE_IIP_LIST$(twccli ls vcs -s $node_id | grep $node_id | awk '{print $8}') "
done
NFS_IIP=$(echo $NFS_IIP | tr $'\n' ' ')
SLAVE_IIP_LIST=$(echo $SLAVE_IIP_LIST | tr $'\n' ' ')

SERVER_SCRIPT="rm openstack-nfs-server.sh master_nfs_node.sh;
wget https://raw.githubusercontent.com/onap/oom/master/docs/openstack-nfs-server.sh; 
wget https://raw.githubusercontent.com/onap/oom/master/docs/master_nfs_node.sh; 
chmod +x openstack-nfs-server.sh;
chmod +x master_nfs_node.sh;
sudo ./openstack-nfs-server.sh; 
sudo rm /etc/exports;
touch /etc/exports;
sudo ./master_nfs_node.sh $SLAVE_IIP_LIST"
SLAVE_SCRIPT="rm slave_nfs_node.sh;
wget https://raw.githubusercontent.com/onap/oom/master/docs/slave_nfs_node.sh; 
chmod +x slave_nfs_node.sh;
sudo ./slave_nfs_node.sh $NFS_IIP"

###
# echo "$NFS_IIP"
###
# exit 0
###

# Setup Script on NFS Server 
echo "Start to connect to NFS Server..." 
echo "###############################"
echo "#ssh to ubuntu@$NFS_SERVER#"
echo "###############################"
ssh -i ~/.ssh/$KEY.pem -o StrictHostkeyChecking=no ubuntu@$NFS_SERVER "$SERVER_SCRIPT"
# echo $SERVER_SCRIPT
# echo "$SERVER_SCRIPT"

echo "Start to connect to Slave Nodes..." 
for node in ${SLAVE_NODES}; do
	echo "###############################"
	echo "#ssh to ubuntu@${node}#"
	echo "###############################"
	ssh -i ~/.ssh/$KEY.pem -o StrictHostkeyChecking=no ubuntu@$node "$SLAVE_SCRIPT"
done

# echo "================================"
# echo "Please check if there are errors"
# echo "================================"
