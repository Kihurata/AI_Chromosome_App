---
id: 7p7ef5
title: 'Riverpod: Không được gọi ref.read().notifier.xxx() trực tiếp trong initState'
layer: project
category: failure
tags:
  - debug
  - riverpod
  - flutter
  - lifecycle
createdAt: '2026-05-14T11:25:57.072Z'
updatedAt: '2026-05-14T11:25:57.072Z'
---

Root cause: Gọi `ref.read(provider.notifier).method()` trực tiếp trong `initState()` của `ConsumerStatefulWidget` gây lỗi "Tried to modify a provider while the widget tree was building". Riverpod không cho phép mutation trong bất kỳ widget lifecycle nào (initState, build, dispose, didChangeDependencies).

Fix: Luôn bọc tất cả Riverpod provider mutations trong `WidgetsBinding.instance.addPostFrameCallback((_) { ... })` để đảm bảo chúng chạy sau khi widget tree hoàn tất build.

Ví dụ sai:
```dart
void initState() {
  super.initState();
  ref.read(drawerProvider.notifier).clear(); // LỖI
}
```

Ví dụ đúng:
```dart
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    ref.read(drawerProvider.notifier).clear(); // ĐÚNG
  });
}
```
