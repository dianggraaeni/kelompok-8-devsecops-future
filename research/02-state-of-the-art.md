# State of the Art: Supply Chain Security dalam DevSecOps

> **Dokumen Riset — Kelompok 8 DevSecOps**
> Tanggal: Juni 2026

---

## 1. Lanskap Keamanan Supply Chain Software

### 1.1 Mengapa Supply Chain Security Menjadi Kritis

Software modern tidak lagi dibangun dari nol. Sebagian besar aplikasi terdiri dari **komponen open-source** yang diambil dari berbagai sumber — package registry seperti npm, PyPI, Maven Central, dan lain-lain. Menurut berbagai laporan industri, antara 70% hingga 90% kode dalam aplikasi modern berasal dari komponen open-source pihak ketiga.

Kondisi ini menciptakan **attack surface** yang sangat luas. Seorang attacker tidak perlu menyerang aplikasi secara langsung — cukup menyusupi salah satu dari ratusan atau ribuan dependensi yang digunakan. Inilah esensi dari **software supply chain attack**: menyerang rantai pasokan software untuk menjangkau target akhir secara massal.

### 1.2 Tren Serangan Supply Chain

Serangan terhadap supply chain software telah meningkat secara dramatis dalam beberapa tahun terakhir:

| Tahun | Insiden Notable | Vektor Serangan |
|-------|----------------|-----------------|
| 2020 | SolarWinds (SUNBURST) | Kompromisasi build system |
| 2021 | Codecov | Modifikasi script CI/CD |
| 2021 | ua-parser-js, coa, rc | Pembajakan akun npm maintainer |
| 2021 | Log4Shell (Log4j) | Vulnerability di library populer |
| 2022 | node-ipc | Maintainer menyisipkan kode berbahaya (protestware) |
| 2023 | PyTorch nightly | Dependency confusion attack |
| 2024 | xz-utils (CVE-2024-3094) | Social engineering terhadap maintainer |

Pola yang terlihat jelas: **serangan semakin sophisticated dan semakin sulit dideteksi**. Kasus xz-utils menunjukkan bahwa bahkan kontributor yang telah membangun kepercayaan selama bertahun-tahun bisa menjadi vektor serangan.

### 1.3 Dampak Ekonomi dan Operasional

Menurut laporan Sonatype "State of the Software Supply Chain" (2024), serangan supply chain telah menyebabkan:

- Kerugian finansial yang mencapai miliaran dolar secara global
- Downtime yang signifikan pada infrastruktur kritis
- Erosi kepercayaan terhadap ekosistem open-source
- Peningkatan regulasi dan persyaratan compliance

Xia et al. (2023) menegaskan bahwa *"organisasi yang tidak memiliki visibilitas terhadap komponen software mereka berada dalam posisi yang sangat rentan"*, karena mereka tidak dapat merespons dengan cepat ketika vulnerability baru ditemukan dalam komponen yang mereka gunakan.

---

## 2. Framework dan Standar yang Ada

Sebagai respons terhadap meningkatnya ancaman supply chain, berbagai framework dan standar telah dikembangkan oleh komunitas keamanan dan pemerintah.

### 2.1 SLSA (Supply-chain Levels for Software Artifacts)

**SLSA** (diucapkan "salsa") adalah framework yang dikembangkan oleh Google dan komunitas OpenSSF untuk meningkatkan integritas supply chain software. SLSA mendefinisikan empat level keamanan:

| Level | Nama | Persyaratan Utama |
|-------|------|-------------------|
| 0 | Tidak ada jaminan | Tidak ada provenance |
| 1 | Provenance tersedia | Dokumentasi proses build |
| 2 | Hosted build platform | Build di platform terpercaya (mis. GitHub Actions) |
| 3 | Hardened build platform | Build terisolasi, provenance non-falsifiable |

SLSA fokus pada **provenance** dan **integritas build process**. Framework ini memberikan roadmap yang jelas bagi organisasi untuk meningkatkan keamanan supply chain mereka secara bertahap.

Dalam konteks proyek kami, pipeline GitHub Actions sudah secara inheren memenuhi beberapa aspek SLSA Level 2 (hosted build platform), tetapi kami perlu menambahkan provenance generation dan artifact signing untuk memenuhi persyaratan secara penuh.

### 2.2 NIST Secure Software Development Framework (SSDF)

**NIST SP 800-218 (SSDF)** menyediakan serangkaian praktik untuk pengembangan software yang aman. SSDF mengorganisasi praktiknya ke dalam empat kelompok:

1. **Prepare the Organization (PO)** — kebijakan dan proses
2. **Protect the Software (PS)** — melindungi kode dan artifact
3. **Produce Well-Secured Software (PW)** — praktik pengembangan yang aman
4. **Respond to Vulnerabilities (RV)** — respons terhadap vulnerability

SSDF secara eksplisit merekomendasikan penggunaan SBOM dan vulnerability scanning sebagai bagian dari praktik keamanan pengembangan software.

### 2.3 OpenSSF Scorecard

**OpenSSF Scorecard** adalah tool otomatis yang mengevaluasi keamanan proyek open-source berdasarkan sejumlah checks, termasuk:

- Apakah proyek menggunakan branch protection
- Apakah dependency di-pin ke versi spesifik
- Apakah ada vulnerability scanning yang aktif
- Apakah artifact di-sign
- Apakah ada SBOM yang tersedia

Scorecard memberikan skor 0-10 untuk setiap check dan skor agregat. Tool ini membantu organisasi mengevaluasi risiko dari dependensi yang mereka gunakan.

### 2.4 Executive Order 14028 (AS)

Pada Mei 2021, Presiden AS mengeluarkan **Executive Order 14028** tentang "Improving the Nation's Cybersecurity". EO ini secara eksplisit mensyaratkan:

- Vendor software yang menjual ke pemerintah AS harus menyediakan **SBOM**
- Software harus dikembangkan mengikuti praktik **secure development**
- Implementasi **zero trust architecture**

Meskipun EO ini berlaku untuk vendor pemerintah AS, dampaknya dirasakan secara global karena banyak perusahaan multinasional yang mengadopsi persyaratan serupa sebagai best practice. Xia et al. (2023) mencatat bahwa EO 14028 menjadi *"katalisator utama dalam meningkatkan kesadaran dan adopsi SBOM di industri"*.

---

## 3. SBOM: Standards dan Tools

### 3.1 Apa itu SBOM?

**Software Bill of Materials (SBOM)** adalah daftar formal dan terstruktur dari semua komponen, library, dan dependensi yang menyusun sebuah software. SBOM berfungsi seperti "daftar bahan" pada produk makanan — memberikan transparansi tentang apa yang ada di dalam produk.

SBOM yang komprehensif mencakup:
- Nama komponen dan versi
- Supplier/publisher
- Hubungan dependensi (direct vs transitive)
- Hash/checksum untuk verifikasi integritas
- Informasi lisensi

### 3.2 Format Standar: CycloneDX vs SPDX

Saat ini ada dua format SBOM yang dominan:

#### CycloneDX

- Dikembangkan oleh **OWASP**
- Fokus pada **security use cases** (vulnerability tracking, license compliance)
- Format: JSON dan XML
- Lebih ringan dan mudah diproses secara programmatik
- Mendukung berbagai tipe BOM: Software, Hardware, SaaSBOM, dan lain-lain
- Iterasi cepat, komunitas yang aktif di ruang keamanan

#### SPDX (Software Package Data Exchange)

- Dikembangkan oleh **Linux Foundation**
- Standar ISO/IEC 5962:2021
- Fokus pada **license compliance** (awalnya)
- Format: JSON, XML, RDF, tag-value, YAML
- Lebih mature dan diadopsi secara luas di enterprise
- Dukungan kuat dari ekosistem Linux

#### Perbandingan

| Aspek | CycloneDX | SPDX |
|-------|-----------|------|
| Organisasi | OWASP | Linux Foundation |
| Fokus utama | Security | License compliance |
| Standar ISO | Belum | Ya (ISO/IEC 5962) |
| Format | JSON, XML | JSON, XML, RDF, tag-value |
| Kemudahan CI/CD | Tinggi | Sedang |
| Vulnerability mapping | Sangat baik | Baik |

O'Donoghue et al. (2024) dalam penelitiannya menunjukkan bahwa *"CycloneDX menghasilkan vulnerability detection yang lebih konsisten dalam konteks CI/CD pipeline"*, yang menjadi salah satu alasan kami memilih format ini untuk proyek kami.

### 3.3 Tools untuk SBOM Generation

#### Syft (Anchore)

- Open-source tool dari Anchore
- Mendukung berbagai ekosistem (npm, pip, maven, go, dll.)
- Output dalam format CycloneDX dan SPDX
- Dapat melakukan scan terhadap container image, filesystem, atau archive
- Integrasi mudah dengan CI/CD pipeline

#### Trivy (Aqua Security)

- Selain vulnerability scanner, Trivy juga bisa generate SBOM
- All-in-one tool yang mencakup scanning dan generation
- Mendukung CycloneDX dan SPDX

#### cdxgen

- Tool khusus untuk CycloneDX generation
- Fokus pada ekosistem JavaScript/Node.js
- Mendukung banyak bahasa pemrograman

#### Perbandingan Tools SBOM Generation

| Tool | Ekosistem | Format Output | Akurasi | CI/CD Integration |
|------|-----------|---------------|---------|-------------------|
| Syft | Multi | CycloneDX, SPDX | Tinggi | Sangat mudah |
| Trivy | Multi | CycloneDX, SPDX | Tinggi | Sangat mudah |
| cdxgen | Multi (fokus JS) | CycloneDX | Tinggi | Mudah |

O'Donoghue et al. (2024) menemukan bahwa *"pemisahan tool antara SBOM generation dan vulnerability scanning menghasilkan coverage dan akurasi yang lebih baik"*. Temuan ini mendukung pendekatan kami untuk menggunakan Syft sebagai SBOM generator dan Trivy sebagai vulnerability scanner, alih-alih menggunakan satu tool untuk kedua fungsi.

### 3.4 Tingkat Adopsi SBOM

Meskipun kesadaran terhadap SBOM meningkat pesat, adopsi aktual masih relatif rendah. Xia et al. (2023) mencatat beberapa temuan penting:

- Banyak organisasi **mengetahui** tentang SBOM tetapi belum mengimplementasikannya
- **Kurangnya otomasi** menjadi barrier utama adopsi
- Organisasi yang sudah mengadopsi SBOM melaporkan **peningkatan signifikan** dalam kemampuan merespons vulnerability
- Ekosistem dengan tooling yang mature (seperti npm/Node.js) memiliki tingkat adopsi yang lebih tinggi

---

## 4. Vulnerability Scanning

### 4.1 Pendekatan Tradisional vs SBOM-Based

#### Scanning Tradisional

Pendekatan tradisional dalam vulnerability scanning melibatkan:
- **Image scanning**: Memindai layer-layer container image secara langsung
- **Dependency file scanning**: Memindai file seperti `package-lock.json` atau `requirements.txt`
- **Runtime scanning**: Memindai aplikasi yang sedang berjalan

Kelemahan pendekatan ini:
- Sering menghasilkan **false positives** karena kurangnya konteks
- Tidak selalu mendeteksi **transitive dependencies**
- Hasil scanning tidak portabel — harus diulang di setiap tahap

#### SBOM-Based Scanning

Pendekatan modern menggunakan SBOM sebagai input untuk vulnerability scanning:

```
Source Code → Build → Generate SBOM → Scan SBOM → Report/Gate
```

Keuntungan:
- SBOM memberikan **daftar komponen yang akurat** untuk di-scan
- Hasil lebih konsisten dan reproducible
- SBOM bisa disimpan sebagai artifact dan di-scan ulang ketika CVE baru ditemukan
- Mengurangi false positives karena konteks yang lebih kaya

### 4.2 Tools Vulnerability Scanning

#### Trivy (Aqua Security)

- Open-source, community-driven
- Mendukung scanning container image, filesystem, Git repository, dan SBOM
- Database vulnerability yang komprehensif (NVD, GitHub Advisories, dll.)
- Sangat cepat dan ringan
- Integrasi native dengan CI/CD pipeline
- Mendukung policy enforcement (fail on CRITICAL)

#### Grype (Anchore)

- Open-source dari Anchore (sama dengan Syft)
- Dirancang sebagai companion tool untuk Syft
- Menggunakan database vulnerability yang sama dengan Anchore Enterprise
- Mendukung scanning SBOM sebagai input
- Lebih ringan dari Trivy untuk use case tertentu

#### Snyk

- Platform komersial dengan tier gratis terbatas
- Mendukung scanning kode, dependensi, container, dan IaC
- Database vulnerability proprietary yang sangat lengkap
- Fitur auto-fix yang dapat membuat pull request otomatis
- Integrasi mendalam dengan platform developer

#### Perbandingan Tools Scanning

| Fitur | Trivy | Grype | Snyk |
|-------|-------|-------|------|
| Lisensi | Open-source | Open-source | Komersial (freemium) |
| SBOM input | ✅ | ✅ | ✅ |
| Container scan | ✅ | ✅ | ✅ |
| IaC scan | ✅ | ❌ | ✅ |
| Database | Multi-source | Anchore DB | Proprietary |
| CI/CD integration | Native | Baik | Sangat baik |
| Kecepatan | Sangat cepat | Cepat | Sedang |
| Auto-fix | ❌ | ❌ | ✅ |

O'Donoghue et al. (2024) menggarisbawahi bahwa *"tidak ada satu tool yang sempurna — pemilihan tool harus disesuaikan dengan konteks dan kebutuhan spesifik organisasi"*. Dalam konteks pipeline CI/CD open-source, Trivy menawarkan keseimbangan terbaik antara fitur, kecepatan, dan kemudahan integrasi.

---

## 5. Artifact Signing

### 5.1 Mengapa Artifact Signing Penting

Artifact signing memberikan jaminan **integritas** dan **autentisitas** dari software artifact. Dengan signing:
- Pengguna dapat memverifikasi bahwa artifact belum dimodifikasi sejak di-sign
- Pengguna dapat memverifikasi bahwa artifact berasal dari sumber yang terpercaya
- Tampering terhadap artifact akan terdeteksi saat verifikasi

### 5.2 Pendekatan Tradisional: PGP/GPG

Secara tradisional, software signing menggunakan **PGP (Pretty Good Privacy)** atau implementasinya **GPG (GNU Privacy Guard)**:

- Developer men-generate key pair (public/private)
- Artifact di-sign menggunakan private key
- Pengguna memverifikasi menggunakan public key

**Kelemahan PGP/GPG:**
- **Key management yang kompleks**: generate, distribute, rotate, revoke
- **Key discovery problem**: bagaimana pengguna mendapatkan public key yang benar?
- **Key revocation** yang tidak reliable
- **Usability** yang buruk — banyak developer yang salah menggunakan PGP
- **Tidak ada transparency log** — tidak ada catatan publik tentang signing event

Kalu et al. (2025) menemukan bahwa *"complexity of key management is the number one barrier to signing adoption"*, dan pendekatan tradisional PGP/GPG adalah kontributor utama terhadap kompleksitas ini.

### 5.3 Pendekatan Modern: Sigstore dan Cosign

**Sigstore** adalah proyek open-source di bawah **OpenSSF (Open Source Security Foundation)** yang bertujuan membuat software signing menjadi **mudah, default, dan transparan**.

Komponen utama Sigstore:

#### Cosign
- Tool untuk sign dan verify container image dan artifact OCI
- Mendukung keyless signing menggunakan OIDC identity
- Mendukung key-based signing untuk use case yang memerlukan long-lived keys

#### Fulcio
- Certificate Authority (CA) yang memberikan **short-lived certificates**
- Sertifikat diterbitkan berdasarkan OIDC identity (GitHub, Google, dll.)
- Sertifikat hanya valid selama beberapa menit — mengeliminasi kebutuhan key revocation

#### Rekor
- **Transparency log** yang immutable
- Mencatat semua signing event secara publik
- Memungkinkan audit dan verifikasi kapan saja
- Mirip dengan Certificate Transparency log untuk TLS

#### Alur Keyless Signing

```
Developer Identity (OIDC) → Fulcio (Certificate) → Sign Artifact → Rekor (Log)
```

1. Developer mengautentikasi via OIDC provider (GitHub Actions OIDC token)
2. Fulcio menerbitkan short-lived certificate berdasarkan identity
3. Artifact di-sign menggunakan certificate tersebut
4. Signing event dicatat di Rekor transparency log
5. Certificate expire — tidak perlu key management

**Keunggulan keyless signing:**
- **Tidak ada private key yang harus dikelola**
- Sertifikat short-lived mengeliminasi kebutuhan key rotation dan revocation
- Transparency log memberikan audit trail publik
- Integrasi native dengan CI/CD (GitHub Actions OIDC)

Kalu et al. (2025) menyatakan bahwa *"keyless signing approaches like Sigstore dramatically lower the barrier to adoption"*, menjadikannya solusi yang ideal untuk proyek-proyek yang ingin mengimplementasikan artifact signing tanpa overhead operasional yang signifikan.

### 5.4 Perbandingan Pendekatan Signing

| Aspek | PGP/GPG | Sigstore (Keyless) |
|-------|---------|--------------------|
| Key management | Manual, kompleks | Tidak diperlukan |
| Certificate lifetime | Long-lived | Short-lived (menit) |
| Revocation | Problematik | Tidak relevan |
| Transparency log | Tidak ada | Rekor |
| CI/CD integration | Manual | Native (OIDC) |
| Usability | Rendah | Tinggi |
| Adoption barrier | Tinggi | Rendah |

---

## 6. Apa yang Masih Kurang

Meskipun ekosistem tool dan framework untuk supply chain security telah berkembang pesat, masih ada beberapa area yang memerlukan perbaikan:

### 6.1 Standardisasi SBOM yang Belum Seragam

Keberadaan dua standar utama (CycloneDX dan SPDX) menciptakan fragmentasi. Meskipun keduanya dapat dikonversi satu sama lain, perbedaan dalam fidelity dan fitur membuat interoperabilitas tidak selalu sempurna. Xia et al. (2023) mencatat bahwa *"kurangnya standardisasi tunggal menghambat adopsi SBOM secara luas"*.

### 6.2 Kualitas SBOM yang Bervariasi

Tidak semua SBOM diciptakan sama. Akurasi SBOM sangat bergantung pada:
- Tool yang digunakan untuk generation
- Ekosistem bahasa pemrograman (maturity bervariasi)
- Fase lifecycle di mana SBOM di-generate (source, build, atau runtime)

O'Donoghue et al. (2024) menunjukkan bahwa *"tool yang berbeda menghasilkan SBOM dengan cakupan komponen yang berbeda, yang pada akhirnya mempengaruhi vulnerability detection"*.

### 6.3 Adopsi Signing yang Masih Rendah

Meskipun Sigstore telah menurunkan barrier adopsi secara signifikan, sebagian besar proyek open-source dan organisasi **belum mengimplementasikan artifact signing**. Kalu et al. (2025) mengidentifikasi bahwa selain key management, faktor lain yang menghambat adopsi termasuk:
- Kurangnya awareness tentang solusi modern
- Inertia organisasi
- Kurangnya persyaratan dari downstream consumers

### 6.4 Gap antara Generation dan Consumption

SBOM saat ini lebih banyak di-**generate** daripada di-**consume**. Banyak organisasi yang sudah menghasilkan SBOM tetapi belum memiliki proses dan tooling untuk memanfaatkan SBOM tersebut secara efektif — misalnya untuk continuous monitoring, incident response, atau compliance reporting.

### 6.5 Runtime Verification yang Belum Mature

Sebagian besar solusi saat ini fokus pada **build-time** dan **deploy-time** verification. **Runtime verification** — memastikan bahwa yang berjalan di production sesuai dengan yang di-build dan di-sign — masih merupakan area yang berkembang.

---

## 7. Posisi Proyek Kami

### 7.1 Scope Implementasi

Proyek kami mengimplementasikan **supply chain security pipeline** yang mencakup tiga pilar utama:

```
SBOM Generation → Vulnerability Scanning → Artifact Signing
     (Syft)            (Trivy)              (Cosign)
```

### 7.2 Kontribusi Terhadap State of the Art

Proyek kami berkontribusi dengan menyediakan **implementasi end-to-end yang terintegrasi** dalam satu pipeline CI/CD. Berbeda dengan sebagian besar literatur yang membahas komponen secara terpisah, kami menunjukkan bagaimana ketiga pilar ini bekerja bersama dalam satu alur kerja yang otomatis dan kohesif.

| Aspek | State of the Art | Proyek Kami |
|-------|-----------------|-------------|
| SBOM Generation | Banyak tool tersedia, adopsi rendah | Terintegrasi di pipeline, otomatis |
| Vulnerability Scanning | Tool mature, sering standalone | Input dari SBOM, gating terintegrasi |
| Artifact Signing | Sigstore available, adopsi rendah | Keyless signing, otomatis di CI/CD |
| Integrasi | Komponen biasanya terpisah | End-to-end dalam satu pipeline |

### 7.3 Alignment dengan Framework

| Framework | Level/Persyaratan | Status Proyek |
|-----------|-------------------|---------------|
| SLSA | Level 2 (hosted, signed provenance) | ✅ Tercapai |
| NIST SSDF | PS.3 (protect software artifacts) | ✅ Tercapai |
| EO 14028 | SBOM requirement | ✅ Tercapai |
| OpenSSF Scorecard | Signing, vulnerability scanning | ✅ Tercapai |

### 7.4 Keputusan Desain yang Didukung Riset

Setiap keputusan desain dalam proyek kami didasarkan pada temuan penelitian:

1. **Syft untuk SBOM** — didukung oleh O'Donoghue et al. (2024) tentang pemisahan tool generation dan scanning
2. **CycloneDX format** — didukung oleh O'Donoghue et al. (2024) tentang konsistensi detection
3. **Cosign keyless signing** — didukung oleh Kalu et al. (2025) tentang eliminasi key management barrier
4. **Fail-fast pada CRITICAL** — didukung oleh Xia et al. (2023) tentang actionability SBOM

Detail lengkap keputusan desain tersedia dalam dokumen terpisah: [03-design-decisions.md](./03-design-decisions.md).

---

## Referensi

1. Xia, B., et al. (2023). *Trusting the Trust: Exploring Practitioner Perspectives on Software Bill of Materials (SBOM)*. arXiv preprint.
2. O'Donoghue, K., et al. (2024). *An Empirical Study of SBOM Generation Tools and Their Impact on Vulnerability Assessment*. Proceedings of IEEE/ACM.
3. Kalu, O., et al. (2025). *Barriers and Enablers to Software Supply Chain Security: A Mixed-Methods Study*. ACM Computing Surveys.
4. SLSA Framework. *Supply-chain Levels for Software Artifacts*. https://slsa.dev
5. NIST. *SP 800-218: Secure Software Development Framework (SSDF)*. https://csrc.nist.gov/publications/detail/sp/800-218/final
6. The White House. *Executive Order 14028: Improving the Nation's Cybersecurity*. May 2021.
7. OpenSSF. *Scorecard: Security Health Metrics for Open Source*. https://securityscorecards.dev
8. Sigstore. *Software Signing for Everyone*. https://sigstore.dev
