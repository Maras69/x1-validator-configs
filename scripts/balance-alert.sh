#!/bin/bash
# Identity Balance Alert Script
# Checks all validator identity accounts and alerts if below threshold

THRESHOLD=0.01  # XNT - alert if balance below this
LOG_FILE="/home/marask/balance-alerts.log"
RPC="https://xolana.xen.network"

# Full identity addresses
declare -A IDENTITIES=(
    ["marask1"]="2sUYt9TgC2GT48eLbL3w5dpFJNxZtN3kKc9KWX267GPh"
    ["marask2"]="HErms883jHQR7vNqcg7PMcVJbduDHtmZRPgWfDYiDvmu"
    ["marask3"]="3pAiLeVRoyiWPfsMSw2eX3UCbf9z59gryDf5aZbvA1ub"
    ["marask4"]="C1EfjvmABMuWhkbTxT77ryC5H3vJMG66z13X9NrNLqfx"
    ["marask5"]="52vNuGHEmCzjTkcir6jWffpzLJvu1VYJz4mnM4Bbfu58"
    ["marask6"]="BHKn9CHLJszou6df36PdsLJxpCZyMCUb4ZUvHpRpvAwu"
    ["marask7"]="FySKnu78y2i7cvK41q7g52VukE23uFozXQ2rGkgJnztV"
)

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
ALERTS=""

echo "[$TIMESTAMP] === Balance Check ===" >> "$LOG_FILE"

for server in "${!IDENTITIES[@]}"; do
    addr="${IDENTITIES[$server]}"
    
    # Get balance via RPC
    response=$(curl -s -X POST "$RPC" -H "Content-Type: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"getBalance\",\"params\":[\"$addr\"]}" 2>/dev/null)
    
    balance=$(echo "$response" | grep -o '"value":[0-9]*' | cut -d: -f2)
    
    if [ -n "$balance" ] && [ "$balance" != "null" ]; then
        # Convert lamports to XNT (divide by 1e9)
        xnt=$(echo "scale=6; $balance / 1000000000" | bc)
        
        if (( $(echo "$xnt < $THRESHOLD" | bc -l) )); then
            msg="WARNING: $server ($addr) LOW BALANCE: $xnt XNT"
            echo "[$TIMESTAMP] $msg" >> "$LOG_FILE"
            ALERTS="$ALERTS\n$msg"
        else
            echo "[$TIMESTAMP] OK: $server = $xnt XNT" >> "$LOG_FILE"
        fi
    else
        echo "[$TIMESTAMP] ERROR: Could not fetch $server balance" >> "$LOG_FILE"
    fi
done

# If there are alerts, print them
if [ -n "$ALERTS" ]; then
    echo -e "\n🚨 LOW BALANCE ALERTS 🚨$ALERTS"
    exit 1
else
    echo "All identity balances OK (above $THRESHOLD XNT)"
    exit 0
fi
