---
title: 'Learning: Specialist Dashboard and Firestore Indexing'
description: Learnings from fixing the Specialist Dashboard loading issues, DI conflicts, and Firestore index management.
createdAt: '2026-05-02T08:55:09.295Z'
updatedAt: '2026-05-02T08:55:09.295Z'
tags:
  - learning
  - specialist
  - dashboard
  - firestore
  - flutter
  - debugging
---

## Patterns

### Reactive Streams with Error Handling
- **What:** Implementing `async*` methods in Repositories that use `yield*` to wrap Firestore streams, wrapped in `try-catch` blocks to convert Firebase errors into functional `Failure` objects.
- **When to use:** Whenever exposing a real-time data stream (Watch) to a Cubit/State Management layer.
- **Source:** @task-ugibx7

### Dev Seeding via Standalone Script
- **What:** Using the Firebase Admin SDK in a Python script (`seed_mock_orders.py`) to inject test data directly into Firestore.
- **When to use:** During development when the UI for data creation isn't ready or when "bloating" the production UI with dev-only buttons is undesirable.
- **Source:** @task-ugibx7

## Decisions

### Managed Composite Indexes
- **Chose:** Defining composite indexes in `firestore.indexes.json` and deploying via CLI.
- **Over:** Manual creation in Firebase Console.
- **Tag:** GOOD_CALL
- **Outcome:** Ensures environment consistency and allows the AI agent to fix "failed-precondition" errors autonomously.
- **Recommendation:** Always maintain the `.json` file for indexes.

### Merging Duplicated Cubits
- **Chose:** Consolidating `SpecialistDashboardCubit` from two different folders into a single canonical location.
- **Over:** Keeping separate versions for "specialist" and "specialist_dashboard".
- **Tag:** GOOD_CALL
- **Outcome:** Resolved GetIt registration errors and improved code maintainability.

## Failures

### Duplicated Registration Path
- **What went wrong:** Having the same Cubit class in two folders led to inconsistent imports. One was registered with `@injectable`, but the UI was importing the non-registered one.
- **Root cause:** Fragmentation during feature development and lack of a single "source of truth" folder.
- **Time lost:** 30 minutes.
- **Prevention:** Use consistent folder structures and periodically run `build_runner` to catch DI gaps.

### Silent Loading Hang
- **What went wrong:** The UI stayed in a loading state indefinitely when a Firestore query failed.
- **Root cause:** The Repository stream didn't catch errors, so the Cubit's `emit.forEach` never received a failure signal to transition out of the loading state.
- **Time lost:** 45 minutes.
- **Prevention:** Always wrap stream-based data fetching in try-catch and emit a failure state.

## [2026-05-06] Navigation & Lifecycle Stability
**Source:** @task-dva5dv
**Tags:** [navigation, lifecycle, cubit, routing]

### Patterns
- **Isolated Detail Routing:** Decouple detail screens from nested list routes. Move them to independent paths (e.g., `/specialist/sample-detail/:id`) to prevent parent list disposal during navigation.
- **Safe Async Emitting:** Always add `if (isClosed) return;` before `emit()` in Cubit methods that use `await`. This prevents crashes when async tasks finish after the user has navigated away.
- **Defensive Layout:** Use `SingleChildScrollView` inside cards or dashboard items to prevent `RenderFlex` overflow crashes when layout constraints are tight (e.g., small screens or resized browser windows).

### Decisions
- **Factory over Singleton for Page Cubits:** Chose `@injectable` (Factory) over `@lazySingleton` for Cubits tied to specific screens. This ensures a clean state on every navigation and avoids "closed cubit" errors when returning to a page. (**GOOD_CALL**)
- **pushNamed for Detail Overlay:** Chose `context.pushNamed` over `context.go` for detail views. This keeps the parent stack alive and allows a simpler back-navigation experience without re-fetching the entire list state. (**TRADEOFF**)

### Failures
- **Unverified DI Generation:** Changed annotations but didn't verify if `build_runner` updated `injection.config.dart`. Resulted in the app still using stale singleton behavior. (**BAD_CALL**)
- **Redundant Navigation Wrappers:** Refactored a widget's navigation but forgot that its parent (`ListView` item) also had an `InkWell` wrapper with a hardcoded route. Always search for route strings throughout the project when refactoring paths.
