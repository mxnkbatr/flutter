# Gevabal.mn (Sacred App)

Буддын ламтай холбогдох Flutter апп + Node.js API.

## Эхлүүлэх

### 1. Backend
```bash
cd backend
npm install
npm run seed    # анхны лам, хэрэглэгч
npm run dev     # http://localhost:3000/api
```

**Тест account:**
| Role | Email | Password |
|------|-------|----------|
| Client | client@test.com | client123 |
| Monk | monk@test.com | monk123 |
| Admin | admin@test.com | admin123 |

### 2. Flutter
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

API URL: `lib/core/api/api_config.dart` → `http://localhost:3000/api`

Android emulator: `http://10.0.2.2:3000/api`

### 3. Firebase
`FIREBASE_SETUP.md` үзнэ үү.

### 4. QPay
`backend/.env` дотор `QPAY_USERNAME`, `QPAY_PASSWORD`, `QPAY_INVOICE_CODE` оруулна.
Хоосон бол **mock QPay** — 15 секундын дараа автоматаар төлөгдсөн гэж тооцно.

### 5. LiveKit
`backend/.env`:
- `LIVEKIT_API_KEY`
- `LIVEKIT_API_SECRET`
- `LIVEKIT_URL` — LiveKit Cloud dashboard-аас авна (`wss://....livekit.cloud`)

## Бүтэц
- `lib/` — Flutter app (01–07 modules)
- `backend/` — Express + MongoDB API
