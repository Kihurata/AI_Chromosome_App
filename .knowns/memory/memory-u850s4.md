---
id: u850s4
title: RangeError from unsafe substring on IDs
layer: project
category: failure
tags:
  - debug
  - flutter
  - ui
createdAt: '2026-05-07T15:11:16.587Z'
updatedAt: '2026-05-07T15:11:16.587Z'
---

Root cause: RangeError (end) in UI due to unsafe substring calls on IDs. Fix: Always check length before calling substring(0, N) on IDs or codes. Found in TestResultsTab, ExaminationForm, and Manager tables.
