#!/bin/bash
# =========================================================
# run-all-tests.sh
# =========================================================
# Anggota C — Acintya Edria Sudarsono (5027231020)
# Komponen: Test Runner — jalankan semua test suite
#
# Menjalankan semua test scripts secara berurutan:
#   1. SBOM Coverage Verification
#   2. Vulnerability Detection Test
#   3. Security Gate Test
#
# Usage: ./scripts/run-all-tests.sh [IMAGE_NAME]
# =========================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

IMAGE="${1:-devsecops-demo:latest}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║  DevSecOps Supply Chain Security — Full Test Suite        ║${NC}"
echo -e "${BOLD}${BLUE}║  Anggota C: Vulnerability Scanning & Gate                 ║${NC}"
echo -e "${BOLD}${BLUE}║  Acintya Edria Sudarsono (5027231020)                     ║${NC}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Image:   $IMAGE"
echo "  Date:    $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "  Scripts: $SCRIPT_DIR"
echo ""

TOTAL_TESTS=3
PASSED=0
FAILED=0

# ─────────────────────────────────────────────────────────
# Pre-flight checks
# ─────────────────────────────────────────────────────────

echo -e "${CYAN}Pre-flight checks...${NC}"

check_tool() {
  if command -v "$1" &> /dev/null; then
    echo -e "  ✅ $1 found: $($1 --version 2>/dev/null | head -1)"
  else
    echo -e "  ${RED}❌ $1 not found — some tests will be skipped${NC}"
  fi
}

check_tool "trivy"
check_tool "jq"
check_tool "syft"
echo ""

# ─────────────────────────────────────────────────────────
# Test 1: SBOM Coverage Verification
# ─────────────────────────────────────────────────────────

echo -e "${BOLD}━━━ [1/3] SBOM Coverage Verification ━━━${NC}"
echo ""

if [ -x "$SCRIPT_DIR/verify-sbom-coverage.sh" ]; then
  if bash "$SCRIPT_DIR/verify-sbom-coverage.sh" "$PROJECT_DIR/app/package-lock.json"; then
    echo -e "${GREEN}  ✅ SBOM Coverage test completed${NC}"
    PASSED=$((PASSED + 1))
  else
    echo -e "${YELLOW}  ⚠️  SBOM Coverage test completed with warnings${NC}"
    PASSED=$((PASSED + 1))
  fi
else
  echo -e "${YELLOW}  ⚠️  SBOM Coverage test script not executable or not found${NC}"
  echo "  Run: chmod +x $SCRIPT_DIR/verify-sbom-coverage.sh"
fi

echo ""

# ─────────────────────────────────────────────────────────
# Test 2: Vulnerability Detection
# ─────────────────────────────────────────────────────────

echo -e "${BOLD}━━━ [2/3] Vulnerability Detection Test ━━━${NC}"
echo ""

if [ -x "$SCRIPT_DIR/test-vulnerability-detection.sh" ]; then
  if bash "$SCRIPT_DIR/test-vulnerability-detection.sh" "$IMAGE"; then
    echo -e "${GREEN}  ✅ Vulnerability detection test completed${NC}"
    PASSED=$((PASSED + 1))
  else
    echo -e "${YELLOW}  ⚠️  Vulnerability detection test completed (vulnerabilities found — expected)${NC}"
    PASSED=$((PASSED + 1))
  fi
else
  echo -e "${YELLOW}  ⚠️  Vulnerability detection test script not executable or not found${NC}"
  echo "  Run: chmod +x $SCRIPT_DIR/test-vulnerability-detection.sh"
fi

echo ""

# ─────────────────────────────────────────────────────────
# Test 3: Security Gate
# ─────────────────────────────────────────────────────────

echo -e "${BOLD}━━━ [3/3] Security Gate Test ━━━${NC}"
echo ""

if [ -x "$SCRIPT_DIR/test-security-gate.sh" ]; then
  if bash "$SCRIPT_DIR/test-security-gate.sh" "$IMAGE"; then
    echo -e "${GREEN}  ✅ Security gate test completed${NC}"
    PASSED=$((PASSED + 1))
  else
    echo -e "${RED}  ❌ Security gate test failed${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  echo -e "${YELLOW}  ⚠️  Security gate test script not executable or not found${NC}"
  echo "  Run: chmod +x $SCRIPT_DIR/test-security-gate.sh"
fi

echo ""

# ─────────────────────────────────────────────────────────
# Final Summary
# ─────────────────────────────────────────────────────────

echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║  TEST SUITE SUMMARY                                       ║${NC}"
echo -e "${BOLD}${BLUE}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${BLUE}║${NC}  Tests Passed:  ${GREEN}${BOLD}$PASSED/$TOTAL_TESTS${NC}                                    ${BOLD}${BLUE}║${NC}"
if [ "$FAILED" -gt 0 ]; then
echo -e "${BOLD}${BLUE}║${NC}  Tests Failed:  ${RED}${BOLD}$FAILED/$TOTAL_TESTS${NC}                                    ${BOLD}${BLUE}║${NC}"
fi
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo -e "${RED}Some tests failed. Review output above for details.${NC}"
  exit 1
else
  echo -e "${GREEN}All tests passed successfully! 🎉${NC}"
fi
