#!/bin/bash

# Usage
# CONF_FILE="path/to/account.conf" && ./acmesh-renew-gandi-pat.sh

if [ -z "$CONF_FILE" ]; then
    echo "Error: CONF_FILE environment variable is not set."
    echo "Usage: CONF_FILE=\"/path/to/account.conf\" $0"
    exit 1
fi

CURRENT_TOKEN=$(grep "SAVED_GANDI_LIVEDNS_TOKEN" "$CONF_FILE" | cut -d"'" -f2)

if [ -z "$CURRENT_TOKEN" ]; then
    echo "Error: Could not find existing token in $CONF_FILE"
    exit 1
fi

RESPONSE=$(curl -s -X POST https://api.gandi.net/v5/organization/access-tokens \
  -H "Authorization: Bearer $CURRENT_TOKEN" \
  -H "Content-Type: application/json")

NEW_TOKEN=$(echo $RESPONSE | jq -r '.access_token')

if [ "$NEW_TOKEN" != "null" ] && [ -n "$NEW_TOKEN" ]; then
    sed -i "s/SAVED_GANDI_LIVEDNS_TOKEN='$CURRENT_TOKEN'/SAVED_GANDI_LIVEDNS_TOKEN='$NEW_TOKEN'/g" "$CONF_FILE"
    echo "Gandi PAT rotated and saved successfully."
else
    echo "API Error: Failed to rotate token. Response: $RESPONSE"
    exit 1
fi
