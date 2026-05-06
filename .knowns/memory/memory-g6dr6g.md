---
id: g6dr6g
title: LocaleDataException from intl package
layer: project
category: failure
tags:
  - debug
  - flutter
  - intl
  - localization
createdAt: '2026-04-30T05:42:23.852Z'
updatedAt: '2026-04-30T05:42:23.852Z'
---

Root cause: Flutter's `intl` package throws `LocaleDataException` if locale data isn't initialized before using `DateFormat` with a specific locale (like `vi`). Fix: Add `import 'package:intl/date_symbol_data_local.dart';` and call `await initializeDateFormatting('vi', null);` inside `main()` before `runApp()`.
