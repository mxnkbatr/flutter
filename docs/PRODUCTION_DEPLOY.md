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
#
# ## Shorebird (Flutter code push)
#
# Хоёр өөр зам — хольж болохгүй:
#
# | Өөрчлөлт | Workflow | Store review |
# |----------|----------|--------------|
# | Native (plugin, permission, icon, Flutter SDK bump) | `ios-app-store` / `android-release` (main push) | Тийм |
# | Зөвхөн Dart засвар/feature | `shorebird-patch-ios` / `shorebird-patch-android` (Codemagic UI-аас гараар) | Үгүй — хэдэн минутад төхөөрөмж рүү |
#
# ### Нэг удаагийн setup (local)
#
# 1. https://console.shorebird.dev бүртгэл
# 2. CLI суулгаад login:
#    ```bash
#    curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
#    shorebird login
#    ```
# 3. Repo root дээр:
#    ```bash
#    shorebird init
#    ```
#    `shorebird.yaml` үүснэ — **commit хий** (`.gitignore`-д оруулахгүй).
# 4. Shorebird Console → Account → API Keys → Create → `SHOREBIRD_TOKEN`
#    Codemagic → Environment variables → group `code-signing` → Secret болгож нэм.
# 5. Baseline release (store-оор нэг удаа):
#    ```bash
#    shorebird release android
#    shorebird release ios
#    ```
#    Эдгээрийг App Store / Play Store-д upload хийсний дараа л patch хийх боломжтой.
#
# ### Patch өгөх
#
# 1. Dart-only өөрчлөлтөө `main`-д merge
# 2. Codemagic → Start new build → `Shorebird Patch iOS` эсвэл `Shorebird Patch Android`
# 3. `release_version` input: `latest` эсвэл яг `2.1.7+43`
# 4. Store submit байхгүй — Shorebird өөрөө төхөөрөмж рүү түгээнэ
#
# Local шалгах:
# ```bash
# shorebird preview
# ```
#
# Patch workflow `main` push дээр **автоматаар ажиллахгүй** (store workflow-тай зөрөхгүйн тулд).
