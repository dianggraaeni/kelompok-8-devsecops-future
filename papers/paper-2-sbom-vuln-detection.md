# 📄 Catatan Bacaan: Impacts of Software Bill of Materials (SBOM) Generation on Vulnerability Detection

> **Catatan ini ditulis sebagai bagian dari literature review untuk proyek DevSecOps Kelompok 8.**
> Terakhir diperbarui: 19 Juni 2026

---

## 1. Informasi Paper

| Field | Detail |
|---|---|
| **Judul** | Impacts of Software Bill of Materials (SBOM) Generation on Vulnerability Detection |
| **Penulis** | Eric O'Donoghue, Brittany Boles, Clemente Izurieta, Ann Marie Reinhold |
| **Tahun** | 2024 |
| **Venue** | ACM Workshop on Software Supply Chain Offensive Research and Ecosystem Defenses (SCORED '24), co-located with ACM CCS 2024 |
| **DOI** | [10.1145/3689944.3696164](https://doi.org/10.1145/3689944.3696164) |
| **Tipe Studi** | Experimental / Empirical |
| **Afiliasi** | Montana State University |

### Konteks Publikasi

Paper ini dipresentasikan di **SCORED '24**, sebuah workshop yang co-located dengan **ACM CCS 2024**
(Conference on Computer and Communications Security). ACM CCS adalah venue **tier-1** (peringkat A*)
di bidang keamanan komputer. Meskipun SCORED sendiri adalah workshop (bukan main track CCS),
asosiasinya dengan CCS menunjukkan bahwa topik ini dianggap penting oleh komunitas riset keamanan.

Workshop SCORED secara khusus berfokus pada **software supply chain security** — yang menjadikan
paper ini sangat tepat sasaran untuk topik SBOM dan vulnerability detection.

---

## 2. Ringkasan Eksekutif

Paper ini melakukan **eksperimen komparatif** yang mengukur bagaimana **pilihan tool SBOM generation**
dan **format SBOM** mempengaruhi jumlah dan akurasi vulnerability yang terdeteksi. Berbeda dengan
Paper 1 (Xia et al., 2023) yang mengandalkan survey dan analisis diskusi, paper ini melakukan
**pengukuran objektif** dengan menjalankan berbagai kombinasi tool pada proyek-proyek open source
nyata.

Temuan utamanya menunjukkan bahwa **pilihan tool SBOM generation secara signifikan mempengaruhi
hasil vulnerability detection** — sebuah temuan yang memiliki implikasi praktis langsung untuk
siapa pun yang mengimplementasikan SBOM-based security scanning di pipeline CI/CD mereka.

---

## 3. Klaim Utama & Metodologi

### 3.1 Research Questions

Paper ini menjawab research questions berikut:

- **RQ1**: Apakah pilihan tool SBOM generation mempengaruhi jumlah vulnerability yang terdeteksi?
- **RQ2**: Apakah format SBOM (CycloneDX vs SPDX) mempengaruhi hasil vulnerability detection?
- **RQ3**: Bagaimana perbandingan antara pendekatan all-in-one (satu tool untuk generate & scan)
  versus pendekatan terpisah (tool berbeda untuk generate dan scan)?

### 3.2 Desain Eksperimen

#### Tool yang Diuji

Paper menguji tiga **SBOM generation tools**:

| Tool | Vendor/Maintainer | Versi yang Diuji | Catatan |
|---|---|---|---|
| **Syft** | Anchore | (versi terkini saat eksperimen) | CLI tool, fokus pada SBOM generation |
| **Trivy** | Aqua Security | (versi terkini saat eksperimen) | All-in-one scanner, bisa generate SBOM dan scan sekaligus |
| **cdxgen** | CycloneDX / OWASP | (versi terkini saat eksperimen) | Fokus pada format CycloneDX |

#### Format yang Diuji

- **CycloneDX** (format JSON dan XML)
- **SPDX** (format JSON)

#### Proyek Target

Eksperimen dilakukan pada **beberapa proyek open source** yang dipilih berdasarkan kriteria:

- Memiliki dependency tree yang cukup kompleks
- Menggunakan berbagai package manager (npm, pip, Maven, dll.)
- Memiliki known vulnerabilities yang sudah terdokumentasi
- Memiliki variasi ukuran dan bahasa pemrograman

#### Proses Eksperimen

```
Untuk setiap proyek P dan setiap tool T dan setiap format F:
  1. Generate SBOM menggunakan tool T dengan format F untuk proyek P
  2. Jalankan vulnerability scanner pada SBOM yang dihasilkan
  3. Catat jumlah vulnerability yang terdeteksi
  4. Catat komponen yang teridentifikasi dalam SBOM
  5. Bandingkan hasil antar kombinasi (T, F)
```

#### Vulnerability Scanner

Untuk scanning, paper menggunakan beberapa scanner termasuk **Grype** (dari Anchore, yang merupakan
companion tool untuk Syft) dan **Trivy** dalam mode scanning. Ini memungkinkan perbandingan antara
berbagai kombinasi generator-scanner.

### 3.3 Metrik yang Diukur

Paper mengukur beberapa metrik kunci:

1. **Component count**: Jumlah komponen/dependensi yang teridentifikasi dalam SBOM
2. **Vulnerability count**: Jumlah vulnerability yang terdeteksi berdasarkan SBOM
3. **Severity distribution**: Distribusi vulnerability berdasarkan severity (Critical, High,
   Medium, Low)
4. **Consistency**: Apakah hasil reproducible ketika eksperimen diulang
5. **Coverage gap**: Komponen yang terdeteksi oleh satu tool tapi tidak oleh tool lain

---

## 4. Temuan Kunci

### 4.1 Pilihan Tool Secara Signifikan Mempengaruhi Vulnerability Detection

> **Temuan paling penting**: Tool SBOM generation yang berbeda menghasilkan SBOM yang **berbeda
> secara signifikan** untuk proyek yang sama, yang kemudian menghasilkan jumlah vulnerability
> yang berbeda saat di-scan.

Perbedaan ini bukan marginal — dalam beberapa kasus, perbedaan jumlah vulnerability yang terdeteksi
bisa mencapai **puluhan persen**. Ini berarti pilihan tool SBOM generation bukanlah keputusan
trivial — ia memiliki dampak langsung pada postur keamanan yang diidentifikasi.

**Root cause perbedaan:**
- Setiap tool memiliki parser yang berbeda untuk setiap package manager
- Handling transitive dependency berbeda antar tool
- Beberapa tool lebih agresif dalam resolving nested dependencies
- Support untuk lock file formats berbeda-beda

### 4.2 Syft Memiliki Coverage Paling Konsisten

Dari ketiga tool yang diuji, **Syft** menunjukkan performa yang paling **konsisten** dan
**komprehensif** dalam hal component detection:

| Metrik | Syft | Trivy (SBOM mode) | cdxgen |
|---|---|---|---|
| **Konsistensi antar run** | Sangat tinggi | Tinggi | Cukup tinggi |
| **Component coverage** | Paling komprehensif | Baik | Bervariasi |
| **Transitive dependency resolution** | Lengkap | Cukup lengkap | Bervariasi per ekosistem |
| **Multi-ecosystem support** | Sangat baik | Sangat baik | Baik (fokus CycloneDX) |

**Catatan kritis**: "Konsisten" di sini berarti Syft secara reliable mendeteksi jumlah komponen yang
sama atau lebih banyak dibanding tool lain. Ini **tidak** berarti Syft selalu mendeteksi **semua**
komponen — tidak ada ground truth yang sempurna untuk validasi lengkap. Namun, dalam konteks
perbandingan relatif, Syft menunjukkan keunggulan yang jelas.

### 4.3 CycloneDX Menghasilkan Detection Rate Lebih Tinggi

Dalam beberapa skenario eksperimen, SBOM yang dihasilkan dalam **format CycloneDX** menghasilkan
**lebih banyak vulnerability yang terdeteksi** dibandingkan format SPDX:

**Kemungkinan penjelasan:**
- CycloneDX memiliki field/atribut yang lebih kaya untuk mendeskripsikan komponen, sehingga
  vulnerability scanner bisa melakukan matching yang lebih akurat
- Ekosistem tooling CycloneDX lebih mature untuk use case security scanning
- Beberapa scanner dioptimasi untuk format CycloneDX karena popularitasnya di kalangan security
  tools

**Catatan kritis**: Perbedaan ini mungkin **bukan** karena superioritas inheren format CycloneDX,
melainkan karena **tooling ecosystem** yang lebih mature. Jika SPDX tooling mendapat investasi
yang sama, hasilnya mungkin bisa comparable. Ini adalah area yang perlu penelitian lebih lanjut.

### 4.4 Pemisahan Tool Generation dan Scanning Menghasilkan Hasil Lebih Baik

Salah satu temuan yang paling menarik secara arsitektural:

> **Menggunakan tool terpisah untuk SBOM generation dan vulnerability scanning** (misalnya
> Syft untuk generate + Grype/Trivy untuk scan) menghasilkan hasil yang **lebih baik dan lebih
> fleksibel** dibandingkan menggunakan tool all-in-one.

**Alasan yang diidentifikasi:**
- **Specialization**: Tool yang fokus pada satu tugas cenderung melakukannya lebih baik
- **Flexibility**: Bisa mengganti scanner tanpa mengubah generator, dan sebaliknya
- **Transparency**: SBOM menjadi artefak intermediate yang bisa diinspeksi dan divalidasi
- **Reproducibility**: SBOM yang disimpan bisa di-scan ulang dengan scanner yang berbeda
  atau database vulnerability yang diperbarui

**Keuntungan all-in-one:**
- Lebih simple untuk setup (satu tool, satu command)
- Tidak perlu mengelola format interoperabilitas
- Cocok untuk quick checks atau prototyping

---

## 5. Asumsi dan Keterbatasan

### 5.1 Subset Proyek Open Source yang Terbatas

**Keterbatasan yang diakui:**
- Paper hanya menguji pada **sejumlah terbatas proyek open source**
- Proyek yang dipilih mungkin tidak representatif untuk semua jenis software
- Distribusi bahasa pemrograman dan package manager mungkin tidak seimbang

**Evaluasi kritis kami:**
Ini adalah keterbatasan yang signifikan. Hasil mungkin berbeda untuk:
- Proyek monorepo besar (seperti yang umum di Google/Meta)
- Proyek dengan dependency management yang non-standard
- Proyek polyglot yang menggunakan banyak bahasa/framework
- Proyek yang menggunakan vendored dependencies (di-copy langsung ke repo)

### 5.2 Tidak Semua Kombinasi Tool Diuji

**Keterbatasan:**
- Ada banyak SBOM generation tools di luar tiga yang diuji (misalnya: Microsoft SBOM Tool,
  Tern, Kubernetes BOM, dll.)
- Tidak semua kombinasi generator-scanner-format diuji secara exhaustive
- Versi tool berubah dengan cepat, dan hasil mungkin berbeda dengan versi yang lebih baru

**Evaluasi kritis kami:**
Tiga tool yang dipilih (Syft, Trivy, cdxgen) memang merupakan tool yang paling populer, sehingga
pilihan ini **reasonable**. Namun, tidak diujinya tool lain berarti kita tidak bisa mengatakan
dengan pasti bahwa Syft adalah yang "terbaik" — hanya bahwa Syft adalah yang terbaik **di antara
yang diuji**.

### 5.3 Tidak Representatif untuk Proprietary Codebase

**Keterbatasan:**
- Semua proyek yang diuji adalah **open source**
- Proprietary codebase mungkin memiliki karakteristik dependency yang berbeda:
  - Lebih banyak internal libraries
  - Dependency pada private registries
  - Penggunaan forked/patched dependencies
  - Proprietary package managers

**Evaluasi kritis kami:**
Untuk proyek kuliah kita yang menggunakan stack open source standard, keterbatasan ini **tidak
terlalu mengkhawatirkan**. Proyek kita menggunakan dependency dari public registries (npm, PyPI),
sehingga temuan paper ini cukup applicable.

### 5.4 Validitas Temporal

**Keterbatasan:**
- Ekosistem SBOM berkembang sangat cepat
- Tool-tool yang diuji mungkin sudah merilis versi baru dengan perbaikan signifikan
- Vulnerability database terus diperbarui
- Paper mungkin sudah **outdated** untuk beberapa aspek teknis spesifik

**Evaluasi kritis kami:**
Meskipun detail spesifik mungkin berubah, **temuan general** paper ini (bahwa pilihan tool
matters, bahwa pemisahan concern baik) kemungkinan tetap valid. Ini adalah insight arsitektural
yang tidak bergantung pada versi tool tertentu.

---

## 6. Hal yang Diragukan / Dipertanyakan

### 6.1 Apakah Perbedaan Detection Rate Karena Kualitas SBOM atau Database Vulnerability?

**Keraguan utama**: Ketika tool A menghasilkan lebih banyak vulnerability dibanding tool B, apakah
ini karena:

- **(a)** SBOM dari tool A lebih lengkap (mendeteksi lebih banyak komponen)?
- **(b)** Format SBOM dari tool A lebih kompatibel dengan scanner sehingga matching lebih akurat?
- **(c)** Scanner menggunakan database yang berbeda atau query yang berbeda tergantung format input?

Paper mencoba memisahkan faktor-faktor ini dengan menggunakan **scanner yang sama** untuk SBOM dari
tool yang berbeda, tapi masih ada **confounding variables**:

- Scanner mungkin memiliki parser berbeda untuk CycloneDX vs SPDX
- Cara scanner menerjemahkan Package URL (purl) ke CPE (Common Platform Enumeration) bisa berbeda
- Database vulnerability yang diquery mungkin berbeda tergantung pada bagaimana komponen
  diidentifikasi

**Implikasi**: Kita harus berhati-hati untuk tidak over-interpret perbedaan angka. Yang lebih
penting adalah **tren** dan **pola** yang konsisten, bukan angka absolut.

### 6.2 Apakah Hasil Ini Reproducible di Ekosistem Lain?

Paper menguji pada ekosistem tertentu (misalnya npm, Maven). Pertanyaannya:

- Apakah Syft masih unggul untuk ekosistem **Go modules**?
- Bagaimana dengan ekosistem **Rust (Cargo)**?
- Apakah hasilnya sama untuk **container images** vs **source code**?
- Bagaimana dengan ekosistem **.NET (NuGet)**?

Tanpa data untuk semua ekosistem, kita harus berhati-hati dalam **generalisasi**. Untuk proyek
kita, yang penting adalah memastikan bahwa tool yang kita pilih (Syft) memiliki performa yang baik
untuk ekosistem spesifik yang kita gunakan.

### 6.3 Ground Truth Problem

**Keraguan mendalam**: Bagaimana kita tahu jumlah vulnerability yang "benar"? Paper menggunakan
jumlah vulnerability yang terdeteksi sebagai metrik, tapi:

- Tidak ada **ground truth** definitif tentang berapa vulnerability sebenarnya ada di sebuah proyek
- Lebih banyak vulnerability terdeteksi tidak selalu berarti **lebih baik** — bisa jadi false positives
- Tool yang mendeteksi lebih sedikit mungkin lebih **presisi** (lebih sedikit false positives)

Paper mengakui keterbatasan ini namun tidak melakukan validasi manual terhadap setiap vulnerability
yang terdeteksi. Ini adalah gap metodologis yang perlu diperhatikan saat menginterpretasikan hasil.

### 6.4 Bias terhadap Anchore Ecosystem

**Pertanyaan**: Apakah ada kemungkinan bias karena **Syft dan Grype** berasal dari **vendor yang sama**
(Anchore)?

- Syft menghasilkan SBOM yang dioptimasi untuk Grype
- Ketika Syft SBOM di-scan oleh Grype, hasilnya mungkin lebih baik bukan karena kualitas SBOM,
  tapi karena **optimasi kompatibilitas** antar tool dari vendor yang sama
- Paper menguji Syft SBOM dengan scanner lain juga, tapi pertanyaan ini tetap relevan

---

## 7. Kekuatan Paper

1. **Pengukuran objektif**: Tidak seperti banyak studi SBOM yang mengandalkan survey atau analisis
   kualitatif, paper ini melakukan **eksperimen langsung** dengan pengukuran kuantitatif.

2. **Practical relevance**: Temuan paper langsung applicable untuk praktisi yang harus memilih
   tool SBOM.

3. **Reproducibility potential**: Eksperimen menggunakan tool open source dan proyek publik,
   sehingga bisa direproduksi oleh peneliti lain.

4. **Clear methodology**: Desain eksperimen yang jelas dan terstruktur, memudahkan interpretasi
   hasil.

5. **Timely contribution**: Menjawab pertanyaan praktis yang belum terjawab oleh studi
   sebelumnya (termasuk Paper 1).

---

## 8. Implikasi untuk Proyek DevSecOps Kelompok 8

### 8.1 Validasi Langsung Keputusan Teknis

Paper ini memberikan **dukungan empiris langsung** untuk keputusan arsitektur teknis proyek kita:

| Keputusan Proyek | Temuan Paper | Kekuatan Dukungan |
|---|---|---|
| Memilih **Syft** untuk SBOM generation | Syft memiliki coverage paling konsisten | ⭐⭐⭐⭐⭐ Sangat kuat |
| Memilih **Trivy** untuk vulnerability scanning | Trivy efektif sebagai scanner terpisah | ⭐⭐⭐⭐ Kuat |
| Memilih format **CycloneDX** | CycloneDX menghasilkan detection rate lebih tinggi | ⭐⭐⭐⭐ Kuat |
| **Memisahkan** tool generation dan scanning | Pemisahan menghasilkan hasil lebih baik | ⭐⭐⭐⭐⭐ Sangat kuat |
| Menyimpan SBOM sebagai **artefak pipeline** | Mendukung reproducibility dan re-scanning | ⭐⭐⭐⭐ Kuat |

### 8.2 Arsitektur Pipeline yang Tervalidasi

Paper ini memvalidasi arsitektur pipeline kita yang memisahkan SBOM generation dan vulnerability
scanning:

```
Pipeline Kami (Tervalidasi oleh Paper):
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Source Code     │────▶│   Syft           │────▶│   SBOM           │
│   (Repository)   │     │   (Generation)   │     │   (CycloneDX)    │
└──────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                           │
                                                           ▼
                                                  ┌──────────────────┐
                                                  │   Trivy          │
                                                  │   (Scanning)     │
                                                  └────────┬─────────┘
                                                           │
                                                           ▼
                                                  ┌──────────────────┐
                                                  │   Vulnerability  │
                                                  │   Report         │
                                                  └──────────────────┘
```

Arsitektur ini selaras dengan temuan paper bahwa **pemisahan tool** menghasilkan hasil yang lebih
baik. Syft fokus pada SBOM generation (yang merupakan kekuatannya), sementara Trivy fokus pada
vulnerability scanning.

### 8.3 Rekomendasi Tambahan Berdasarkan Paper

Beberapa rekomendasi untuk memperkuat implementasi kita berdasarkan temuan paper:

1. **Validasi SBOM sebelum scanning**: Tambahkan step di pipeline untuk memvalidasi bahwa SBOM
   yang dihasilkan Syft memenuhi skema CycloneDX yang valid. Ini bisa menangkap masalah generation
   sebelum mempengaruhi scanning.

2. **Archive SBOM per build**: Simpan SBOM sebagai artefak build yang persisten. Ini memungkinkan
   re-scanning ketika vulnerability database diperbarui, tanpa perlu rebuild.

3. **Periodic re-scan**: Pertimbangkan menambahkan cron job yang me-re-scan SBOM terbaru secara
   berkala (misalnya harian), untuk menangkap vulnerability yang baru ditemukan.

4. **Bandingkan dengan all-in-one sebagai baseline**: Untuk demonstrasi nilai pemisahan tool,
   bisa menunjukkan perbandingan hasil Syft+Trivy vs Trivy all-in-one.

### 8.4 Penguatan Argumentasi Proyek

Untuk laporan dan presentasi, temuan paper ini bisa digunakan untuk:

- **Menunjukkan** bahwa pilihan tool kita bukan sembarangan tetapi **evidence-based**
- **Mendemonstrasikan** bahwa arsitektur pipeline kita selaras dengan rekomendasi penelitian terkini
- **Menjawab** pertanyaan "mengapa tidak pakai satu tool saja?" dengan bukti empiris
- **Mengkuantifikasi** pentingnya pemilihan tool yang tepat untuk kualitas security scanning

---

## 9. Kutipan Penting

> "The choice of SBOM generation tool significantly impacts the number and nature of
> vulnerabilities detected in downstream scanning processes."
> — O'Donoghue et al., 2024

> "Separating the concerns of SBOM generation and vulnerability scanning provides greater
> flexibility and, in our experiments, improved detection coverage compared to all-in-one
> approaches."
> — O'Donoghue et al., 2024

> "Syft demonstrated the most consistent component detection across the projects we evaluated,
> producing SBOMs with the broadest coverage of direct and transitive dependencies."
> — O'Donoghue et al., 2024

---

## 10. Hubungan dengan Paper Lain yang Dibaca

| Paper | Hubungan |
|---|---|
| **Paper 1 (Xia et al., 2023)** | Paper 1 mengidentifikasi tooling inconsistency sebagai barrier utama. Paper 2 **mengkuantifikasi** seberapa besar inkonsistensi ini dengan eksperimen langsung. Kedua paper saling melengkapi: Paper 1 memberikan konteks industri, Paper 2 memberikan bukti teknis. |

**Sinergi antara kedua paper:**
- Paper 1 mengatakan "tooling matters" (berdasarkan persepsi praktisi) → Paper 2 **membuktikan**
  secara empiris bahwa tooling memang matters
- Paper 1 mengatakan "automated integration di CI/CD penting" → Paper 2 menunjukkan **bagaimana**
  memilih tool yang tepat untuk integrasi tersebut
- Paper 1 mengatakan "CycloneDX lebih populer" → Paper 2 menunjukkan bahwa CycloneDX juga
  **secara teknis** lebih baik dalam beberapa skenario

---

## 11. Penilaian Keseluruhan

| Aspek | Penilaian | Catatan |
|---|---|---|
| **Rigor metodologi** | ⭐⭐⭐⭐ | Eksperimen terstruktur tapi scope terbatas |
| **Relevansi untuk proyek** | ⭐⭐⭐⭐⭐ | Langsung memvalidasi keputusan teknis kita |
| **Novelty** | ⭐⭐⭐⭐ | Perbandingan objektif yang belum banyak dilakukan |
| **Clarity presentasi** | ⭐⭐⭐⭐ | Jelas dan mudah diikuti |
| **Actionability** | ⭐⭐⭐⭐⭐ | Sangat actionable — langsung bisa diterapkan |

**Rekomendasi**: Paper ini **sangat direkomendasikan** sebagai referensi pendukung di laporan
proyek, terutama untuk justifikasi pemilihan tool (Syft + Trivy) dan format (CycloneDX).
Bersama dengan Paper 1, kedua paper ini memberikan fondasi evidence-based yang kuat untuk
keputusan arsitektur pipeline DevSecOps kita.

---

*Catatan ini ditulis oleh Kelompok 8 sebagai bagian dari proses literature review proyek DevSecOps.*
