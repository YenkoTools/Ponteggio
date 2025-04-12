#!/bin/bash
set -e

# ------------------------
# Update version.json
# ------------------------

# Get script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Fetch the latest tags
git fetch --tags

# Get the most recent tag
GIT_TAG=$(git describe --tags --abbrev=0 || echo "v0.0.0")

# Get short commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)

# Get hostname and current user
COMPUTER_NAME=$(hostname)
CURRENT_USER=$(whoami)

# Build date info
NOW=$(date +%s)
MIDNIGHT=$(date -d "$(date +%F) 00:00:00" +%s)
MINUTES_SINCE_MIDNIGHT=$(( (NOW - MIDNIGHT) / 60 ))
BUILD_TICK=$MINUTES_SINCE_MIDNIGHT

# Format build date
BUILD_DATE=$(date --iso-8601=seconds)

# Build number (YYYYMMDD.Tick)
DATE=$(date +%Y%m%d)
BUILD_NUMBER="${DATE}.${BUILD_TICK}"

# Get branch and full commit hash
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_HEAD=$(git rev-parse HEAD)

# Print build number
echo "Build Number: $BUILD_NUMBER"

# Create JSON object
JSON=$(jq -n \
    --arg BuildNumber "$BUILD_NUMBER" \
    --arg BuildDate "$BUILD_DATE" \
    --arg BuildHost "$COMPUTER_NAME" \
    --arg CommitHash "$COMMIT_HASH" \
    --arg CurrentUser "$CURRENT_USER" \
    --arg GitBranch "$GIT_BRANCH" \
    --arg GitHead "$GIT_HEAD" \
    --arg GitTag "$GIT_TAG" \
    '{
        BuildNumber: $BuildNumber,
        BuildDate: $BuildDate,
        BuildHost: $BuildHost,
        CommitHash: $CommitHash,
        CurrentUser: $CurrentUser,
        GitBranch: $GitBranch,
        GitHead: $GitHead,
        GitTag: $GitTag
    }')

# Write to version.json
OUTPUT_PATH="$SCRIPT_DIR/src/Api/wwwroot/version.json"
mkdir -p "$(dirname "$OUTPUT_PATH")"
echo "$JSON" > "$OUTPUT_PATH"

echo "✅ version.json written to $OUTPUT_PATH"

