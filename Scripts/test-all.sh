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

    printf "\n"
    printf "${BOLD}=== %s ===${RESET}\n" "$name"
    if eval "$cmd"; then
        printf "${GREEN}PASSED${RESET}: %s\n" "$name"
        ((PASSED++)) || true
    else
        printf "${RED}FAILED${RESET}: %s\n" "$name"
        ((FAILED++)) || true
    fi
}

printf "${BOLD}Running all Definery tests...${RESET}\n"

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

printf "\n"
printf "${BOLD}=============================${RESET}\n"
printf "${GREEN}Passed: %d${RESET}  ${RED}Failed: %d${RESET}\n" "$PASSED" "$FAILED"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
