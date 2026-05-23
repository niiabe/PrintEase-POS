---
name: flutter-feature-builder
description: >
  MUST be used for generating scalable Flutter features, modules,
  screens, services, repositories, Riverpod providers, reusable widgets,
  and production-ready UI systems inside existing Flutter applications.
  This skill specializes in feature-by-feature implementation using
  clean architecture and modular Flutter engineering standards.
license: MIT
compatibility:
  - opencode
---

# Flutter Feature Builder

## Purpose

This skill is responsible for generating production-ready Flutter features
inside an existing Flutter application.

It focuses on:

- Feature isolation
- Clean architecture
- Reusable widgets
- Riverpod state management
- Scalable folder structures
- UI composition
- Local/offline-first systems
- POS and business application workflows

---

# 1. Feature Generation Protocol

Always generate features in this exact order:

1. Models
2. Entities
3. Datasources
4. Repositories
5. Providers
6. Controllers
7. Screens
8. Widgets
9. Dialogs
10. Utilities

Never skip architecture layers.

---

# 2. Required Architecture Style

Always use:

```txt
Feature-Based Clean Architecture
```

Structure:

```txt
features/
└── feature_name/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    │
    ├── domain/
    │   ├── entities/
    │   └── usecases/
    │
    ├── presentation/
    │   ├── controllers/
    │   ├── screens/
    │   └── widgets/
```

---

# 3. Riverpod Enforcement Rules

Always:

- Use Riverpod for state management
- Keep providers feature-scoped
- Separate providers from UI
- Use AsyncValue correctly
- Avoid rebuild storms
- Isolate feature state

Never:

- Put business logic inside widgets
- Access repositories directly from UI
- Create global mutable state

---

# 4. UI Composition Rules

Every screen must contain:

- AppBar section
- Header section
- Content section
- Action section
- State section

State section includes:

- loading
- error
- empty
- success

---

# 5. Widget Strategy

Always:

- Extract reusable widgets
- Create shared components
- Keep widgets small and composable
- Reuse design patterns consistently

Required shared widgets:

- AppButton
- AppInput
- AppCard
- AppLoader
- AppErrorView
- AppEmptyView

---

# 6. File Size Rules

Strictly enforce:

- Keep files under 300 lines where possible
- Avoid monolithic widgets
- Split large screens into sections
- Separate dialogs and forms into their own widgets

---

# 7. Form Architecture Rules

Every form must include:

- Validation
- Error handling
- Loading state
- Separate controllers
- Reusable form fields

Never mix validation logic with UI rendering.

---

# 8. Database & Storage Rules

Preferred local storage stack:

```yaml
sqflite:
shared_preferences:
path_provider:
```

Rules:

- Abstract database access behind repositories
- Never access SQLite directly from UI
- Use services for storage operations
- Keep models serializable

---

# 9. Printer & POS Rules

For thermal/POS systems:

Always support:

- ESC/POS printers
- 58mm paper
- 80mm paper
- Bluetooth printing
- Offline printing

Preferred packages:

```yaml
print_bluetooth_thermal:
esc_pos_utils_plus:
```

---

# 10. PDF System Rules

Use:

```yaml
pdf:
printing:
```

Generate:

- PDF service
- PDF export helpers
- Share/export utilities
- Reprint support

---

# 11. Responsive Design Rules

Always support:

- Mobile
- Tablet
- Desktop/Web

Use:

- LayoutBuilder
- MediaQuery
- Flexible widgets

Never use fixed-width layouts.

---

# 12. Performance Optimization Rules

Always:

- Use const constructors
- Lazy-load long lists
- Minimize rebuilds
- Memoize expensive UI when needed
- Scope providers properly

Avoid:

- Large widget trees in one file
- Unnecessary provider watching
- Duplicate state objects

---

# 13. AI Code Generation Rules

Always:

- Generate production-ready code
- Explain folder placement
- Explain architecture decisions
- Prefer scalability over shortcuts
- Reuse components first

Never:

- Create giant files
- Duplicate widgets
- Hardcode colors or spacing
- Mix UI and business logic
- Generate placeholder TODO implementations unless requested

---

# 14. Recommended Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod:
  go_router:
  dio:
  sqflite:
  path_provider:
  pdf:
  printing:
  intl:
  cached_network_image:
  flutter_screenutil:
```

---

# 15. Output Expectations

Generated output must be:

- Modular
- Reusable
- Production-ready
- Maintainable
- Responsive
- Offline-capable
- Cleanly structured
- Easy to extend

---

# Final Principle

This skill exists to ensure every generated Flutter feature:

- scales correctly
- follows clean architecture
- uses Riverpod properly
- avoids technical debt
- remains maintainable long-term
- supports real production applications