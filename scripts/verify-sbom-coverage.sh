#!/bin/bash
# =========================================================
# verify-sbom-coverage.sh
# =========================================================
# Anggota C — Acintya Edria Sudarsono (5027231020)
# Komponen: SBOM Coverage Verification
#
# Script ini memverifikasi bahwa SBOM yang dihasilkan Syft
# mencakup semua dependensi yang ada di package-lock.json.
#
# Justifikasi: Xia et al. (2023) mengidentifikasi "tooling
# inconsistency" sebagai barrier utama adopsi SBOM. Script
# ini memvalidasi coverage tool yang digunakan.
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

# Configuration
LOCKFILE="${1:-app/package-lock.json}"
SBOM_CDX="${2:-sbom.cdx.json}"
SBOM_SPDX="${3:-sbom.spdx.json}"

print_header() {
  echo ""
  echo -e "${BOLD}${BLUE}============================================${NC}"
  echo -e "${BOLD}${BLUE}  $1${NC}"
  echo -e "${BOLD}${BLUE}============================================${NC}"
  echo ""
}

# =========================================================
# Main
# =========================================================

print_header "SBOM Coverage Verification"

echo -e "  Lock file:  ${BOLD}$LOCKFILE${NC}"
echo -e "  SBOM (CDX): ${BOLD}$SBOM_CDX${NC}"
echo -e "  SBOM (SPDX):${BOLD}$SBOM_SPDX${NC}"
echo ""

# Check prerequisites
if ! command -v jq &> /dev/null; then
  echo -e "${RED}ERROR: jq is required but not installed${NC}"
  exit 1
fi

# =========================================================
# Step 1: Count dependencies from package-lock.json
# =========================================================

print_header "Step 1: Dependencies from package-lock.json"

if [ -f "$LOCKFILE" ]; then
  # Count all packages (excluding the root "")
  LOCKFILE_TOTAL=$(cat "$LOCKFILE" | jq '[.packages | keys[] | select(. != "")] | length')
  LOCKFILE_DIRECT=$(cat "$LOCKFILE" | jq '[.dependencies // {} | keys[]] | length')

  echo "  Total packages (direct + transitive): $LOCKFILE_TOTAL"
  echo "  Direct dependencies:                   $LOCKFILE_DIRECT"
  echo ""

  echo "  Direct dependencies:"
  cat "$LOCKFILE" | jq -r '.dependencies // {} | keys[] | "    📦 \(.)"'
else
  echo -e "${RED}  ERROR: Lock file not found: $LOCKFILE${NC}"
  echo "  Run 'cd app && npm install' first."
  exit 1
fi

# =========================================================
# Step 2: Count components in CycloneDX SBOM
# =========================================================

print_header "Step 2: Components in CycloneDX SBOM"

if [ -f "$SBOM_CDX" ]; then
  CDX_COMPONENTS=$(cat "$SBOM_CDX" | jq '.components | length')
  CDX_NPM=$(cat "$SBOM_CDX" | jq '[.components[] | select(.purl // "" | startswith("pkg:npm"))] | length')

  echo "  Total components:    $CDX_COMPONENTS"
  echo "  NPM packages:        $CDX_NPM"
  echo ""

  # Calculate coverage
  if [ "$LOCKFILE_TOTAL" -gt 0 ]; then
    CDX_COVERAGE=$(echo "scale=1; $CDX_NPM * 100 / $LOCKFILE_TOTAL" | bc 2>/dev/null || echo "N/A")
    echo -e "  Coverage (npm/lock): ${BOLD}${CDX_COVERAGE}%${NC}"
  fi
else
  echo -e "${YELLOW}  SBOM CycloneDX not found: $SBOM_CDX${NC}"
  echo "  Generate with: syft <image> -o cyclonedx-json > $SBOM_CDX"
  CDX_COMPONENTS="N/A"
  CDX_NPM="N/A"
  CDX_COVERAGE="N/A"
fi

# =========================================================
# Step 3: Count packages in SPDX SBOM
# =========================================================

print_header "Step 3: Packages in SPDX SBOM"

if [ -f "$SBOM_SPDX" ]; then
  SPDX_PACKAGES=$(cat "$SBOM_SPDX" | jq '.packages | length')
  SPDX_NPM=$(cat "$SBOM_SPDX" | jq '[.packages[] | select((.externalRefs // [])[] | .referenceLocator // "" | startswith("pkg:npm"))] | length' 2>/dev/null || echo "$SPDX_PACKAGES")

  echo "  Total packages:    $SPDX_PACKAGES"
  echo "  NPM packages:      $SPDX_NPM"
  echo ""

  if [ "$LOCKFILE_TOTAL" -gt 0 ]; then
    SPDX_COVERAGE=$(echo "scale=1; $SPDX_NPM * 100 / $LOCKFILE_TOTAL" | bc 2>/dev/null || echo "N/A")
    echo -e "  Coverage (npm/lock): ${BOLD}${SPDX_COVERAGE}%${NC}"
  fi
else
  echo -e "${YELLOW}  SBOM SPDX not found: $SBOM_SPDX${NC}"
  echo "  Generate with: syft <image> -o spdx-json > $SBOM_SPDX"
  SPDX_PACKAGES="N/A"
  SPDX_NPM="N/A"
  SPDX_COVERAGE="N/A"
fi

# =========================================================
# Step 4: Format Comparison Summary
# =========================================================

print_header "Step 4: Format Comparison (O'Donoghue et al., 2024)"

echo "  ┌──────────────────┬─────────────┬─────────────┬──────────┐"
echo "  │ Source            │ Total Pkgs  │ NPM Pkgs    │ Coverage │"
echo "  ├──────────────────┼─────────────┼─────────────┼──────────┤"
printf "  │ package-lock.json │ %-11s │ %-11s │ 100%%     │\n" "$LOCKFILE_TOTAL" "$LOCKFILE_TOTAL"
printf "  │ CycloneDX SBOM   │ %-11s │ %-11s │ %-8s │\n" "${CDX_COMPONENTS:-N/A}" "${CDX_NPM:-N/A}" "${CDX_COVERAGE:-N/A}%"
printf "  │ SPDX SBOM        │ %-11s │ %-11s │ %-8s │\n" "${SPDX_PACKAGES:-N/A}" "${SPDX_NPM:-N/A}" "${SPDX_COVERAGE:-N/A}%"
echo "  └──────────────────┴─────────────┴─────────────┴──────────┘"
echo ""

# Assessment
echo -e "  ${CYAN}Assessment:${NC}"
if [ "${CDX_COVERAGE:-0}" != "N/A" ]; then
  CDX_COV_INT=$(echo "$CDX_COVERAGE" | cut -d'.' -f1)
  if [ "${CDX_COV_INT:-0}" -ge 95 ]; then
    echo -e "  ${GREEN}✅ CycloneDX coverage ≥95% — Excellent${NC}"
  elif [ "${CDX_COV_INT:-0}" -ge 80 ]; then
    echo -e "  ${YELLOW}⚠️  CycloneDX coverage ≥80% — Good (some packages may differ in naming)${NC}"
  else
    echo -e "  ${RED}❌ CycloneDX coverage <80% — Investigate discrepancies${NC}"
  fi
fi

echo ""
echo -e "  ${CYAN}Key insight from O'Donoghue et al. (2024):${NC}"
echo "  Different SBOM formats may report different numbers of"
echo "  components due to naming conventions and scope definitions."
echo "  This does NOT necessarily mean one is 'better' — it means"
echo "  organizations should standardize on one format for consistency."
echo ""
