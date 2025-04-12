#!/bin/bash
set -e

# Usage: ./git-tag.sh <version> [message]

# Get parameters
VERSION="$1"
MESSAGE="$2"

# Check if version is provided
if [ -z "$VERSION" ]; then
    echo "Error: Version is required."
    echo "Usage: ./git-tag.sh <version> [message]"
    exit 1
fi

# Default message to version if not provided
if [ -z "$MESSAGE" ]; then
    MESSAGE="$VERSION"
fi

# Create the annotated tag
git tag -a "$VERSION" -m "$MESSAGE"

# Push the tag to the remote
git push origin "$VERSION"

echo "✅ Tagged repository with version $VERSION and pushed to the remote repository."

