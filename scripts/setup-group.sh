#!/bin/bash

set -e

SERVER_IP="${NODE_IP_FOR_DEEPFLOW:-$(grep NODE_IP_FOR_DEEPFLOW .env | cut -d= -f2)}"
SERVER_PORT="30417"
GROUP_NAME="sekawan"
DOMAIN_NAME="legacy-host"
CONFIG_FILE="common/config/agent-group/group-config.yaml"

echo "DeepFlow Server: $SERVER_IP:$SERVER_PORT"

# create domain for legacy host sync
echo "Creating domain: $DOMAIN_NAME"
curl -s -X POST "http://$SERVER_IP:$SERVER_PORT/v1/domains/" \
  -H "Content-Type: application/json" \
  -d "{\"NAME\": \"$DOMAIN_NAME\", \"TYPE\": 23}" | python3 -m json.tool || true

# create agent group
echo "Creating agent group: $GROUP_NAME"
RESULT=$(curl -s -X POST "http://$SERVER_IP:$SERVER_PORT/v1/vtap-groups/" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$GROUP_NAME\"}")

echo "$RESULT" | python3 -m json.tool || true

# get agent group LCUUID and SHORT_UUID
echo "Fetching agent group info..."
GROUP_INFO=$(curl -s "http://$SERVER_IP:$SERVER_PORT/v1/vtap-groups/" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin).get('DATA', [])
for g in data:
    if g['NAME'] == '$GROUP_NAME':
        print(g.get('LCUUID', ''))
        print(g.get('SHORT_UUID', ''))
        break
" 2>/dev/null)

LCUUID=$(echo "$GROUP_INFO" | sed -n '1p')
SHORT_UUID=$(echo "$GROUP_INFO" | sed -n '2p')

if [ -z "$LCUUID" ]; then
  echo "ERROR: Could not find agent group. Check if deepflow-server is running."
  exit 1
fi

echo "Agent group LCUUID: $LCUUID"
echo "Agent group ID: $SHORT_UUID"
echo ""
echo "Use this in your agent's deepflow-agent.yaml:"
echo "    vtap-group-id-request: '$SHORT_UUID'"
echo ""

# push agent group config via REST API (YAML body)
# Ref: https://github.com/deepflowio/deepflow/blob/main/server/controller/http/router/vtap_group_config.go
echo "Pushing agent group config..."
RESULT=$(curl -s -X POST "http://$SERVER_IP:$SERVER_PORT/v1/vtap-group-configuration/advanced/" \
  -H "Content-Type: application/x-yaml" \
  -d "vtap_group_id: $SHORT_UUID
$(cat $CONFIG_FILE)")

echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"
echo ""
echo "Done! Agent group '$GROUP_NAME' created with ID: $SHORT_UUID"