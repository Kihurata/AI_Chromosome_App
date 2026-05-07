---
id: d7b53s
title: AI Analysis Result Field Mapping Convention
layer: project
category: convention
tags:
  - flutter
  - ai-integration
  - build-runner
createdAt: '2026-05-07T07:06:51.844Z'
updatedAt: '2026-05-07T07:06:51.844Z'
---

When implementing AI analysis results in the frontend:
1. Ensure `MetaphaseImage` entity has `aiCount` and `aiScore`.
2. Ensure `MetaphaseImageModel` maps `ai_count` and `ai_score` from/to Firestore.
3. Use `image.aiScore ?? 0` and `image.aiCount ?? 0` in UI widgets.
4. Always run `build_runner` after changing injected constructors or serializable fields.
