#!/bin/bash

echo "很好！你應該有準備好關鍵物品(cluster.yaml, rke)了"
echo "密鑰也藏好了(~/.ssh/xxx.pem)"
echo "人柱力(master & workers)應該也調教好了"
echo "只要你有把我們的魔法陣畫好(安全性群組tcp/udp全開)"
echo "我們就可以開始來做法了(rke up)！"

# RKE up
mv rke_linux-amd64 rke
chmod +x rke
sudo mv rke /bin

rke up

echo -n "請確保一下施法(rke)有無成功(y/n):"
read RKE_UP
if [ $RKE_UP != 'y' ]; then
	echo "施法失敗！墓穴要崩塌了>< 快逃！"
	exit 1
fi

# Install kubectl
echo "施法看似成功了呢～接下來，我們要來學習一些好用的法術(kubectl & helm)！"
echo "首先是法術1-生靈統領(kubectl)，這招可以讓你知道各召喚物的狀況喔！"
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.11/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "不知道你的法術學得如何，來試試看吧！"
kubectl version
echo -n "看起來成功嗎？(y/n):"
read CTL_OK
if [ $CTL_OK != 'y' ]; then
	echo "哎，再回去修煉幾天吧～"
	exit 1
fi

mkdir  ~/.kube/
cp kube_config_cluster.yml ~/.kube/config.onap
export KUBECONFIG=~/.kube/config.onap
kubectl config use-context onap
kubectl get nodes -o=wide


# Install Helm
echo "很好！再來學習法術2-通靈術(helm)！"
wget https://get.helm.sh/helm-v2.16.6-linux-amd64.tar.gz
tar -zxvf helm-v2.16.6-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
kubectl -n kube-system  rollout status deploy/tiller-deploy

# Install K8s Dashboard
echo "希望法術都有學習成功！接下來我派一個上Buff的小精靈給你：小KD(k8s dashboard)"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

echo "靈魂認定應該進行完畢，來教你與它互動的方式吧！"
echo "首先第一步，先拿取你的鑰匙(複製以下的token)，我也幫你建立一份在dashboard.token裡面"
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | grep token: | awk '{print $2}' > dashboard.token
echo "之後你可以透過「靈魂傳送」(tunneling)來進入此異空間(跳板機)，使用「鏡花水月」(proxy)來開啟，最後再以血之獻祭(本機開網頁)開啟"
echo "[[[ STEP 1: 靈魂傳送 ]]]"
echo "> ssh -i 金鑰檔案 -L 8001:127.0.0.1:8001 ubuntu@跳板機器ip

例如
> ssh -i twcc-kp1600483233027.pem -L 8001:127.0.0.1:8001 ubuntu@203.145.218.202"
echo "[[[ STEP 2: 鏡花水月 ]]]"
echo "> kubectl proxy &"
echo "[[[ STEP 3: 血之獻祭 ]]]"
echo "用瀏覽器開 http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

echo "死靈法師訓練到此結束，希望你都有成功！"