# OpenCode CLI v1 — headless server (opencode serve)
FROM node:22-bookworm-slim

# git dibutuhkan opencode untuk operasi VCS (status, diff, snapshot)
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Pin versi OpenCode 1 di sini (override saat build: --build-arg OPENCODE_VERSION=x.y.z)
ARG OPENCODE_VERSION=1.19.6
RUN npm install -g --no-fund --no-audit "opencode-ai@${OPENCODE_VERSION}"

# Direktori kerja default untuk sesi/proyek
WORKDIR /workspace

EXPOSE 4096

# Render meng-inject $PORT (default 10000); fallback 4096 untuk run lokal.
# --hostname 0.0.0.0 wajib: default opencode serve adalah 127.0.0.1.
CMD ["sh", "-c", "opencode serve --hostname 0.0.0.0 --port ${PORT:-4096}"]
