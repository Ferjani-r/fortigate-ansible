#!/bin/bash

DEVICE_IP=$1
INTERFACE=$2
TOKEN=$3
OUTPUT_FILE=$4

# Use curl to fetch interface config via FortiGate REST API
# Note: Replace the URL and endpoint with your FortiGate's API path
curl -k -X GET -H "Authorization: Bearer $TOKEN" "https://$DEVICE_IP/api/v2/monitor/system/interface/$INTERFACE/config" -o "$OUTPUT_FILE"

if [ $? -eq 0 ] && [ -s "$OUTPUT_FILE" ]; then
    echo "Backup for interface $INTERFACE saved to $OUTPUT_FILE"
else
    echo "Failed to backup interface $INTERFACE" >&2
    exit 1
fi
