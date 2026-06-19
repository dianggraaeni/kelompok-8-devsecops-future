# Metrik Baseline — Sebelum Implementasi Supply Chain Security

> **Tanggal Pengukuran:** _[Diisi saat pipeline baseline dijalankan]_  
> **Pipeline Run ID:** _[Diisi dari GitHub Actions run]_  
> **Branch:** `main`

---

## 1. Ringkasan Baseline

Dokumen ini mencatat kondisi pipeline CI/CD **sebelum** implementasi enhancement
supply chain security. Pada kondisi baseline, pipeline hanya menjalankan tahapan
standar (build, test, push) tanpa mekanisme keamanan rantai pasok seperti:

- **SBOM (Software Bill of Materials)** — tidak ada generasi daftar dependensi
- **Vulnerability Scanning** — tidak ada pemindaian kerentanan otomatis
- **Artifact Signing** — tidak ada penandatanganan atau verifikasi image

Tujuan pencatatan baseline ini adalah untuk menyediakan titik referensi kuantitatif
yang akan dibandingkan dengan metrik setelah implementasi enhancement, sehingga
efektivitas peningkatan keamanan dapat diukur secara objektif.

---

## 2. Metrik Baseline

| No | Metrik                              | Nilai Baseline          | Keterangan                                                    |
|----|-------------------------------------|-------------------------|---------------------------------------------------------------|
| 1  | Jumlah vulnerability terdeteksi     | **0**                   | Tidak ada scanning mechanism dalam pipeline                   |
| 2  | SBOM coverage                       | **0%**                  | Tidak ada SBOM generation sama sekali                         |
| 3  | Artifact signing                    | **Tidak ada**           | Tidak ada signing maupun verification pada container image    |
| 4  | Waktu pipeline (baseline)           | **~2 menit**            | Estimasi waktu build + test + push tanpa security steps       |
| 5  | Pipeline failure rate (security)    | **0%**                  | Tidak ada security gate yang dapat menghentikan pipeline      |
| 6  | SLSA level                          | **Level 0**             | Tidak ada supply chain security compliance                    |
| 7  | Dependency transparency             | **None**                | Harus dilakukan manual via `npm audit`                        |

### 2.1 Detail Metrik

#### Jumlah Vulnerability Terdeteksi: 0

Pipeline saat ini tidak memiliki langkah scanning kerentanan. Artinya, meskipun
terdapat dependensi yang rentan (lihat Bagian 4), pipeline tidak mampu
mendeteksi atau melaporkannya. Nilai 0 **bukan** berarti tidak ada kerentanan,
melainkan tidak ada mekanisme untuk mendeteksinya.

#### SBOM Coverage: 0%

Tidak ada proses generasi SBOM (baik dalam format SPDX maupun CycloneDX).
Akibatnya, tidak ada visibilitas terhadap komponen perangkat lunak yang
terkandung dalam artifact yang dihasilkan.

#### Artifact Signing: Tidak Ada

Container image yang di-push ke registry tidak ditandatangani secara kriptografi.
Hal ini berarti tidak ada jaminan integritas maupun provenance dari artifact
yang dihasilkan pipeline.

#### Waktu Pipeline: ~2 Menit

Estimasi waktu eksekusi pipeline baseline:

| Step         | Estimasi Waktu |
|--------------|----------------|
| Checkout     | ~5 detik       |
| Build        | ~45 detik      |
| Test         | ~30 detik      |
| Docker Push  | ~40 detik      |
| **Total**    | **~2 menit**   |

> **Catatan:** Waktu aktual akan diukur dari pipeline run dan dicatat sebagai evidence.

#### Pipeline Failure Rate (Security): 0%

Karena tidak ada security gate, pipeline tidak pernah gagal karena alasan keamanan.
Semua build akan lolos meskipun mengandung kerentanan kritis.

#### SLSA Level: Level 0

Berdasarkan framework SLSA (Supply-chain Levels for Software Artifacts), pipeline
saat ini berada di **Level 0** — tidak ada jaminan supply chain security.

#### Dependency Transparency: None

Untuk mengetahui dependensi dan kerentanannya, developer harus secara manual
menjalankan `npm audit` di lokal. Tidak ada mekanisme otomatis dalam pipeline.

---

## 3. Screenshot / Evidence

> [!NOTE]
> Bagian ini akan diisi dengan screenshot dan log dari pipeline run aktual
> sebagai bukti kondisi baseline.

- [ ] Screenshot pipeline run (GitHub Actions)
- [ ] Log output pipeline (tanpa security steps)
- [ ] Waktu eksekusi aktual dari pipeline run
- [ ] Screenshot `npm audit` manual (menunjukkan vulnerability yang tidak terdeteksi pipeline)

---

## 4. Known Vulnerable Dependencies

Berikut adalah daftar dependensi yang sengaja menggunakan versi rentan dalam
`package.json` untuk keperluan evaluasi:

### 4.1 lodash v4.17.15

| CVE ID          | Severity     | Jenis Kerentanan       |
|-----------------|--------------|------------------------|
| CVE-2021-23337  | **HIGH**     | Command Injection      |
| CVE-2019-10744  | **CRITICAL** | Prototype Pollution    |
| CVE-2020-28500  | **MEDIUM**   | ReDoS                  |

### 4.2 jsonwebtoken v8.5.1

| CVE ID          | Severity     | Jenis Kerentanan       |
|-----------------|--------------|------------------------|
| CVE-2022-23529  | **HIGH**     | Remote Code Execution  |
| CVE-2022-23540  | **HIGH**     | Authentication Bypass  |

### 4.3 axios v0.21.1

| CVE ID          | Severity     | Jenis Kerentanan       |
|-----------------|--------------|------------------------|
| CVE-2021-3749   | **HIGH**     | ReDoS                  |

### 4.4 minimist v1.2.5

| CVE ID          | Severity     | Jenis Kerentanan       |
|-----------------|--------------|------------------------|
| CVE-2021-44906  | **CRITICAL** | Prototype Pollution    |

### 4.5 node-fetch v2.6.0

| CVE ID          | Severity     | Jenis Kerentanan       |
|-----------------|--------------|------------------------|
| CVE-2022-0235   | **HIGH**     | Information Disclosure |

### Ringkasan Kerentanan (Total)

| Severity     | Jumlah |
|--------------|--------|
| CRITICAL     | 2      |
| HIGH         | 5      |
| MEDIUM       | 1      |
| **Total**    | **8**  |

> [!WARNING]
> Seluruh kerentanan di atas **tidak terdeteksi** oleh pipeline baseline karena
> tidak ada mekanisme scanning. Ini menunjukkan risiko signifikan pada supply
> chain security.

---

## 5. Kesimpulan

Pipeline saat ini memiliki **ZERO visibility** terhadap keamanan rantai pasok:

- **Tidak ada deteksi kerentanan** — 8+ CVE yang diketahui tidak terdeteksi
- **Tidak ada transparansi dependensi** — tidak ada SBOM yang dihasilkan
- **Tidak ada jaminan integritas** — artifact tidak ditandatangani
- **Tidak ada security gate** — pipeline tidak pernah gagal karena keamanan

Kondisi ini menempatkan proyek pada risiko tinggi terhadap serangan supply chain
seperti dependency confusion, typosquatting, dan distribusi artifact yang
telah dimodifikasi. Enhancement yang akan diimplementasikan bertujuan untuk
mengatasi seluruh kekurangan ini secara komprehensif.

---

> _Dokumen ini adalah bagian dari evaluasi proyek DevSecOps Kelompok 8._
