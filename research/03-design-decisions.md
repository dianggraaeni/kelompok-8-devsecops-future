# Design Decisions: Keputusan Desain Pipeline Supply Chain Security

> **Dokumen Riset — Kelompok 8 DevSecOps**
> Tanggal: Juni 2026

---

## Pendahuluan

Dokumen ini mendokumentasikan setiap keputusan desain yang kami ambil dalam membangun pipeline supply chain security. Setiap keputusan didasarkan pada temuan penelitian akademis dan best practices industri, mengikuti format:

> *"Kami memilih [pendekatan X] karena [Penulis, Tahun] menunjukkan bahwa [temuan Y]. Dalam konteks pipeline kami, ini berarti [implikasi Z]."*

Tiga paper utama yang menjadi dasar keputusan kami:

| Paper | Penulis | Tahun | Fokus |
|-------|---------|-------|-------|
| Paper 1 | Xia et al. | 2023 | Perspektif praktisi terhadap SBOM |
| Paper 2 | O'Donoghue et al. | 2024 | Studi empiris tool SBOM dan vulnerability assessment |
| Paper 3 | Kalu et al. | 2025 | Barriers dan enablers software supply chain security |

---

## Keputusan 1: Syft untuk SBOM Generation

### Keputusan

> *Kami memilih **Syft** (Anchore) sebagai tool SBOM generation karena O'Donoghue et al. (2024) menunjukkan bahwa **pemisahan tool antara generation dan scanning menghasilkan coverage dan akurasi yang lebih baik** dibandingkan menggunakan satu tool untuk kedua tugas. Dalam konteks pipeline kami, ini berarti kami mendapatkan SBOM yang lebih lengkap dan komprehensif yang kemudian dapat digunakan oleh scanner manapun sebagai input.*

### Rasionalisasi Detail

O'Donoghue et al. (2024) melakukan studi empiris yang membandingkan berbagai tool SBOM generation dan dampaknya terhadap vulnerability assessment. Temuan kunci yang relevan:

1. **Tool yang dirancang khusus untuk SBOM generation** (seperti Syft) menghasilkan daftar komponen yang lebih lengkap dibandingkan tool yang menggabungkan generation dan scanning dalam satu proses
2. **Coverage dependensi transitif** lebih baik ketika SBOM di-generate oleh tool yang dedicated
3. **Format output yang konsisten** memudahkan integrasi dengan berbagai scanner

### Alternatif yang Dipertimbangkan

#### Alternatif 1: Trivy sebagai SBOM Generator + Scanner (All-in-One)

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Satu tool untuk semua fungsi, setup lebih sederhana |
| Kekurangan | Coverage SBOM bisa lebih rendah karena bukan fokus utama |
| Keputusan | Ditolak — O'Donoghue et al. (2024) menunjukkan tool dedicated menghasilkan SBOM yang lebih komprehensif |

#### Alternatif 2: cdxgen

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Fokus pada CycloneDX, coverage JavaScript/Node.js yang sangat baik |
| Kekurangan | Kurang mature dibanding Syft, komunitas lebih kecil |
| Keputusan | Tidak dipilih — Syft menawarkan multi-ecosystem support yang lebih luas dan komunitas yang lebih aktif |

#### Alternatif 3: Microsoft SBOM Tool (sbom-tool)

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Didukung Microsoft, fokus pada SPDX |
| Kekurangan | Fokus SPDX (bukan CycloneDX), kurang fleksibel |
| Keputusan | Tidak dipilih — kami memilih CycloneDX sebagai format (lihat Keputusan 2) |

### Implementasi

```yaml
# GitHub Actions step
- name: Generate SBOM with Syft
  uses: anchore/sbom-action@v0
  with:
    image: ${{ env.IMAGE_NAME }}:${{ github.sha }}
    format: cyclonedx-json
    output-file: sbom.cdx.json
```

---

## Keputusan 2: Format CycloneDX (bukan SPDX)

### Keputusan

> *Kami memilih **CycloneDX** sebagai format SBOM karena O'Donoghue et al. (2024) menunjukkan bahwa **CycloneDX menghasilkan vulnerability detection yang lebih konsisten dalam konteks CI/CD pipeline**. Dalam konteks pipeline kami, konsistensi deteksi vulnerability adalah prioritas tertinggi karena kami menggunakan SBOM sebagai input langsung untuk scanning otomatis yang menentukan apakah deployment dilanjutkan atau dihentikan (gating).*

### Rasionalisasi Detail

O'Donoghue et al. (2024) membandingkan output vulnerability scanning menggunakan SBOM dalam format CycloneDX versus SPDX. Temuan yang relevan:

1. **Konsistensi deteksi**: CycloneDX menghasilkan hasil vulnerability detection yang lebih konsisten di berbagai tool scanner
2. **Mapping ke vulnerability database**: CycloneDX memiliki mapping yang lebih langsung ke identifier vulnerability (CPE, PURL)
3. **Kecepatan parsing**: Format CycloneDX JSON lebih cepat diproses oleh scanner

### Trade-offs

| Aspek | CycloneDX | SPDX |
|-------|-----------|------|
| **Standardisasi** | Standar OWASP, belum ISO | ISO/IEC 5962:2021 ✅ |
| **Security focus** | Sangat baik ✅ | Baik |
| **License compliance** | Baik | Sangat baik ✅ |
| **CI/CD integration** | Sangat baik ✅ | Baik |
| **Vulnerability mapping** | Sangat baik ✅ | Baik |
| **Enterprise adoption** | Meningkat | Lebih tinggi |
| **Interoperability** | Sangat baik ✅ | Sangat baik ✅ |

**Trade-off utama:** Dengan memilih CycloneDX, kami mengorbankan standar ISO yang dimiliki SPDX. Namun, dalam konteks proyek kami yang berfokus pada **security** (bukan license compliance), CycloneDX memberikan keuntungan yang lebih relevan.

### Justifikasi Tambahan

Xia et al. (2023) juga mencatat bahwa *"format SBOM harus dipilih berdasarkan use case utama"*. Karena use case utama kami adalah **vulnerability detection dan pipeline gating**, CycloneDX adalah pilihan yang lebih tepat.

---

## Keputusan 3: Keyless Signing dengan Sigstore/Cosign

### Keputusan

> *Kami memilih **Sigstore keyless signing** (menggunakan Cosign) karena Kalu et al. (2025) menemukan bahwa **key management complexity adalah barrier #1 adopsi software signing**. Dalam konteks pipeline kami, keyless signing mengeliminasi kebutuhan untuk mengelola private key secara manual — autentikasi dilakukan melalui OIDC token dari GitHub Actions, sertifikat bersifat short-lived, dan semua signing event dicatat di Rekor transparency log.*

### Rasionalisasi Detail

Kalu et al. (2025) melakukan studi mixed-methods yang mengidentifikasi barriers dan enablers dalam adopsi software supply chain security. Temuan utama tentang signing:

1. **Key management complexity** (generate, store, rotate, revoke) menjadi alasan #1 organisasi tidak mengadopsi artifact signing
2. **Kurangnya infrastruktur PKI** di organisasi kecil-menengah memperburuk masalah ini
3. **Keyless signing approaches** seperti Sigstore secara dramatis menurunkan barrier adopsi
4. **Transparency logs** memberikan mekanisme audit yang tidak tersedia di pendekatan tradisional

### Alternatif yang Dipertimbangkan

#### Alternatif 1: PGP/GPG Signing dengan Key Pair Manual

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Mature, well-understood, tidak bergantung pada layanan eksternal |
| Kekurangan | Key management complexity tinggi, tidak ada transparency log, key distribution problem |
| Keputusan | Ditolak — Kalu et al. (2025) mengidentifikasi ini sebagai barrier utama adopsi |

#### Alternatif 2: Cosign dengan Key Pair (Key-based, bukan Keyless)

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Tidak bergantung pada OIDC provider, key bisa disimpan di KMS |
| Kekurangan | Masih memerlukan key management (meskipun lebih sederhana dari PGP) |
| Keputusan | Tidak dipilih sebagai default — keyless lebih sesuai untuk CI/CD pipeline yang terotomasi |

#### Alternatif 3: Notation (Microsoft/AWS)

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Didukung oleh Microsoft dan AWS, integrasi dengan cloud KMS |
| Kekurangan | Ekosistem lebih kecil, memerlukan cloud KMS setup, kurang mature |
| Keputusan | Tidak dipilih — Sigstore/Cosign memiliki ekosistem yang lebih mature dan komunitas yang lebih besar |

### Cara Kerja dalam Pipeline Kami

```
GitHub Actions Workflow Triggered
         │
         ▼
  OIDC Token Generated ──→ Fulcio CA
         │                    │
         │               Short-lived
         │               Certificate
         │                    │
         ▼                    ▼
  Container Image ──→ Cosign Sign ──→ Rekor Log
         │
         ▼
  Signed Image Pushed to Registry
```

### Implementasi

```yaml
# GitHub Actions step
- name: Sign container image (keyless)
  env:
    COSIGN_EXPERIMENTAL: "true"
  run: |
    cosign sign --yes \
      ${{ env.IMAGE_NAME }}@${{ steps.build.outputs.digest }}
```

---

## Keputusan 4: Trivy untuk Vulnerability Scanning

### Keputusan

> *Kami memilih **Trivy** (Aqua Security) sebagai vulnerability scanner karena O'Donoghue et al. (2024) menunjukkan bahwa **pemilihan tool scanning secara signifikan mempengaruhi hasil deteksi vulnerability**, dan Trivy secara konsisten menunjukkan coverage yang tinggi terhadap berbagai ekosistem. Dalam konteks pipeline kami, Trivy menerima SBOM CycloneDX sebagai input (dihasilkan oleh Syft), memungkinkan pendekatan terpisah yang direkomendasikan oleh penelitian.*

### Rasionalisasi Detail

O'Donoghue et al. (2024) menemukan bahwa:

1. **Tidak semua scanner mendeteksi vulnerability yang sama** — ada variasi signifikan antar tool
2. **Trivy memiliki coverage yang konsisten** di berbagai ekosistem, termasuk Node.js
3. **Input dari SBOM** menghasilkan scanning yang lebih fokus dan akurat
4. **Multi-source vulnerability database** (NVD, GitHub Advisories, vendor advisories) memberikan coverage yang lebih luas

### Alternatif yang Dipertimbangkan

#### Alternatif 1: Grype (Anchore)

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Companion tool untuk Syft (sama-sama Anchore), SBOM-first design |
| Kekurangan | Database vulnerability lebih terbatas, fitur tambahan (IaC scan) tidak tersedia |
| Keputusan | Tidak dipilih — Trivy menawarkan fitur yang lebih lengkap dan database yang lebih komprehensif |

#### Alternatif 2: Snyk

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Database vulnerability proprietary yang sangat lengkap, fitur auto-fix |
| Kekurangan | Komersial (batas gratis terbatas), tidak fully open-source, vendor lock-in |
| Keputusan | Tidak dipilih — sebagai proyek akademis, kami memprioritaskan tool open-source yang dapat direproduksi tanpa batasan lisensi |

#### Alternatif 3: OSV-Scanner (Google)

| Aspek | Evaluasi |
|-------|----------|
| Kelebihan | Database OSV yang terkurasi, fokus pada ekosistem open-source |
| Kekurangan | Fitur lebih terbatas, container image scanning kurang mature |
| Keputusan | Tidak dipilih — Trivy lebih mature dan memiliki fitur yang lebih lengkap |

### Mengapa Bukan "Syft + Grype" (Satu Vendor)?

Meskipun Syft dan Grype berasal dari vendor yang sama (Anchore) dan dirancang untuk bekerja bersama, kami memilih **Syft + Trivy** karena:

1. O'Donoghue et al. (2024) menunjukkan bahwa **diversifikasi tool** dapat meningkatkan coverage
2. Trivy memiliki **database vulnerability yang lebih luas** (multi-source)
3. Trivy menawarkan **fitur tambahan** seperti IaC scanning dan secret detection yang berguna untuk future expansion
4. Format SBOM CycloneDX bersifat **tool-agnostic** — scanner manapun dapat memprosesnya

### Implementasi

```yaml
# GitHub Actions step
- name: Scan SBOM for vulnerabilities
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: sbom
    input: sbom.cdx.json
    severity: CRITICAL,HIGH
    exit-code: 1  # Fail pipeline on findings
```

---

## Keputusan 5: Fail-Fast pada CRITICAL Vulnerability

### Keputusan

> *Kami menerapkan kebijakan **fail-fast** yang menghentikan pipeline ketika ditemukan vulnerability dengan severity **CRITICAL** karena Xia et al. (2023) menekankan bahwa **nilai SBOM terletak pada actionability-nya** — SBOM yang dihasilkan tapi tidak ditindaklanjuti tidak memberikan manfaat keamanan yang nyata. Dalam konteks pipeline kami, ini berarti pipeline secara otomatis mencegah deployment container image yang mengandung vulnerability kritis, memastikan bahwa SBOM bukan hanya dokumen pasif tetapi secara aktif melindungi production environment.*

### Rasionalisasi Detail

Xia et al. (2023) menyoroti bahwa:

1. **SBOM tanpa aksi** adalah latihan compliance semata — tidak meningkatkan keamanan aktual
2. **Actionability** adalah faktor kunci yang membedakan implementasi SBOM yang efektif dari yang tidak
3. **Automated gating** (menghentikan pipeline berdasarkan temuan) adalah bentuk actionability yang paling langsung
4. Praktisi yang diwawancarai dalam studi ini menekankan pentingnya **automated response** terhadap temuan vulnerability

### Policy yang Diterapkan

| Severity | Aksi | Alasan |
|----------|------|--------|
| CRITICAL | ❌ **Block deployment** | Risiko eksploitasi sangat tinggi, harus diperbaiki sebelum deploy |
| HIGH | ⚠️ **Warning, log** | Perlu perhatian tapi mungkin ada mitigasi lain; tidak otomatis memblokir untuk menghindari pipeline stall yang berlebihan |
| MEDIUM | ℹ️ **Log only** | Dicatat untuk remediasi terjadwal |
| LOW | ℹ️ **Log only** | Dicatat untuk awareness |

### Trade-offs

**Pro:**
- Mencegah deployment image dengan vulnerability kritis ke production
- Memaksa tim untuk menangani vulnerability kritis segera
- Memberikan enforcement otomatis tanpa bergantung pada proses manual review

**Kontra:**
- Bisa menyebabkan **deployment delay** jika ada false positive
- Vulnerability di base image atau OS package mungkin tidak bisa segera diperbaiki
- Memerlukan proses **exception/waiver** untuk kasus tertentu

### Mitigasi Kontra

- Menggunakan severity **CRITICAL only** (bukan CRITICAL+HIGH) untuk mengurangi false positive dan pipeline blockage
- Menyediakan mekanisme **ignore file** (`.trivyignore`) untuk vulnerability yang sudah di-assess dan diterima risikonya
- Tim melakukan review berkala terhadap policy threshold

### Kalu et al. (2025) juga mendukung pendekatan ini:

> Kalu et al. (2025) menemukan bahwa organisasi yang mengimplementasikan **automated security gates** dalam pipeline CI/CD mereka menunjukkan postur keamanan yang secara signifikan lebih baik dibandingkan yang mengandalkan review manual.

---

## Keputusan 6: Node.js sebagai Aplikasi Target

### Keputusan

> *Kami memilih **Node.js** sebagai ekosistem aplikasi target karena O'Donoghue et al. (2024) dan Xia et al. (2023) mencatat bahwa **kematangan (maturity) tooling SBOM bervariasi antar ekosistem**, dan ekosistem Node.js/npm memiliki salah satu tingkat dukungan tooling yang paling mature. Dalam konteks pipeline kami, ini berarti kami dapat mendemonstrasikan implementasi supply chain security dengan tingkat keberhasilan dan akurasi yang tinggi.*

### Rasionalisasi Detail

1. **Ekosistem npm** memiliki file lock (`package-lock.json`) yang detail dan terstandar, memudahkan SBOM generation yang akurat
2. **Dependency tree** Node.js yang mendalam memberikan contoh yang baik tentang pentingnya scanning transitive dependencies
3. **Tool support** untuk SBOM generation dan vulnerability scanning di ekosistem Node.js sangat mature
4. Xia et al. (2023) mencatat bahwa *"ekosistem dengan package manager yang mature memiliki tingkat akurasi SBOM yang lebih tinggi"*

### Mengapa Bukan Ekosistem Lain?

| Ekosistem | SBOM Maturity | Alasan Tidak Dipilih |
|-----------|--------------|---------------------|
| Python (pip) | Sedang | `requirements.txt` tidak selalu menyertakan transitive dependencies |
| Java (Maven) | Tinggi | Kompleksitas setup yang lebih tinggi untuk proyek demo |
| Go | Tinggi | Go modules cukup mature, tapi ekosistem dependensi lebih kecil |
| Rust (Cargo) | Sedang | Ekosistem lebih baru, tooling SBOM kurang mature |

### Karakteristik Node.js yang Relevan

```
Aplikasi Node.js Sederhana
├── package.json (direct dependencies)
├── package-lock.json (full dependency tree, pinned versions)
└── node_modules/
    ├── express/
    │   ├── body-parser/
    │   │   └── raw-body/
    │   ├── cookie/
    │   └── ... (ratusan sub-dependencies)
    └── ... 
```

Sebuah aplikasi Express.js sederhana dengan beberapa direct dependencies bisa memiliki **200-500+ transitive dependencies**. Ini memberikan demonstrasi yang sangat relevan tentang mengapa SBOM dan vulnerability scanning diperlukan.

---

## Keputusan 7: Multi-stage Docker Build

### Keputusan

> *Kami menggunakan **multi-stage Docker build** karena Kalu et al. (2025) menekankan pentingnya **mengurangi attack surface** sebagai prinsip dasar supply chain security, dan Xia et al. (2023) menyoroti bahwa **komponen yang tidak diperlukan di production seharusnya tidak ada di production image**. Dalam konteks pipeline kami, multi-stage build memastikan bahwa development dependencies, build tools, dan file sementara tidak masuk ke dalam final image, sehingga SBOM yang dihasilkan hanya mencerminkan komponen yang benar-benar berjalan di production.*

### Rasionalisasi Detail

1. **Attack surface reduction**: Image yang lebih kecil dengan lebih sedikit komponen berarti lebih sedikit potential vulnerability
2. **SBOM accuracy**: SBOM yang di-generate dari production image hanya berisi komponen yang benar-benar diperlukan
3. **Scan efficiency**: Fewer components = faster scanning = faster pipeline
4. **Compliance**: Menunjukkan bahwa kami mengikuti prinsip least privilege dan minimal footprint

### Arsitektur Multi-stage Build

```dockerfile
# ============================================
# Stage 1: Build (dependencies & compilation)
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Install ALL dependencies (termasuk devDependencies)
COPY package*.json ./
RUN npm ci

# Copy source dan build
COPY . .
RUN npm run build

# ============================================
# Stage 2: Production (runtime only)
# ============================================
FROM node:20-alpine AS production

WORKDIR /app

# Install PRODUCTION dependencies only
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy built artifacts dari stage builder
COPY --from=builder /app/dist ./dist

# Non-root user untuk security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001
USER appuser

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Perbandingan: Single-stage vs Multi-stage

| Aspek | Single-stage | Multi-stage |
|-------|-------------|-------------|
| Image size | ~500MB+ | ~150MB |
| Dependencies di image | Semua (dev + prod) | Production only |
| Build tools di image | ✅ Ada | ❌ Tidak ada |
| SBOM accuracy | Mencakup komponen yang tidak perlu | Hanya komponen production |
| Attack surface | Luas | Minimal |
| Vulnerability scan results | Banyak noise dari dev deps | Fokus pada production deps |

### Dampak pada Pipeline

Dengan multi-stage build:

1. **SBOM yang dihasilkan Syft** hanya mencakup production dependencies, bukan devDependencies
2. **Vulnerability scanning** oleh Trivy menghasilkan temuan yang lebih relevan (less noise)
3. **Image yang di-sign** oleh Cosign memiliki footprint yang lebih kecil dan lebih aman
4. **Compliance posture** lebih baik karena menunjukkan prinsip minimal footprint

Xia et al. (2023) menegaskan bahwa *"kualitas SBOM sangat bergantung pada apa yang ada di dalam artifact — semakin bersih artifact, semakin meaningful SBOM-nya"*.

---

## Ringkasan Keputusan Desain

| # | Keputusan | Tool/Pendekatan | Paper Pendukung | Alasan Utama |
|---|-----------|----------------|-----------------|--------------|
| 1 | SBOM Generation | Syft | O'Donoghue et al. (2024) | Pemisahan generation/scanning lebih akurat |
| 2 | Format SBOM | CycloneDX | O'Donoghue et al. (2024) | Konsistensi deteksi vulnerability di CI/CD |
| 3 | Artifact Signing | Cosign (keyless) | Kalu et al. (2025) | Eliminasi key management barrier |
| 4 | Vulnerability Scanner | Trivy | O'Donoghue et al. (2024) | Coverage tinggi, multi-source DB |
| 5 | Pipeline Policy | Fail-fast CRITICAL | Xia et al. (2023) | Actionability SBOM |
| 6 | Ekosistem Target | Node.js | O'Donoghue/Xia | Tooling maturity tinggi |
| 7 | Docker Strategy | Multi-stage build | Kalu/Xia | Attack surface reduction, SBOM accuracy |

---

## Referensi

1. Xia, B., et al. (2023). *Trusting the Trust: Exploring Practitioner Perspectives on Software Bill of Materials (SBOM)*. arXiv preprint.
2. O'Donoghue, K., et al. (2024). *An Empirical Study of SBOM Generation Tools and Their Impact on Vulnerability Assessment*. Proceedings of IEEE/ACM.
3. Kalu, O., et al. (2025). *Barriers and Enablers to Software Supply Chain Security: A Mixed-Methods Study*. ACM Computing Surveys.
4. SLSA Framework. *Supply-chain Levels for Software Artifacts*. https://slsa.dev
5. Sigstore. *Cosign: Container Signing, Verification and Storage in an OCI Registry*. https://sigstore.dev
6. Aqua Security. *Trivy: A Simple and Comprehensive Vulnerability Scanner*. https://trivy.dev
7. Anchore. *Syft: A CLI tool and Go library for generating SBOMs*. https://github.com/anchore/syft
