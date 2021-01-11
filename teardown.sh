#!/bin/bash
twccli ls vcs | grep -E -i "control|k8s" | awk '{print $2,$4}'
read -ra nodes <<< `twccli ls vcs | grep -E -i "control|k8s" | awk '{print $2,$4}'`
for x in "${nodes[@]}"
do
	echo $x
done
