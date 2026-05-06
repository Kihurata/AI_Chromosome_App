---
id: yylmqf
title: Non-exhaustive switch after enum update (TestOrderStatus)
layer: project
category: failure
tags:
  - debug
  - flutter
  - enums
createdAt: '2026-05-06T14:54:25.737Z'
updatedAt: '2026-05-06T14:54:25.737Z'
---

Root cause: Added `TestOrderStatus.culturing` enum member but missed updating several switch statements, causing `non_exhaustive_switch_statement` errors. Fix: Update all UI switch statements that map `TestOrderStatus` to labels or styles. Check: `test_results_tab.dart`, `recent_patients_table.dart`, `lab_examination_table.dart`.
