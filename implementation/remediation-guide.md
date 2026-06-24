# Panduan Remediasi Vulnerability
# =========================================================
# Komponen: Vulnerability Scanning & Security Gate
# =========================================================

## Daftar Vulnerability yang Terdeteksi & Remediasi

Dokumen ini mendokumentasikan proses remediasi vulnerability yang terdeteksi
oleh Trivy dalam pipeline enhanced. Setiap vulnerability disertai analisis
dan langkah remediasi yang diambil.

---

## 1. Vulnerability yang Terdeteksi

### 1.1 lodash v4.17.15

| CVE ID | Severity | Tipe | Status Remediasi |
|--------|----------|------|-----------------|
| CVE-2019-10744 | 🔴 **CRITICAL** | Prototype Pollution | ✅ Upgrade ke 4.17.21 |
| CVE-2021-23337 | 🟠 **HIGH** | Command Injection | ✅ Upgrade ke 4.17.21 |
| CVE-2020-28500 | 🟡 **MEDIUM** | ReDoS | ✅ Upgrade ke 4.17.21 |

**Analisis:**
- `CVE-2019-10744`: Prototype Pollution via `defaultsDeep` — attacker bisa memodifikasi Object prototype
  dan mempengaruhi seluruh aplikasi. **CRITICAL** karena bisa dieksploitasi tanpa autentikasi.
- `CVE-2021-23337`: Command Injection via template function — jika user input langsung dimasukkan
  ke lodash template tanpa sanitasi. Dalam kode kita, kita menggunakan `_.trim`, `_.filter`,
  `_.sortBy`, `_.countBy` — fungsi yang **tidak** terpengaruh. Namun tetap harus di-fix.
- `CVE-2020-28500`: ReDoS di fungsi `trimEnd` — bisa menyebabkan denial of service.

**Remediasi:** `npm install lodash@4.17.21`

---

### 1.2 jsonwebtoken v8.5.1

| CVE ID | Severity | Tipe | Status Remediasi |
|--------|----------|------|-----------------|
| CVE-2022-23529 | 🟠 **HIGH** | Remote Code Execution | ✅ Upgrade ke 9.0.2 |
| CVE-2022-23540 | 🟠 **HIGH** | Authentication Bypass | ✅ Upgrade ke 9.0.2 |

**Analisis:**
- `CVE-2022-23529`: RCE melalui crafted JWT token — jika `secretOrPublicKey` object disediakan
  oleh pihak yang tidak dipercaya. Dalam kode kita, secret di-hardcode (`JWT_SECRET`), jadi
  risiko eksploitasi rendah, tapi tetap harus di-patch.
- `CVE-2022-23540`: Bypass signature validation — memungkinkan forged token diterima sebagai valid.
  **Ini berbahaya** untuk endpoint yang memerlukan autentikasi.

**Remediasi:** `npm install jsonwebtoken@9.0.2`

---

### 1.3 axios v0.21.1

| CVE ID | Severity | Tipe | Status Remediasi |
|--------|----------|------|-----------------|
| CVE-2021-3749 | 🟠 **HIGH** | ReDoS | ✅ Upgrade ke 1.7.9 |

**Analisis:**
- `CVE-2021-3749`: ReDoS melalui crafted URL — bisa menyebabkan server hang.
  Digunakan di endpoint `/external/status` untuk HTTP call.

**Remediasi:** `npm install axios@1.7.9`

---

### 1.4 minimist v1.2.5

| CVE ID | Severity | Tipe | Status Remediasi |
|--------|----------|------|-----------------|
| CVE-2021-44906 | 🔴 **CRITICAL** | Prototype Pollution | ✅ Upgrade ke 1.2.8 |

**Analisis:**
- `CVE-2021-44906`: Prototype Pollution melalui argument parsing. Minimist adalah
  transitive dependency (digunakan oleh tools lain). **CRITICAL** karena bisa
  mempengaruhi behavior seluruh aplikasi.

**Remediasi:** `npm install minimist@1.2.8` atau update parent dependency

---

### 1.5 node-fetch v2.6.0

| CVE ID | Severity | Tipe | Status Remediasi |
|--------|----------|------|-----------------|
| CVE-2022-0235 | 🟠 **HIGH** | Information Disclosure | ✅ Upgrade ke 2.7.0 |

**Analisis:**
- `CVE-2022-0235`: Exposure of sensitive information — headers bisa bocor saat
  redirect ke domain lain. Node-fetch digunakan sebagai transitive dependency.

**Remediasi:** `npm install node-fetch@2.7.0`

---

## 2. Ringkasan Remediasi

| Severity | Sebelum | Sesudah Remediasi | Perubahan |
|----------|---------|-------------------|-----------|
| 🔴 CRITICAL | 2 | 0 | -2 ✅ |
| 🟠 HIGH | 5 | 0 | -5 ✅ |
| 🟡 MEDIUM | 1 | 0 | -1 ✅ |
| **Total** | **8** | **0** | **-8** ✅ |

## 3. Perintah Remediasi (Satu Langkah)

```bash
cd app

# Update semua vulnerable dependencies sekaligus
npm install \
  lodash@4.17.21 \
  jsonwebtoken@9.0.2 \
  axios@1.7.9 \
  minimist@1.2.8 \
  node-fetch@2.7.0

# Verifikasi dengan npm audit
npm audit

# Jalankan tests untuk memastikan tidak ada breaking changes
npm test
```

## 4. Verifikasi Pasca-Remediasi

```bash
# Build image baru
docker build -t devsecops-demo:remediated .

# Scan ulang dengan Trivy
trivy image --severity CRITICAL,HIGH devsecops-demo:remediated

# Expected: No CRITICAL or HIGH vulnerabilities
# Pipeline akan PASS di security gate
```

---

> **Catatan dari paper:** Xia et al. (2023) menekankan bahwa nilai SBOM terletak
> pada *actionability*-nya. Dokumen ini menunjukkan bahwa vulnerability yang
> terdeteksi oleh scanning **bisa ditindaklanjuti** dengan remediasi yang jelas,
> bukan hanya dilaporkan tanpa solusi.
