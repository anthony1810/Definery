#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

FAILED=0
PASSED=0

run_test() {
    local name="$1"
    local cmd="$2"

    echo ""
    echo "${BOLD}=== $name ===${RESET}"
    if eval "$cmd"; then
        echo "${GREEN}PASSED${RESET}: $name"
        ((PASSED++))
    else
        echo "${RED}FAILED${RESET}: $name"
        ((FAILED++))
    fi
}

echo "${BOLD}Running all Definery tests...${RESET}"

# SPM package tests (macOS)
run_test "WordFeature (build)" "swift build --package-path '$PROJECT_DIR/Modules/WordFeature'"
run_test "WordAPI" "swift test --package-path '$PROJECT_DIR/Modules/WordAPI'"
run_test "WordCache" "swift test --package-path '$PROJECT_DIR/Modules/WordCache'"
run_test "WordCacheInfrastructure" "swift test --package-path '$PROJECT_DIR/Modules/WordCacheInfrastructure'"

# iOS app tests
run_test "Definery-iOS" "xcodebuild test \
    -project '$PROJECT_DIR/Definery.xcodeproj' \
    -scheme Definery-iOS \
    -testPlan Definery-iOS \
    -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.0' \
    CODE_SIGN_IDENTITY='' CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=YES \
    2>&1 | tail -20"

echo ""
echo "${BOLD}=============================${RESET}"
echo "${GREEN}Passed: $PASSED${RESET}  ${RED}Failed: $FAILED${RESET}"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
