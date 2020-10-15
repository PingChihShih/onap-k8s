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

TMP=.tmp.temp
TARGET=cluster.yml
SCRIPT="ifconfig"
M_NODES=$(twccli ls vcs | grep "$PREFIX-control"  | awk '{print $8}')
W_NODES=$(twccli ls vcs | grep "$PREFIX-k8s"  | awk '{print $8}')
FLAG="StrictHostkeyChecking=no"

# ==========================
# START TO WRITE cluster.yml
# ==========================

echo "nodes:" > ${TARGET}

# Master Nodes

COUNT=1
for fip in ${M_NODES}; do
	ssh -i ${KEY}.pem -o ${FLAG} ubuntu@${fip} ${SCRIPT} > ${TMP}
	while IFS='' read -r line || [[ -n "$line" ]]; do
        	# echo "% ${line[0]}"
        	initial="$(echo $line | head -c 5)"
	        if [ "$initial" = "ens3:" ]; then
                	read -r line
			iip=$(echo $line | awk '{print $2}')
			break
        	fi
	done < ${TMP}
	cat >> ${TARGET} << EOF 
- address: ${fip}
  port: "22" 
  internal_address: ${iip}
  role:
  - controlplane
  - etcd
  hostname_override: "${PREFIX}-control-$COUNT"
  user: ubuntu
  ssh_key_path: "~/.ssh/${KEY}.pem"
EOF
COUNT=$(($COUNT+1))
done

# Worker Nodes

COUNT=1
for fip in ${W_NODES}; do
	ssh -i ${KEY}.pem -o ${FLAG} ubuntu@${fip} ${SCRIPT} > ${TMP}
	while IFS='' read -r line || [[ -n "$line" ]]; do
        	# echo "% ${line[0]}"
        	initial="$(echo $line | head -c 5)"
	        if [ "$initial" = "ens3:" ]; then
                	read -r line
			iip=$(echo $line | awk '{print $2}')
			break
        	fi
	done < ${TMP}
	cat >> ${TARGET} << EOF 
- address: ${fip}
  port: "22" 
  internal_address: ${iip}
  role:
  - worker
  hostname_override: "${PREFIX}-k8s-$COUNT"
  user: ubuntu
  ssh_key_path: "~/.ssh/${KEY}.pem"
EOF
COUNT=$(($COUNT+1))
done

# Services and others...

cat >> ${TARGET} << EOF
services:
  kube-api:
    service_cluster_ip_range: 10.43.0.0/16
    pod_security_policy: false
    always_pull_images: false
  kube-controller:
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
  kubelet:
    cluster_domain: cluster.local
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
network:
  plugin: canal
authentication:
  strategy: x509
ssh_key_path: "~/.ssh/${KEY}.pem"
ssh_agent_auth: false
authorization:
  mode: rbac
ignore_docker_version: false
kubernetes_version: "v1.15.11-rancher1-2"
private_registries:
- url: nexus3.onap.org:10001
  user: docker
  password: docker
  is_default: true
cluster_name: "onap"
restore:
  restore: false
  snapshot_name: ""
EOF

# ==========================
# END OF WRITING cluster.yml
# ==========================

rm -f ${TMP}
