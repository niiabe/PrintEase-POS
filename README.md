# PrintEase POS

> Thermal receipt printing made easy. A lightweight, offline-first Flutter POS app for Bluetooth thermal printers.

PrintEase POS connects to Bluetooth thermal printers via ESC/POS protocol. Design receipt templates, create and manage receipts, export as PDF (with save-to-Downloads and native preview), and print directly — no internet or account required. Features a dashboard, receipt editing, auto-print, scan timeout/cancel, set-as-default template, and a full App Permissions Center in Settings. **Android only** (web/linux/windows removed).

---

## Features

### Printer Management
- Bluetooth printer scanning & discovery (paired + nearby unpaired via native `startDiscovery` — with 15s timeout & cancel)
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
- Customizable: store name, phone, header, footer, logo upload (auto-resized for thermal printer limits)
- Font size, alignment (left/center), spacing controls
- Toggle visibility for logo, QR code, dividers, itemized list
- "Set as Default Template" toggle on save
- Save button with unsaved-changes guard (confirmation dialog)
- Delete button when editing existing template

### Thermal Printing
- Full ESC/POS command generation including logo rendering (auto-resized to 320px/200px max width)
- Direct printing to connected Bluetooth printer
- Print status tracking (not printed / printed / failed)
- Reprint from receipt history
- Auto-print after receipt creation (configurable)
- Paper size-aware formatting
- Template-aware store name and footer on printed receipts

### PDF Export
- Generate PDF receipts matching thermal print format (same columns: Item / Qty / Total — no extra Price column)
- Native PDF preview (scrollable, zoomable)
- Save to Downloads folder with native system progress notification (via `flutter_file_downloader`)
- Share, print PDFs via system dialogs
- PDF history with preview and management

### Settings & Data
- Dark/Light theme toggle (persisted)
- Store info (name, phone, currency, configurable tax %)
- Default receipt template selector
- Printer settings (paper width, print density, character size, line spacing)
- Auto-connect, auto-save, auto-print toggles
- Full backup & restore (database + settings + templates)
- App Permissions Center — view & request Bluetooth, Notifications, and Photos/Videos permissions

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
| **Settings** | Appearance, store info, printer, receipt defaults, default template, App Permissions Center, backup/restore, Save button |
| **Backup & Restore** | Export/import app data to/from device storage |
| **PDF Exports** | List of exported PDFs with native preview, share, print, delete, save to Downloads (with native progress notification) |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (SDK ^3.11.5, upgraded to 3.44.0 / Dart 3.12.0) |
| **Kotlin** | 2.2.20 (overrode 3rd-party plugin versions to resolve deprecation warning) |
| **Gradle** | 8.14 + AGP 8.11.1 |
| **Desugaring** | `coreLibraryDesugaring` enabled (for `flutter_local_notifications`) |
| **State Management** | Riverpod (`flutter_riverpod` + `StateNotifier`) |
| **Routing** | `go_router` with `ShellRoute` (persistent bottom nav) |
| **Database** | SQLite (`sqflite`) — tables: `receipts`, `receipt_items`, `templates` |
| **Preferences** | `shared_preferences` (JSON-encoded settings) |
| **Bluetooth** | `print_bluetooth_thermal` + `esc_pos_utils_plus` |
| **PDF** | `pdf` + `printing` + `flutter_file_downloader` (native progress notifications) |
| **Image Picker** | `image_picker` (for store logos in templates) |
| **File Picker** | `file_picker` (for backup restore) |
| **Formatting** | `intl` |
| **Permissions** | Custom MethodChannel + `permission_handler` |
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
│   │   ├── core/                     # Constants, services, theme, utils
│   │   │   └── services/             # Platform channels (Bluetooth, native printer, PDF save, permissions, notifications)
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
│   └── android/                      # Android platform config (web/linux/windows removed)
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
flutter run -d <device-id>

# Or build APK and install manually
flutter build apk --debug
# APK location: build/app/outputs/flutter-apk/app-debug.apk
```

### Build Release APK

```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk

# Install on device
flutter install -d <device-id>
```

**Signing:** Release builds are signed with the project's keystore configured in `android/app/build.gradle.kts`.

---

## Configuration Notes

### Android
- **Min SDK:** Flutter default (typically 21+)
- **Permissions:** INTERNET, BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_CONNECT, BLUETOOTH_SCAN, ACCESS_FINE_LOCATION (maxSdkVersion=30), POST_NOTIFICATIONS, READ_MEDIA_IMAGES, WRITE_EXTERNAL_STORAGE (maxSdkVersion=28), READ_EXTERNAL_STORAGE (maxSdkVersion=32)
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

## Release

- **Latest:** v1.0.0+2 (May 24, 2026)
- **Application ID:** `io.niiabe.easepos`
- **Test print:** `TEST PRINT / by / NiiAbe.github.io`

## Known Limitations

- Bluetooth only (no USB/Wi-Fi printer support)
- Offline-only (no cloud sync)
- `dart:io` imports make web deployment unsupported (web platform removed)
- Print status requires manual refresh after printing
- 3rd-party plugins (`flutter_file_downloader`, `image_picker_android`, `print_bluetooth_thermal`, `shared_preferences_android`) still apply KGP directly instead of using Flutter's built-in Kotlin — non-fatal warning until plugin authors update
- No domain layer in architecture (empty `domain/` directories) — data + presentation layers only
- PDF "Save to Downloads" button may fail to copy to public Downloads — `flutter_file_downloader` package has known compatibility issues; fallback to app-internal storage works
- Major dependency bumps (riverpod 3.x, go_router 17.x, file_picker 11.x) blocked — require code migration due to breaking API changes

---

## License

MIT License
