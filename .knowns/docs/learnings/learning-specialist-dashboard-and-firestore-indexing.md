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
