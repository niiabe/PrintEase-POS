---
name: flutter-expert-builder
description: MUST be used for all Flutter app development, Flutter UI generation, responsive layouts, Riverpod architecture, clean Flutter code structure, reusable widget systems, Firebase integration, local storage, API integration, Flutter animations, and production-ready Flutter applications. Optimized for AI-assisted Flutter development using VS Code, Cursor AI, and OpenCode.
license: MIT
compatibility: opencode
---

# Flutter Expert Builder Skill

## Purpose

This skill provides professional Flutter development architecture and standards for scalable production-ready mobile applications.

Use this skill for:
- Flutter mobile apps
- Flutter web apps
- POS systems
- Thermal printer apps
- Admin dashboards
- E-commerce apps
- Booking systems
- Offline-first apps
- Firebase apps
- API-based apps

---

# Core Flutter Rules

Always:
- Use clean architecture
- Use reusable widgets
- Use responsive layouts
- Use null safety
- Use feature-based structure
- Keep files modular
- Use strongly typed models

Never:
- Create giant widget files
- Put business logic inside UI
- Duplicate widgets repeatedly
- Hardcode values repeatedly
- Use deeply nested widget trees unnecessarily

---

# Preferred Architecture

Always use:

```plaintext
lib/
│
├── core/
│   ├── constants/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   ├── errors/
│   └── extensions/
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── settings/
│   ├── profile/
│   └── home/
│
├── shared/
│   ├── widgets/
│   ├── dialogs/
│   ├── layouts/
│   └── components/
│
├── routes/
│
├── app.dart
└── main.dart
```

---

# State Management Rules

Preferred:
- flutter_riverpod

Alternative:
- Provider

Avoid:
- massive setState usage
- global mutable variables
- tightly coupled logic

---

# Routing Rules

Always use:
- go_router

Structure:
```plaintext
routes/
└── app_router.dart
```

Avoid:
- inline navigation everywhere
- unmanaged route logic

---

# UI Rules

Always:
- build reusable widgets
- separate sections into widgets
- use responsive design
- support dark mode
- optimize spacing consistency

Preferred:
- Material 3

Use:
- flutter_screenutil for scaling

---

# Widget Rules

Maximum:
- 300 lines per widget file

Break large pages into:
- sections
- cards
- forms
- dialogs
- reusable components

---

# Naming Conventions

Widgets:
```plaintext
login_screen.dart
app_button.dart
dashboard_card.dart
```

Providers:
```plaintext
auth_provider.dart
theme_provider.dart
```

Services:
```plaintext
api_service.dart
storage_service.dart
```

Models:
```plaintext
user_model.dart
product_model.dart
```

---

# Recommended Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod:
  go_router:
  dio:
  intl:
  shared_preferences:
  flutter_screenutil:
  cached_network_image:
```

---

# API Rules

Preferred:
- dio

Always:
- separate API services
- handle exceptions properly
- create typed responses
- use repositories

Never:
- call APIs directly inside widgets

---

# Firebase Rules

Preferred packages:
- firebase_core
- firebase_auth
- cloud_firestore
- firebase_storage

Always:
- initialize Firebase properly
- separate Firebase services
- handle auth states cleanly

---

# Local Storage Rules

Preferred:
- shared_preferences
- sqflite
- hive

Use:
- shared_preferences for small settings
- sqflite/hive for structured data

---

# Theme Rules

Always support:
- Light mode
- Dark mode

Structure:
```plaintext
core/theme/
├── app_theme.dart
├── light_theme.dart
└── dark_theme.dart
```

---

# Form Rules

Always:
- validate forms
- separate controllers
- use reusable form fields
- handle loading states properly

---

# Performance Rules

Always:
- const constructors where possible
- lazy load lists
- optimize rebuilds
- separate providers efficiently

Avoid:
- unnecessary rebuilds
- giant widget trees
- excessive nesting

---

# AI Generation Rules

When generating code:
- create modular files
- avoid placeholder logic
- generate production-ready code
- keep architecture scalable
- avoid monolithic screens

Always:
- explain folder placement
- generate reusable widgets first
- separate services/providers/models

---

# Recommended Development Workflow

1. Setup project structure
2. Setup theme
3. Setup routing
4. Setup providers
5. Build reusable widgets
6. Build screens
7. Connect services
8. Add local storage/API
9. Optimize UI
10. Refactor components

---

# Responsive Design Rules

Support:
- phones
- tablets
- landscape mode

Avoid:
- fixed width layouts
- overflow issues
- non-scalable widgets

---

# Error Handling Rules

Always:
- handle exceptions gracefully
- show user-friendly messages
- create reusable error widgets

---

# Clean Code Rules

Always:
- use constants
- create helper methods
- separate concerns
- use enums where needed

Never:
- duplicate logic
- hardcode colors everywhere
- hardcode spacing repeatedly

---

# Testing Rules

Preferred:
- widget tests
- provider tests
- service tests

---

# Production Rules

Always:
- optimize assets
- compress images
- remove debug prints
- separate environment configs

---

# Final Principles

Focus on:
- scalability
- maintainability
- readability
- responsiveness
- reusable architecture
- production readiness

The generated Flutter app should always:
- look modern
- stay modular
- be easy to maintain
- support future scaling
- follow clean architecture principles