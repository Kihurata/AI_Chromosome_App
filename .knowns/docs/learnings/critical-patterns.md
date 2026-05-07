---
title: Critical Patterns
description: Promoted learnings that save the most time. Read at session start via kn-init.
createdAt: '2026-04-28T05:23:00.000Z'
updatedAt: '2026-05-07T07:55:52.807Z'
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


## [2026-05-02] AI Integration & Flutter Refactor Learnings
**Category:** failure / decision
**Source:** @task-ugibx7, @task-mtaugq
**Tags:** [flutter, debugging, imports]

*   **Import Depth Awareness:** Incorrect relative import depth in nested directories causes major lint errors. Always verify depth and consider using `flutter analyze` immediately after edits.
*   **DI Registration:** Forgetting `@lazySingleton` or `@injectable` on new logic components results in `InvalidType` in generated DI code.
*   **Header Replacement Safety:** When editing imports, ensure `package:flutter/material.dart` is preserved to avoid "Undefined name 'Text'" etc.

**Full entry:** @doc/learnings/learning-ai-frontend-integration-debugging


## [2026-05-02] Prevent Silent Loading Hangs in Reactive Streams
**Category:** failure
**Source:** @task-ugibx7
**Tags:** [flutter, firestore, reactive-ui]

UI loading states can hang indefinitely if a Firestore stream fails (e.g., missing index) and the Repository doesn't explicitly catch and emit the error. Always wrap `yield*` in `try-catch` within `async*` repository methods to ensure errors reach the Cubit/State layer.

**Full entry:** @doc/learnings/learning-specialist-dashboard-and-firestore-indexing


## [2026-05-06] Cubit Safety: `isClosed` check before `emit`
**Category:** failure → pattern
**Source:** @task-dva5dv
**Tags:** [cubit, lifecycle, async, flutter]

In Cubit methods containing `await`, always verify the Cubit is still active before emitting:

```dart
Future<void> loadData() async {
  final data = await repository.getData();
  if (isClosed) return; // Critical check
  emit(DataLoaded(data));
}
```
Failing to do this results in `Bad state: Cannot emit new states after calling close` crashes if the user navigates away before the async task finishes.

**Full entry:** @doc/learnings/learning-specialist-dashboard-and-firestore-indexing

---

## [2026-05-06] UI: Defensive Overflow Protection
**Category:** failure → pattern
**Source:** @task-dva5dv
**Tags:** [ui, flutter, layout, overflow]

Dashboard cards or list items that might be squashed on small screens or resized windows should be wrapped in a `SingleChildScrollView` (or use flexible widgets) to prevent `RenderFlex` overflow crashes.

**Full entry:** @doc/learnings/learning-specialist-dashboard-and-firestore-indexing


## [2026-05-06] UI: Robust Dashboard Card Layout
**Category:** pattern / failure
**Source:** @task-jjckim
**Tags:** [ui, flutter, layout, overflow]

Standard `Column` with `MainAxisAlignment.spaceBetween` inside a GridView will crash with `RenderFlex overflow` if squashed. The correct robust pattern is:
Wrap in `LayoutBuilder` -> `SingleChildScrollView` -> `ConstrainedBox(minHeight: constraints.maxHeight)` -> `IntrinsicHeight`. This preserves the space-between look when possible but allows scrolling when needed.

**Full entry:** @doc/learnings/learning-notification-and-dashboard-integration


## [2026-05-07] AI Server Integration & Security
**Category:** pattern / failure
**Source:** @task-3pasee
**Tags:** [ai-server, ngrok, security]

**Summary:** 
1. Luôn thêm header `ngrok-skip-browser-warning: true` khi gọi API qua Ngrok để tránh trang Splash. 
2. Đồng bộ hóa API Key giữa Backend và AI Server (Colab) để tránh lỗi 403 Forbidden. 
3. Cấu hình URL linh hoạt qua Firestore thay vì hardcode để thích ứng với URL động của Ngrok.

**Full entry:** @doc/learnings/ai-server-implementation-decisions
