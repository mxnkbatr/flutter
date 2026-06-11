# Sacred App — iOS UI Design System

> **Cursor reference:** Бүх UI prompt, screen, widget ажилд эхлээд энэ файлыг уншина.
> Apple HIG + Dark luxury — харанхуй алт + цагаан цэврүүн.

**Code paths:** `lib/core/theme/app_colors.dart` · `lib/core/theme/app_text.dart` · `lib/shared/widgets/`

---

## Өнгөний тогтолцоо

Бүх өнгийг зөвхөн `AppColors`-оос авна. Hardcode хэзээ ч хийхгүй (`Color(0x...)`, `Colors.white` гэх мэт).

### Dark surfaces (AppBar, Hero, Card dark)

| Token | Hex | Use |
|-------|-----|-----|
| `inkDeep` | `0xFF1A1208` | Хамгийн харанхуй — AppBar, Hero bg |
| `inkMid` | `0xFF2C2008` | Dark card bg |
| `inkLight` | `0xFF3D3010` | Separator, subtle border дотор dark bg |

### Gold (accent, CTA, highlight)

| Token | Hex | Use |
|-------|-----|-----|
| `goldPrime` | `0xFFF5C842` | Үндсэн accent — CTA, icon, selected |
| `goldLight` | `0xFFFFF8E1` | Gold tinted surface — chip bg, badge bg |
| `goldMuted` | `0xFF8B7A4A` | Subtitle дотор dark bg, secondary text |

### Light surfaces (content areas)

| Token | Hex | Use |
|-------|-----|-----|
| `surface` | `0xFFFAFAF8` | Scaffold bg — цагаан бишхэн шаргал |
| `surfaceEl` | `0xFFFFFFFF` | Card, input bg |
| `border` | `0xFFE8E6E0` | Card border 0.5px |
| `borderSub` | `0xFFF0EDE6` | Row divider |

### Text

| Token | Hex | Use |
|-------|-----|-----|
| `textPri` | `0xFF1A1208` | Heading, body |
| `textSec` | `0xFF888888` | Subtitle, meta |
| `textHint` | `0xFFC0B898` | Placeholder, disabled |

### Semantic

| Token | Hex |
|-------|-----|
| `success` | `0xFF2D9B4E` |
| `warning` | `0xFFE8A000` |
| `danger` | `0xFFE53935` |

---

## Typography — SF Pro (iOS default)

Flutter автоматаар SF Pro ашиглана iOS дээр. `fontFamily` заахгүй — system default.

| Style | Size | Weight | Extra | Use |
|-------|------|--------|-------|-----|
| `h1` | 28px | w700 | ls: -0.5 | Screen title |
| `h2` | 22px | w600 | | Section heading |
| `h3` | 17px | w600 | | Card title (iOS body bold) |
| `body` | 15px | w400 | lh: 1.5 | Content text |
| `bodySmall` | 13px | w400 | | Meta, description |
| `caption` | 11px | w400 | ls: 0.3 | Tag, badge label |
| `goldLabel` | 11px | w700 | ls: 0.5, `goldPrime` | Special badge |
| `price` | 17px | w700 | | Үнэ харуулах |

Import: `AppText.h1`, `AppText.body`, гэх мэт — `lib/core/theme/app_text.dart`

---

## Spacing — 4px grid

| px | Use |
|----|-----|
| 4 | icon gap, badge padding |
| 8 | chip padding, small gap |
| 12 | card внутренний gap |
| 16 | card padding, section gap |
| 20 | screen horizontal padding (iOS standard) |
| 24 | section vertical gap |
| 32 | large section gap |

---

## Border radius

| px | Use |
|----|-----|
| 8 | chip, small badge |
| 12 | input field, small card |
| 14 | standard card |
| 20 | large card, bottom sheet |
| 28 | phone pill shape |
| 50% | avatar, circle button |

---

## iOS-specific rules (чухал)

1. **SafeArea** — бүх screen-д заавал. Top + Bottom.
2. **Status bar** — dark bg дээр: light icons. Light bg дээр: dark icons.
3. **Bottom nav** — home indicator зай: `MediaQuery.of(context).padding.bottom + 8`
4. **AppBar height** — 44px (iOS standard). Large title хэрэглэх бол 96px.
5. **Back button** — iOS-style `CupertinoIcons.chevron_left`, "Буцах" label хажуудаа
6. **Modal bottom sheet** — top handle bar (4×36px, border radius 2)
7. **Tap target** — доод хязгаар 44×44px (Apple HIG)
8. **Haptic feedback** — товч дарахад `HapticFeedback.lightImpact()`
9. **Scroll** — `BouncingScrollPhysics()` — iOS rubber band эффект
10. **Transition** — GoRouter ашиглана, `CupertinoPageRoute` биш; slide-from-right transition (iOS feel)

---

## Shared widgets

Бүх screen-д эдгээр widget-уудыг дахин ашиглана. Шинэ screen бичихээс өмнө `lib/shared/widgets/` шалгана.

| Widget | Spec |
|--------|------|
| `SacredAppBar` | inkDeep bg, gold title, back button |
| `SacredCard` | white + 0.5px border + 14 radius |
| `SacredCardDark` | inkMid bg + 0.5px inkLight border |
| `SacredButton` | gold bg, inkDeep text, 52px height |
| `SacredOutlineBtn` | white bg, border, 52px |
| `SacredInput` | filled white, gold focus border |
| `SacredBadge` | status badge — confirmed/pending/cancelled |
| `SacredAvatar` | CachedNetworkImage + fallback initials |
| `SacredDivider` | borderSub color, 0.5px |
| `SacredShimmer` | gold highlight shimmer loading |
| `SacredEmptyState` | icon + title + subtitle + optional CTA |

**Одоо байгаа:** `SacredCard`, `SacredButton` (`lib/shared/widgets/`)

---

## Animation rules

### Duration

| Token | ms | Use |
|-------|-----|-----|
| `fast` | 150 | Tap feedback, toggle |
| `normal` | 250 | Page element appear |
| `slow` | 400 | Page transition, modal |

### Curve

- `easeOut` — element appear (from bottom/scale)
- `easeInOut` — toggle, switch

### Ашиглах

- `AnimatedContainer` — height/color/border transition
- `AnimatedOpacity` — fade in content
- `SlideTransition` — bottom sheet, card reveal
- `Hero` — monk image → profile page

### Хэзээ ч ашиглахгүй

`AnimationController` + `TickerProvider` — зөвхөн шаардлагатай үед

---

## Screen spec файлууд (дараалал)

Дэлгэрэнгүй screen prompt-ууд:

| # | File | Scope |
|---|------|-------|
| 01 | `docs/ui/UI_01_SPLASH_ONBOARDING_LOGIN.md` | Splash, onboarding, login |
| 02 | `docs/ui/UI_02_HOME_SEARCH.md` | Home, search |
| 03 | `docs/ui/UI_03_MONK_PROFILE_BOOKING.md` | Monk profile, booking |
| 04 | `docs/ui/UI_04_PAYMENT_SUCCESS.md` | Payment, success |
| 05 | `docs/ui/UI_05_VIDEO_CALL.md` | Video call |
| 06 | `docs/ui/UI_06_MONK_DASHBOARD.md` | Monk dashboard |
| 07 | `docs/ui/UI_07_ADMIN_PANEL.md` | Admin panel |

Screen бичихдээ: **DESIGN_SYSTEM → UI_XX spec → одоогийн код** гэсэн дарааллаар уншина.
