#!/bin/bash

DEVICE_IP=$1
INTERFACE=$2
CREDENTIALS=$3
OUTPUT_FILE=$4

# Extract username and password from credentials (format: username:password)
USERNAME=$(echo "$CREDENTIALS" | cut -d':' -f1)
PASSWORD=$(echo "$CREDENTIALS" | cut -d':' -f2)

# Use sshpass to automate SSH login (install sshpass if needed: sudo apt install sshpass)
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$DEVICE_IP" "show full-configuration | grep -A 10 \"config system interface\" | grep -A 5 \"$INTERFACE\"" > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Backup for interface $INTERFACE saved to $OUTPUT_FILE"
else
    echo "Failed to backup interface $INTERFACE" >&2
    exit 1
fi
