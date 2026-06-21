# README — Implementasi DevSecOps Supply Chain Security

> **Kelompok 8** — Proyek Keamanan Supply Chain pada CI/CD Pipeline  
> Repositori: `kelompok-8-devsecops-future`

---

## 1. Komponen yang Diimplementasikan

Implementasi ini terdiri dari **5 komponen utama** yang bekerja secara terintegrasi dalam pipeline CI/CD:

| No | Komponen | Tool | Deskripsi |
|----|----------|------|-----------|
| 1 | **App & Containerization** | Docker | Aplikasi web sederhana yang dikemas dalam container Docker dengan multi-stage build untuk meminimalkan attack surface |
| 2 | **SBOM Generation** | Syft (Anchore) | Menghasilkan Software Bill of Materials dalam format CycloneDX JSON dari container image |
| 3 | **Vulnerability Scanning** | Trivy (Aqua Security) | Memindai SBOM dan container image untuk mendeteksi kerentanan yang diketahui (CVE) |
| 4 | **Artifact Signing** | Cosign (Sigstore) | Menandatangani container image secara kriptografis untuk menjamin integritas dan provenance |
| 5 | **CI/CD Integration** | GitHub Actions | Mengorkestrasikan seluruh pipeline secara otomatis pada setiap push atau pull request |

### Mengapa Tool Ini?

- **Syft** dipilih berdasarkan temuan O'Donoghue et al. (2024) yang menunjukkan variasi signifikan antar-tool SBOM — Syft memiliki cakupan deteksi komponen yang luas.
- **Trivy** digunakan terpisah dari Syft agar fungsi *generation* dan *scanning* tidak bergantung pada satu tool (*best-of-breed approach*).
- **Cosign** dipilih karena merupakan bagian dari ekosistem Sigstore yang menjadi standar de facto untuk artifact signing di cloud-native.

---

## 2. Arsitektur Pipeline

Pipeline CI/CD mengikuti arsitektur **linear dengan quality gates**, di mana setiap tahap harus berhasil sebelum tahap berikutnya dieksekusi:

```
┌─────────────┐    ┌──────────────┐    ┌─────────────────┐    ┌──────────────┐    ┌────────────┐
│  Build &     │───▶│  SBOM        │───▶│  Vulnerability   │───▶│  Artifact    │───▶│  Push &    │
│  Dockerfile  │    │  Generation  │    │  Scanning        │    │  Signing     │    │  Publish   │
│  (Docker)    │    │  (Syft)      │    │  (Trivy)         │    │  (Cosign)    │    │  (GHCR)    │
└─────────────┘    └──────────────┘    └─────────────────┘    └──────────────┘    └────────────┘
                                              │
                                              ▼
                                     ┌─────────────────┐
                                     │  Security Gate   │
                                     │  (CRITICAL/HIGH  │
                                     │   = FAIL)        │
                                     └─────────────────┘
```

### Alur Detail:

1. **Build** — Source code di-build dan container image dibuat menggunakan Dockerfile dengan multi-stage build.
2. **SBOM Generation** — Syft memindai image yang dihasilkan dan menghasilkan SBOM dalam format CycloneDX JSON.
3. **Vulnerability Scanning** — Trivy memindai SBOM untuk mendeteksi CVE. Jika ditemukan kerentanan dengan severity `CRITICAL` atau `HIGH`, pipeline akan **gagal** (security gate).
4. **Artifact Signing** — Jika lolos scanning, image ditandatangani menggunakan Cosign dengan keyless signing (Sigstore).
5. **Push & Publish** — Image yang sudah ditandatangani di-push ke GitHub Container Registry (GHCR), dan SBOM disimpan sebagai artefak pipeline.

---

## 3. Pembagian Kerja

| Anggota | Peran | Tanggung Jawab |
|---------|-------|----------------|
| **A — Dian Anggraeni** | App & Containerization | Membuat aplikasi, menulis Dockerfile dengan multi-stage build, konfigurasi `.dockerignore`, optimasi ukuran image |
| **B — Tsaldia Hukma Cita** | CI/CD & SBOM | Membuat workflow GitHub Actions, mengintegrasikan Syft untuk generasi SBOM, konfigurasi output format CycloneDX |
| **C — Acin** | Vulnerability Scanning & Gate | Mengintegrasikan Trivy ke pipeline, mengonfigurasi severity threshold, membuat security gate yang menghentikan pipeline jika ditemukan kerentanan kritis |
| **D — Callista** | Artifact Signing & Verification | Mengimplementasikan Cosign untuk signing image, menyiapkan verifikasi tanda tangan, mengelola key management |

---

## 4. Cara Menjalankan

### Prasyarat

- Docker terinstal dan berjalan
- Akses ke repositori GitHub dengan GitHub Actions diaktifkan
- (Opsional) Cosign CLI untuk verifikasi lokal

### Menjalankan secara Otomatis (CI/CD)

Pipeline berjalan secara otomatis ketika:
- Ada **push** ke branch `main`
- Ada **pull request** ke branch `main`

Cukup lakukan push ke repositori:

```bash
git add .
git commit -m "feat: update aplikasi"
git push origin main
```

### Menjalankan secara Lokal (Manual)

```bash
# 1. Build image
docker build -t kelompok8-app:latest .

# 2. Generate SBOM
syft kelompok8-app:latest -o cyclonedx-json > sbom.cdx.json

# 3. Scan kerentanan
trivy sbom sbom.cdx.json --severity CRITICAL,HIGH --exit-code 1

# 4. Sign image (memerlukan image di registry)
cosign sign ghcr.io/kelompok-8/app:latest

# 5. Verify signature
cosign verify ghcr.io/kelompok-8/app:latest
```

---

## 5. File Konfigurasi

Berikut adalah daftar file konfigurasi utama dalam proyek ini:

| File | Lokasi | Fungsi |
|------|--------|--------|
| `Dockerfile` | `/` (root) | Definisi container image dengan multi-stage build |
| `devsecops-pipeline.yml` | `.github/workflows/` | Workflow utama GitHub Actions untuk pipeline DevSecOps |
| `.dockerignore` | `/` (root) | Mengecualikan file yang tidak perlu dari Docker build context |
| `sbom.cdx.json` | (generated) | Output SBOM dalam format CycloneDX — dihasilkan saat pipeline berjalan |
| `trivy-results.json` | (generated) | Hasil pemindaian kerentanan Trivy — dihasilkan saat pipeline berjalan |

---

> **Catatan:** Dokumentasi lengkap mengenai landasan akademis dan refleksi kelompok tersedia di `docs/refleksi-kelompok.md`.
