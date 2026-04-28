---
title: Critical Patterns
description: Promoted learnings that save the most time. Read at session start via kn-init.
createdAt: '2026-04-28T05:23:00.000Z'
updatedAt: '2026-04-28T05:23:00.000Z'
tags:
  - learning
  - critical
---

# Critical Patterns

Promoted learnings from completed work. Read this at the start of every session via `kn-init`. These are lessons that cost the most to learn and save the most by knowing.

---

## [2026-04-28] Cubit Stream: `await for`, NOT `emit.forEach`
**Category**: failure → pattern
**Source**: task a3m4u4, task 2tou5t
**Tags**: [cubit, flutter-bloc, stream, firestore]

In `flutter_bloc` **Cubit**, the only correct way to subscribe to a long-lived Stream is:

```dart
await for (final result in myStream()) {
  if (isClosed) break;
  result.fold(...);
}
```

`emit.forEach()` **does not exist** on `Cubit`'s `emit` (which is just `void Function(State)`).  
It exists ONLY on `Bloc`'s `Emitter`. Using `emit.forEach` in a Cubit causes a compile error:  
`"The method 'forEach' isn't defined for the type 'Function'"`.

**Full entry**: @doc/learnings/receptionist-clean-architecture-refactor

---

## [2026-04-28] No `cloud_firestore` or Repository imports in Presentation layer
**Category**: convention
**Source**: task 2tou5t
**Tags**: [clean-architecture, receptionist, presentation]

Any import of `package:cloud_firestore/cloud_firestore.dart` or `*_repository.dart` inside `lib/presentation/` violates Clean Architecture. All Firestore access must go through:

**DataSource → Repository → Usecase → Cubit → BlocBuilder in UI**

Legacy screens had `ClinicalRepository` injected as constructor params across 7 files — full refactor required. Enforce at PR review: reject any presentation file importing data-layer or Firestore packages directly.

**Full entry**: @doc/learnings/receptionist-clean-architecture-refactor
