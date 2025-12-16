#!/bin/bash

# =============================================================================
# Readarr to Bark iOS Notification Script
# =============================================================================
# This script sends Readarr event notifications to a Bark iOS server.
# Supports: On Grab, On Download, On Upgrade, On Health Issue events
#
# Setup Instructions:
# 1. Edit the configuration section below with your Bark server details
# 2. Make this script executable: chmod +x readarr-bark-notify.sh
# 3. In Readarr: Settings > Connect > Add > Custom Script
# 4. Set the path to this script
# 5. Enable the events you want notifications for
# =============================================================================

# -----------------------------------------------------------------------------
# CONFIGURATION - Edit these values
# -----------------------------------------------------------------------------

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared Bark configuration
if [ -f "$SCRIPT_DIR/bark.conf" ]; then
    source "$SCRIPT_DIR/bark.conf"
else
    echo "ERROR: bark.conf not found in $SCRIPT_DIR"
    echo "Please create bark.conf with BARK_SERVER, BARK_KEY, and BARK_SOUND settings"
    exit 1
fi

# Application-specific settings
BARK_GROUP="ReadarrAB"
BARK_ICON="https://readarr.com/img/logo.png"

# -----------------------------------------------------------------------------
# Script Logic - No need to edit below this line
# -----------------------------------------------------------------------------

# Check if Bark key is configured
if [ "$BARK_KEY" = "YOUR_DEVICE_KEY_HERE" ] || [ -z "$BARK_KEY" ]; then
    echo "ERROR: BARK_KEY is not configured. Please edit bark.conf and set your Bark device key."
    exit 1
fi

# Function to send notification to Bark
send_bark_notification() {
    local title="$1"
    local body="$2"
    local url="$3"
    local level="$4"  # Notification priority: active, timeSensitive, passive

    # Build JSON payload
    local json_payload=$(cat <<EOF
{
    "title": "$title",
    "body": "$body",
    "device_key": "$BARK_KEY",
    "group": "$BARK_GROUP"
EOF
)

    # Add optional parameters
    if [ -n "$BARK_SOUND" ]; then
        json_payload+=",\"sound\": \"$BARK_SOUND\""
    fi

    if [ -n "$BARK_ICON" ]; then
        json_payload+=",\"icon\": \"$BARK_ICON\""
    fi

    if [ -n "$url" ]; then
        json_payload+=",\"url\": \"$url\""
    fi

    if [ -n "$level" ]; then
        json_payload+=",\"level\": \"$level\""
    fi

    json_payload+="}"

    # Send to Bark server
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "${BARK_SERVER}/push")

    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n-1)

    if [ "$http_code" = "200" ]; then
        echo "Notification sent successfully to Bark"
        return 0
    else
        echo "Failed to send notification. HTTP Code: $http_code"
        echo "Response: $response_body"
        return 1
    fi
}

# Escape special characters for JSON
escape_json() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g' | tr -d '\n\r'
}

# -----------------------------------------------------------------------------
# Event Handlers
# -----------------------------------------------------------------------------

case "$readarr_eventtype" in
    Grab)
        title="📚 ReadarrAB: Book Grabbed"
        body="$readarr_author_name - $readarr_book_title
Quality: ${readarr_release_quality}
Indexer: ${readarr_release_indexer}
Size: ${readarr_release_size}"

        # Build Readarr URL
        if [ -n "$READARR_URL" ] && [ -n "$readarr_book_id" ]; then
            url="${READARR_URL}/book/${readarr_book_id}"
        else
            url="$READARR_URL"
        fi

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$url")

        send_bark_notification "$title" "$body" "$url" ""
        ;;

    Download)
        title="✅ ReadarrAB: Book Downloaded"
        body="$readarr_author_name - $readarr_book_title
Quality: ${readarr_bookfile_quality}
Path: ${readarr_bookfile_path}"

        # Build Readarr URL
        if [ -n "$READARR_URL" ] && [ -n "$readarr_book_id" ]; then
            url="${READARR_URL}/book/${readarr_book_id}"
        else
            url="$READARR_URL"
        fi

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$url")

        send_bark_notification "$title" "$body" "$url" ""
        ;;

    Upgrade)
        title="⬆️ ReadarrAB: Book Upgraded"
        body="$readarr_author_name - $readarr_book_title
Old Quality: ${readarr_bookfile_previousquality}
New Quality: ${readarr_bookfile_quality}"

        # Build Readarr URL
        if [ -n "$READARR_URL" ] && [ -n "$readarr_book_id" ]; then
            url="${READARR_URL}/book/${readarr_book_id}"
        else
            url="$READARR_URL"
        fi

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$url")

        send_bark_notification "$title" "$body" "$url" ""
        ;;

    Health)
        # Determine severity emoji
        case "$readarr_health_issue_level" in
            Error)
                emoji="🔴"
                ;;
            Warning)
                emoji="⚠️"
                ;;
            *)
                emoji="ℹ️"
                ;;
        esac

        title="$emoji ReadarrAB Health: $readarr_health_issue_level"
        body="Type: $readarr_health_issue_type
Message: $readarr_health_issue_message
Wiki: $readarr_health_issue_wiki"

        # Build URL - prefer Readarr system status page over wiki
        if [ -n "$READARR_URL" ]; then
            url="${READARR_URL}/system/status"
        else
            url="$readarr_health_issue_wiki"
        fi

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$url")

        # Health issues are time-sensitive
        send_bark_notification "$title" "$body" "$url" "timeSensitive"
        ;;

    Test)
        title="🧪 ReadarrAB: Test Notification"
        body="This is a test notification from Readarr to Bark. If you're seeing this, the connection is working! 🎉"

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$READARR_URL")

        send_bark_notification "$title" "$body" "$url" ""
        ;;

    *)
        echo "Unknown event type: $readarr_eventtype"
        echo "Available Readarr environment variables:"
        env | grep ^readarr_ | sort
        exit 1
        ;;
esac

exit 0
