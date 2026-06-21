# Firebase тохиргоо (Gevabal.mn)

## Одоогийн байдал

| Зүйл | Статус |
|------|--------|
| `firebase_core` + `firebase_messaging` package | ✅ Суулгасан |
| Push notification код | ✅ `push_notification_service.dart` |
| FCM token backend руу илгээх | ✅ `POST /users/profile` |
| `firebase_options.dart` (бодит config) | ❌ **Та үүсгэх хэрэгтэй** |
| `google-services.json` (Android) | ❌ |
| `GoogleService-Info.plist` (iOS) | ❌ |

**Chrome дээр** (`flutter run -d chrome`) Firebase config байхгүй бол push ажиллахгүй, гэхдээ апп бусад бүх зүйл ажиллана.

---

## Алхам 1 — Firebase төсөл үүсгэх

1. [Firebase Console](https://console.firebase.google.com/) нээнэ
2. **Add project** → нэр: `gevabal` эсвэл `sacred-app`
3. Google Analytics — заавал биш

---

## Алхам 2 — App бүртгэх

### Web (Chrome туршилт)
- Project → ⚙️ → **Your apps** → **Web** (`</>`)
- App nickname: `gevabal-web`
- Register

### Android
- **Add app** → Android
- Package name: `mn.gevabal.app`
- `google-services.json` татаж `android/app/` дотор хийнэ

### iOS
- **Add app** → iOS
- Bundle ID: `mn.gevabal.app`
- `GoogleService-Info.plist` татаж `ios/Runner/` дотор хийнэ

---

## Алхам 3 — FlutterFire CLI (хамгийн чухал)

PowerShell дээр:

```powershell
dart pub global activate flutterfire_cli
firebase login
cd "C:\Users\User\Desktop\buyntsog app"
flutterfire configure
```

Сонголтууд:
- Firebase төсөл сонгох
- Platforms: **web**, **android**, **ios** (аль алийг нь ашиглах вэ)

Энэ нь автоматаар `lib/firebase_options.dart` үүсгэнэ.

Дараа нь:
```powershell
flutter pub get
flutter run -d chrome
```

---

## Алхам 4 — Cloud Messaging идэвхжүүлэх

1. Firebase Console → **Build** → **Cloud Messaging**
2. iOS-д: **APNs key** (.p8 файл) оруулах шаардлагатай (App Store-д гаргахад)
3. Web-д: **Web Push certificates** (VAPID key) — `flutterfire configure` ихэнхийг тохируулна

---

## Алхам 5 — Backend-ээс push илгээх (дуудлагын мэдэгдэл)

Backend дээр `firebase-admin` ашиглана. Service account:

1. Firebase Console → Project Settings → **Service accounts**
2. **Generate new private key** → JSON татаж `backend/firebase-service-account.json` хадгална
3. `backend/.env` дээр:
   ```
   FIREBASE_SERVICE_ACCOUNT=./firebase-service-account.json
   ```

`firebase-service-account.json` файлыг **git-д оруулахгүй** (.gitignore-д орсон).

---

## Тест хийх

1. Бодит утас эсвэл Android emulator дээр ажиллуулна (Chrome-д push хязгаартай)
2. Нэвтэрсний дараа console дээр FCM token харагдана
3. Firebase Console → Cloud Messaging → **Send test message** → token оруулж туршина

---

## Түгээмэл асуулт

**Апп унах уу Firebase байхгүй үед?**  
Үгүй — `main.dart` try/catch-аар алгасдаг.

**Chrome дээр push ажиллах уу?**  
Web config (`firebase_options.dart` web хэсэг) зөв бол ажиллана, гэхдээ browser notification зөвшөөрөл хэрэгтэй.

**Юу хийх шаардлагатай вэ?**  
Зөвхөн `flutterfire configure` нэг удаа ажиллуулахад ихэнх зүйл бэлэн болно.
