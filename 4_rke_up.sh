#!/bin/bash

echo "很好！你應該有準備好關鍵物品(cluster.yaml, rke)了"
echo "人柱力(master & workers)應該也調教好了"
echo "只要你有把我們的魔法陣畫好(安全性群組tcp/udp全開)"
echo "我們就可以開始來做法了(rke up)！"

echo ">>> INSTALL <<< install pip"
sudo apt install python3-pip

echo ">>> INSTALL <<< install twccli"
pip3 install twcc-cli

echo ">>> SETTING <<< put twccli into bin"
sudo mv /home/ubuntu/.local/bin/twccli /usr/local/bin/twccli

echo ">>> SETTING <<< twccli initialization"
echo "// 記得去找你的金鑰跟計畫編號！"
twccli config init

echo "前置處理完畢！接下來請去執行下一個script吧！"
