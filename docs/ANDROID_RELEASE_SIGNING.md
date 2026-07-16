# Codemagic Android release signing
#
# Play Store-д зөвхөн **upload keystore** (.jks) ашиглана. Debug keystore (`androiddebugkey`) хэрэглэхгүй.
#
# ## 1. Keystore үүсгэх (нэг удаа — алдаж болохгүй, backup хадгал!)
#
# ```powershell
# keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
# ```
#
# ## 2. Base64 болгох (Codemagic CM_KEYSTORE)
#
# ```powershell
# [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))
# ```
#
# macOS/Linux:
# ```bash
# base64 -i upload-keystore.jks | pbcopy
# ```
#
# ## 3. Codemagic → Application → Environment variables
#
# | Variable | Type | Value |
# |----------|------|-------|
# | `CM_KEYSTORE` | Secret | base64(.jks файл) |
# | `CM_KEYSTORE_PASSWORD` | Secret | keystore password |
# | `CM_KEY_ALIAS` | Variable | `upload` (эсвэл alias нэр) |
# | `CM_KEY_PASSWORD` | Secret | key password |
#
# Group: `code-signing` эсвэл global — `android-release` workflow автоматаар уншина.
#
# ## 4. Local AAB (Android Studio / CLI)
#
# `android/key.properties` үүсгэх (git-д commit хийхгүй):
#
# ```
# storePassword=YOUR_STORE_PASSWORD
# keyPassword=YOUR_KEY_PASSWORD
# keyAlias=upload
# storeFile=app/upload-keystore.jks
# ```
#
# ```powershell
# flutter build appbundle --release `
#   --dart-define=API_BASE_URL=https://geva-backend.onrender.com/api `
#   --dart-define=PREFER_DEV_AUTH=false
# ```
#
# Output: `build/app/outputs/bundle/release/app-release.aab`
