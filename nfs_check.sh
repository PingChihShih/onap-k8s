#!/bin/bash

if [ $2 ]; then
  PREFIX=$1
  KEY=$2
else
  echo "Please Enter Some Necessary Info for Creating cluster.yml!"

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
NFS=$(twccli ls vcs | grep "$PREFIX-nfs-server"  | awk '{print $8}')
W_NODES=$(twccli ls vcs | grep "$PREFIX-k8s"  | awk '{print $8}')
N_SCRIPT="cd /dockerdata-nfs; touch test.hank"
W_SCRIPT="ls /dockerdata-nfs"


ssh -i ~/.ssh/${KEY}.pem -o StrictHostkeyChecking=no ubuntu@$NFS "${N_SCRIPT}"

echo "Start to connect to worker nodes..."
for node in ${W_NODES}; do
	echo "=============================="
	echo "|   ubuntu@${node}   |"
	echo "=============================="
	ssh -i ~/.ssh/${KEY}.pem -o StrictHostkeyChecking=no ubuntu@$node "${W_SCRIPT}"
done
