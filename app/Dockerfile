# =========================================
# Stage 1: Build
# =========================================
# Menggunakan Node.js 18 Alpine sebagai base image
# Alpine dipilih untuk ukuran image yang lebih kecil
FROM node:18-alpine AS builder
RUN apk update && apk upgrade --no-cache

# Set working directory
WORKDIR /app

# Copy dependency files terlebih dahulu (untuk optimasi Docker layer caching)
# Jika package.json dan package-lock.json tidak berubah, layer npm install
# akan di-cache dan tidak perlu dijalankan ulang
COPY package*.json ./

# Install semua dependencies (termasuk devDependencies untuk testing)
RUN npm ci

# Copy seluruh source code
COPY . .

# Jalankan tests untuk memastikan aplikasi berjalan dengan baik
RUN npm test

# =========================================
# Stage 2: Production
# =========================================
FROM node:18-alpine AS production
RUN npm install -g npm@latest && \
    apk update && apk upgrade --no-cache

# Metadata labels sesuai OCI Image Spec
# Label ini akan muncul di SBOM dan membantu traceability
LABEL org.opencontainers.image.title="DevSecOps Supply Chain Demo" \
      org.opencontainers.image.description="Task Management API for SBOM & Supply Chain Security Demo" \
      org.opencontainers.image.authors="Kelompok 8" \
      org.opencontainers.image.source="https://github.com/dianggraaeni/kelompok-8-devsecops-future" \
      org.opencontainers.image.vendor="Kelompok 8 - DevSecOps" \
      org.opencontainers.image.version="1.0.0"

# Buat user non-root untuk security best practice
# Menjalankan container sebagai root adalah anti-pattern keamanan
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install HANYA production dependencies
# --omit=dev menghilangkan devDependencies untuk mengurangi attack surface
RUN npm ci --omit=dev && \
    npm cache clean --force

# Copy source code dari builder stage
COPY --from=builder /app/src ./src

# Set ownership ke non-root user
RUN chown -R appuser:appgroup /app

# Gunakan non-root user
USER appuser

# Expose port aplikasi
EXPOSE 3000

# Set environment variable
ENV NODE_ENV=production

# Health check untuk container orchestration (Docker/Kubernetes)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Jalankan aplikasi
CMD ["node", "src/index.js"]
