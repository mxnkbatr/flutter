# Production deploy checklist
#
# ## Render backend
# - Dashboard: https://dashboard.render.com → geva-api service
# - Auto-deploy: main branch push (repo холбогдсон бол)
# - Env vars: MONGODB_URI, JWT_SECRET, LIVEKIT_*, QPAY_*, FIREBASE_*, CLOUDINARY_*, APP_BASE_URL=https://geva-backend.onrender.com
# - **JWT_SECRET**: Render дээр `generateValue` ашигла — local .env-тэй ижил байх ёсгүй
# - **Secrets**: backend/.env commit хийхгүй (.gitignore-д байна)
#
# ## Deploy шалгах
#
# ```powershell
# curl.exe -s "https://geva-backend.onrender.com/api/health"
# ```
#
# Хүлээгдэх JSON:
# - `ok: true`
# - `build`: git commit hash (7 тэмдэгт) — GitHub main-тай таарч байгаа эсэх
# - `features.forceProductDelete: true`
# - `qpayConfigured: true` (production QPay env байвал)
#
# Git commit hash:
# ```powershell
# git rev-parse --short HEAD
# ```
#
# ## Cold start багасгах
# - GitHub Action: `.github/workflows/keep-render-warm.yml` (10 мин тутам ping)
# - Repo push хийсний дараа GitHub → Actions идэвхжинэ
# - Эсвэл Render paid plan / UptimeRobot → GET /api/health
#
# ## Codemagic Android
# - `docs/ANDROID_RELEASE_SIGNING.md` уншаарай
# - CM_KEYSTORE + 3 password/alias variable заавал
