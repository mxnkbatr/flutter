# UI Prompt 02 — Home + Monk List + Search

**Reference:** [`SACRED_APP_DESIGN_SYSTEM.md`](../SACRED_APP_DESIGN_SYSTEM.md)

## Implementation

| Screen / Widget | Path |
|-----------------|------|
| Home | `lib/features/home/home_screen.dart` |
| Search | `lib/features/home/search_screen.dart` |
| Recommendation card | `lib/features/home/widgets/recommended_monk_card.dart` |
| Category chip | `lib/features/home/widgets/category_chip.dart` |
| Sort button | `lib/features/home/widgets/sort_button.dart` |
| Monk list tile | `lib/features/home/widgets/monk_list_tile.dart` |
| Search bar delegate | `lib/features/home/widgets/search_bar_delegate.dart` |
| Search providers | `lib/features/home/providers/search_provider.dart` |

## Routes

- `/home` — main feed (ClientShell)
- `/search` — full-page search (`context.push('/search')`)

## Hero

`Monk.heroTag(id)` — grid card image → profile AppBar image

**Дараагийн:** `UI_03_MONK_PROFILE_BOOKING.md`
