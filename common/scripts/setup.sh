#!/bin/bash

set -e

CTL="common/bin/deepflow-ctl"
GROUP_NAME="sekawan"
GROUP_ID="g-sekawan123"
DOMAIN_CONFIG="common/config/deepflow-agent/domain-config.yaml"
GROUP_CONFIG="common/config/deepflow-agent/group-config.yaml"
DEEPFLOWCTL_VER="${DEEPFLOW_VERSION:-$(grep DEEPFLOW_VERSION .env | cut -d= -f2)}"

# Install deepflow-ctl if not present
if [ ! -f "$CTL" ]; then
    echo "Installing deepflow-ctl $DEEPFLOWCTL_VER..."
    curl -o "$CTL" \
        "https://deepflow-ce.oss-cn-beijing.aliyuncs.com/bin/ctl/$DEEPFLOWCTL_VER/linux/$(arch \
        | sed 's|x86_64|amd64|' | sed 's|aarch64|arm64|')/deepflow-ctl"
    chmod a+x "$CTL"
fi

# Create domain if not exists
if ! $CTL domain list | grep -q "legacy-host"; then
    echo "Creating domain 'legacy-host'..."
    $CTL domain create -f "$DOMAIN_CONFIG"
else
    echo "Domain 'legacy-host' already exists, skipping."
fi

# Create agent group if not exists
if ! $CTL agent-group list | grep -q "$GROUP_ID"; then
    echo "Creating agent group '$GROUP_NAME' with ID $GROUP_ID..."
    $CTL agent-group create --id "$GROUP_ID" "$GROUP_NAME"
else
    echo "Agent group '$GROUP_ID' already exists, skipping."
fi

# Create or update agent group config
if $CTL agent-group-config list | grep -q "$GROUP_ID"; then
    echo "Updating group configuration for $GROUP_ID..."
    $CTL agent-group-config update "$GROUP_ID" -f "$GROUP_CONFIG"
else
    echo "Creating group configuration for $GROUP_ID..."
    $CTL agent-group-config create "$GROUP_ID" -f "$GROUP_CONFIG"
fi

echo "Done! Group ID: $GROUP_ID"
