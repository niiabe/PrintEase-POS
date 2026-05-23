---
name: flutter-thermal-pos
description: MUST be used for Flutter thermal printer apps, POS systems, Bluetooth ESC/POS printing, receipt builders, offline receipt storage, PDF export, receipt history, and clean Flutter architecture. Enforces scalable feature-based architecture, reusable widgets, Riverpod state management, and modular Flutter code organization.
license: MIT
compatibility: opencode
---

# Flutter Thermal POS Skill

## Purpose

This skill helps build clean, scalable Flutter thermal POS printer applications.

Always use this skill when building:
- Thermal printer apps
- Receipt printing apps
- Bluetooth printer integrations
- ESC/POS printing
- POS systems
- Receipt designers
- Receipt history systems
- PDF export systems

---

# Architecture Rules

Always use feature-based clean architecture.

Structure:

```plaintext
lib/
│
├── core/
│   ├── constants/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── printer/
│   ├── receipts/
│   ├── settings/
│   ├── templates/
│   └── pdf_export/
│
├── shared/
│   ├── widgets/
│   ├── dialogs/
│   └── layouts/
│
├── routes/
│
├── app.dart
└── main.dart
```

---

# State Management

Always use:
- flutter_riverpod

Avoid:
- setState for large features
- bloated controllers
- giant screens

---

# Printer Rules

Always use ESC/POS compatible implementation.

Preferred packages:
- print_bluetooth_thermal
- esc_pos_utils_plus

Requirements:
- Bluetooth support
- 58mm support
- 80mm support
- reconnect support
- test print support

---

# Receipt Rules

Receipts MUST:
- save locally
- support PDF export
- support reprint
- support QR codes
- support logos
- support templates

Use SQLite for local storage.

Preferred packages:
- sqflite
- path_provider

---

# UI Rules

Always:
- create reusable widgets
- split large widgets
- use responsive layouts
- support dark mode
- avoid giant files

Maximum:
- 300 lines per widget file

Break widgets into:
- sections
- cards
- dialogs
- components

---

# Receipt Designer Rules

Receipt builder must support:
- header editing
- footer editing
- logo upload
- alignment
- QR code
- paper size selection
- spacing customization

---

# PDF Rules

Use:
- pdf
- printing

Support:
- download PDF
- share PDF
- reprint PDF

---

# Routing Rules

Always use:
- go_router

Avoid:
- inline navigation everywhere

---

# Database Rules

Always separate:
- models
- services
- repositories
- providers

Never place database logic inside widgets.

---

# Code Quality Rules

Always:
- create strongly typed models
- use null safety
- avoid duplicate code
- use constants
- create reusable services

Never:
- hardcode UI repeatedly
- place business logic in UI
- create massive files

---

# Development Workflow

Build in this order:

1. Project Setup
2. Routing
3. Printer Connection
4. Receipt UI
5. Receipt Database
6. Print Service
7. PDF Export
8. Receipt Designer
9. History Screen
10. Settings

---

# Recommended Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod:
  go_router:

  sqflite:
  path_provider:

  pdf:
  printing:

  print_bluetooth_thermal:
  esc_pos_utils_plus:

  image_picker:
  intl:
```

---

# Important Rules

The app:
- MUST work offline
- MUST NOT require authentication
- MUST save receipts locally
- MUST support PDF export
- MUST support Bluetooth thermal printing

Focus on:
- simplicity
- scalability
- maintainability
- reusable architecture