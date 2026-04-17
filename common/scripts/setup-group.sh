#!/bin/bash

set -e

SERVER_IP="${NODE_IP_FOR_DEEPFLOW:-$(grep NODE_IP_FOR_DEEPFLOW .env | cut -d= -f2)}"
SERVER_PORT="30417"
GROUP_NAME="sekawan"
DOMAIN_NAME="legacy-host"
CONFIG_FILE="common/config/agent-group/group-config.yaml"
DEEPFLOWCTL_VER=$(echo "${DEEPFLOW_VERSION:-$(grep DEEPFLOW_VERSION .env | cut -d= -f2)}" | sed 's/^v//')

# Setup deepflow-ctl kalau belum ada
if ! command -v deepflow-ctl &> /dev/null; then
    echo "deepflow-ctl tidak ditemukan, memulai proses download..."
    curl -o /usr/bin/deepflow-ctl \
    "https://deepflow-ce.oss-cn-beijing.aliyuncs.com/bin/ctl/$DEEPFLOWCTL_VER/linux/$(arch \
    | sed 's|x86_64|amd64|' | sed 's|aarch64|arm64|')/deepflow-ctl"
    chmod a+x /usr/bin/deepflow-ctl
fi

# Buat agent group dan konfigurasi
deepflow-ctl agent-group create "$GROUP_NAME"
GROUP_ID=$(deepflow-ctl agent-group list | awk 'NR>1 && $1=="'$GROUP_NAME'" {print $2}')
deepflow-ctl agent-group create "$GROUP_ID" --config-file "$CONFIG_FILE"