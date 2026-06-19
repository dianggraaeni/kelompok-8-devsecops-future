# Metrik Setelah Implementasi — Post-Enhancement Supply Chain Security

> **Tanggal Pengukuran:** _[TO BE MEASURED]_  
> **Pipeline Run ID:** _[TO BE MEASURED]_  
> **Branch:** `main`

---

## 1. Ringkasan

Dokumen ini mencatat kondisi pipeline CI/CD **setelah** implementasi enhancement
supply chain security. Pipeline yang telah ditingkatkan mencakup tiga komponen
utama keamanan rantai pasok:

- **SBOM Generation** — pembuatan Software Bill of Materials otomatis menggunakan Syft
- **Vulnerability Scanning** — pemindaian kerentanan otomatis menggunakan Trivy
- **Artifact Signing** — penandatanganan container image menggunakan Cosign

Metrik yang tercatat di sini akan dibandingkan dengan metrik baseline (sebelum
implementasi) untuk mengukur efektivitas enhancement secara kuantitatif.

> [!NOTE]
> Nilai yang ditandai **[TO BE MEASURED]** akan diisi setelah pipeline
> enhanced berhasil dijalankan dan hasilnya diverifikasi.

---

## 2. Metrik Setelah Enhancement

| No | Metrik                              | Nilai                   | Target                            |
|----|-------------------------------------|-------------------------|-----------------------------------|
| 1  | Jumlah vulnerability terdeteksi     | [TO BE MEASURED]        | ≥8 vulnerabilities (sesuai CVE)   |
| 2  | SBOM coverage                       | [TO BE MEASURED]        | 100% (direct + transitive)        |
| 3  | Artifact signing                    | [TO BE MEASURED]        | 100% images ditandatangani        |
| 4  | Waktu pipeline (enhanced)           | [TO BE MEASURED]        | T₀ + ΔT (overhead security)      |
| 5  | Pipeline failure rate (security)    | [TO BE MEASURED]        | >0% (fail pada CRITICAL CVE)     |
| 6  | SLSA level                          | [TO BE MEASURED]        | Level 1–2                         |
| 7  | Dependency transparency             | [TO BE MEASURED]        | 100% via SBOM                     |

### 2.1 Detail Metrik

#### Jumlah Vulnerability Terdeteksi: [TO BE MEASURED]

Diharapkan Trivy mendeteksi minimal **8 vulnerability** dari dependensi yang
sengaja ditambahkan (lodash, jsonwebtoken, axios, minimist, node-fetch), meliputi:

- 2 × CRITICAL (Prototype Pollution)
- 5 × HIGH (Command Injection, RCE, Auth Bypass, ReDoS, Info Disclosure)
- 1 × MEDIUM (ReDoS)

> **Hasil Aktual:** _[TO BE MEASURED — isi jumlah dan breakdown severity]_

#### SBOM Coverage: [TO BE MEASURED]

Target: **100%** dari seluruh dependensi (direct dan transitive) tercakup dalam
SBOM yang dihasilkan oleh Syft dalam format SPDX/CycloneDX.

> **Hasil Aktual:** _[TO BE MEASURED — isi persentase dan jumlah komponen]_

#### Artifact Signing: [TO BE MEASURED]

Target: **100%** container image yang dipush ke registry ditandatangani
menggunakan Cosign (keyless signing via Sigstore/Fulcio).

> **Hasil Aktual:** _[TO BE MEASURED — isi status signing dan verifikasi]_

#### Waktu Pipeline: [TO BE MEASURED]

Diharapkan terjadi penambahan waktu (overhead) akibat security steps:

| Step                    | Estimasi Waktu       |
|-------------------------|----------------------|
| Checkout                | ~5 detik             |
| Build                   | ~45 detik            |
| Test                    | ~30 detik            |
| **SBOM Generation**     | ~30–60 detik (baru)  |
| **Vulnerability Scan**  | ~60–90 detik (baru)  |
| Docker Push             | ~40 detik            |
| **Artifact Signing**    | ~20–30 detik (baru)  |
| **Total Estimasi**      | **~4–5 menit**       |

Overhead keamanan diperkirakan: **ΔT ≈ 2–3 menit** tambahan dari baseline ~2 menit.

> **Waktu Aktual:** _[TO BE MEASURED — isi waktu dari pipeline run]_

#### Pipeline Failure Rate (Security): [TO BE MEASURED]

Diharapkan pipeline **gagal** ketika menemukan kerentanan dengan severity
CRITICAL atau HIGH (tergantung konfigurasi threshold). Ini menunjukkan bahwa
security gate berfungsi dengan benar.

> **Hasil Aktual:** _[TO BE MEASURED — isi apakah pipeline gagal/berhasil dan alasannya]_

#### SLSA Level: Target Level 1–2

Dengan implementasi SBOM, signing, dan provenance, pipeline diharapkan memenuhi
persyaratan SLSA Level 1 (provenance tersedia) hingga Level 2 (provenance
dihasilkan oleh build service).

> **Hasil Aktual:** _[TO BE MEASURED — isi level SLSA yang dicapai]_

#### Dependency Transparency: Target 100%

Dengan SBOM yang dihasilkan secara otomatis, seluruh dependensi harus
terdokumentasi dan dapat diaudit tanpa proses manual.

> **Hasil Aktual:** _[TO BE MEASURED — isi persentase transparansi]_

---

## 3. Perbandingan Sebelum vs Sesudah

| Metrik                           | Sebelum (Baseline)   | Sesudah (Enhanced)   | Perubahan              |
|----------------------------------|----------------------|----------------------|------------------------|
| Vulnerability terdeteksi         | 0                    | [TO BE MEASURED]     | [TO BE MEASURED]       |
| SBOM coverage                    | 0%                   | [TO BE MEASURED]     | [TO BE MEASURED]       |
| Artifact signing                 | Tidak ada            | [TO BE MEASURED]     | [TO BE MEASURED]       |
| Waktu pipeline                   | ~2 menit             | [TO BE MEASURED]     | +ΔT [TO BE MEASURED]   |
| Pipeline failure rate (security) | 0%                   | [TO BE MEASURED]     | [TO BE MEASURED]       |
| SLSA level                       | Level 0              | [TO BE MEASURED]     | [TO BE MEASURED]       |
| Dependency transparency          | None                 | [TO BE MEASURED]     | [TO BE MEASURED]       |

> [!IMPORTANT]
> Tabel di atas harus diisi dengan data aktual dari pipeline run setelah
> seluruh enhancement diimplementasikan dan diuji.

---

## 4. Evidence

> [!NOTE]
> Bagian ini akan diisi dengan screenshot, log, dan bukti lainnya dari
> pipeline run yang telah di-enhance.

### 4.1 Screenshot Pipeline Run

- [ ] Screenshot GitHub Actions workflow run (enhanced pipeline)
- [ ] Screenshot durasi setiap step dalam pipeline

### 4.2 Hasil Vulnerability Scan

- [ ] Output Trivy scan (daftar vulnerability terdeteksi)
- [ ] Screenshot severity breakdown

### 4.3 SBOM Output

- [ ] Contoh SBOM yang dihasilkan (SPDX/CycloneDX)
- [ ] Daftar komponen yang terdeteksi dalam SBOM

### 4.4 Artifact Signing

- [ ] Bukti signing berhasil (Cosign output)
- [ ] Bukti verifikasi signature berhasil

### 4.5 Security Gate

- [ ] Screenshot pipeline yang gagal karena CRITICAL vulnerability
- [ ] Log error message dari security gate

---

> _Dokumen ini adalah bagian dari evaluasi proyek DevSecOps Kelompok 8._  
> _Akan diperbarui setelah pipeline enhanced berhasil dijalankan._
