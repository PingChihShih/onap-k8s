#!/bin/bash

if [ $1 ] && [ $2 ]; then
	prefix=$1
	key=$2
else
	echo "You should enter a prefix for your cluster!"
	echo "e.g. bash cluster_creator.sh test test_key" 
	exit 1
fi

for i in $(seq 1 3)
do
	twccli mk vcs -n ${prefix}-control-${i} -fip -ptype v.super -key $key -net "default_network" -img "Ubuntu 18.04"
	#echo "master node \"${prefix}-control-${i}\" created"
done

for i in $(seq 1 12)
do
	twccli mk vcs -n ${prefix}-k8s-${i} -fip -ptype v.2xsuper -key $key -net "default_network" -img "Ubuntu 18.04"
	#echo "worker node \"${prefix}-k8s-${i}\" created"
done
