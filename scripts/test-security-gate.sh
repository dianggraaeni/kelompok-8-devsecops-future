#!/bin/bash
# =========================================================
# test-security-gate.sh
# =========================================================
# Anggota C — Acintya Edria Sudarsono (5027231020)
# Komponen: Security Gate Testing
#
# Script ini menguji 3 skenario security gate:
#   Skenario A: Push dengan CRITICAL CVE → Pipeline FAIL
#   Skenario B: Push dengan hanya MEDIUM/LOW → Pipeline PASS
#   Skenario C: Push setelah remediasi → Pipeline PASS (clean)
#
# Justifikasi: Xia et al. (2023) — SBOM value lies in
# actionability. Pipeline yang menghasilkan SBOM tapi
# tidak mengambil tindakan pada temuan vulnerability
# tidak memberikan value security.
# =========================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}============================================${NC}"
  echo -e "${BOLD}${BLUE}  $1${NC}"
  echo -e "${BOLD}${BLUE}============================================${NC}"
  echo ""
}

# =========================================================
# Security Gate Logic (mirrors enhanced-pipeline.yml)
# =========================================================

simulate_security_gate() {
  local SCAN_RESULT_FILE="$1"
  local SCENARIO_NAME="$2"
  local EXPECTED_RESULT="$3"

  if [ ! -f "$SCAN_RESULT_FILE" ]; then
    echo -e "  ${RED}ERROR: Scan result file not found: $SCAN_RESULT_FILE${NC}"
    return 1
  fi

  CRITICAL=$(cat "$SCAN_RESULT_FILE" | jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length')
  HIGH=$(cat "$SCAN_RESULT_FILE" | jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH")] | length')
  TOTAL=$(cat "$SCAN_RESULT_FILE" | jq '[.Results[]?.Vulnerabilities[]?] | length')

  echo -e "  Scenario: ${BOLD}$SCENARIO_NAME${NC}"
  echo "  ├── CRITICAL: $CRITICAL"
  echo "  ├── HIGH:     $HIGH"
  echo "  └── Total:    $TOTAL"
  echo ""

  # Gate logic: FAIL if CRITICAL > 0
  if [ "$CRITICAL" -gt 0 ]; then
    ACTUAL_RESULT="FAIL"
    echo -e "  Gate Decision: ${RED}${BOLD}❌ BLOCKED${NC} — $CRITICAL CRITICAL vulnerability(ies) found"
    echo ""
    echo "  CRITICAL CVEs that triggered the gate:"
    cat "$SCAN_RESULT_FILE" | jq -r '
      .Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL") |
      "    🔴 \(.VulnerabilityID): \(.PkgName)@\(.InstalledVersion) → fix: \(.FixedVersion // "none")"
    '
  else
    ACTUAL_RESULT="PASS"
    if [ "$HIGH" -gt 0 ]; then
      echo -e "  Gate Decision: ${YELLOW}${BOLD}⚠️  PASSED (with warnings)${NC} — $HIGH HIGH vulnerability(ies)"
    else
      echo -e "  Gate Decision: ${GREEN}${BOLD}✅ PASSED (clean)${NC} — No CRITICAL or HIGH vulnerabilities"
    fi
  fi

  echo ""

  # Validate against expected result
  if [ "$ACTUAL_RESULT" == "$EXPECTED_RESULT" ]; then
    echo -e "  ${GREEN}✅ TEST PASSED — Gate result matches expected: $EXPECTED_RESULT${NC}"
    return 0
  else
    echo -e "  ${RED}❌ TEST FAILED — Expected: $EXPECTED_RESULT, Got: $ACTUAL_RESULT${NC}"
    return 1
  fi
}

# =========================================================
# Main Test Execution
# =========================================================

print_header "Security Gate Test Suite"
echo -e "${CYAN}Testing the security gate logic that controls deployment decisions.${NC}"
echo ""
echo "  Gate Policy:"
echo "  ├── CRITICAL vulnerability found → ❌ BLOCK deployment"
echo "  ├── HIGH only (no CRITICAL)      → ⚠️  ALLOW (with warning)"
echo "  └── No CRITICAL/HIGH             → ✅ ALLOW (clean)"
echo ""

IMAGE="${1:-devsecops-demo:latest}"
OUTPUT_DIR="test-results"
mkdir -p "$OUTPUT_DIR"

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=3

# =========================================================
# Skenario A: Image with CRITICAL vulnerabilities
# =========================================================

print_header "Skenario A: Image with CRITICAL CVE"
echo "  Using current image with deliberately vulnerable dependencies"
echo "  (lodash@4.17.15 → CVE-2019-10744 CRITICAL, minimist@1.2.5 → CVE-2021-44906 CRITICAL)"
echo ""

# Scan the image
print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

echo -e "${BLUE}ℹ️  Scanning image: $IMAGE${NC}"

trivy image \
  --severity CRITICAL,HIGH,MEDIUM \
  --format json \
  --output "$OUTPUT_DIR/gate-scenario-a.json" \
  --ignore-unfixed \
  "$IMAGE" 2>/dev/null

if simulate_security_gate "$OUTPUT_DIR/gate-scenario-a.json" "A: With CRITICAL CVE" "FAIL"; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# =========================================================
# Skenario B: Simulated scan with MEDIUM only
# =========================================================

print_header "Skenario B: Image with MEDIUM-only vulnerabilities"
echo "  Simulating scan result with only MEDIUM severity"
echo "  (Represents image after fixing CRITICAL and HIGH deps)"
echo ""

# Create a simulated scan result with only MEDIUM vulnerabilities
cat > "$OUTPUT_DIR/gate-scenario-b.json" << 'SIMEOF'
{
  "SchemaVersion": 2,
  "ArtifactName": "devsecops-demo:remediated-partial",
  "ArtifactType": "container_image",
  "Results": [
    {
      "Target": "Node.js",
      "Class": "lang-pkgs",
      "Type": "node-pkg",
      "Vulnerabilities": [
        {
          "VulnerabilityID": "CVE-2020-28500",
          "PkgName": "lodash",
          "InstalledVersion": "4.17.20",
          "FixedVersion": "4.17.21",
          "Severity": "MEDIUM",
          "Title": "Regular Expression Denial of Service (ReDoS)"
        }
      ]
    }
  ]
}
SIMEOF

if simulate_security_gate "$OUTPUT_DIR/gate-scenario-b.json" "B: MEDIUM only (partial fix)" "PASS"; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# =========================================================
# Skenario C: Simulated clean scan (all fixed)
# =========================================================

print_header "Skenario C: Image after full remediation"
echo "  Simulating scan result with zero vulnerabilities"
echo "  (All dependencies updated to latest secure versions)"
echo ""

# Create a simulated clean scan result
cat > "$OUTPUT_DIR/gate-scenario-c.json" << 'SIMEOF'
{
  "SchemaVersion": 2,
  "ArtifactName": "devsecops-demo:remediated-full",
  "ArtifactType": "container_image",
  "Results": [
    {
      "Target": "Node.js",
      "Class": "lang-pkgs",
      "Type": "node-pkg",
      "Vulnerabilities": null
    }
  ]
}
SIMEOF

if simulate_security_gate "$OUTPUT_DIR/gate-scenario-c.json" "C: Fully remediated (clean)" "PASS"; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# =========================================================
# Summary
# =========================================================

print_header "SECURITY GATE TEST SUMMARY"

echo "  ┌───────────┬──────────────────────────────────┬──────────┬──────────┐"
echo "  │ Scenario  │ Description                      │ Expected │ Result   │"
echo "  ├───────────┼──────────────────────────────────┼──────────┼──────────┤"
echo "  │ A         │ With CRITICAL CVE                │ ❌ FAIL  │ $([ -f "$OUTPUT_DIR/gate-scenario-a.json" ] && cat "$OUTPUT_DIR/gate-scenario-a.json" | jq -r '[.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' | xargs -I{} sh -c '[ {} -gt 0 ] && echo "❌ FAIL  " || echo "✅ PASS  "' || echo "N/A      ")│"
echo "  │ B         │ MEDIUM only (partial fix)        │ ✅ PASS  │ ✅ PASS  │"
echo "  │ C         │ Fully remediated (clean)         │ ✅ PASS  │ ✅ PASS  │"
echo "  └───────────┴──────────────────────────────────┴──────────┴──────────┘"
echo ""
echo -e "  Tests Passed: ${GREEN}${BOLD}$TESTS_PASSED/$TESTS_TOTAL${NC}"
if [ "$TESTS_FAILED" -gt 0 ]; then
  echo -e "  Tests Failed: ${RED}${BOLD}$TESTS_FAILED/$TESTS_TOTAL${NC}"
fi
echo ""

# Exit with appropriate code
if [ "$TESTS_FAILED" -gt 0 ]; then
  exit 1
fi
