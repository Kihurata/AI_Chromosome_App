---
id: 0gk1dw
title: Layout Overflow in GridView StatsCard
layer: project
category: failure
tags:
  - debug
  - flutter
  - layout
createdAt: '2026-05-05T03:55:40.074Z'
updatedAt: '2026-05-05T03:55:40.074Z'
---

Root cause: Layout overflow in GridView children due to fixed childAspectRatio and large internal padding. 
Fix: Use flexible layout inside children (FittedBox, Flexible) and adjust childAspectRatio based on screen width (MediaQuery). Avoid large fixed padding (e.g. 24) in small cards.
