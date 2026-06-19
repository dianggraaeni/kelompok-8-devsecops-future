# Scripts — Testing & Verification

> **Anggota C** — Acintya Edria Sudarsono (5027231020)  
> Komponen: Vulnerability Scanning & Security Gate

---

## Daftar Scripts

| Script | Fungsi | Status |
|--------|--------|--------|
| `run-all-tests.sh` | Master runner — jalankan semua test suite | ✅ |
| `test-vulnerability-detection.sh` | Test deteksi vulnerability (image scan + SBOM scan) | ✅ |
| `test-security-gate.sh` | Test 3 skenario security gate (CRITICAL/MEDIUM/clean) | ✅ |
| `verify-sbom-coverage.sh` | Verifikasi coverage SBOM vs package-lock.json | ✅ |

---

## Cara Menjalankan

### Prerequisites

```bash
# Install Trivy
# macOS
brew install trivy

# Linux
sudo apt-get install trivy

# Atau via Docker
docker pull aquasec/trivy
```

### Jalankan Semua Test

```bash
# Dari root project directory
chmod +x scripts/*.sh

# Jalankan semua test
./scripts/run-all-tests.sh devsecops-demo:latest
```

### Jalankan Test Individual

```bash
# 1. SBOM Coverage
./scripts/verify-sbom-coverage.sh app/package-lock.json sbom.cdx.json sbom.spdx.json

# 2. Vulnerability Detection
./scripts/test-vulnerability-detection.sh devsecops-demo:latest sbom.cdx.json sbom.spdx.json

# 3. Security Gate
./scripts/test-security-gate.sh devsecops-demo:latest
```

---

## Output yang Dihasilkan

Setelah menjalankan test, folder `test-results/` akan berisi:

```
test-results/
├── vuln-image-scan.json        ← Hasil Trivy image scan
├── vuln-sbom-cdx-scan.json     ← Hasil Trivy scan dari SBOM CycloneDX
├── vuln-sbom-spdx-scan.json    ← Hasil Trivy scan dari SBOM SPDX
├── trivy-results.sarif         ← SARIF report untuk GitHub Security tab
├── gate-scenario-a.json        ← Scan result skenario A (CRITICAL)
├── gate-scenario-b.json        ← Scan result skenario B (MEDIUM only)
├── gate-scenario-c.json        ← Scan result skenario C (clean)
└── test-summary.json           ← Ringkasan semua test dalam JSON
```

---

## Referensi Paper

- **O'Donoghue et al. (2024)** — "Impacts of SBOM Generation on Vulnerability Detection" (SCORED '24 @ ACM CCS)
  - Justifikasi pemilihan Trivy sebagai scanner
  - Perbandingan CycloneDX vs SPDX dalam deteksi vulnerability

- **Xia et al. (2023)** — "An Empirical Study on SBOM" (ICSE 2023)
  - Justifikasi security gate (actionability of SBOM)
  - Coverage verification approach
