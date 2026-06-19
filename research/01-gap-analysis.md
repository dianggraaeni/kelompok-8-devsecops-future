# Gap Analysis: Pipeline CI/CD Saat Ini

> **Dokumen Riset — Kelompok 8 DevSecOps**
> Tanggal: Juni 2026

---

## 1. Pipeline Saat Ini (Baseline)

Pada modul-modul sebelumnya, kelompok kami telah membangun pipeline CI/CD sederhana menggunakan **GitHub Actions** dengan alur kerja sebagai berikut:

```
Code Push → Build Image → Test → Deploy to Kubernetes
```

### 1.1 Detail Setiap Tahap

| Tahap | Deskripsi | Tool |
|-------|-----------|------|
| **Code Push** | Developer melakukan push ke branch `main` atau membuat pull request | Git + GitHub |
| **Build Image** | Dockerfile di-build menjadi container image menggunakan `docker build` | Docker |
| **Test** | Unit test dan integration test dijalankan secara otomatis | Jest / Mocha |
| **Deploy** | Image di-push ke container registry, kemudian di-deploy ke cluster Kubernetes | kubectl / Helm |

### 1.2 Apa yang Sudah Berjalan dengan Baik

Pipeline ini sudah berhasil mengotomasi proses dari kode hingga deployment. Setiap perubahan kode secara otomatis melewati tahap build dan test sebelum sampai ke production. Dari sisi **DevOps**, pipeline ini sudah memenuhi prinsip dasar continuous integration dan continuous deployment.

### 1.3 Apa yang Belum Ada

Namun, dari perspektif **DevSecOps** dan khususnya **supply chain security**, pipeline ini memiliki celah yang signifikan. Tidak ada mekanisme untuk:

- Mengetahui komponen apa saja yang berjalan di production
- Mendeteksi vulnerability pada dependensi (langsung maupun transitif)
- Memastikan integritas artifact yang di-deploy
- Membuktikan asal-usul (provenance) dari setiap artifact

---

## 2. Gap yang Teridentifikasi

Setelah melakukan analisis mendalam terhadap pipeline saat ini dan membandingkannya dengan standar industri serta temuan penelitian terkini, kami mengidentifikasi **empat gap kritis** yang harus ditangani.

### 2.1 Gap 1: Tidak Ada Inventory Dependensi (SBOM)

**Kondisi Saat Ini:**
Pipeline tidak menghasilkan Software Bill of Materials (SBOM) pada tahap manapun. Artinya, setelah container image di-build dan di-deploy ke production, **tidak ada catatan formal** tentang komponen software apa saja yang ada di dalamnya — termasuk library, framework, dan dependensi transitif.

**Dampak Langsung:**
- Tim tidak mengetahui komponen apa yang berjalan di environment production
- Ketika CVE baru ditemukan (misalnya CVE yang mempengaruhi library tertentu), tim **tidak bisa merespons dengan cepat** karena harus melakukan investigasi manual untuk menentukan apakah komponen yang terdampak ada di sistem
- Proses audit keamanan menjadi sangat lambat dan labor-intensive
- Tidak memenuhi persyaratan regulasi yang semakin ketat terkait transparansi komponen software

**Dasar Akademis:**

> Xia et al. (2023) dalam penelitiannya menyatakan bahwa *"lack of automated SBOM generation is primary adoption barrier"* untuk implementasi supply chain security yang efektif. Penelitian ini menggarisbawahi bahwa tanpa otomasi dalam pembuatan SBOM, organisasi cenderung tidak memiliki visibilitas terhadap komponen software mereka, yang pada akhirnya menghambat kemampuan respons terhadap insiden keamanan.

**Contoh Skenario:**
Bayangkan sebuah CVE kritis ditemukan pada library `lodash` versi tertentu. Tanpa SBOM, tim harus:
1. Secara manual memeriksa `package.json` dan `package-lock.json`
2. Memeriksa setiap Dockerfile dan base image
3. Menjalankan `npm list` di setiap environment
4. Mencocokkan versi secara manual

Proses ini bisa memakan waktu **berjam-jam hingga berhari-hari**, padahal dengan SBOM otomatis, informasi ini tersedia dalam **hitungan detik**.

---

### 2.2 Gap 2: Tidak Ada Vulnerability Scanning Berbasis Dependensi

**Kondisi Saat Ini:**
Pipeline tidak memiliki tahap vulnerability scanning sama sekali. Tidak ada tool yang melakukan pemindaian terhadap dependensi — baik yang dideklarasikan langsung (direct dependencies) maupun yang ditarik secara tidak langsung (transitive dependencies).

**Dampak Langsung:**
- Vulnerability pada transitive dependencies **tidak terdeteksi** sama sekali
- Aplikasi yang di-deploy ke production bisa mengandung komponen dengan vulnerability yang sudah diketahui (known vulnerabilities)
- Tidak ada gate/checkpoint yang mencegah deployment image dengan vulnerability kritis
- Tim baru mengetahui adanya vulnerability setelah terjadi eksploitasi

**Dasar Akademis:**

> O'Donoghue et al. (2024) dalam penelitiannya menunjukkan bahwa *"tool choice significantly impacts vulnerability detection outcomes"*. Penelitian ini membandingkan berbagai tool scanning dan menemukan bahwa pemilihan tool yang tepat, serta kombinasi antara SBOM generation dan vulnerability scanning, secara signifikan mempengaruhi jumlah dan akurasi vulnerability yang terdeteksi.

**Mengapa Transitive Dependencies Berbahaya:**
Dalam ekosistem Node.js, sebuah aplikasi dengan 50 direct dependencies bisa memiliki **ratusan hingga ribuan** transitive dependencies. Sebagai contoh:

```
express (direct)
  └── body-parser
       └── raw-body
            └── iconv-lite
                 └── safer-buffer  ← vulnerability bisa ada di sini
```

Tanpa scanning yang komprehensif, vulnerability di level `safer-buffer` tidak akan terdeteksi meskipun secara teknis komponen tersebut berjalan di production.

---

### 2.3 Gap 3: Tidak Ada Artifact Signing dan Verification

**Kondisi Saat Ini:**
Container image yang di-build oleh pipeline langsung di-push ke registry dan di-deploy ke Kubernetes **tanpa proses signing apapun**. Tidak ada mekanisme untuk memverifikasi bahwa image yang di-deploy adalah image yang sama dengan yang di-build oleh pipeline CI/CD.

**Dampak Langsung:**
- Container image bisa **di-tamper** (dimodifikasi) antara tahap build dan deploy tanpa terdeteksi
- Tidak ada cara untuk membuktikan bahwa image berasal dari pipeline resmi
- Serangan supply chain seperti registry poisoning atau man-in-the-middle tidak dapat dideteksi
- Tidak memenuhi prinsip **integrity verification** yang direkomendasikan oleh framework keamanan modern

**Dasar Akademis:**

> Kalu et al. (2025) dalam penelitiannya menemukan bahwa *"key management complexity is #1 barrier to signing adoption"*. Temuan ini menjelaskan mengapa banyak organisasi — termasuk pipeline kami — belum mengimplementasikan artifact signing: kompleksitas pengelolaan kunci kriptografi (key generation, rotation, storage, revocation) menjadi hambatan utama. Namun, solusi modern seperti Sigstore dengan keyless signing telah mengeliminasi barrier ini.

**Skenario Serangan:**
Tanpa signing, seorang attacker yang mendapatkan akses ke container registry bisa:
1. Pull image yang legitimate
2. Memasukkan malware atau backdoor
3. Push kembali image yang sudah dimodifikasi dengan tag yang sama
4. Kubernetes akan pull dan menjalankan image yang sudah di-compromise

Dengan artifact signing, skenario ini dapat dicegah karena signature pada image yang dimodifikasi tidak akan valid.

---

### 2.4 Gap 4: Tidak Ada Provenance Metadata

**Kondisi Saat Ini:**
Pipeline tidak menghasilkan metadata provenance yang mencatat informasi tentang proses build — siapa yang memicu build, kapan build dilakukan, dari commit/source code mana, dan di environment apa.

**Dampak Langsung:**
- Tidak bisa membuktikan **siapa** yang melakukan build
- Tidak bisa membuktikan **kapan** build dilakukan
- Tidak bisa membuktikan **dari source code mana** build dilakukan
- Tidak memenuhi persyaratan audit trail untuk compliance
- Sulit melakukan forensik ketika terjadi insiden keamanan

**Dasar Akademis:**

> **SLSA (Supply-chain Levels for Software Artifacts) Framework** mensyaratkan provenance metadata mulai dari **Level 1** ke atas. Pada SLSA Level 1, provenance harus menunjukkan bahwa artifact di-build oleh build system tertentu. Pada level yang lebih tinggi, provenance harus non-falsifiable dan dihasilkan oleh build platform yang terisolasi.

**Tabel Persyaratan SLSA:**

| SLSA Level | Persyaratan Provenance |
|------------|----------------------|
| Level 0 | Tidak ada provenance (kondisi pipeline kami saat ini) |
| Level 1 | Provenance tersedia, menunjukkan build system yang digunakan |
| Level 2 | Provenance di-generate oleh hosted build platform |
| Level 3 | Provenance non-falsifiable, build platform terisolasi |

Pipeline kami saat ini berada di **SLSA Level 0** — level terendah tanpa provenance sama sekali.

---

## 3. Dampak Gap: Pelajaran dari Insiden Dunia Nyata

Gap-gap yang teridentifikasi di atas bukan hanya masalah teoretis. Beberapa insiden keamanan terbesar dalam sejarah software terjadi karena gap-gap yang sama persis.

### 3.1 SolarWinds Supply Chain Attack (2020)

Pada Desember 2020, ditemukan bahwa platform monitoring SolarWinds Orion telah disusupi melalui serangan supply chain. Attacker menyisipkan malware (SUNBURST) ke dalam proses build SolarWinds, sehingga update yang didistribusikan ke sekitar **18.000 pelanggan** — termasuk lembaga pemerintah AS dan perusahaan Fortune 500 — mengandung backdoor.

**Relevansi dengan gap kami:**
- **Gap 3 (Artifact Signing):** Jika artifact signing dan verification diterapkan secara end-to-end, modifikasi unauthorized pada build artifact akan terdeteksi
- **Gap 4 (Provenance):** Provenance metadata yang kuat akan menunjukkan anomali dalam proses build

### 3.2 Log4Shell / Log4j (2021)

Pada Desember 2021, vulnerability kritis (CVE-2021-44228) ditemukan pada library Apache Log4j, yang digunakan secara luas di ekosistem Java. Vulnerability ini memungkinkan Remote Code Execution (RCE) dan mendapat skor CVSS 10.0 (maksimal).

**Relevansi dengan gap kami:**
- **Gap 1 (SBOM):** Organisasi yang memiliki SBOM bisa langsung mengidentifikasi apakah mereka menggunakan Log4j dan versi berapa — respons dalam hitungan menit. Organisasi tanpa SBOM memerlukan **berminggu-minggu** untuk audit manual
- **Gap 2 (Vulnerability Scanning):** Scanning otomatis akan mendeteksi vulnerability ini segera setelah CVE dipublikasikan

### 3.3 xz-utils Backdoor (2024)

Pada Maret 2024, ditemukan backdoor yang disisipkan secara sengaja ke dalam library kompresi xz-utils (CVE-2024-3094). Seorang kontributor yang telah membangun kepercayaan selama bertahun-tahun menyisipkan kode berbahaya yang menargetkan OpenSSH melalui systemd.

**Relevansi dengan gap kami:**
- **Gap 1 (SBOM):** SBOM yang komprehensif akan menunjukkan keberadaan xz-utils sebagai dependensi
- **Gap 2 (Vulnerability Scanning):** Scanning berbasis CVE database akan mendeteksi versi yang terdampak
- **Gap 4 (Provenance):** Provenance yang kuat membantu dalam analisis forensik pasca-insiden

### 3.4 Ringkasan Dampak

| Insiden | Tahun | Dampak | Gap yang Relevan |
|---------|-------|--------|-----------------|
| SolarWinds | 2020 | 18.000+ organisasi terdampak | Gap 3, Gap 4 |
| Log4Shell | 2021 | Jutaan sistem terdampak | Gap 1, Gap 2 |
| xz-utils | 2024 | Potensi compromised SSH di seluruh Linux | Gap 1, Gap 2, Gap 4 |

---

## 4. Prioritas Penyelesaian

Berdasarkan analisis dampak dan feasibility implementasi, kami memprioritaskan penyelesaian gap sebagai berikut:

### Prioritas 1: SBOM Generation (Gap 1)

**Alasan:** SBOM adalah fondasi dari semua aktivitas supply chain security lainnya. Tanpa SBOM, vulnerability scanning berbasis dependensi tidak akan efektif, dan provenance metadata tidak lengkap. SBOM juga relatif mudah diimplementasikan menggunakan tool seperti Syft.

**Rencana:** Mengintegrasikan Syft ke dalam pipeline untuk menghasilkan SBOM dalam format CycloneDX secara otomatis pada setiap build.

### Prioritas 2: Vulnerability Scanning (Gap 2)

**Alasan:** Setelah SBOM tersedia, langkah logis berikutnya adalah menggunakan SBOM tersebut sebagai input untuk vulnerability scanning. Ini memberikan **actionable security insight** langsung dari pipeline.

**Rencana:** Mengintegrasikan Trivy untuk melakukan scanning terhadap SBOM yang dihasilkan, dengan policy fail-fast untuk vulnerability CRITICAL.

### Prioritas 3: Artifact Signing (Gap 3)

**Alasan:** Signing memastikan integritas artifact dari build hingga deploy. Dengan adanya Sigstore/Cosign yang menawarkan keyless signing, barrier implementasi yang diidentifikasi oleh Kalu et al. (2025) sudah jauh berkurang.

**Rencana:** Mengintegrasikan Cosign dengan keyless signing (OIDC-based) ke dalam pipeline.

### Prioritas 4: Provenance Metadata (Gap 4)

**Alasan:** Provenance melengkapi ketiga solusi di atas dengan memberikan konteks lengkap tentang proses build. Ini penting untuk audit dan compliance, namun prioritasnya di bawah ketiga gap lainnya karena dampak langsung terhadap keamanan relatif lebih rendah.

**Rencana:** Memanfaatkan fitur SLSA provenance dari GitHub Actions dan attestation dari Cosign.

### Ringkasan Prioritas

```
┌─────────────────────────────────────────────────────┐
│  Prioritas 1: SBOM Generation (Syft + CycloneDX)   │  ← Fondasi
├─────────────────────────────────────────────────────┤
│  Prioritas 2: Vulnerability Scanning (Trivy)        │  ← Deteksi
├─────────────────────────────────────────────────────┤
│  Prioritas 3: Artifact Signing (Cosign keyless)     │  ← Integritas
├─────────────────────────────────────────────────────┤
│  Prioritas 4: Provenance Metadata (SLSA)            │  ← Auditabilitas
└─────────────────────────────────────────────────────┘
```

---

## Referensi

1. Xia, B., et al. (2023). *Trusting the Trust: Exploring Practitioner Perspectives on Software Bill of Materials (SBOM)*. arXiv preprint.
2. O'Donoghue, K., et al. (2024). *An Empirical Study of SBOM Generation Tools and Their Impact on Vulnerability Assessment*. Proceedings of IEEE/ACM.
3. Kalu, O., et al. (2025). *Barriers and Enablers to Software Supply Chain Security: A Mixed-Methods Study*. ACM Computing Surveys.
4. SLSA Framework. *Supply-chain Levels for Software Artifacts*. https://slsa.dev
