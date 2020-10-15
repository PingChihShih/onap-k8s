#!/bin/bash

if [ $5 ]; then
  PREFIX=$1
  KEY=$2
  MASTER_NUM=$3
  WORKER_NUM=$4
  CPU_NUM=$5
else
	echo "Please Enter Some Necessary Info for Creating Cluster!"

	echo -n "Node Prefix: "
	read PREFIX

	echo -n "Key Name(w/o .pem): "
	read KEY

	echo -n "# of Master Nodes: "
	read MASTER_NUM

	echo -n "# of Worker Nodes: "
	read WORKER_NUM

	echo -n "CPU # of Worker Nodes(2, 4, 8): "
	read CPU_NUM
	if [ $CPU_NUM == '2' ]; then
		WORKER_TYPE='v.super'
	elif [ $CPU_NUM == '4' ]; then
		WORKER_TYPE='v.xsuper'
	elif [ $CPU_NUM == '8' ]; then
		WORKER_TYPE='v.2xsuper'
	else
		"Invalid argument $CPU_NUM, please try again."
		exit 1
	fi
fi

echo ""
echo "==================================="
echo "Here's your setting: "
echo "==================================="
echo "$PREFIX-control-[i] * $MASTER_NUM, type: v.super"
echo "$PREFIX-k8s-[i] * $WORKER_NUM, type: $WORKER_TYPE"
echo "==================================="
echo ""
echo -n "To Continue? (y/n): "
read B_CONTINUE

if [ $B_CONTINUE != 'y' ]; then
	echo "So closed >A< See you next time!"
	exit 1
fi

for i in $(seq 1 $MASTER_NUM)
do
	twccli mk vcs -n $PREFIX-control-${i} -fip -ptype v.super -key $KEY -net "default_network" -img "Ubuntu 18.04"
	#echo "master node \"${prefix}-control-${i}\" created"
done

for i in $(seq 1 $WORKER_NUM)
do
	twccli mk vcs -n $PREFIX-k8s-${i} -fip -ptype $WORKER_TYPE -key $KEY -net "default_network" -img "Ubuntu 18.04"
	#echo "worker node \"${prefix}-k8s-${i}\" created"
done

echo "============"
echo "| Success! |"
echo "============"
echo ""
echo -n "Continue to Create cluster.yaml? (y/n): "
read B_CONTINUE2

if [ $B_CONTINUE2 != 'y' ]; then
	echo "Okay, Bye!"
	exit 1
fi