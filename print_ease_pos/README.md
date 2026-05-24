# PrintEase POS

> Thermal receipt printing made easy. A lightweight, offline-first Flutter POS app for Bluetooth thermal printers — Android only.

PrintEase POS is a production-ready Flutter application that connects to Bluetooth thermal printers using ESC/POS protocol. It allows users to design receipt layouts, create and manage receipts, export as PDF, and print directly to POS printers — all without an internet connection or user account.

---

## Features

### Printer Management
- Bluetooth printer scanning & discovery (paired + nearby unpaired devices via native `startDiscovery`)
- Connect/disconnect with auto-reconnect support
- Preferred printer persistence
- ESC/POS protocol compatibility
- 58mm and 80mm paper size support
- Test print functionality
- Bluetooth state detection & user-friendly enable prompts
- Scan timeout (15s) with cancel button

### Receipt Creation & Management
- Create receipts with auto-generated receipt numbers (`RCP-YYYYMM-NNNN`)
- Edit existing receipts
- Add/edit/remove receipt items dynamically
- Automatic subtotal, tax (configurable, defaults to 0%), and total calculation
- Customer name, store name, and notes support
- Receipt history with search & filter (by date, print status, receipt number)
- Swipe-to-delete with confirmation
- Receipt detail view with all information
- Auto-print after creation (optional)

### Receipt Designer & Templates
- Visual template editor with live preview
- Multiple template support (Shop Receipt, Restaurant Receipt, Invoice, Delivery Slip)
- Customizable: store name, phone, header, footer, logo upload (auto-resized for thermal)
- Paper size selection (58mm / 80mm)
- Font size, alignment (left/center), and spacing controls
- Visibility toggles for logo, QR code, dividers, itemized list
- "Set as Default Template" toggle on save
- Templates persisted locally via SQLite

### Thermal Printing
- ESC/POS command generation for receipt data
- Direct printing to connected Bluetooth printer
- Print status tracking (not printed / printed / failed)
- Reprint support from receipt history
- Paper size-aware formatting including logo rendering
- Template-aware store name and footer

### PDF Export
- Generate PDF receipts matching thermal print format (same columns: Item / Qty / Total)
- Save PDFs to device storage with system download notifications
- Share PDFs via system share sheet
- Print PDFs via system print dialog
- PDF history with list view and preview
- One-tap download button on receipt detail & history
- Template-aware filenames and store branding

### Settings
- Dark/Light theme toggle (persisted)
- Store information (name, phone, currency, tax %)
- Printer settings (auto-connect, print density, character size, line spacing)
- Paper width selection (58mm / 80mm)
- Auto-save and auto-print toggles
- Default template selection
- App permissions center (Bluetooth, Notifications, Storage)
- Save button with confirmation

### Dashboard
- Today's receipt count and sales total
- Printer connection status
- Quick-action buttons (New Receipt, Scan Printer, Templates, PDF Exports)
- Recent receipts list (last 5)

### Backup & Restore
- Full backup (database + settings + templates)
- Restore from backup folder
- Granular restore options
- Timestamped backup folders

---

## Screens

| Screen | Description |
|---|---|---|
| **Dashboard** | Home screen — today's stats, quick actions, recent receipts |
| **Printer** | Connection status, scan devices, test print, paper size selector |
| **Receipts** | Receipt list with search, filters, swipe actions, download PDF |
| **Create Receipt** | Form with dynamic items, auto-calculated totals, save/edit |
| **Receipt Detail** | Full receipt view, print, download PDF, delete |
| **Templates** | Template list with swipe-to-delete, tap to edit |
| **Template Designer** | Live preview + all customization settings + set as default |
| **Settings** | Appearance, store info, printer, receipt, data management, permissions |
| **Backup & Restore** | Export/import app data |
| **PDF Export** | List of exported PDFs with preview, share, print, delete |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (SDK ^3.11.5) |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Routing** | `go_router` with ShellRoute (bottom navigation) |
| **Database** | SQLite (`sqflite`) with migration support |
| **Preferences** | `shared_preferences` |
| **Bluetooth Printing** | `print_bluetooth_thermal` + `esc_pos_utils_plus` |
| **PDF Generation** | `pdf` + `printing` |
| **Image Picking** | `image_picker` |
| **File Picking** | `file_picker` |
| **Formatting** | `intl` |
| **Architecture** | Feature-Based Clean Architecture |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, ProviderScope
├── app.dart                           # MaterialApp.router with theme + router
├── core/
│   ├── constants/                     # App constants, spacing, typography, radius
│   ├── services/                      # Platform channels (Bluetooth, native printer, PDF save, permissions, notifications)
│   ├── theme/                         # AppColors, light & dark ThemeData
│   └── utils/                         # Extensions (date, currency, responsiveness)
├── routes/
│   ├── app_routes.dart                # Route path constants
│   └── app_router.dart                # GoRouter configuration
├── shared/
│   ├── layouts/                       # AppShell (bottom nav), ResponsiveLayout
│   ├── dialogs/                       # Bluetooth dialog, Confirm dialog
│   └── widgets/                       # Reusable UI components
└── features/
    ├── dashboard/                     # Home screen with stats, quick actions
    ├── printer/                       # Bluetooth printer (scan, connect, print)
    ├── receipts/                      # Receipt CRUD, creation, history
    ├── templates/                     # Receipt template designer
    ├── settings/                      # App settings, backup & restore
    └── pdf_export/                    # PDF generation, storage, sharing
```

Each feature follows a **data/presentation** clean architecture pattern:

```
feature/
├── data/
│   ├── models/          # Data classes with fromMap/toMap serialization
│   ├── datasources/     # Raw data access (SQLite, SharedPreferences, Bluetooth, File System)
│   ├── services/        # Business logic operations
│   └── repositories/    # Abstraction layer wrapping datasources
└── presentation/
    ├── controllers/     # Riverpod StateNotifier providers
    ├── screens/         # Full-screen pages
    └── widgets/         # Feature-specific reusable components
```

---

## Database

- **Engine:** SQLite via `sqflite` (version 2)
- **Tables:** `receipts`, `receipt_items`, `templates`
- **Migration:** v1 → v2 adds templates table
- **Settings:** `SharedPreferences` (JSON encoded)

---

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.5
- Android device/emulator (Bluetooth required for printing) — **web/linux/windows platforms removed**
- A Bluetooth ESC/POS thermal printer (optional for development)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/PrintEase-POS.git
cd PrintEase-POS

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Generate a Release APK

```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk

# Install on device
flutter install -d <device-id>
```

**Signing:** Release builds are signed with the project's keystore configured in `android/app/build.gradle.kts`.

---

## Development

This project was built using OpenCode AI with specialized skills:

- **flutter-master-architect** — Project foundation, architecture, theme, routing
- **flutter-feature-builder** — Feature-by-feature implementation (printer, receipts, templates, settings, pdf_export)
- **flutter-expert-builder** — General Flutter development best practices
- **flutter-thermal-pos** — Specialized POS domain knowledge (ESC/POS, receipt layout, thermal printing)

### Development Order

1. Project Setup & Architecture
2. Routing & Navigation
3. Printer Connection (Bluetooth scanning, connect, disconnect)
4. Receipt UI & Creation
5. Local Database (SQLite)
6. Thermal Printing Service (ESC/POS)
7. PDF Export
8. Receipt Designer & Templates
9. Receipt History & Management
10. Settings & Backup/Restore
11. Production Optimization & Release

---

## Release

- **Latest:** v1.0.0+2 (May 24, 2026)
- **Application ID:** `io.niiabe.easepos`
- **Test print:** `TEST PRINT / by / NiiAbe.github.io`
- **Signing:** Release keystore configured in `android/app/build.gradle.kts`

## Known Limitations

- Bluetooth only (no USB/Wi-Fi printer support)
- Offline-only (no cloud sync)
- Android only (web/linux/windows platforms removed)
- Print status requires manual refresh after printing
- 3rd-party plugins still apply KGP — non-fatal warning
- Major dependency bumps (riverpod 3.x, go_router 17.x) blocked — require code migration
- PDF "Save to Downloads" may fail on some devices — `flutter_file_downloader` compatibility; internal storage fallback works

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*Built with Flutter + OpenCode AI*
