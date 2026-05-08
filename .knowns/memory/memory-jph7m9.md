---
id: jph7m9
title: Fix horizontal overflow in side-by-side workspace steps
layer: project
category: pattern
tags:
  - debug
  - flutter
  - layout
  - overflow
createdAt: '2026-05-08T06:50:01.772Z'
updatedAt: '2026-05-08T06:50:01.772Z'
---

Root cause: Text widgets in Rows (like ISCN labels) or fixed-width grids (KaryotypeGrid) inside Expanded columns causing RenderFlex overflow on small screens. Fix: Wrap long Text in Expanded + ellipsis, use Wrap instead of Row for buttons/images, and add horizontal scroll to wide components like KaryotypeGrid.
