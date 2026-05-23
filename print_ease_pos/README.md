# PrintEase POS

> Thermal receipt printing made easy. A lightweight, offline-first Flutter POS app for Bluetooth thermal printers.

PrintEase POS is a production-ready Flutter application that connects to Bluetooth/Wi-Fi thermal printers using ESC/POS protocol. It allows users to design receipt layouts, create and manage receipts, export as PDF, and print directly to POS printers — all without an internet connection or user account.

---

## Features

### Printer Management
- Bluetooth printer scanning & discovery
- Connect/disconnect with auto-reconnect support
- Preferred printer persistence
- ESC/POS protocol compatibility
- 58mm and 80mm paper size support
- Test print functionality
- Bluetooth state detection & user-friendly enable prompts

### Receipt Creation & Management
- Create receipts with auto-generated receipt numbers (`RCP-YYYYMM-NNNN`)
- Add/edit/remove receipt items dynamically
- Automatic subtotal, tax (configurable), and total calculation
- Customer name, store name, and notes support
- Receipt history with search & filter (by date, print status, receipt number)
- Swipe-to-delete with confirmation
- Receipt detail view with all information

### Receipt Designer & Templates
- Visual template editor with live preview
- Multiple template support (Shop Receipt, Restaurant Receipt, Invoice, Delivery Slip)
- Customizable: store name, phone, header, footer, logo upload
- Paper size selection (58mm / 80mm)
- Font size, alignment (left/center), and spacing controls
- Visibility toggles for logo, QR code, dividers, itemized list
- Templates persisted locally via SQLite

### Thermal Printing
- ESC/POS command generation for receipt data
- Direct printing to connected Bluetooth printer
- Print status tracking (not printed / printed / failed)
- Reprint support from receipt history
- Print preview widget
- Paper size-aware formatting

### PDF Export
- Generate thermal-style PDF receipts
- Save PDFs to device storage
- Share PDFs via system share sheet
- Print PDFs via system print dialog
- PDF history with list view and preview
- One-tap download button on receipt detail & history

### Settings
- Dark/Light theme toggle (persisted)
- Store information (name, phone, currency, tax %)
- Printer settings (auto-connect, print density, character size, line spacing)
- Paper width selection (58mm / 80mm)
- Auto-save and auto-print toggles
- Default template selection

### Backup & Restore
- Full backup (database + settings + templates)
- Restore from backup folder
- Granular restore options
- Timestamped backup folders

---

## Screens

| Screen | Description |
|---|---|
| **Printer** | Connection status, scan devices, test print, paper size selector |
| **Receipts** | Receipt list with search, filters, swipe actions, download PDF |
| **Create Receipt** | Form with dynamic items, auto-calculated totals, save |
| **Receipt Detail** | Full receipt view, print, download PDF, delete |
| **Templates** | Template list with swipe-to-delete, tap to edit |
| **Template Designer** | Live preview + all customization settings |
| **Settings** | Appearance, store info, printer, receipt, data management |
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
- Android device/emulator (Bluetooth required for printing)
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
```

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

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*Built with Flutter + OpenCode AI*
