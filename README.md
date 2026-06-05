# Pairvi

**Pairvi** is a Flutter app for legal professionals to prepare accurate **goshwara** (degree amount) calculations for court cases. It helps advocates and court staff compute year-wise breakdowns, track payments, save work locally, and export court-ready PDF reports.

## About

Goshwara statements are used in Pakistani legal practice to summarize how a decree amount accrues over time, often with annual percentage increments, partial payments, and verification status. Doing this by hand is slow and error-prone. Pairvi automates the math, keeps a clear record of each case, and produces documents suitable for filing or sharing.

The app is designed for daily use in chambers and courts: fast data entry, readable results, offline access, and bilingual support for English and Urdu.

## Features

- **Goshwara calculator** — Enter court, case details, decree holder vs judgement debtor, degree amount, date range, and annual increment percentage
- **Year-wise summary** — Automatic breakdown by year with per-month amounts, month counts, and totals
- **Payment tracking** — Record paid amounts with optional dates and order sheet numbers; see total paid and remaining balance
- **Case types** — Searchable preset list plus custom case types
- **Verification status** — Mark goshwara as verified/finalized (e.g. by court or counsel)
- **Save & resume** — Calculations stored locally with Hive; reopen recent cases from the dashboard
- **PDF export** — Generate and share goshwara calculation reports
- **English & Urdu** — Full UI translation with RTL layout for Urdu
- **Light, dark & system theme** — Appearance follows device settings or can be set manually
- **Responsive layout** — Works on phones, tablets, and desktop-width layouts with adaptive navigation
- **Web landing page** — Marketing site with the same calculator for browser use

## Screenshots & branding

App icons and splash assets are generated from `ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png`. After replacing icons, sync all platforms:

```bash
cp ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png assets/images/app_icon.png
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter clean
```

## Tech stack

| Layer | Choice |
|-------|--------|
| Framework | [Flutter](https://flutter.dev) 3.x (Dart ^3.11) |
| Local storage | Hive, SharedPreferences |
| PDF | `pdf`, `printing` |
| Sharing | `share_plus` |
| i18n | Custom translations (en / ur) |
| Icons & splash | `flutter_launcher_icons`, `flutter_native_splash` |

## Supported platforms

- iOS
- Android
- macOS
- Web (landing + calculator)
- Windows / Linux (Flutter project scaffold present)

## Getting started

### Prerequisites

- Flutter SDK (3.11+)
- Xcode (iOS/macOS), Android Studio or SDK (Android), or Chrome (web)

### Install & run

```bash
git clone <repository-url>
cd gushwarah
flutter pub get
flutter run
```

Run on a specific device:

```bash
flutter run -d ios
flutter run -d android
flutter run -d chrome   # web
```

### Tests

```bash
flutter test
```

### Build release

```bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
```

## Project structure

```
lib/
├── main.dart                 # App entry, theme & locale
├── app_theme.dart            # Light/dark themes
├── screens/                  # Splash, home, calculator, settings
├── widgets/                  # Shared UI (logo, footer, tables, forms)
├── services/                 # Calculator, storage, export, locale, theme
├── models/                   # Case input, payments, saved calculations
├── data/                     # Case types, verification options
└── l10n/                     # English & Urdu strings
```

## Credits

- **Credit:** Advocate Islamuddin
- **Developed by:** [Techease Solutions](https://techease.com)

## License

Private project — not published to pub.dev (`publish_to: 'none'`).
