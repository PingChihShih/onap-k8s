#!/bin/bash

echo "準備開始踏入很容易失誤的腳本威能世界..."
echo "在一開始，我們先來做些Setup吧！"

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
