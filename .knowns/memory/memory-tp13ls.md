---
id: tp13ls
title: 'Layout crash: Expanded inside SingleChildScrollView (via MainListLayout)'
layer: project
category: failure
tags:
  - debug
  - flutter
  - layout
createdAt: '2026-05-07T06:40:16.248Z'
updatedAt: '2026-05-07T06:40:16.248Z'
---

Root cause: Using `Expanded` inside a `Column` that is wrapped in a `SingleChildScrollView` (often via `MainListLayout` when `onRefresh` is provided) causes 'Render box with no size' or 'Assertion failed' layout crashes. 

Fix: Remove `Expanded` and use `shrinkWrap: true` with `NeverScrollableScrollPhysics()` on internal lists to allow them to size naturally within the top-level scroll view. Avoid nested `SingleChildScrollViews` by removing redundant ones in page bodies.
