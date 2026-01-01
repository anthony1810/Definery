#!/bin/bash

# Xcode Cloud post-build script to trigger GitHub Actions workflows
# This script runs after xcodebuild completes in Xcode Cloud

# Exit if GITHUB_TOKEN is not set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Warning: GITHUB_TOKEN not set. Skipping GitHub Actions trigger."
    exit 0
fi

REPO="anthony1810/Definery"

# Determine which workflow to trigger based on CI_WORKFLOW (case-insensitive)
WORKFLOW_LOWER=$(echo "$CI_WORKFLOW" | tr '[:upper:]' '[:lower:]')

case "$WORKFLOW_LOWER" in
    *"release"*)
        EVENT_TYPE="xcc-release"
        echo "Triggering release workflow..."
        ;;
    *"ios"*)
        EVENT_TYPE="xcc-test-ios"
        echo "Triggering iOS test workflow..."
        ;;
    *"macos"*)
        EVENT_TYPE="xcc-test-macos"
        echo "Triggering macOS test workflow..."
        ;;
    *)
        echo "Unknown workflow: $CI_WORKFLOW. Skipping GitHub Actions trigger."
        exit 0
        ;;
esac

# Trigger the GitHub Actions workflow
curl -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$REPO/dispatches" \
    -d "{\"event_type\":\"$EVENT_TYPE\"}"

echo "GitHub Actions workflow triggered: $EVENT_TYPE"
