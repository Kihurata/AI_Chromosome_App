---
id: ea2t6u
title: 'Flutter BLoC: All Cubits must be registered in MultiBlocProvider in main.dart'
layer: project
category: failure
tags:
  - debug
  - flutter-bloc
  - di
  - cubit
createdAt: '2026-04-30T05:32:30.594Z'
updatedAt: '2026-04-30T05:32:30.594Z'
---

Root cause: Any `BlocBuilder<XCubit, XState>` in the widget tree will crash with `ProviderNotFoundException` if `XCubit` is not listed in the global `MultiBlocProvider` in `main.dart`. Fix: Add a `BlocProvider<XCubit>(create: (_) => ...)` entry for every Cubit used anywhere in the app. Since many datasources use `FirebaseFirestore.instance` directly (not through GetIt), construct them manually inside the `create` callback without going through injectable/GetIt.
