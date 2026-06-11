# UI Prompt 01 — Splash + Onboarding + Login

**Reference:** [`SACRED_APP_DESIGN_SYSTEM.md`](../SACRED_APP_DESIGN_SYSTEM.md)

**Зорилго:** Хэрэглэгч app нээхэд WOW мэдрэмж өгөх, login хялбар.

## Implementation

| Screen | Path |
|--------|------|
| Splash | `lib/features/splash/presentation/splash_screen.dart` |
| Onboarding | `lib/features/auth/presentation/onboarding_screen.dart` |
| Login | `lib/features/auth/presentation/login_screen.dart` |
| SacredInput | `lib/shared/widgets/sacred_input.dart` |

## Assets

- `assets/icons/sacred_logo.svg`
- `assets/icons/google.svg`
- `assets/icons/onboard_video.svg`
- `assets/lottie/meditation.json`, `calendar.json`

## Routes

- `/splash` → auth check → `/onboarding` (эхний удаа) эсвэл `/auth/login`
- `/onboarding` → `/auth/login`
- `/auth/login` → role-based home

## Cursor зааврууд

- Login error: SnackBar биш — inline `errorText`
- Keyboard: `SingleChildScrollView` + `BouncingScrollPhysics`
- Forgot password: `showModalBottomSheet` + email + send
- Lottie: `assets/lottie/` — `errorBuilder` fallback icon

**Дараагийн:** `UI_02_HOME_SEARCH.md`
