---
id: thsh6h
title: 'Flutter Web + Firebase: phải init trước runApp()'
layer: project
category: failure
tags:
  - debug
  - firebase
  - flutter-web
createdAt: '2026-04-30T04:45:06.246Z'
updatedAt: '2026-04-30T04:45:06.246Z'
---

Root cause: `main()` không có `async/await` và thiếu `Firebase.initializeApp()` trước `runApp()`, khiến Firebase chưa load JS SDK xong.

Fix: Chuyển `main()` thành `async`, thêm:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`

Signal: `TypeError: Instance of 'FirebaseException': type 'FirebaseException' is not a subtype of type 'JavaScriptObject'`
