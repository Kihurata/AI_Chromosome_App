---
id: c0bfwv
title: Safe Context Usage Pattern
layer: project
category: pattern
tags:
  - flutter
  - lifecycle
  - context
createdAt: '2026-05-07T20:45:50.157Z'
updatedAt: '2026-05-07T20:45:50.157Z'
---

Always check 'if (!context.mounted) return;' before UI actions in listeners. Never use 'FocusScope.of(context)' in 'dispose()' as it causes 'deactivated widget' errors. Full reference: @doc/learnings/learning-specialist-dashboard-and-firestore-indexing
