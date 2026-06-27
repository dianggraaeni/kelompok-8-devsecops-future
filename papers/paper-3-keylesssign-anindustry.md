# 📄 Catatan Bacaan: An Industry Interview Study of Software Signing for Supply Chain Security

> **Catatan ini ditulis sebagai bagian dari literature review untuk proyek DevSecOps Kelompok 8.**
> Terakhir diperbarui: 27 Juni 2026

---

# 1. Informasi Paper

| Field              | Detail                                                                                                                                       |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Judul**          | An Industry Interview Study of Software Signing for Supply Chain Security                                                                    |
| **Penulis**        | Kelechi G. Kalu, Tanmay Singla, Chinenye Okafor, Santiago Torres-Arias, James C. Davis                                                       |
| **Tahun**          | 2025                                                                                                                                         |
| **Venue**          | 34th USENIX Security Symposium (USENIX Security 2025)                                                                                        |
| **DOI / Link**     | [https://www.usenix.org/conference/usenixsecurity25/presentation/kalu](https://www.usenix.org/conference/usenixsecurity25/presentation/kalu) |
| **Tipe Studi**     | Qualitative Empirical Study (Semi-Structured Interviews)                                                                                     |
| **Afiliasi**       | Purdue University                                                                                                                            |
| **Jumlah Halaman** | 21 halaman                                                                                                                                   |

### Konteks Publikasi

Paper ini dipublikasikan pada **USENIX Security Symposium 2025**, salah satu konferensi paling bergengsi (Tier-1) di bidang cybersecurity. Berbeda dengan penelitian eksperimental yang menguji tool secara langsung, paper ini berfokus pada **praktik nyata industri** melalui wawancara dengan para praktisi keamanan perangkat lunak yang berpengalaman. 

---

# 2. Ringkasan Eksekutif

Paper ini mengeksplorasi bagaimana **software signing** benar-benar diterapkan di industri untuk meningkatkan keamanan software supply chain.

Penelitian dilakukan melalui:

1. **18 wawancara semi-terstruktur**
2. **13 organisasi berbeda**
3. Praktisi senior yang bertanggung jawab terhadap software security dan supply chain.

Penelitian tidak hanya membahas **bagaimana software signing digunakan**, tetapi juga:

* tantangan implementasi,
* persepsi pentingnya signing,
* pengaruh regulasi,
* serta bagaimana organisasi mengelola proses signing.

Hasil penelitian menunjukkan bahwa walaupun hampir semua organisasi telah melakukan software signing pada artifact akhir, **verifikasi signature masih jarang dilakukan**, sehingga manfaat signing belum dimaksimalkan. Paper juga menemukan bahwa **key management merupakan tantangan teknis terbesar**, sehingga pendekatan **keyless signing** seperti Sigstore menjadi solusi yang banyak direkomendasikan. 

---

# 3. Klaim Utama & Metodologi

## 3.1 Research Questions

Paper menjawab empat research question utama.

* **RQ1**: Bagaimana software signing diterapkan dalam software supply chain?
* **RQ2**: Apa tantangan implementasi software signing?
* **RQ3**: Seberapa penting software signing menurut praktisi?
* **RQ4**: Bagaimana pengaruh insiden keamanan, standar, dan regulasi terhadap adopsi software signing? 

---

## 3.2 Metodologi

Penelitian menggunakan pendekatan **semi-structured interview**.

* **18 praktisi keamanan**
* **13 organisasi**
* berasal dari perusahaan cloud, security, SaaS, open source, hingga aerospace.
* durasi wawancara sekitar **50 menit** per peserta.

Analisis dilakukan menggunakan:

* Thematic Analysis
* Framework Analysis
* Multi-stage coding

hingga diperoleh berbagai tema mengenai praktik software signing di industri. 

---

# 4. Temuan Kunci yang Relevan untuk Implementasi

## 4.1 Hampir Semua Organisasi Melakukan Signing pada Artifact

Semua organisasi yang diwawancarai melakukan signing terhadap **final software artifact** sebelum didistribusikan.

Namun,

verifikasi terhadap signature sebelum deployment masih sangat sedikit dilakukan.

Artinya,

banyak organisasi melakukan signing hanya sebagai proses akhir tanpa benar-benar memanfaatkan proses verifikasi. 

---

## 4.2 Key Management Menjadi Tantangan Terbesar

Paper menemukan bahwa tantangan paling banyak disebut adalah:

* penyimpanan private key
* distribusi public key
* rotasi key
* pengelolaan PKI

Masalah ini menyebabkan banyak organisasi kesulitan menerapkan software signing secara konsisten. 

---

## 4.3 Keyless Signing Menjadi Solusi

Beberapa praktisi secara eksplisit merekomendasikan penggunaan:

* Sigstore
* Keyless Signing
* OIDC Identity

karena:

* tidak perlu menyimpan private key permanen,
* mengurangi risiko kebocoran key,
* mempermudah rotasi,
* lebih mudah diintegrasikan dengan CI/CD.

Paper menyebut bahwa identitas dapat diverifikasi menggunakan OIDC (misalnya GitHub Identity), sehingga keaslian penanda tangan tetap terjamin tanpa harus mengelola key jangka panjang. 

---

## 4.4 Signing Harus Diotomatisasi

Paper menunjukkan bahwa proses signing paling efektif ketika dilakukan secara otomatis di pipeline CI/CD.

Beberapa organisasi menggunakan:

* GitHub Actions
* Build Pipeline
* Automated Signing

untuk memastikan setiap artifact yang berhasil dibangun langsung ditandatangani tanpa intervensi manual. 

---

## 4.5 Signing Bukan Satu-satunya Mekanisme Keamanan

Sebagian besar praktisi berpendapat bahwa signing tidak cukup berdiri sendiri.

Signing perlu dikombinasikan dengan:

* SBOM
* Attestation
* Vulnerability Scanning
* Metadata Collection

agar provenance software menjadi lebih kuat.

Dengan kata lain,

Signing hanya memastikan artifact tidak berubah,

sedangkan SBOM menjelaskan isi artifact tersebut. 

---

# 5. Asumsi dan Keterbatasan Paper

## 5.1 Jumlah Responden Relatif Kecil

Paper hanya melibatkan:

* 18 praktisi
* 13 organisasi

Walaupun sesuai dengan metodologi penelitian kualitatif, hasilnya tidak dapat digeneralisasikan ke seluruh industri software. 

---

## 5.2 Fokus pada Organisasi Berpengalaman

Sebagian besar responden berasal dari organisasi yang memang bergerak di bidang keamanan software.

Akibatnya,

tantangan organisasi kecil atau startup mungkin belum sepenuhnya terwakili.

---

## 5.3 Tidak Melakukan Eksperimen Tool

Paper ini tidak membandingkan:

* Cosign vs Notary
* Sigstore vs GPG
* Keyless vs Key-based

melainkan berfokus pada pengalaman praktisi.

Oleh karena itu paper ini melengkapi, bukan menggantikan, studi eksperimental mengenai tool. 

---

# 6. Hal yang Dipertanyakan

## 6.1 Apakah Semua Organisasi Cocok Menggunakan Keyless Signing?

Paper menunjukkan banyak keuntungan keyless signing.

Namun,

belum dibahas secara mendalam bagaimana implementasinya pada organisasi yang:

* tidak menggunakan cloud,
* tidak memiliki OIDC,
* bekerja secara offline.

---

## 6.2 Mengapa Verifikasi Signature Masih Jarang Dilakukan?

Walaupun hampir semua organisasi melakukan signing,

paper menunjukkan bahwa proses **verify** sering diabaikan.

Ini menjadi pertanyaan penting,

karena tanpa verifikasi, manfaat software signing menjadi berkurang.

---

## 6.3 Belum Ada Evaluasi Performa

Paper tidak membahas:

* tambahan waktu pipeline,
* overhead signing,
* dampak terhadap performa CI/CD.

Padahal hal tersebut cukup penting dalam implementasi DevSecOps.

---

# 7. Kekuatan Paper

Beberapa kekuatan utama paper ini adalah:

1. **Berbasis praktik industri nyata**, bukan simulasi laboratorium.
2. **Dipublikasikan di USENIX Security**, salah satu venue terbaik di bidang keamanan siber.
3. Menjelaskan **tantangan teknis, organisasi, dan manusia** secara menyeluruh.
4. Memberikan rekomendasi implementasi yang dapat langsung diterapkan.
5. Menunjukkan bahwa software signing merupakan bagian penting dari software supply chain security.

---

# 8. Implikasi untuk Proyek DevSecOps Kelompok 8

## 8.1 Validasi Keputusan Menggunakan Cosign

Paper mendukung penggunaan:

* Cosign
* Sigstore
* Keyless Signing

karena mengurangi kompleksitas key management.

Hal ini sesuai dengan implementasi pipeline kelompok kami.

---

## 8.2 Validasi Integrasi ke CI/CD

Paper menunjukkan bahwa signing sebaiknya dilakukan secara otomatis.

Pipeline GitHub Actions kami menerapkan:

```
Build Image
      ↓
Generate SBOM
      ↓
Scan Vulnerability
      ↓
Cosign Sign
      ↓
Publish Image
```

Pendekatan ini selaras dengan praktik yang direkomendasikan dalam paper. 

---

## 8.3 Signing Harus Diikuti Verifikasi

Paper juga mengingatkan bahwa signing saja belum cukup.

Karena itu proyek kami juga menyediakan tahap:

```
cosign verify
```

untuk memastikan artifact benar-benar valid sebelum digunakan.

---

## 8.4 Kombinasi SBOM + Scanning + Signing

Paper menekankan bahwa software signing memberikan manfaat maksimal jika dipadukan dengan metadata keamanan lain seperti SBOM dan vulnerability scanning.

Arsitektur proyek kami mengikuti pendekatan tersebut dengan mengintegrasikan:

* **Syft** untuk menghasilkan SBOM,
* **Trivy** untuk vulnerability scanning,
* **Cosign** untuk artifact signing dan verification.

Dengan demikian, implementasi kami tidak hanya menjamin integritas artifact, tetapi juga meningkatkan transparansi komponen dan membantu deteksi kerentanan secara otomatis.

---

# 9. Kutipan Penting

> "Key management issues were the most reported issues." 

> "Sigstore comes in... keyless signing... you don't have to worry about long-lasting static keys." 

> "All 18 subjects said that signing is done at the deployment stage to establish provenance." 

---

# 10. Hubungan dengan Paper Lain yang Dibaca

| Paper                                 | Hubungan                                                                                                                                                                                             |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Paper 1 (Xia et al., 2023)**        | Paper 1 menjelaskan pentingnya SBOM untuk transparansi software supply chain, sedangkan paper ini menjelaskan bagaimana software signing digunakan untuk menjaga integritas dan provenance artifact. |
| **Paper 2 (O'Donoghue et al., 2024)** | Paper 2 menjadi dasar pemilihan tool SBOM (Syft, CycloneDX, Trivy), sedangkan paper ini menjadi dasar pemilihan **Cosign dengan keyless signing** sebagai mekanisme artifact signing.                |

---

# 11. Penilaian Keseluruhan

| Aspek                      | Penilaian | Catatan                                                                     |
| -------------------------- | --------- | --------------------------------------------------------------------------- |
| **Rigor metodologi**       | ⭐⭐⭐⭐⭐     | Wawancara mendalam dengan praktisi senior menggunakan thematic analysis     |
| **Relevansi untuk proyek** | ⭐⭐⭐⭐⭐     | Sangat relevan sebagai dasar penggunaan Cosign dan keyless signing          |
| **Novelty**                | ⭐⭐⭐⭐⭐     | Studi kualitatif pertama yang membahas praktik software signing di industri |
| **Clarity presentasi**     | ⭐⭐⭐⭐      | Penyajian sistematis dengan banyak contoh nyata dari praktisi               |
| **Actionability**          | ⭐⭐⭐⭐⭐     | Rekomendasi implementasi dapat langsung diterapkan pada pipeline DevSecOps  |

**Rekomendasi:** Paper ini layak dijadikan referensi utama pada bagian **Design Decisions** proyek, terutama untuk menjelaskan **mengapa kelompok memilih Cosign dengan mekanisme keyless signing**. Berbeda dengan dokumentasi resmi yang hanya menjelaskan cara penggunaan Cosign, paper ini memberikan **landasan empiris dari praktik industri**, menunjukkan bahwa pendekatan tersebut dipilih untuk mengatasi tantangan utama berupa manajemen kunci (key management), meningkatkan integrasi dengan CI/CD, serta memperkuat integritas dan provenance artifact dalam software supply chain.
