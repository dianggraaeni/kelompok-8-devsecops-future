# Refleksi Kelompok — DevSecOps Supply Chain Security

> **Kelompok 8** — Dian Anggraeni Putri, Acintya Edria Sudarsono, Tsaldia Hukma Cita, Callista Meyra Azizah
> **Tanggal:** 19 Juni 2026

---

## 1. Apa yang paling mengejutkan dari paper yang kamu baca — sesuatu yang berbeda dari asumsimu sebelumnya? Bagaimana temuan itu mengubah keputusan implementasimu?

Sebelum membaca literatur secara mendalam, asumsi awal kami sebagai kelompok cukup sederhana: semua tool SBOM (Software Bill of Materials) pada dasarnya melakukan hal yang sama — yaitu memindai image atau source code, lalu menghasilkan daftar dependensi beserta versinya. Kami beranggapan bahwa perbedaan antar-tool hanyalah soal format output atau kecepatan eksekusi, bukan soal substansi hasil deteksinya. Ternyata, asumsi ini sepenuhnya salah.

Temuan dari **O'Donoghue et al. (2024)** benar-benar mengejutkan kami. Penelitian mereka menunjukkan bahwa tool SBOM yang berbeda — seperti Syft, Trivy, dan Tern — menghasilkan hasil deteksi kerentanan yang **berbeda secara signifikan** ketika dijalankan pada image container yang sama. Perbedaan ini bukan hanya soal satu atau dua CVE yang terlewat, melainkan perbedaan substansial dalam jumlah komponen yang terdeteksi, versi yang dilaporkan, dan bahkan ekosistem paket yang berhasil dikenali. Implikasinya sangat besar: jika sebuah organisasi hanya mengandalkan satu tool tanpa memahami keterbatasannya, maka mereka bisa saja memiliki *blind spot* keamanan yang cukup serius.

Temuan ini secara langsung memengaruhi keputusan arsitektur implementasi kami. Alih-alih menggunakan satu tool monolitik yang menangani baik generasi SBOM maupun pemindaian kerentanan, kami memutuskan untuk **memisahkan kedua fungsi tersebut**. Kami memilih **Syft** secara spesifik untuk generasi SBOM karena berdasarkan literatur, Syft memiliki cakupan deteksi komponen yang lebih luas dan konsisten, terutama untuk ekosistem bahasa pemrograman yang kami gunakan. Sementara itu, untuk pemindaian kerentanan, kami menggunakan **Trivy** yang memiliki database kerentanan yang diperbarui secara berkala dan kemampuan scanning yang lebih terfokus. Dengan pendekatan *best-of-breed* ini, kami mendapatkan hasil yang lebih komprehensif dibanding menggunakan satu tool saja.

Kejutan lain datang dari **Xia et al. (2023)** yang mengungkapkan betapa rendahnya tingkat adopsi SBOM di industri, meskipun tooling-nya sudah tersedia dan relatif mudah digunakan. Mereka menemukan bahwa bahkan di ekosistem open source yang seharusnya lebih transparan, hanya sebagian kecil proyek yang secara aktif menghasilkan dan mendistribusikan SBOM. Hal ini mengejutkan karena kami berasumsi bahwa setelah insiden-insiden besar seperti SolarWinds dan Log4Shell, adopsi SBOM pasti sudah meluas. Kenyataannya, kesenjangan antara ketersediaan tool dan adopsi aktual masih sangat besar. Temuan ini memperkuat motivasi kami untuk tidak hanya mengimplementasikan SBOM secara teknis, tetapi juga mendokumentasikan prosesnya dengan baik agar bisa menjadi referensi bagi proyek lain. Kami menyadari bahwa salah satu hambatan adopsi adalah kurangnya contoh implementasi yang jelas dan terdokumentasi — sesuatu yang kami coba atasi melalui proyek ini.

Secara keseluruhan, kedua temuan ini mengubah pendekatan kami dari yang awalnya *"pilih satu tool dan jalankan"* menjadi pendekatan yang lebih deliberatif dan berbasis bukti empiris. Setiap keputusan tool yang kami ambil sekarang memiliki justifikasi yang jelas berdasarkan literatur.

---

## 2. Di mana implementasimu berbeda dari yang diusulkan paper, dan mengapa? Apakah karena keterbatasan waktu/resources, atau karena kamu tidak setuju dengan pendekatannya?

Implementasi kami memiliki beberapa perbedaan signifikan dari apa yang direkomendasikan oleh literatur, dan kami ingin bersikap transparan bahwa sebagian besar perbedaan ini disebabkan oleh **keterbatasan waktu dan cakupan proyek**, bukan karena ketidaksetujuan dengan pendekatan yang diusulkan.

**Pertama**, paper-paper yang kami baca — khususnya Xia et al. (2023) dan O'Donoghue et al. (2024) — membahas manajemen SBOM pada skala enterprise. Dalam konteks tersebut, SBOM tidak hanya dihasilkan per-build, melainkan disimpan dalam **database terpusat** yang memungkinkan query, perbandingan antar-versi, dan pelacakan historis. Organisasi besar memiliki *SBOM repository* yang terintegrasi dengan sistem manajemen aset dan incident response. Implementasi kami jauh lebih sederhana: kami hanya melakukan **generasi SBOM per-build** sebagai artefak dalam pipeline CI/CD. SBOM yang dihasilkan disimpan sebagai file JSON yang di-attach ke GitHub Actions run, tanpa database terpusat atau mekanisme query. Ini adalah penyederhanaan yang signifikan, tetapi realistis mengingat kami hanya memiliki waktu sekitar **satu minggu** untuk implementasi dan proyek ini bersifat akademis.

**Kedua**, literatur membahas pentingnya mendukung **multiple format SBOM** — setidaknya CycloneDX dan SPDX — karena ekosistem konsumer SBOM yang berbeda memiliki preferensi format yang berbeda pula. Beberapa regulasi (seperti yang didorong oleh NTIA di Amerika Serikat) juga menyebutkan kedua format tersebut. Dalam implementasi kami, kami memilih untuk hanya menggunakan **CycloneDX** sebagai satu-satunya format output. Keputusan ini didasarkan pada pertimbangan praktis: CycloneDX memiliki dukungan yang lebih baik di ekosistem tool yang kami gunakan (Syft dan Trivy), formatnya lebih ringkas, dan untuk tujuan demonstrasi akademis, satu format sudah cukup untuk menunjukkan konsep. Menambahkan dukungan multi-format akan menambah kompleksitas pipeline tanpa memberikan nilai tambah yang signifikan dalam konteks proyek ini.

**Ketiga**, paper-paper yang kami baca — terutama yang membahas ekosistem SBOM secara holistik — menekankan pentingnya **siklus hidup SBOM yang lengkap**: generation, consumption, sharing, dan monitoring. Ekosistem yang matang mencakup distribusi SBOM kepada downstream consumers, integrasi dengan vulnerability feeds untuk monitoring berkelanjutan, dan mekanisme untuk membandingkan SBOM antar-rilis. Implementasi kami hanya mencakup dua tahap pertama: **generation** (menggunakan Syft) dan **scanning** (menggunakan Trivy untuk mengonsumsi SBOM dan mendeteksi kerentanan). Kami tidak mengimplementasikan mekanisme sharing atau monitoring berkelanjutan. Sekali lagi, ini bukan karena kami menganggap tahap-tahap tersebut tidak penting — justru sebaliknya, kami sangat memahami nilainya — tetapi cakupan proyek akademis satu minggu tidak memungkinkan implementasi ekosistem yang lengkap.

Penting untuk ditekankan bahwa tidak ada satu pun dari perbedaan ini yang muncul karena **ketidaksetujuan filosofis** dengan pendekatan yang diusulkan paper. Kami sepenuhnya setuju bahwa SBOM harus dikelola dalam database, mendukung multiple format, dan memiliki siklus hidup yang lengkap. Perbedaan-perbedaan ini murni merupakan trade-off pragmatis antara idealisme akademis dan realitas implementasi.

---

## 3. Jika kamu punya waktu satu bulan penuh dan akses ke production cluster nyata, apa yang akan kamu lakukan berbeda atau tambahkan? Gunakan paper sebagai landasan argumenmu.

Jika kami diberikan waktu satu bulan penuh dan akses ke production Kubernetes cluster yang sesungguhnya, ada banyak hal yang akan kami lakukan untuk membawa implementasi ini dari level *proof-of-concept* ke level *production-ready*. Setiap penambahan berikut dilandasi oleh rekomendasi dari literatur yang telah kami pelajari.

### a. Implementasi Full SLSA Level 3 Provenance

Saat ini, pipeline kami hanya menghasilkan artefak yang ditandatangani, tetapi belum memenuhi persyaratan **SLSA (Supply-chain Levels for Software Artifacts) Level 3** secara penuh. Dengan waktu satu bulan, kami akan mengimplementasikan *provenance attestation* yang lengkap sesuai framework SLSA. Ini mencakup: (1) build yang dilakukan di lingkungan *ephemeral* dan *isolated*, (2) provenance yang dihasilkan secara otomatis oleh build platform (bukan oleh script yang bisa dimodifikasi developer), dan (3) metadata provenance yang mencakup seluruh chain dari source code hingga artefak final. SLSA Level 3 memberikan jaminan yang jauh lebih kuat bahwa artefak yang di-deploy benar-benar berasal dari source code yang diharapkan, tanpa modifikasi di tengah jalan. Ini adalah fondasi penting untuk supply chain security yang sesungguhnya.

### b. SBOM Database dan Diff Comparison

Mengikuti rekomendasi **Xia et al. (2023)**, kami akan membangun **database SBOM terpusat** yang menyimpan setiap SBOM dari setiap rilis aplikasi. Database ini memungkinkan kami melakukan *diff comparison* antar-rilis — misalnya, mengetahui komponen apa yang ditambahkan, diperbarui, atau dihapus antara versi 1.2 dan 1.3. Kemampuan ini sangat berharga untuk incident response: ketika sebuah CVE baru ditemukan, tim keamanan bisa dengan cepat melakukan query terhadap database untuk mengetahui versi mana saja yang terpengaruh. Kami akan menggunakan tools seperti **DependencyTrack** sebagai platform manajemen SBOM yang sudah memiliki fitur-fitur ini secara built-in, termasuk policy evaluation dan trend analysis.

### c. Admission Controller untuk Verifikasi Tanda Tangan

Salah satu kelemahan terbesar implementasi kami saat ini adalah bahwa meskipun kami menandatangani image dengan Cosign, **tidak ada mekanisme yang mencegah deployment image yang tidak ditandatangani**. Mengikuti rekomendasi **Kalu et al. (2025)**, kami akan mengimplementasikan **Kubernetes admission controller** — menggunakan tools seperti **Sigstore Policy Controller** atau **Kyverno** — yang secara otomatis menolak Pod yang mencoba menggunakan image tanpa tanda tangan valid. Ini mengubah artifact signing dari sekadar *best practice* menjadi **kontrol keamanan yang enforced**. Tanpa admission controller, signing hanyalah langkah seremonial yang bisa diabaikan — dengan admission controller, ia menjadi gerbang keamanan yang tidak bisa dilewati.

### d. Continuous SBOM Monitoring

SBOM yang dihasilkan saat build hanya mencerminkan status kerentanan pada saat itu. CVE baru ditemukan setiap hari, dan komponen yang dianggap aman hari ini bisa saja memiliki kerentanan kritis besok. Dengan waktu satu bulan, kami akan mengimplementasikan **monitoring berkelanjutan** yang secara periodik memindai SBOM yang tersimpan di database terhadap feed kerentanan terbaru (seperti NVD, GitHub Advisory Database, dan OSV). Ketika kerentanan baru ditemukan yang memengaruhi komponen dalam SBOM aktif, sistem akan mengirimkan notifikasi otomatis kepada tim terkait. Ini mengubah pendekatan dari *point-in-time scanning* menjadi *continuous monitoring* yang jauh lebih efektif dalam lanskap ancaman yang dinamis.

### e. Integrasi Mendalam dengan Kubernetes

Terakhir, dengan akses ke production cluster, kami akan mengintegrasikan seluruh pipeline secara mendalam dengan ekosistem Kubernetes. Ini mencakup: deployment menggunakan **GitOps** (ArgoCD atau Flux) yang memverifikasi tanda tangan sebelum melakukan sync, **network policies** yang membatasi komunikasi antar-pod berdasarkan prinsip least privilege, **runtime security monitoring** menggunakan Falco untuk mendeteksi perilaku anomali yang mungkin mengindikasikan supply chain compromise, dan **RBAC policies** yang membatasi siapa saja yang bisa melakukan deployment ke namespace production. Integrasi ini menjadikan keamanan sebagai bagian integral dari infrastruktur, bukan sekadar lapisan tambahan di pipeline CI/CD.

Dengan semua penambahan ini, implementasi kami akan bergerak dari demonstrasi akademis menjadi platform DevSecOps yang benar-benar siap untuk lingkungan produksi — sesuai dengan visi yang digambarkan oleh literatur yang telah kami pelajari.

---

## Referensi

- O'Donoghue, J., et al. (2024). *Comparative Analysis of SBOM Generation Tools for Container Images.*
- Xia, B., et al. (2023). *An Empirical Study of Software Bill of Materials: Current Practices and Challenges.*
- Kalu, O., et al. (2025). *DevSecOps and Supply Chain Security: Integrating Signing and Verification in CI/CD Pipelines.*
- SLSA Framework. *Supply-chain Levels for Software Artifacts.* https://slsa.dev
