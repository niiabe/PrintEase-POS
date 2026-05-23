# PrintEase POS

> Thermal receipt printing made easy. A lightweight, offline-first Flutter POS app for Bluetooth thermal printers.

PrintEase POS connects to Bluetooth thermal printers via ESC/POS protocol. Design receipt templates, create and manage receipts, export as PDF (with save-to-Downloads and native preview), and print directly — no internet or account required. Features a dashboard, receipt editing, auto-print, and scan timeout/cancel.

---

## Features

### Printer Management
- Bluetooth printer scanning & discovery (with 15s timeout & cancel)
- Connect/disconnect with auto-reconnect
- Preferred printer persistence
- 58mm and 80mm paper size support
- Test print functionality
- Bluetooth state detection with native enable request (ACTION_REQUEST_ENABLE)

### Receipt Creation & History
- Auto-generated receipt numbers (`RCP-YYYYMM-NNNN`)
- Dynamic add/edit/remove receipt items
- Configurable tax percentage (default 0%, properly applied to totals)
- Edit existing receipts (items, customer, notes)
- Customer name, store name, and notes
- Search by receipt number, filter by date & print status
- Swipe-to-delete with confirmation

### Receipt Template Designer
- Visual editor with live preview
- Auto-seeded default templates on first install (Shop, Restaurant, Invoice, Delivery Slip)
- Customizable: store name, phone, header, footer, logo upload
- Font size, alignment (left/center), spacing controls
- Toggle visibility for logo, QR code, dividers, itemized list
- Save button with unsaved-changes guard (confirmation dialog)

### Thermal Printing
- Full ESC/POS command generation
- Direct printing to connected Bluetooth printer
- Print status tracking (not printed / printed / failed)
- Reprint from receipt history
- Auto-print after receipt creation (configurable)
- Paper size-aware formatting
- Configurable tax rate shown on printed receipt

### PDF Export
- Generate thermal-style PDF receipts
- Native PDF preview (scrollable, zoomable)
- Save to Downloads folder (Android)
- Share, print PDFs via system dialogs
- PDF history with preview and management

### Settings & Data
- Dark/Light theme toggle (persisted)
- Store info (name, phone, currency, configurable tax %)
- Default receipt template selector
- Printer settings (paper width, print density, character size, line spacing)
- Auto-connect, auto-save, auto-print toggles
- Full backup & restore (database + settings + templates)

---

## Branding & Icons

PrintEase POS uses custom branded icons across all platforms:

| Platform | Icon Location |
|---|---|
| **Android Launcher** | `android/app/src/main/res/mipmap-*dpi/ic_launcher.png` |
| **Android Adaptive** | `mipmap-anydpi-v26/ic_launcher.xml` (API 26+) |
| **Android Splash** | `launch_background.xml` with centered icon |
| **iOS App Store** | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (15 sizes) |
| **Flutter Asset** | `assets/images/app_icon.png`, `assets/images/logo.svg` |

Source icons available in `app_icons/`:
- `Android/` — 48/72/96/144/192px PNGs
- `iOS/` — 20×20 through 1024×1024 PNGs
- `Source/PrintEasePOS_1024.png` — master 1024×1024 source

---

## Screens

| Screen | Description |
|---|---|
| **Dashboard** | Today's receipt count & sales, printer status, quick actions, recent receipts |
| **Printer** | Connection status, scan devices (15s timeout + cancel), test print, paper size selector |
| **Receipts** | List with search, status & date filters, swipe delete, PDF download |
| **Create/Edit Receipt** | Form with dynamic items, auto-calculated totals, save, auto-print |
| **Receipt Detail** | Full view with print/reprint, edit, download PDF, delete |
| **Templates** | Template list with swipe delete, tap to edit |
| **Template Designer** | Live preview + all customization settings + logo picker + Save button with unsaved-changes guard |
| **Settings** | Appearance, store info, printer, receipt defaults, default template, backup/restore, Save button |
| **Backup & Restore** | Export/import app data to/from device storage |
| **PDF Exports** | List of exported PDFs with native preview, share, print, delete, save to Downloads |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (SDK ^3.11.5, upgraded to 3.44.0 / Dart 3.12.0) |
| **State Management** | Riverpod (`flutter_riverpod` + `StateNotifier`) |
| **Routing** | `go_router` with `ShellRoute` (persistent bottom nav) |
| **Database** | SQLite (`sqflite`) — tables: `receipts`, `receipt_items`, `templates` |
| **Preferences** | `shared_preferences` (JSON-encoded settings) |
| **Bluetooth** | `print_bluetooth_thermal` + `esc_pos_utils_plus` |
| **PDF** | `pdf` + `printing` |
| **Image Picker** | `image_picker` (for store logos in templates) |
| **File Picker** | `file_picker` (for backup restore) |
| **Formatting** | `intl` |
| **Architecture** | Feature-based with data/presentation layers |

---

## Project Structure

```
PrintEase-POS/
├── app_icons/                        # Source icons (Android/iOS/Source)
│   ├── Android/                      # 48-192px PNGs per density
│   ├── iOS/                          # AppIcon set (20-1024px)
│   └── Source/                       # Master 1024×1024 PNG
├── PrintEasePOS_AppIcon.png          # Root 1024×1024 app icon
├── PrintEasePOS_AppIcon.svg          # Vector app icon source
├── PrintEasePOS_Logo.svg             # Vector logo source
├── print_ease_pos/                   # Flutter application root
│   ├── lib/
│   │   ├── main.dart                 # Entry point + ProviderScope
│   │   ├── app.dart                  # MaterialApp.router + theme
│   │   ├── core/                     # Constants, theme, utils
│   │   ├── routes/                   # GoRouter config (ShellRoute)
│   │   ├── shared/                   # Reusable widgets, dialogs, layouts
│   │   └── features/                 # Feature modules
│   │       ├── dashboard/            # Home screen with stats & quick actions
│   │       ├── printer/              # Bluetooth scan (timeout/cancel), connect, print
│   │       ├── receipts/             # CRUD, creation, history, editing
│   │       ├── templates/            # Template designer & preview
│   │       ├── settings/             # Settings + backup/restore
│   │       └── pdf_export/           # PDF generation, preview & management
│   ├── assets/images/                # Bundled app icon & logo
│   └── android/ios/web/              # Platform configs
```

### Feature Module Structure

```
feature/
├── data/
│   ├── models/           # Data classes with fromMap/toMap
│   ├── datasources/      # Raw data access (SQLite, SharedPrefs, Bluetooth)
│   ├── services/         # Business logic (ESC/POS, PDF, Backup)
│   └── repositories/     # Coordination layer
└── presentation/
    ├── controllers/      # Riverpod StateNotifier providers
    ├── screens/          # Full pages
    └── widgets/          # Feature components
```

---

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.5 (latest stable recommended)
- Android device (Bluetooth required for printing)
- Bluetooth ESC/POS thermal printer (optional)

### Run on Device

```bash
cd print_ease_pos

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Or build APK and install manually
flutter build apk --debug
# APK location: build/app/outputs/flutter-apk/app-debug.apk
```

### Build Release APK

```bash
flutter build apk --release
# For split APKs (per architecture):
flutter build apk --split-per-abi
```

**Important:** Before building a release APK, configure signing in `android/app/build.gradle.kts`. By default, the release build uses debug signing keys.

---

## Configuration Notes

### Android
- **Min SDK:** Flutter default (typically 21+)
- **Permissions:** BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_CONNECT, BLUETOOTH_SCAN, ACCESS_FINE_LOCATION (Android 12+)
- **App Icons:** Custom PrintEasePOS icons across all densities + adaptive icon support (API 26+)

### App Icon Files

| Density | Size | Source |
|---|---|---|
| mdpi | 48×48 | `app_icons/Android/icon-48.png` |
| hdpi | 72×72 | `app_icons/Android/icon-72.png` |
| xhdpi | 96×96 | `app_icons/Android/icon-96.png` |
| xxhdpi | 144×144 | `app_icons/Android/icon-144.png` |
| xxxhdpi | 192×192 | `app_icons/Android/icon-192.png` |

---

## Development

Built with [OpenCode AI](https://opencode.ai):

| Skill | Purpose |
|---|---|
| **flutter-master-architect** | Foundation, architecture, theme, routing |
| **flutter-feature-builder** | Feature-by-feature implementation |
| **flutter-expert-builder** | Advanced patterns, code quality, best practices |
| **flutter-thermal-pos** | ESC/POS, receipt layout, thermal printing |

---

## Known Limitations

- Bluetooth only (no USB/Wi-Fi printer support)
- Offline-only (no cloud sync)
- `dart:io` imports make web deployment unsupported
- Print status requires manual refresh after printing

---

## License

MIT License
