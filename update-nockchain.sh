#!/bin/bash

set -e

echo -e "\n🔄 开始更新 nockchain..."

# 检查并创建 .env 文件
echo -e "\n📝 检查环境配置文件..."
if [ ! -f ".env" ]; then
    echo "⚠️ 未找到 .env 文件，从示例文件创建..."
    if [ -f ".env_example" ]; then
        cp .env_example .env
        echo "✅ 已从 .env_example 创建 .env 文件"
    else
        echo "❌ 错误：未找到 .env_example 文件"
        echo "请确保项目包含 .env_example 文件"
        exit 1
    fi
fi

# 备份当前环境变量
echo -e "\n📦 备份当前环境变量..."
if [ -f ".env" ]; then
    # 创建备份目录（如果不存在）
    mkdir -p .env_backups
    
    # 使用时间戳创建备份文件名
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file=".env_backups/.env.backup_${timestamp}"
    
    cp .env "$backup_file"
    echo "✅ 已备份 .env 文件到 ${backup_file}"
    
    # 显示最近的备份
    echo -e "\n📋 最近的备份文件："
    ls -t .env_backups/.env.backup_* | head -n 5
fi

# 询问并更新 MINING_PUBKEY
echo -e "\n🔑 请输入你的挖矿公钥 (MINING_PUBKEY)："
read -r mining_pubkey
if [ -n "$mining_pubkey" ]; then
    # 如果 .env 中已有 MINING_PUBKEY，则更新它
    if grep -q "^MINING_PUBKEY=" .env; then
        sed -i "s|^MINING_PUBKEY=.*$|MINING_PUBKEY=$mining_pubkey|" .env
    else
        # 如果不存在，则添加到文件末尾
        echo "MINING_PUBKEY=$mining_pubkey" >> .env
    fi
    echo "✅ 已更新挖矿公钥"
else
    echo "⚠️ 未输入挖矿公钥，保持原有配置"
fi

# 拉取最新代码
echo -e "\n📥 拉取最新代码..."
git pull

# 重新编译和安装
echo -e "\n🔧 重新编译和安装组件..."
make build
make install-hoonc
make install-nockchain-wallet
make install-nockchain

# 更新环境变量
echo -e "\n🔄 更新环境变量..."
source ~/.bashrc

echo -e "\n✅ 更新完成！"
echo -e "\n📝 后续步骤："
echo "1. 如果节点正在运行，需要重启节点："
echo "   screen -r leader   # 或 screen -r follower"
echo "   按 Ctrl+C 停止当前节点"
echo "   然后运行 make run-nockchain-leader 或 make run-nockchain-follower"
echo -e "\n2. 如果遇到问题，可以查看备份的环境变量："
echo "   ls -t .env_backups/.env.backup_* | head -n 5  # 查看最近的5个备份" 