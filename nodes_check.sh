#!/bin/bash

if [ $2 ]; then
  PREFIX=$1
  KEY=$2
else
  echo "Please Enter Some Necessary Info for Setting Cluster!"

  echo -n "Node Prefix: "
  read PREFIX

  echo -n "Key Name(w/o .pem): "
  read KEY
fi

SCRIPT="ls; docker version"
M_NODES=$(twccli ls vcs | grep "$PREFIX-control"  | awk '{print $8}')
W_NODES=$(twccli ls vcs | grep "$PREFIX-k8s"  | awk '{print $8}')

echo "Start to connect to master nodes..." 
for node in ${M_NODES}; do
	echo "=============================="
	echo "|   ubuntu@${node}   |"
	echo "=============================="
	ssh -i ${KEY}.pem -o StrictHostkeyChecking=no ubuntu@$node "${SCRIPT}"
done

echo "Start to connect to worker nodes..." 
for node in ${W_NODES}; do
	echo "=============================="
	echo "|   ubuntu@${node}   |"
	echo "=============================="
	ssh -i ${KEY}.pem -o StrictHostkeyChecking=no ubuntu@$node "${SCRIPT}"
done

echo "================================"
echo "Please check if there are errors"
echo "================================"
