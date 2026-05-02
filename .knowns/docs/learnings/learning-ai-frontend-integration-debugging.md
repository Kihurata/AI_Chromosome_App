---
title: 'Learning: AI Frontend Integration Debugging'
description: Learnings and failures from the AI Frontend Integration task.
createdAt: '2026-05-02T07:05:43.677Z'
updatedAt: '2026-05-02T07:05:43.677Z'
tags:
  - learning
  - flutter
  - ai-integration
  - debugging
---

# Learning: AI Frontend Integration Debugging

## Patterns

### Reactive Firestore Polling in Cubit
- **What:** Using `await for` with Firestore snapshots inside a Cubit to monitor backend-driven state changes.
- **When to use:** When the UI needs to react to external triggers (AI server status updates) without continuous HTTP polling.
- **Source:** @task-mtaugq

## Decisions

### Manual AI Trigger
- **Chose:** Explicit "Start AI" button.
- **Over:** Automatic background triggering.
- **Tag:** GOOD_CALL
- **Outcome:** Prevented accidental resource consumption and provided clear UX for when expensive operations start.
- **Recommendation:** Always use explicit triggers for non-instant AI processing.

### Non-blocking Thumbnail Overlays
- **Chose:** Stack-based status indicators on images.
- **Over:** Full-screen blocking loaders.
- **Tag:** GOOD_CALL
- **Outcome:** specialist can continue reviewing other images while one is being processed.

## Failures

### Relative Import Depth Error
- **What went wrong:** 115 lint errors due to `../../../` instead of `../../../../`.
- **Root cause:** Misjudgment of directory nesting when creating files in `lib/presentation/screens/workspace/steps/`.
- **Time lost:** 15 minutes.
- **Prevention:** Use `flutter analyze` immediately after creating new files. Consider using package imports for deep paths.

### Accidental Deletion of Material Imports
- **What went wrong:** `Text`, `Widget`, and `Icon` became undefined.
- **Root cause:** `replace_file_content` overwrote the import section without including `material.dart`.
- **Time lost:** 5 minutes.
- **Prevention:** Always view the existing imports before replacing the header of a file.

### Dependency Injection Omission
- **What went wrong:** `InvalidType` in `injection.config.dart`.
- **Root cause:** Forgot to annotate `UploadImageForAiAnalysis` and `TriggerAiAnalysis` with `@lazySingleton`.
- **Time lost:** 10 minutes.
- **Prevention:** Annotate every new Usecase/Repository/Cubit immediately upon creation.
