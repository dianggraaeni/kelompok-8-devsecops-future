# Analisis Evaluasi — Supply Chain Security Enhancement

> **Tanggal Analisis:** _[TO BE COMPLETED]_  
> **Penulis:** Kelompok 8

---

## 1. Ringkasan Analisis

Dokumen ini menyajikan analisis komprehensif terhadap efektivitas implementasi
supply chain security enhancement pada pipeline CI/CD. Analisis dilakukan dengan
membandingkan metrik baseline (sebelum implementasi) dengan metrik setelah
implementasi untuk menentukan apakah enhancement yang dilakukan berhasil
mencapai tujuan yang ditetapkan.

**Pertanyaan utama yang dijawab:**

1. Apakah pipeline mampu mendeteksi kerentanan yang sebelumnya tidak terlihat?
2. Apakah SBOM yang dihasilkan mencakup seluruh dependensi?
3. Apakah artifact signing berhasil menjamin integritas container image?
4. Berapa overhead performa yang ditimbulkan oleh security steps?
5. Apakah security gate efektif mencegah artifact yang rentan?

> [!NOTE]
> Bagian yang ditandai **[TO BE COMPLETED]** akan diisi setelah data aktual
> dari pipeline run tersedia.

---

## 2. Analisis per Metrik

### 2.1 Vulnerability Detection

**Tujuan:** Mendeteksi kerentanan yang diketahui dalam dependensi secara otomatis.

| Aspek                    | Detail                                      |
|--------------------------|---------------------------------------------|
| Tool yang digunakan      | Trivy                                       |
| Baseline (sebelum)       | 0 vulnerability terdeteksi                  |
| Hasil (sesudah)          | [TO BE COMPLETED]                           |
| Target                   | ≥8 vulnerability (sesuai CVE yang diketahui)|
| Status                   | [TO BE COMPLETED — TERCAPAI / TIDAK]        |

**Analisis:**

[TO BE COMPLETED — Isi dengan analisis apakah Trivy berhasil mendeteksi
seluruh vulnerability yang diketahui. Jika ada yang terlewat, jelaskan
alasannya. Jika ada vulnerability tambahan yang terdeteksi di luar yang
diketahui, dokumentasikan juga.]

**Breakdown Deteksi per Dependensi:**

| Dependensi       | CVE yang Diharapkan | CVE Terdeteksi      | Status              |
|------------------|---------------------|---------------------|---------------------|
| lodash 4.17.15   | 3                   | [TO BE COMPLETED]   | [TO BE COMPLETED]   |
| jsonwebtoken 8.5.1| 2                  | [TO BE COMPLETED]   | [TO BE COMPLETED]   |
| axios 0.21.1     | 1                   | [TO BE COMPLETED]   | [TO BE COMPLETED]   |
| minimist 1.2.5   | 1                   | [TO BE COMPLETED]   | [TO BE COMPLETED]   |
| node-fetch 2.6.0 | 1                   | [TO BE COMPLETED]   | [TO BE COMPLETED]   |

---

### 2.2 SBOM Coverage

**Tujuan:** Menghasilkan SBOM yang mencakup 100% dependensi (direct + transitive).

| Aspek                    | Detail                                      |
|--------------------------|---------------------------------------------|
| Tool yang digunakan      | Syft                                        |
| Baseline (sebelum)       | 0% coverage                                 |
| Hasil (sesudah)          | [TO BE COMPLETED]                           |
| Target                   | 100%                                        |
| Status                   | [TO BE COMPLETED — TERCAPAI / TIDAK]        |

**Analisis:**

[TO BE COMPLETED — Isi dengan analisis apakah SBOM yang dihasilkan mencakup
seluruh komponen. Periksa kelengkapan informasi seperti nama paket, versi,
lisensi, dan hash. Evaluasi format SBOM yang digunakan (SPDX / CycloneDX).]

---

### 2.3 Artifact Integrity (Signing)

**Tujuan:** Menjamin integritas dan provenance container image melalui
penandatanganan kriptografi.

| Aspek                    | Detail                                      |
|--------------------------|---------------------------------------------|
| Tool yang digunakan      | Cosign (Sigstore)                           |
| Baseline (sebelum)       | Tidak ada signing                           |
| Hasil (sesudah)          | [TO BE COMPLETED]                           |
| Target                   | 100% image ditandatangani                   |
| Status                   | [TO BE COMPLETED — TERCAPAI / TIDAK]        |

**Analisis:**

[TO BE COMPLETED — Isi dengan analisis apakah signing berhasil dilakukan dan
apakah verifikasi signature juga berhasil. Dokumentasikan metode signing
yang digunakan (keyless vs key-based) dan implikasinya.]

---

### 2.4 Pipeline Performance (Overhead)

**Tujuan:** Mengukur overhead performa yang ditimbulkan oleh penambahan
security steps dalam pipeline.

| Aspek                    | Detail                                      |
|--------------------------|---------------------------------------------|
| Waktu baseline           | ~2 menit                                    |
| Waktu enhanced           | [TO BE COMPLETED]                           |
| Overhead (ΔT)            | [TO BE COMPLETED]                           |
| Target                   | Overhead ≤3 menit (total ≤5 menit)          |
| Status                   | [TO BE COMPLETED — TERCAPAI / TIDAK]        |

**Analisis:**

[TO BE COMPLETED — Isi dengan analisis apakah overhead yang ditimbulkan masih
dalam batas yang dapat diterima. Bandingkan trade-off antara waktu tambahan
dengan manfaat keamanan yang diperoleh. Apakah overhead ini signifikan dalam
konteks development workflow?]

**Breakdown Waktu per Step:**

| Step                | Baseline     | Enhanced         | Selisih             |
|---------------------|--------------|------------------|---------------------|
| Checkout            | ~5 dtk       | [TO BE COMPLETED]| [TO BE COMPLETED]   |
| Build               | ~45 dtk      | [TO BE COMPLETED]| [TO BE COMPLETED]   |
| Test                | ~30 dtk      | [TO BE COMPLETED]| [TO BE COMPLETED]   |
| SBOM Generation     | N/A          | [TO BE COMPLETED]| [TO BE COMPLETED]   |
| Vulnerability Scan  | N/A          | [TO BE COMPLETED]| [TO BE COMPLETED]   |
| Docker Push         | ~40 dtk      | [TO BE COMPLETED]| [TO BE COMPLETED]   |
| Artifact Signing    | N/A          | [TO BE COMPLETED]| [TO BE COMPLETED]   |

---

### 2.5 Security Gate Effectiveness

**Tujuan:** Memastikan pipeline gagal ketika kerentanan kritis ditemukan.

| Aspek                    | Detail                                      |
|--------------------------|---------------------------------------------|
| Baseline (sebelum)       | 0% failure rate (tidak ada gate)            |
| Hasil (sesudah)          | [TO BE COMPLETED]                           |
| Target                   | >0% (fail on CRITICAL/HIGH severity)        |
| Status                   | [TO BE COMPLETED — TERCAPAI / TIDAK]        |

**Analisis:**

[TO BE COMPLETED — Isi dengan analisis apakah security gate berhasil
menghentikan pipeline saat kerentanan kritis ditemukan. Evaluasi konfigurasi
severity threshold dan apakah threshold yang dipilih sudah tepat.]

---

## 3. Hubungan dengan Paper

Analisis ini menghubungkan hasil implementasi dengan temuan dari paper referensi
yang digunakan dalam proyek ini.

### 3.1 Xia et al. — "Trust in Software Supply Chains"

[TO BE COMPLETED — Hubungkan hasil evaluasi dengan temuan paper Xia et al.
mengenai pentingnya trust dalam supply chain. Apakah implementasi SBOM dan
signing berhasil meningkatkan trust sesuai framework yang diusulkan paper?]

**Poin-poin perbandingan:**

- Transparansi dependensi: [TO BE COMPLETED]
- Verifikasi integritas: [TO BE COMPLETED]
- Deteksi kerentanan otomatis: [TO BE COMPLETED]

### 3.2 O'Donoghue et al. — "Software Supply Chain Security"

[TO BE COMPLETED — Hubungkan hasil evaluasi dengan rekomendasi paper O'Donoghue
et al. mengenai praktik terbaik supply chain security. Apakah implementasi
sudah sesuai dengan rekomendasi yang diberikan?]

**Poin-poin perbandingan:**

- Adopsi SBOM: [TO BE COMPLETED]
- Penggunaan signing: [TO BE COMPLETED]
- Security automation: [TO BE COMPLETED]

---

## 4. Keterbatasan

Berikut adalah keterbatasan dari evaluasi yang dilakukan:

1. **Lingkup Terbatas** — Evaluasi hanya dilakukan pada satu pipeline dan satu
   aplikasi. Hasil mungkin berbeda untuk proyek dengan skala dan kompleksitas
   yang berbeda.

2. **Dependensi yang Disengaja** — Vulnerability yang diuji adalah dependensi
   yang sengaja dibuat rentan. Dalam skenario nyata, pola kerentanan mungkin
   berbeda dan lebih kompleks.

3. **Waktu Pengujian** — Pengukuran waktu pipeline dapat bervariasi tergantung
   pada kondisi runner GitHub Actions (load, region, spesifikasi hardware).

4. **Database Kerentanan** — Hasil scan Trivy bergantung pada kelengkapan
   database kerentanan pada saat scan dijalankan. CVE baru yang belum masuk
   database tidak akan terdeteksi.

5. **Keyless Signing** — Penggunaan keyless signing (Sigstore/Fulcio) bergantung
   pada ketersediaan infrastruktur Sigstore. Dalam lingkungan air-gapped,
   pendekatan ini tidak dapat digunakan.

6. [TO BE COMPLETED — Tambahkan keterbatasan lain yang ditemukan selama evaluasi]

---

## 5. Kesimpulan

[TO BE COMPLETED — Isi dengan kesimpulan keseluruhan dari analisis evaluasi]

**Template kesimpulan:**

Berdasarkan analisis yang telah dilakukan, implementasi supply chain security
enhancement pada pipeline CI/CD **[BERHASIL / SEBAGIAN BERHASIL / TIDAK BERHASIL]**
mencapai tujuan yang ditetapkan:

- **Vulnerability Detection:** [TO BE COMPLETED — ringkasan pencapaian]
- **SBOM Coverage:** [TO BE COMPLETED — ringkasan pencapaian]
- **Artifact Signing:** [TO BE COMPLETED — ringkasan pencapaian]
- **Pipeline Performance:** [TO BE COMPLETED — ringkasan pencapaian]
- **Security Gate:** [TO BE COMPLETED — ringkasan pencapaian]

Enhancement ini meningkatkan postur keamanan rantai pasok dari **SLSA Level 0**
menjadi **[TO BE COMPLETED]**, sesuai dengan rekomendasi dari paper referensi
yang digunakan.

> [!IMPORTANT]
> Kesimpulan akhir akan ditulis setelah seluruh data evaluasi terkumpul
> dan dianalisis secara menyeluruh.

---

> _Dokumen ini adalah bagian dari evaluasi proyek DevSecOps Kelompok 8._  
> _Akan dilengkapi setelah pipeline enhanced berhasil dijalankan dan diuji._
