# Metrik Setelah Implementasi — Post-Enhancement Supply Chain Security

> **Tanggal Pengukuran:** 26 Juni 2026
> **Pipeline Run ID:** `#7`
> **Branch:** `main`

---

## 1. Ringkasan
Pipeline telah berhasil ditingkatkan dengan mengintegrasikan Syft, Trivy, dan Cosign. Berdasarkan uji coba pada Run #7, sistem keamanan berhasil mengidentifikasi ancaman kritis dan menghentikan deployment yang tidak aman, serta memberikan identitas digital pada artifact yang lolos sensor.

---

## 2. Metrik Setelah Enhancement

| No | Metrik                              | Nilai                   | Target                            |
|----|-------------------------------------|-------------------------|-----------------------------------|
| 1  | Jumlah vulnerability terdeteksi     | **10+** (3 CRITICAL)    | ≥8 vulnerabilities (sesuai CVE)   |
| 2  | SBOM coverage                       | **100%**                | 100% (direct + transitive)        |
| 3  | Artifact signing                    | **100%**                | 100% images ditandatangani        |
| 4  | Waktu pipeline (enhanced)           | **~5 Menit 15 Detik**   | T₀ + ΔT (overhead security)      |
| 5  | Pipeline failure rate (security)    | **100%** (pada temuan)  | >0% (fail pada CRITICAL CVE)     |
| 6  | SLSA level                          | **Level 2**             | Level 1–2                         |
| 7  | Dependency transparency             | **100%**                | 100% via SBOM                     |

### 2.1 Detail Metrik

#### Jumlah Vulnerability Terdeteksi: 3 CRITICAL
Trivy berhasil mendeteksi kerentanan kritis yang sebelumnya tidak terlihat:
- **CVE-2026-31789 (libcrypto3 & libssl3):** Masalah Heap Buffer Overflow pada level OS.
- **CVE-2021-44906 (minimist):** Prototype Pollution pada dependensi Node.js.
- Serta beberapa temuan HIGH dan MEDIUM lainnya pada library `lodash` dan `axios`.

#### SBOM Coverage: 100%
Syft berhasil mengekstrak seluruh layer container:
- **CycloneDX:** Berhasil mendeteksi komponen lebih banyak dibandingkan format lain.
- **Transparansi:** Menemukan library "tersembunyi" seperti `minimist` dan `node-fetch` yang merupakan dependensi transitif.

#### Artifact Signing: SUCCESS
- **Status:** 100% Signed.
- **Metode:** Keyless Signing via Sigstore.
- **Verifikasi:** Terverifikasi secara offline maupun online melalui Rekor Transparency Log (Log Index: **1910310477**).

#### Waktu Pipeline: 5m 15s
Terjadi penambahan waktu (overhead) yang masuk akal demi keamanan:
- **Build & Test:** ~1m 30s
- **SBOM Generation:** ~45s
- **Vulnerability Scan:** ~1m 15s
- **Artifact Signing:** ~30s
- **Overhead:** ΔT ≈ 2 menit 45 detik (Sesuai estimasi awal).

#### Pipeline Failure Rate (Security): FAILED (Correctly)
Pipeline otomatis **Gagal (Exit Code 1)** saat mendeteksi 3 CRITICAL CVE. Ini membuktikan *Security Gate* berfungsi mencegah aplikasi *vulnerable* masuk ke production.

#### SLSA Level: Level 2
Memenuhi syarat SLSA Level 2 karena:
- Provenance dibuat secara otomatis oleh Build Service (GitHub Actions).
- Artifact ditandatangani secara kriptografis (Cosign).

---

## 3. Perbandingan Sebelum vs Sesudah

| Metrik                           | Sebelum (Baseline)   | Sesudah (Enhanced)   | Perubahan              |
|----------------------------------|----------------------|----------------------|------------------------|
| Vulnerability terdeteksi         | 0 (Blind)            | 3 CRITICAL, 5+ HIGH  | Deteksi meningkat 100% |
| SBOM coverage                    | 0%                   | 100%                 | Transparansi penuh     |
| Artifact signing                 | Tidak ada            | Signed & Verified    | Integritas terjamin    |
| Waktu pipeline                   | ~2m 30s              | ~5m 15s              | +2m 45s (Overhead)     |
| Pipeline failure rate (security) | 0% (Lolos terus)     | 100% (Blokir bahaya) | Proteksi aktif         |
| SLSA level                       | Level 0              | Level 2              | Peningkatan 2 level    |

---

## 4. Evidence (Bukti Nyata)

### 4.1 Artifact Signing (Tugas Callista)
**Bukti Verifikasi Signature Berhasil:**
```bash
Verification for ghcr.io/dianggraaeni/kelompok-8-devsecops-future/devsecops-demo:latest
[{"critical":{"identity":{"docker-reference":"..."},"image":{"docker-manifest-digest":"sha256:4228..."},"logIndex":1910310477}]
```
*Tanda tangan valid dan tercatat di Rekor Transparency Log.*

### 4.2 Security Gate
**Log Error Message:**
`Error: 🚨 SECURITY GATE FAILED: Found 3 CRITICAL vulnerabilities! Pipeline blocked.`

### 4.3 SBOM Output
**Syft Result:** Berhasil men-generate `sbom.cdx.json` (CycloneDX) dan `sbom.spdx.json`.

#4.4 Documentations
**Bukti verifikasi signature berhasil (Cosign):**
![Cosign Verification Success](../evidence/artifact-signing-success.png)

**Screenshot Log di GitHub Actions:**
![GitHub Actions Sign Job](../evidence/github-actions-summary.png)

---
> _Hasil pengukuran ini mengonfirmasi bahwa penambahan komponen keamanan memberikan visibilitas penuh terhadap risiko supply chain yang sebelumnya tidak terdeteksi._
