# 📄 Catatan Bacaan: An Empirical Study on Software Bill of Materials

> **Catatan ini ditulis sebagai bagian dari literature review untuk proyek DevSecOps Kelompok 8.**
> Terakhir diperbarui: 19 Juni 2026

---

## 1. Informasi Paper

| Field | Detail |
|---|---|
| **Judul** | An Empirical Study on Software Bill of Materials: Where We Stand and the Road Ahead |
| **Penulis** | Boming Xia, Tingting Bi, Zhenchang Xing, Qinghua Lu, Liming Zhu |
| **Tahun** | 2023 |
| **Venue** | IEEE/ACM 45th International Conference on Software Engineering (ICSE 2023) |
| **DOI** | [10.1109/ICSE48619.2023.00219](https://doi.org/10.1109/ICSE48619.2023.00219) |
| **Tipe Studi** | Empirical Study (Mixed Methods: Survey + Mining Software Repository) |
| **Afiliasi** | CSIRO's Data61 & Australian National University |
| **Jumlah Halaman** | 13 halaman |

### Konteks Publikasi

Paper ini dipresentasikan di ICSE 2023, yang merupakan venue **tier-1** (peringkat A*) dalam bidang
software engineering. Fakta bahwa paper diterima di ICSE memberikan indikasi bahwa metodologi dan
kontribusinya telah melalui proses peer review yang sangat ketat. ICSE memiliki acceptance rate
sekitar 20-25%, sehingga kualitas akademis paper ini bisa dianggap tinggi.

---

## 2. Ringkasan Eksekutif

Paper ini melakukan studi empiris komprehensif tentang **status adopsi Software Bill of Materials
(SBOM)** di industri perangkat lunak. Studi dilakukan melalui dua pendekatan komplementer:

1. **Survey terhadap 138 praktisi** software engineering yang memiliki pengalaman dengan SBOM
2. **Analisis 5.478 postingan Stack Overflow** yang terkait SBOM

Dari kedua sumber data tersebut, penulis membangun sebuah **SBOM Goal Model** yang mengidentifikasi
empat tujuan utama adopsi SBOM: *transparency*, *vulnerability management*, *license compliance*,
dan *supply chain integrity*. Penulis juga mengidentifikasi barrier-barrier utama yang menghambat
adopsi SBOM secara luas.

---

## 3. Klaim Utama & Metodologi

### 3.1 Research Questions

Paper ini menjawab tiga research question utama:

- **RQ1**: Apa saja tujuan (goals) dari SBOM dan bagaimana mereka saling berhubungan?
- **RQ2**: Apa saja tantangan (challenges) yang dihadapi praktisi dalam mengadopsi SBOM?
- **RQ3**: Bagaimana kondisi tooling dan ecosystem SBOM saat ini?

### 3.2 Metodologi Survey

- **Rekrutmen**: Partisipan direkrut melalui mailing list komunitas open source, LinkedIn, dan
  forum profesional terkait software supply chain security
- **Jumlah responden**: 138 praktisi yang valid (setelah filtering)
- **Demografi**: Mayoritas dari Amerika Utara dan Eropa, dengan pengalaman profesional rata-rata
  5+ tahun
- **Instrumen**: Kuesioner semi-structured dengan campuran pertanyaan tertutup (Likert scale) dan
  terbuka (free-text)
- **Analisis**: Thematic analysis untuk data kualitatif, statistik deskriptif untuk data kuantitatif

### 3.3 Metodologi Mining Stack Overflow

- **Data source**: Stack Overflow Data Dump (public dataset)
- **Periode**: Postingan dari 2010 hingga awal 2023
- **Query**: Kombinasi keyword terkait SBOM, CycloneDX, SPDX, software composition analysis
- **Jumlah postingan**: 5.478 postingan yang relevan (setelah filtering)
- **Analisis**: Topic modeling menggunakan LDA (Latent Dirichlet Allocation) untuk mengidentifikasi
  tema-tema utama dalam diskusi SBOM

### 3.4 SBOM Goal Model

Kontribusi utama paper adalah **SBOM Goal Model** yang terdiri dari empat dimensi:

```
SBOM Goal Model
├── Transparency
│   ├── Component inventory visibility
│   ├── Dependency tree documentation
│   └── Version tracking
├── Vulnerability Management
│   ├── Known vulnerability identification
│   ├── Proactive risk assessment
│   └── Patch prioritization
├── License Compliance
│   ├── License obligation tracking
│   ├── Conflict detection
│   └── Legal risk mitigation
└── Supply Chain Integrity
    ├── Provenance verification
    ├── Tampering detection
    └── Trust chain validation
```

Model ini dibangun secara iteratif melalui:
1. Initial coding dari respons survey
2. Validasi silang dengan topik-topik yang muncul di Stack Overflow
3. Refinement melalui diskusi antar penulis (inter-rater agreement)

---

## 4. Temuan Kunci yang Relevan untuk Implementasi

### 4.1 Automated SBOM Generation di CI/CD Pipeline

> **Temuan**: Lebih dari 70% responden yang telah berhasil mengadopsi SBOM menyatakan bahwa
> **otomasi dalam CI/CD pipeline** adalah faktor kunci keberhasilan mereka.

Ini adalah temuan yang **paling relevan** untuk proyek kami. Paper secara eksplisit menyatakan bahwa
organisasi yang mencoba melakukan SBOM generation secara manual atau semi-otomatis cenderung
mengabaikannya setelah beberapa waktu karena overhead yang terlalu tinggi.

**Implikasi praktis**: SBOM generation harus menjadi bagian **integral** dari pipeline CI/CD, bukan
langkah terpisah yang memerlukan intervensi manual. Ini selaras dengan pendekatan kita yang
menggunakan GitHub Actions untuk automated SBOM generation.

### 4.2 Perbandingan Format: CycloneDX vs SPDX

Paper menemukan bahwa:

| Aspek | CycloneDX | SPDX |
|---|---|---|
| **Adopsi di survey** | ~55% responden | ~40% responden |
| **Fokus utama** | Security & vulnerability management | License compliance & legal |
| **Kemudahan tooling** | Lebih banyak tool yang support | Lebih mature tapi kompleks |
| **Diskusi di SO** | Lebih banyak pertanyaan teknis | Lebih banyak pertanyaan konseptual |
| **Standarisasi** | OWASP-backed | ISO/IEC 5962:2021 (standar internasional) |

> **Catatan kritis**: Perlu diperhatikan bahwa angka-angka persentase di atas berasal dari sample
> yang relatif kecil (138 responden). Distribusi ini mungkin tidak mencerminkan distribusi adopsi
> global yang sebenarnya.

### 4.3 Integrasi SBOM dengan Vulnerability Scanning

Paper mengidentifikasi bahwa **value proposition terbesar** dari SBOM, menurut praktisi, adalah
kemampuannya untuk diintegrasikan dengan vulnerability scanning tools:

- **82% responden** menyatakan vulnerability management sebagai use case utama SBOM
- SBOM yang terintegrasi dengan vulnerability database (seperti NVD, OSV) memberikan visibilitas
  yang jauh lebih baik dibanding hanya dependency listing biasa
- Continuous monitoring menggunakan SBOM memungkinkan deteksi vulnerability baru pada komponen
  yang sudah di-deploy

Ini memvalidasi arsitektur pipeline kita yang menghubungkan SBOM generation langsung dengan
vulnerability scanning menggunakan Trivy.

### 4.4 Kebutuhan Tooling yang Mudah Diintegrasikan

Dari analisis Stack Overflow, ditemukan bahwa:

- **Mayoritas pertanyaan** (sekitar 35%) terkait dengan kesulitan integrasi tool
- Praktisi membutuhkan tool yang memiliki **CLI yang baik** dan **API yang jelas**
- Format output yang konsisten dan machine-readable sangat dihargai
- Docker container support untuk tool SBOM menjadi semakin penting

### 4.5 Barrier Utama Adopsi SBOM

Paper mengidentifikasi beberapa barrier utama, diurutkan berdasarkan frekuensi kemunculan:

1. **Tooling inconsistency** (disebutkan oleh ~60% responden) — tool yang berbeda menghasilkan
   SBOM yang berbeda untuk project yang sama
2. **Lack of automation** (~50%) — proses manual terlalu membebani tim
3. **Insufficient tooling maturity** (~45%) — banyak tool masih beta atau kurang stabil
4. **Knowledge gap** (~40%) — tim tidak memahami apa itu SBOM dan mengapa penting
5. **Organizational resistance** (~30%) — manajemen tidak melihat ROI dari investasi SBOM
6. **Standard fragmentation** (~25%) — kebingungan antara CycloneDX, SPDX, dan SWID

---

## 5. Asumsi dan Keterbatasan Paper

### 5.1 Sample Bias pada Survey

**Keterbatasan yang diakui penulis:**
- Survey dilakukan **hanya dalam bahasa Inggris**, sehingga praktisi dari negara non-Anglophone
  (termasuk Indonesia, Jepang, Korea, China) mungkin underrepresented
- Rekrutmen melalui mailing list open source dan LinkedIn menciptakan **self-selection bias** —
  hanya praktisi yang sudah aware tentang SBOM yang cenderung merespons
- Tidak ada informasi tentang distribusi ukuran organisasi responden (startup vs enterprise)

**Evaluasi kritis kami:**
Ini adalah keterbatasan yang cukup serius. Praktisi di Asia Tenggara, termasuk Indonesia, mungkin
memiliki tantangan dan perspektif yang berbeda tentang SBOM. Regulasi lokal, maturity level
organisasi, dan ketersediaan talent bisa sangat berbeda. Hasil survey ini harus diinterpretasikan
dengan hati-hati saat diterapkan di konteks lokal.

### 5.2 Stack Overflow Bias

**Keterbatasan:**
- Stack Overflow hanya mencerminkan masalah yang **dipublikasikan** — banyak masalah SBOM di
  enterprise yang tidak pernah diposting karena alasan kerahasiaan
- Postingan yang mendapat banyak upvote belum tentu mencerminkan masalah yang paling umum,
  melainkan masalah yang paling *menarik* bagi komunitas SO
- Tren diskusi di Stack Overflow bisa dipengaruhi oleh hype cycle, bukan adopsi nyata

**Evaluasi kritis kami:**
Mining Stack Overflow adalah metodologi yang **well-established** dalam software engineering
research, namun memiliki inherent limitation. Enterprise-level challenges, seperti integrasi SBOM
dengan sistem procurement legacy atau compliance framework internal, kemungkinan besar tidak
tercermin di Stack Overflow. Ini berarti paper mungkin **underestimate** kompleksitas adopsi SBOM
di organisasi besar.

### 5.3 Tidak Mengukur Efektivitas Tool Secara Langsung

Paper **tidak** melakukan eksperimen langsung untuk membandingkan kualitas output dari berbagai
SBOM generation tools. Semua klaim tentang tooling berdasarkan **persepsi** praktisi dan **diskusi**
di Stack Overflow, bukan pengukuran objektif. Ini adalah gap yang signifikan — dan kebetulan gap
ini diisi oleh Paper 2 (O'Donoghue et al., 2024) yang kita baca berikutnya.

---

## 6. Hal yang Diragukan / Dipertanyakan

### 6.1 Representativitas Sample 138 Responden

**Keraguan utama**: Apakah 138 responden cukup untuk mewakili industri software global yang terdiri
dari jutaan developer?

Secara statistik, 138 responden memberikan margin of error sekitar ±8.3% pada confidence level 95%
(asumsi populasi tak terbatas). Ini cukup lebar untuk survey yang mengklaim memberikan gambaran
tentang "where we stand." Namun, perlu diakui bahwa:

- Untuk studi kualitatif dengan thematic analysis, 138 responden sebenarnya **cukup besar** — banyak
  studi kualitatif di SE research menggunakan 15-30 responden
- Paper mengkompensasi dengan data dari 5.478 postingan Stack Overflow sebagai triangulasi
- Temuan-temuan utama konsisten antara survey dan data Stack Overflow, yang menambah credibility

**Kesimpulan kami**: Untuk temuan kualitatif (jenis barrier, tujuan SBOM), sample ini **cukup
adequate**. Namun untuk klaim kuantitatif (persentase adopsi, distribusi tool preference), angka-angka
harus diinterpretasikan sebagai **indikatif**, bukan definitif.

### 6.2 Apakah Pola Stack Overflow Mencerminkan Adopsi Nyata di Enterprise?

**Keraguan**: Stack Overflow digunakan terutama oleh developer individu. Enterprise biasanya
memiliki tim internal, vendor support, dan knowledge base sendiri. Apakah diskusi di Stack Overflow
benar-benar representatif untuk adopsi SBOM di level organisasi?

Kami memperkirakan ada **disconnect** antara apa yang didiskusikan di Stack Overflow dan apa yang
terjadi di enterprise:

- Enterprise mungkin sudah lebih advanced dalam adopsi SBOM karena dorongan regulasi
  (seperti Executive Order 14028 di AS)
- Tantangan enterprise mungkin lebih pada **governance dan process**, bukan pada technical tooling
- Developer yang bertanya di Stack Overflow mungkin berada di fase awal adopsi, sehingga gambaran
  dari SO mungkin **skewed ke early-stage challenges**

### 6.3 Validitas SBOM Goal Model

Apakah goal model yang diusulkan benar-benar komprehensif? Ada beberapa use case SBOM yang
mungkin belum tercakup:

- **Audit dan forensik** — penggunaan SBOM untuk investigasi insiden keamanan
- **End-of-life management** — tracking komponen yang sudah tidak di-maintain
- **Regulatory compliance spesifik** — kepatuhan terhadap regulasi industri tertentu (misalnya
  FDA untuk medical devices, yang memiliki kebutuhan SBOM yang sangat spesifik)

Mungkin kategori-kategori ini tercakup secara implisit dalam model, tetapi paper tidak membahasnya
secara eksplisit.

---

## 7. Kekuatan Paper

Meskipun ada keterbatasan, paper ini memiliki beberapa kekuatan yang signifikan:

1. **Mixed methods approach**: Kombinasi survey dan mining Stack Overflow memberikan triangulasi
   yang kuat. Temuan dari satu sumber divalidasi oleh sumber lain.

2. **Timeliness**: Paper ini dipublikasikan pada waktu yang tepat — saat adopsi SBOM mulai
   meningkat secara global pasca Executive Order 14028 dan berbagai regulasi lainnya.

3. **Practical contributions**: SBOM Goal Model memberikan framework yang dapat digunakan oleh
   praktisi untuk mengevaluasi dan merencanakan adopsi SBOM di organisasi mereka.

4. **Identification of research gaps**: Paper dengan jelas mengidentifikasi area-area yang
   memerlukan penelitian lebih lanjut, yang telah memicu studi-studi lanjutan (termasuk paper 2
   yang kita baca).

5. **Replicability**: Metodologi yang digunakan cukup jelas dan detailed, memungkinkan replikasi
   di konteks lain (misalnya dengan responden dari wilayah geografis yang berbeda).

---

## 8. Implikasi untuk Proyek DevSecOps Kelompok 8

### 8.1 Validasi Keputusan Arsitektur

Paper ini **mendukung** beberapa keputusan arsitektur kunci dalam proyek kita:

| Keputusan Proyek | Dukungan dari Paper | Kekuatan Dukungan |
|---|---|---|
| Automated SBOM generation di GitHub Actions | 70%+ praktisi setuju ini kunci keberhasilan | ⭐⭐⭐⭐⭐ Sangat kuat |
| Memilih format CycloneDX | CycloneDX lebih populer dan security-focused | ⭐⭐⭐⭐ Kuat |
| Integrasi SBOM + vulnerability scanning | 82% responden menganggap ini value utama | ⭐⭐⭐⭐⭐ Sangat kuat |
| Menggunakan tool dengan CLI yang baik | Kebutuhan tooling integrasi tervalidasi | ⭐⭐⭐⭐ Kuat |

### 8.2 Antisipasi Tantangan

Berdasarkan barrier yang diidentifikasi paper, kita perlu mengantisipasi:

1. **Tooling inconsistency**: Kita harus memastikan bahwa SBOM yang dihasilkan tool kita
   (Syft) **konsisten** dan **reproducible** antar build. Menambahkan automated validation
   step di pipeline bisa menjadi langkah mitigasi.

2. **Knowledge gap**: Dalam dokumentasi proyek, kita harus menyertakan **penjelasan yang jelas**
   tentang apa itu SBOM dan mengapa kita menggunakannya. Ini membantu reviewer dan penguji
   yang mungkin belum familiar.

3. **Standard fragmentation**: Meskipun kita memilih CycloneDX, kita mungkin perlu menambahkan
   kemampuan **export ke SPDX** untuk interoperabilitas — atau setidaknya mendokumentasikan
   alasan pemilihan format.

### 8.3 Penguatan Argumen Proyek

Untuk presentasi dan laporan akhir, temuan paper ini bisa digunakan untuk:

- **Justify** mengapa SBOM penting dan relevan (berdasarkan survey industri)
- **Menunjukkan** bahwa pendekatan kita selaras dengan best practices industri
- **Mendukung** klaim bahwa pipeline kita mengimplementasikan SBOM dengan cara yang
  direkomendasikan oleh riset terkini
- **Menunjukkan** awareness terhadap tantangan adopsi SBOM dan bagaimana kita mengatasinya

### 8.4 Gaps yang Perlu Diisi oleh Sumber Lain

Paper ini tidak menjawab beberapa pertanyaan yang relevan untuk proyek kita:

- **Perbandingan objektif kualitas SBOM** dari tool yang berbeda → dijawab oleh Paper 2
- **Best practices konfigurasi Syft** untuk hasil optimal → perlu referensi dari dokumentasi tool
- **Integrasi SBOM dengan GitHub Security features** → perlu referensi dari dokumentasi GitHub
- **Standar SBOM untuk ekosistem Node.js/Python secara spesifik** → perlu referensi tambahan

---

## 9. Kutipan Penting

> "The most significant barrier to SBOM adoption is not the lack of standards or formats, but
> rather the inconsistency and immaturity of tooling that generates, consumes, and validates SBOMs."
> — Xia et al., 2023

> "Practitioners overwhelmingly identified vulnerability management as the primary driver for
> SBOM adoption, followed by regulatory compliance requirements."
> — Xia et al., 2023

> "Automated SBOM generation integrated into CI/CD pipelines was consistently identified as the
> most effective approach by practitioners who have successfully adopted SBOM practices."
> — Xia et al., 2023

---

## 10. Hubungan dengan Paper Lain yang Dibaca

| Paper | Hubungan |
|---|---|
| **Paper 2 (O'Donoghue et al., 2024)** | Mengisi gap paper ini tentang perbandingan objektif kualitas tool SBOM. Paper 2 melakukan eksperimen yang paper 1 tidak lakukan. |

---

## 11. Penilaian Keseluruhan

| Aspek | Penilaian | Catatan |
|---|---|---|
| **Rigor metodologi** | ⭐⭐⭐⭐ | Mixed methods yang solid, tapi sample size bisa lebih besar |
| **Relevansi untuk proyek** | ⭐⭐⭐⭐⭐ | Sangat relevan — langsung mendukung keputusan desain kita |
| **Novelty** | ⭐⭐⭐⭐ | Studi empiris pertama yang komprehensif tentang SBOM |
| **Clarity presentasi** | ⭐⭐⭐⭐ | Well-written dan well-structured |
| **Actionability** | ⭐⭐⭐⭐ | Temuan dapat langsung diterapkan dalam praktik |

**Rekomendasi**: Paper ini **wajib** dijadikan referensi utama dalam laporan proyek kita, terutama
untuk bagian literature review dan justifikasi arsitektur pipeline DevSecOps.

---

*Catatan ini ditulis oleh Kelompok 8 sebagai bagian dari proses literature review proyek DevSecOps.*
