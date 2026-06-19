# Kelompok 8 — DevSecOps Supply Chain Security

> **"Meningkatkan pipeline DevSecOps dengan Software Supply Chain Security (SBOM Generation + Vulnerability Scanning + Artifact Signing) karena gap kurangnya transparansi dependensi dan verifikasi integritas artifact."**

[![Enhanced Pipeline](https://github.com/dianggraaeni/kelompok-8-devsecops-future/actions/workflows/enhanced-pipeline.yml/badge.svg)](https://github.com/dianggraaeni/kelompok-8-devsecops-future/actions/workflows/enhanced-pipeline.yml)

---

## Daftar Isi

- [Ringkasan Proyek](#-ringkasan-proyek)
- [Tim](#-tim)
- [Arsitektur](#-arsitektur)
- [Paper yang Digunakan](#-paper-yang-digunakan)
- [Quick Start](#-quick-start)
- [Struktur Repositori](#-struktur-repositori)
- [Komponen Implementasi](#-komponen-implementasi)
- [Evaluasi](#-evaluasi)
- [Cara Reproduksi](#-cara-reproduksi)

---

## Ringkasan Proyek

### Masalah yang Diselesaikan

Pipeline CI/CD tradisional umumnya hanya menjalankan: **Code → Build → Test → Deploy**. Namun, pipeline ini memiliki gap keamanan supply chain yang serius:

| # | Gap | Dampak |
|---|-----|--------|
| 1 | ❌ Tidak ada inventory dependensi (SBOM) | Tidak tahu komponen apa yang berjalan di production |
| 2 | ❌ Tidak ada vulnerability scanning | CVE di dependensi tidak terdeteksi |
| 3 | ❌ Tidak ada artifact signing | Container image bisa di-tamper tanpa terdeteksi |
| 4 | ❌ Tidak ada provenance | Tidak bisa membuktikan asal-usul artifact |

### Solusi yang Diimplementasikan

Kami menambahkan **3 komponen keamanan supply chain** ke pipeline berdasarkan temuan dari paper ilmiah:

1. **SBOM Generation** — Menggunakan [Syft](https://github.com/anchore/syft) dengan format CycloneDX
2. **Vulnerability Scanning** — Menggunakan [Trivy](https://github.com/aquasecurity/trivy) dengan security gate
3. **Artifact Signing** — Menggunakan [Cosign](https://github.com/sigstore/cosign) dengan Sigstore keyless signing

---

## Tim

| NRP | Nama | Komponen Teknis |
|---------|------|-----------------|
| **5027231016** | Dian Anggraeni Putri | App & Containerization (Node.js app, Dockerfile) |
| **5027231020** | Acintya Edria Sudarsono | Vulnerability Scanning & Gate (Trivy, security gate) |
| **5027231036** | Tsaldia Hukma Cita | CI/CD Pipeline & SBOM (GitHub Actions, Syft) |
| **5027231060** | Callista Meyra Azizah | Artifact Signing & Verification (Cosign, Sigstore) |

---

## Arsitektur

### Pipeline Sebelum (Baseline)
```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Code    │ →  │  Build   │ →  │  Test    │ →  │ Deploy   │
│  Push    │    │  Image   │    │  (Unit)  │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
       ❌ No SBOM        ❌ No signing      ❌ No vuln scan
```

### Pipeline Sesudah (Enhanced)
```
┌──────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────┐
│  Code    │ →  │  Build   │ →  │ 📋 SBOM Gen │ →  │ 🔍 Vuln     │ →  │ ✍️ Sign  │ →  │ 🚀 Deploy│
│  Push    │    │  Image   │    │ (Syft +      │    │ Scan (Trivy  │    │ (Cosign  │    │          │
│          │    │  & Push  │    │  CycloneDX)  │    │  + Gate)     │    │  keyless)│    │          │
└──────────┘    └──────────┘    └──────────────┘    └──────────────┘    └──────────┘    └──────────┘
                                      │                    │                  │
                                      ▼                    ▼                  ▼
                               ┌──────────────┐    ┌──────────────┐   ┌───────────┐
                               │ SBOM Artifact│    │ Vulnerability│   │ Signature │
                               │ (CycloneDX)  │    │ Report       │   │ (Rekor    │
                               └──────────────┘    │ (SARIF)      │   │  log)     │
                                                   └──────────────┘   └───────────┘
                                                         │
                                                         ▼
                                                  ┌──────────────┐
                                                  │ 🚨 Gate:     │
                                                  │ Block deploy │
                                                  │ jika CRITICAL│
                                                  │ CVE ditemukan│
                                                  └──────────────┘
```

---

## Paper yang Digunakan

### Paper 1 (Utama)
> **"An Empirical Study on Software Bill of Materials: Where We Stand and the Road Ahead"**
> Boming Xia, Tingting Bi, Zhenchang Xing, Qinghua Lu, Liming Zhu — **ICSE 2023** (CORE A*)
> DOI: [10.1109/ICSE48619.2023.00197](https://doi.org/10.1109/ICSE48619.2023.00197)

### Paper 2 (Pendamping)
> **"Impacts of Software Bill of Materials (SBOM) Generation on Vulnerability Detection"**
> Eric O'Donoghue, Brittany Boles, Clemente Izurieta, Ann Marie Reinhold — **SCORED '24 @ ACM CCS 2024**
> DOI: [10.1145/3689944.3696164](https://doi.org/10.1145/3689944.3696164)

### Paper Bonus
> **"An Industry Interview Study of Software Signing for Supply Chain Security"**
> Kelechi G. Kalu, et al. — **USENIX Security 2025**

Lihat [catatan bacaan lengkap di `papers/`](papers/)

---

## Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [Docker](https://www.docker.com/) v20+
- [Git](https://git-scm.com/)
- GitHub account dengan akses ke GitHub Container Registry

### Setup dari Nol

```bash
# 1. Clone repository
git clone https://github.com/dianggraaeni/kelompok-8-devsecops-future.git
cd kelompok-8-devsecops-future

# 2. Install dependencies
cd app
npm install

# 3. Jalankan tests
npm test

# 4. Jalankan aplikasi secara lokal
npm start
# Aplikasi berjalan di http://localhost:3000

# 5. Cek health endpoint
curl http://localhost:3000/health
```

### Build Docker Image

```bash
# Build image
cd app
docker build -t devsecops-demo:latest .

# Jalankan container
docker run -p 3000:3000 devsecops-demo:latest

# Cek health
curl http://localhost:3000/health
```

### Menjalankan Full Pipeline

Pipeline berjalan otomatis saat push ke branch `main` atau `develop`. Untuk trigger manual:

1. Buka tab **Actions** di GitHub
2. Pilih workflow **"Enhanced Pipeline (With Supply Chain Security)"**
3. Klik **"Run workflow"**

### Verifikasi Lokal (Opsional)

Jika ingin menjalankan tools secara lokal:

```bash
# Install Syft
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Generate SBOM
syft packages devsecops-demo:latest -o cyclonedx-json > sbom.cdx.json

# Install Trivy
# (lihat https://aquasecurity.github.io/trivy/latest/getting-started/installation/)

# Scan vulnerabilities dari SBOM
trivy sbom sbom.cdx.json

# Scan image langsung
trivy image devsecops-demo:latest

# Install Cosign
# (lihat https://docs.sigstore.dev/system_config/installation/)

# Verify image signature (setelah pipeline sign)
cosign verify \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  --certificate-identity-regexp=".*" \
  ghcr.io/dianggraaeni/kelompok-8-devsecops-future/devsecops-demo:latest
```

---

## Struktur Repositori

```
kelompok-8-devsecops-future/
├── README.md                          ← Dokumen ini
├── .gitignore
├── app/                               ← Aplikasi target (Anggota A — Dian)
│   ├── package.json                   ← Dependencies (termasuk yang vulnerable untuk demo)
│   ├── Dockerfile                     ← Multi-stage Docker build
│   ├── .dockerignore
│   └── src/
│       ├── index.js                   ← Express.js REST API
│       └── index.test.js              ← Unit tests (Jest + Supertest)
├── .github/
│   └── workflows/
│       ├── baseline-pipeline.yml      ← Pipeline TANPA enhancement (baseline)
│       └── enhanced-pipeline.yml      ← Pipeline DENGAN supply chain security
├── papers/
│   ├── paper-1-sbom-empirical-study.md   ← Reading notes: Xia et al. (2023)
│   └── paper-2-sbom-vuln-detection.md    ← Reading notes: O'Donoghue et al. (2024)
├── research/
│   ├── 01-gap-analysis.md             ← Gap yang diselesaikan, berbasis paper
│   ├── 02-state-of-the-art.md         ← Landscape supply chain security
│   └── 03-design-decisions.md         ← Keputusan desain + justifikasi paper
├── implementation/
│   ├── README-implementation.md       ← Dokumentasi implementasi
│   ├── syft-config.yaml               ← Konfigurasi Syft (SBOM generation)
│   ├── trivy-config.yaml              ← Konfigurasi Trivy (vulnerability scanning)
│   └── cosign-policy.yaml             ← Konfigurasi Cosign (artifact signing)
├── evaluation/
│   ├── metrics-before.md              ← Baseline sebelum implementasi
│   ├── metrics-after.md               ← Pengukuran setelah implementasi
│   └── analysis.md                    ← Analisis perbandingan
├── presentation/
│   └── (slides.pdf)                   ← Slide presentasi
└── docs/
    └── refleksi-kelompok.md           ← Refleksi kelompok (3 pertanyaan)
```

---

## Komponen Implementasi

### 1. Aplikasi Target (Anggota A — Dian)

| Aspek | Detail |
|-------|--------|
| **Bahasa** | Node.js (Express.js) |
| **Tipe** | REST API — Task Management |
| **Endpoints** | Health, Auth (register/login), Tasks CRUD, Stats |
| **Testing** | Jest + Supertest (unit tests) |
| **Docker** | Multi-stage build, non-root user, health check |

**Fitur keamanan Dockerfile:**
- ✅ Multi-stage build (build vs production)
- ✅ Non-root user (`appuser`)
- ✅ Production-only dependencies (`npm ci --omit=dev`)
- ✅ OCI labels untuk traceability
- ✅ Docker HEALTHCHECK

**Vulnerable dependencies:**

| Package | Version | CVE | Severity |
|---------|---------|-----|----------|
| lodash | 4.17.15 | CVE-2021-23337 | 🟠 HIGH |
| lodash | 4.17.15 | CVE-2019-10744 | 🔴 CRITICAL |
| jsonwebtoken | 8.5.1 | CVE-2022-23529 | 🟠 HIGH |
| axios | 0.21.1 | CVE-2021-3749 | 🟠 HIGH |
| minimist | 1.2.5 | CVE-2021-44906 | 🔴 CRITICAL |
| node-fetch | 2.6.0 | CVE-2022-0235 | 🟠 HIGH |

> ⚠️ Dependencies ini **sengaja** menggunakan versi lama dengan known CVE untuk mendemonstrasikan kemampuan vulnerability scanning. Dalam production, semua dependencies harus di-update ke versi terbaru.

### 2. SBOM Generation

- **Tool**: Syft (Anchore)
- **Format**: CycloneDX JSON + SPDX JSON
- **Justifikasi**: O'Donoghue et al. (2024) — Syft memiliki coverage paling konsisten

### 3. Vulnerability Scanning

- **Tool**: Trivy (Aqua Security)
- **Mode**: Image scan + SBOM-based scan
- **Output**: SARIF (untuk GitHub Security tab) + JSON
- **Gate**: Pipeline fail pada CRITICAL vulnerability
- **Justifikasi**: O'Donoghue et al. (2024) — Trivy memiliki detection rate tinggi

### 4. Artifact Signing

- **Tool**: Cosign (Sigstore)
- **Mode**: Keyless signing (OIDC via GitHub Actions)
- **Log**: Rekor transparency log
- **Justifikasi**: Kalu et al. (2025) — keyless signing menghilangkan barrier key management

---

## Evaluasi

### Metrik Perbandingan

| Metrik | Sebelum | Sesudah |
|--------|---------|---------|
| Vulnerability terdeteksi | 0 | N (terdeteksi otomatis) |
| SBOM coverage | 0% | 100% direct+transitive |
| Artifact signing | ❌ Tidak ada | ✅ 100% signed |
| Security gate | ❌ Tidak ada | ✅ Fail pada CRITICAL |
| SLSA level | Level 0 | Level 1-2 |

Lihat detail lengkap di [`evaluation/`](evaluation/)

---

## API Reference

### Endpoints

| Method | Endpoint | Auth | Deskripsi |
|--------|----------|------|-----------|
| GET | `/health` | ❌ | Health check |
| GET | `/info` | ❌ | Informasi aplikasi |
| POST | `/auth/register` | ❌ | Register user baru |
| POST | `/auth/login` | ❌ | Login (dapatkan JWT token) |
| POST | `/tasks` | ✅ | Buat task baru |
| GET | `/tasks` | ✅ | List semua tasks (filter: status, priority) |
| GET | `/tasks/:id` | ✅ | Detail satu task |
| PUT | `/tasks/:id` | ✅ | Update task |
| DELETE | `/tasks/:id` | ✅ | Hapus task |
| GET | `/stats` | ✅ | Statistik tasks |
| GET | `/external/status` | ❌ | Cek koneksi external API |

### Contoh Penggunaan

```bash
# Register
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "email": "demo@example.com"}'

# Login
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "demo"}' | jq -r '.token')

# Create task
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "Setup SBOM", "priority": "high"}'

# List tasks
curl http://localhost:3000/tasks \
  -H "Authorization: Bearer $TOKEN"
```

---

## Cara Reproduksi

### Dari Nol (Untuk Verifikasi Reproducibility)

1. **Clone repo** dan pastikan semua file ada
2. **Jalankan `npm install`** di folder `app/`
3. **Jalankan `npm test`** — semua test harus pass
4. **Build Docker image** — `docker build -t devsecops-demo .` di folder `app/`
5. **Jalankan container** — `docker run -p 3000:3000 devsecops-demo`
6. **Cek health** — `curl http://localhost:3000/health`
7. **Push ke GitHub** — Pipeline Enhanced akan berjalan otomatis
8. **Cek GitHub Actions** — Lihat SBOM, vulnerability scan, dan signing results

---

## Lisensi

Proyek ini dibuat untuk keperluan akademis — Tugas Akhir mata kuliah Operasional Pengembang (DevOps).

---

*Dibuat oleh Kelompok 8 — Dian, Acin, Tsaldia, Callista*
