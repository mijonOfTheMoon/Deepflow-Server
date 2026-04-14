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
  -d "{\"name\": \"$DOMAIN_NAME\", \"type\": \"agent_sync\"}" | python3 -m json.tool || true

# create agent group
echo "Creating agent group: $GROUP_NAME"
RESULT=$(curl -s -X POST "http://$SERVER_IP:$SERVER_PORT/v1/vtap-groups/" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$GROUP_NAME\"}")

echo "$RESULT" | python3 -m json.tool || true

# get agent group ID
echo "Fetching agent group ID..."
GROUP_ID=$(curl -s "http://$SERVER_IP:$SERVER_PORT/v1/vtap-groups/" | \
  python3 -c "import sys,json; groups=json.load(sys.stdin).get('DATA',[]); print(next((g['SHORT_UUID'] for g in groups if g['NAME']=='$GROUP_NAME'),''))" 2>/dev/null)

if [ -z "$GROUP_ID" ]; then
  echo "ERROR: Could not find agent group ID. Check if deepflow-server is running."
  exit 1
fi

echo "Agent group ID: $GROUP_ID"
echo ""
echo "Use this in your agent's deepflow-agent.yaml:"
echo "    vtap-group-id-request: '$GROUP_ID'"
echo ""

# push agent group config
echo "Pushing agent group config..."
docker exec deepflow-server deepflow-ctl agent-group-config create "$GROUP_ID" \
  -f <(cat "$CONFIG_FILE") 2>/dev/null || \
docker exec -i deepflow-server deepflow-ctl agent-group-config create "$GROUP_ID" -f - < "$CONFIG_FILE"

echo ""
echo "Done!"