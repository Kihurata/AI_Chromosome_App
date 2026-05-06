---
id: 9rwz90
title: Zero-size render box (Expanded in ScrollView)
layer: project
category: failure
tags:
  - flutter
  - layout
  - expanded
  - debug
createdAt: '2026-05-06T15:18:00.843Z'
updatedAt: '2026-05-06T15:18:00.843Z'
---

Root cause: Used `Expanded` inside a `Column` which was nested inside a `SingleChildScrollView`. In Flutter, `SingleChildScrollView` provides unbounded height constraints, making `Expanded` fail to calculate its size (often resulting in zero size). This triggered repeated `Cannot hit test a render box with no size` errors in the specialist dashboard. Fix: Remove `Expanded` and use `MainAxisAlignment` or fixed sizes when inside unbounded parents.
