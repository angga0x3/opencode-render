# OpenCode Server di Render (Blueprint)

Deploy **OpenCode CLI v1** (`opencode serve`) sebagai web service di Render
menggunakan Render Blueprint (`render.yaml`). Semua nilai flag/endpoint di bawah
ini diverifikasi langsung dari source `v1.19.6` (repo `anomalyco/opencode`).

## Isi folder

| File | Fungsi |
|---|---|
| `render.yaml` | Blueprint Render: web service Docker + health check + env vars |
| `Dockerfile` | Image `node:22-slim` + `git` + `opencode-ai` (npm), jalankan `opencode serve` |
| `.dockerignore` | Minimalkan build context |

## Langkah deploy

1. Push isi folder ini ke root sebuah repo GitHub (`render.yaml` **harus** di root repo).
2. Dashboard Render → **New + → Blueprint** → pilih repo → Render otomatis membaca `render.yaml`.
3. Saat apply, isi env var yang muncul (`sync: false`):
   - `OPENCODE_SERVER_PASSWORD` — **disarankan wajib**. Ini password HTTP Basic
     untuk melindungi server. Kalau kosong, server terbuka untuk siapa pun yang
     tahu URL (API key provider Anda bisa dipakai orang lain).
   - API key provider yang Anda pakai (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`,
     `GOOGLE_API_KEY`, `OPENROUTER_API_KEY`, `GROQ_API_KEY`, `XAI_API_KEY`) —
     isi minimal satu.
4. Klik **Apply** → build & deploy berjalan otomatis.

## Cara akses

URL service: `https://<nama-service>.onrender.com`

- **Web UI (embedded)** — buka URL di browser; muncul Basic auth prompt.
  Username default `opencode` (bisa diganti via `OPENCODE_SERVER_USERNAME`),
  password = `OPENCODE_SERVER_PASSWORD` yang Anda set.
- **API** — semua request pakai HTTP Basic auth:
  ```bash
  curl -u "opencode:$OPENCODE_SERVER_PASSWORD" https://<service>.onrender.com/doc
  ```
  `/doc` mengembalikan spesifikasi OpenAPI berisi daftar lengkap endpoint
  (sesi, prompt, file, dll).
- **Health check Render** — `GET /site.webmanifest` (satu-satunya path yang
  di-layani tanpa auth, jadi tetap 200 walau password aktif).

### Flag penting di Dockerfile

- `--hostname 0.0.0.0` — wajib. Default `opencode serve` adalah `127.0.0.1`
  dan tidak akan bisa diakses dari luar container.
- `--port ${PORT:-4096}` — Render meng-inject `$PORT` (default 10000).
- `--cors https://app-anda.com` — tambahkan ke `CMD` di Dockerfile hanya jika
  API dipanggil dari browser/web app di domain lain (bukan dari embedded web UI).

## Catatan & batasan

- **Plan free** → instance tidur setelah ±15 menit tanpa traffic (request
  pertama berikutnya lambat/cold start), dan **tidak mendukung disk** — data
  sesi di `~/.local/share/opencode` hilang saat deploy ulang/restart.
- **Persistensi**: upgrade ke plan berbayar, aktifkan blok `disk:` (mount
  `/data`, 1 GB) beserta `XDG_DATA_HOME` / `XDG_CONFIG_HOME` yang sudah
  disiapkan (terkomentar) di `render.yaml`.
- **Ganti versi**: ubah `ARG OPENCODE_VERSION` di `Dockerfile`
  (line v1 terakhir saat blueprint ini dibuat: `1.19.6`; jangan pakai tag
  `2.x` — CLI-nya berbeda, npm `@opencode/cli`).
- Binary kebutuhan lain (LSP, registry models.dev) diunduh on-demand saat
  pertama dipakai; di free plan ini diulang setiap deploy.
