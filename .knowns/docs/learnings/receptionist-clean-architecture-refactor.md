---
title: "Learning: Receptionist Module Clean Architecture Refactor"
description: Decisions and failures from migrating Receptionist UI from ClinicalRepository to Clean Architecture (BLoC/Cubit).
createdAt: '2026-04-28T05:22:00.000Z'
updatedAt: '2026-04-28T05:22:00.000Z'
tags:
  - learning
  - receptionist
  - clean-architecture
  - cubit
  - flutter
---

# Learning: Receptionist Module Clean Architecture Refactor

**Source tasks**: a3m4u4 (Data/Logic layer), 2tou5t (UI refactor)
**Date**: 2026-04-28

---

## Patterns

### `await for` is the correct Cubit stream pattern
- **What**: To listen to a Firestore stream inside a Cubit, use `await for` loop with `if (isClosed) break` guard.
- **When to use**: Any Cubit that needs to subscribe to a long-lived Stream (Firestore `.snapshots()`, WebSocket, etc.)
- **Source**: task a3m4u4

### Dual state classes for multi-screen Cubit
- **What**: When one Cubit serves screens with different query contexts (today vs. date-range), use two separate state classes (`AppointmentLoaded` vs `RangeAppointmentsLoaded`) instead of adding a boolean flag.
- **When to use**: Whenever a BlocBuilder in Screen A might accidentally render from data fetched for Screen B.
- **Source**: task 2tou5t

---

## Decisions

### Use `await for` over `emit.forEach`
- **Chose**: `await for (final result in stream()) { if (isClosed) break; ... }`
- **Over**: `await emit.forEach(stream, onData: ...)` — appeared in flutter_bloc docs but does not exist on Cubit's `emit`.
- **Tag**: SURPRISE
- **Outcome**: Compile error discovered only at analyze time. Correct pattern worked cleanly.
- **Recommendation**: Always use `await for` with `isClosed` guard for Cubit streams. Never use `emit.forEach` — it is only available on Bloc `emit`, not Cubit `emit`.

### Temporary `PatientModel.fromEntity()` bridge
- **Chose**: Keep `PatientDetailScreen(patient: PatientModel.fromEntity(p))` as a bridge.
- **Over**: Refactoring `PatientDetailScreen` to accept `Patient` entity in the same task.
- **Tag**: TRADEOFF
- **Outcome**: Saved scope on the 2tou5t task. `PatientModel extends Patient` so the bridge is zero-cost at runtime.
- **Recommendation**: Schedule `PatientDetailScreen` refactor as a separate task. Track as tech debt.

### Separate `RangeAppointmentsLoaded` state
- **Chose**: New state class for calendar's range query.
- **Over**: Reusing `AppointmentLoaded` with a separate flag or overwriting the same state.
- **Tag**: GOOD_CALL
- **Outcome**: Calendar's `BlocBuilder` only reacts to `RangeAppointmentsLoaded`, dashboard reacts to `AppointmentLoaded` — zero interference between screens.
- **Recommendation**: Apply this pattern whenever one Cubit drives multiple screens with different query shapes.

---

## Failures

### `emit.forEach` assumed to exist in Cubit API
- **What went wrong**: Initial implementation used `await emit.forEach(stream, onData: ...)` which causes `The method 'forEach' isn't defined for the type 'Function'` compile error.
- **Root cause**: Confusing `Bloc`-specific `emit` methods (which do have `forEach`) with `Cubit`'s simpler `emit` function. The flutter_bloc docs describe both but they are different contexts.
- **Time lost**: ~10 minutes.
- **Prevention**: Check class hierarchy — `Cubit` emit is just a `void Function(State)`. Only `Bloc`'s `Emitter` has `forEach`, `onEach`, etc.

### ClinicalRepository spread across 7 presentation files
- **What went wrong**: Legacy code had `ClinicalRepository` injected as constructor parameters across 5 screens and 2 widgets, including direct `FirebaseFirestore.instance` calls inside UI.
- **Root cause**: Gradual feature additions without enforcing the Clean Architecture boundary — each new screen copy-pasted the repo injection pattern.
- **Time lost**: Full refactor required for all 7 files simultaneously.
- **Prevention**: Enforce Clean Architecture at PR review: any import of `cloud_firestore` or `*_repository.dart` in `presentation/` should be rejected. Use `dart analyze` custom lint rules if possible.
