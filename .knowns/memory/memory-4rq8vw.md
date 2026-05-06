---
id: 4rq8vw
title: Cross-platform file picking (Web support)
layer: project
category: convention
tags:
  - flutter-web
  - file-picker
  - cross-platform
createdAt: '2026-05-06T14:54:30.890Z'
updatedAt: '2026-05-06T14:54:30.890Z'
---

Root cause: `dart:io` `File` is not supported on Web. Using `FilePicker.platform.pickFiles` with `withData: true` and accessing `PlatformFile.bytes` (Uint8List) is the recommended way for cross-platform file handling in this project. Fix: Change `List<File>` to `List<PlatformFile>` in dialog states.
