---
id: ienly7
title: 'Flutter Web / Riverpod: Unsafe ref usage in dispose'
layer: project
category: failure
tags:
  - debug
  - riverpod
  - flutter-web
createdAt: '2026-05-07T15:54:43.179Z'
updatedAt: '2026-05-07T15:54:43.179Z'
---

Root cause: Accessing 'ref' in 'dispose()' of a 'ConsumerStatefulWidget' can trigger 'Bad state: Using ref when unmounted' if the element is already inactive (common on Flutter Web during rapid navigation).

Fix: Use 'ProviderScope.containerOf(context, listen: false).read(provider)' inside 'dispose()' instead of 'ref.read()'.
