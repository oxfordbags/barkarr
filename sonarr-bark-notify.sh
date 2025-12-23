#!/bin/bash

# =============================================================================
# Sonarr to Bark iOS Notification Script
# =============================================================================
# This script sends Sonarr event notifications to a Bark iOS server.
# Supports: On Grab, On Download, On Upgrade, On Health Issue events
#
# Setup Instructions:
# 1. Edit the configuration section below with your Bark server details
# 2. Make this script executable: chmod +x sonarr-bark-notify.sh
# 3. In Sonarr: Settings > Connect > Add > Custom Script
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
BARK_GROUP="Sonarr"
BARK_ICON="https://sonarr.tv/img/logo.png"

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
    printf '%s' "$1" | sed ':a;N;$!ba;s/\\/\\\\/g;s/"/\\"/g;s/	/\\t/g;s/\n/\\n/g'
}

# -----------------------------------------------------------------------------
# Event Handlers
# -----------------------------------------------------------------------------

case "$sonarr_eventtype" in
    Grab)
        title="📺 Sonarr: Episode Grabbed"
        body="$sonarr_series_title - S${sonarr_release_seasonnumber}E${sonarr_release_episodenumbers}
${sonarr_release_episodetitles}
Quality: ${sonarr_release_quality}
Indexer: ${sonarr_release_indexer}"

        # Build Sonarr URL
        if [ -n "$SONARR_URL" ] && [ -n "$sonarr_series_id" ]; then
            url="${SONARR_URL}/series/${sonarr_series_id}"
        else
            url="$SONARR_URL"
        fi

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$url")

        send_bark_notification "$title" "$body" "$url" ""
        ;;

    Download)
        title="✅ Sonarr: Episode Downloaded"

        # Handle multiple episodes
        if [ -n "$sonarr_episodefile_episodenumbers" ]; then
            episodes="S${sonarr_episodefile_seasonnumber}E${sonarr_episodefile_episodenumbers}"
        else
            episodes="S${sonarr_episodefile_seasonnumber}E${sonarr_episodefile_episodenumber}"
        fi

        body="$sonarr_series_title - $episodes
${sonarr_episodefile_episodetitles}
Quality: ${sonarr_episodefile_quality}"

        # Build Sonarr URL
        if [ -n "$SONARR_URL" ] && [ -n "$sonarr_series_id" ]; then
            url="${SONARR_URL}/series/${sonarr_series_id}"
        else
            url="$SONARR_URL"
        fi

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$url")

        send_bark_notification "$title" "$body" "$url" ""
        ;;

    Upgrade)
        title="⬆️ Sonarr: Episode Upgraded"

        # Handle multiple episodes
        if [ -n "$sonarr_episodefile_episodenumbers" ]; then
            episodes="S${sonarr_episodefile_seasonnumber}E${sonarr_episodefile_episodenumbers}"
        else
            episodes="S${sonarr_episodefile_seasonnumber}E${sonarr_episodefile_episodenumber}"
        fi

        body="$sonarr_series_title - $episodes
${sonarr_episodefile_episodetitles}
Old Quality: ${sonarr_deletedrelativepaths}
New Quality: ${sonarr_episodefile_quality}"

        # Build Sonarr URL
        if [ -n "$SONARR_URL" ] && [ -n "$sonarr_series_id" ]; then
            url="${SONARR_URL}/series/${sonarr_series_id}"
        else
            url="$SONARR_URL"
        fi

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$url")

        send_bark_notification "$title" "$body" "$url" ""
        ;;

    Health)
        # Determine severity emoji
        case "$sonarr_health_issue_level" in
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

        title="$emoji Sonarr Health: $sonarr_health_issue_level"
        body="Type: $sonarr_health_issue_type
Message: $sonarr_health_issue_message
Wiki: $sonarr_health_issue_wiki"

        # Build URL - prefer Sonarr system status page over wiki
        if [ -n "$SONARR_URL" ]; then
            url="${SONARR_URL}/system/status"
        else
            url="$sonarr_health_issue_wiki"
        fi

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$url")

        # Health issues are time-sensitive
        send_bark_notification "$title" "$body" "$url" "timeSensitive"
        ;;

    Test)
        title="🧪 Sonarr: Test Notification"
        body="This is a test notification from Sonarr to Bark. If you're seeing this, the connection is working! 🎉"

        # Escape for JSON
        title=$(escape_json "$title")
        body=$(escape_json "$body")
        url=$(escape_json "$SONARR_URL")

        send_bark_notification "$title" "$body" "$url" ""
        ;;

    *)
        echo "Unknown event type: $sonarr_eventtype"
        echo "Available Sonarr environment variables:"
        env | grep ^sonarr_ | sort
        exit 1
        ;;
esac

exit 0
