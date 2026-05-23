---
name: flutter-master-architect
description: >
  MUST be used for ALL Flutter development including apps, POS systems,
  admin dashboards, Firebase apps, API apps, offline apps, and UI generation.
  This skill enforces clean architecture, intelligent UI composition,
  Riverpod state modeling, scalable feature design, and production-ready
  Flutter engineering standards for AI-assisted development tools like
  OpenCode, Cursor AI, and VS Code agents.
license: MIT
compatibility:
  - opencode
---

# Flutter Master Architect

## 1. Core Intelligence Layer

The AI must classify every request before generating code.

### App Type Detection

Always detect the application type:

- POS system
- Booking system
- Admin dashboard
- Consumer mobile app
- Offline-first app
- Printer/IoT app
- API-based app
- Firebase app
- Hybrid app

### Complexity Levels

#### MVP
- Simple UI
- Basic Riverpod state
- Minimal architecture

#### Standard
- API integration
- Authentication
- Navigation/routing
- Repository pattern

#### Advanced
- Offline support
- Synchronization
- Caching
- Strict clean architecture

#### Enterprise
- Modular feature isolation
- Service abstraction
- Dependency injection ready
- Highly scalable structure

---

## 2. Architecture Decision Engine

Architecture must scale based on application complexity.

### MVP Apps

- Simple Riverpod providers
- Minimal repository layer
- Lightweight structure

### Standard Apps

- Feature-based architecture
- Riverpod + repositories
- Shared services

### Advanced Apps

- Strict clean architecture
- Separate:
  - data
  - domain
  - presentation

### Enterprise Apps

- Fully modular features
- Service layer abstraction
- Dependency injection ready
- Large-scale maintainability

---

## 3. Unified Project Structure

```txt
lib/
│
├── core/
│   ├── config/
│   ├── constants/
│   ├── theme/
│   ├── network/
│   ├── errors/
│   ├── utils/
│   └── services/
│
├── features/
│   ├── feature_name/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   │
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── controllers/
│
├── shared/
│   ├── widgets/
│   ├── components/
│   ├── dialogs/
│   └── layouts/
│
├── routes/
├── app.dart
└── main.dart
```

---

## 4. UI Intelligence System

### Screen Composition Rules

Every screen must contain:

1. Screen
2. AppBar section
3. Header section
4. Content section
5. Action section
6. State section
   - loading
   - error
   - empty

### UI Construction Rules

- No business logic inside UI
- Every major section becomes a widget
- Reusable UI must become shared components
- Design mobile-first, then scale to tablet and desktop

---

## 5. Design System

Always use design tokens.

### Spacing Tokens

| Token | Value |
|---|---|
| xs | 4 |
| sm | 8 |
| md | 16 |
| lg | 24 |
| xl | 32 |

### Radius Tokens

| Token | Value |
|---|---|
| small | 8 |
| medium | 16 |
| large | 24 |

### Typography Tokens

- display
- headline
- title
- body
- caption

### Rules

- Never hardcode spacing
- Never hardcode colors
- Always use theme tokens

---

## 6. State Management (Riverpod)

### Structure

```txt
providers/
controllers/
states/
```

### Rules

- UI must never communicate with services directly
- Providers are the only bridge
- Controllers contain business logic
- Services handle external systems
- Keep providers feature-scoped

---

## 7. API Architecture

Always enforce:

- `dio` for networking
- Repository pattern
- DTO models separated from UI/domain models
- Centralized error wrapper system
- Typed API responses

---

## 8. Feature Generation Order

Always generate features in this order:

1. Model
2. Datasource
3. Repository
4. Provider / Controller
5. UI Screens
6. UI Widgets

Never reverse this order.

---

## 9. Form System

Every form must include:

- Validation layer
- Controller separation
- Reusable input widgets
- Loading state handling
- Error state handling
- Form submission abstraction

---

## 10. AI Generation Behavior

### Always

- Split files logically
- Avoid monolithic screens
- Reuse widgets whenever possible
- Explain folder placement
- Enforce Riverpod architecture
- Generate production-ready structure
- Keep code scalable and maintainable

### Never

- Mix UI and API logic
- Create single-file apps except demos
- Duplicate widgets
- Hardcode values
- Place networking inside widgets

---

## 11. Responsive Rules

Always support:

- Mobile
- Tablet
- Desktop/Web

### Use

- `MediaQuery`
- `LayoutBuilder`
- Flexible and adaptive widgets

### Never

- Use fixed widths
- Use pixel-only layouts
- Assume one screen size

---

## 12. Performance Rules

Always:

- Use `const` widgets where possible
- Use lazy-loaded lists
- Minimize rebuilds
- Isolate providers per feature
- Optimize widget trees
- Avoid unnecessary state updates

---

## 13. Testing Strategy

### Required Testing Layers

- Widget tests for UI
- Provider tests for state logic
- Repository tests for data layer
- Integration tests for major flows

---

## 14. Shared Widget Strategy

Always create reusable widgets:

- `AppButton`
- `AppInput`
- `AppCard`
- `AppLoader`
- `AppErrorView`

Never duplicate UI patterns.

---

## 15. Recommended Dependency Stack

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

---

## 16. Code Generation Enforcement Rules

### File Structure Rules

- Never create massive files
- Split widgets into reusable components properly
- Keep files under 300 lines where possible
- Organize files by feature responsibility
- Separate presentation, domain, and data layers strictly

### Reusability Rules

- Always reuse existing shared widgets before creating new ones
- Extract repeated UI into reusable components
- Centralize design tokens and theme usage
- Avoid duplicated business logic

### Riverpod Rules

- Use Riverpod correctly and consistently
- Keep providers feature-scoped
- Avoid unnecessary rebuilds
- Use isolated providers for scalable state management
- UI must never access services directly

### Architecture Rules

- Follow clean architecture strictly
- Use repository pattern consistently
- Keep UI, business logic, and data access separated
- Services must handle external systems only
- Controllers manage feature logic

### AI Output Rules

- Explain generated folder structure clearly
- Generate production-ready code only
- Avoid placeholder implementations unless explicitly requested
- Prefer scalable solutions over shortcuts
- Optimize for maintainability and readability

# Final System Principles

This skill enforces:

- Scalable architecture by default
- Production-ready Flutter applications
- Reusable UI systems
- Strict separation of concerns
- Intelligent feature generation
- Predictable AI output structure
- Clean and maintainable Flutter engineering