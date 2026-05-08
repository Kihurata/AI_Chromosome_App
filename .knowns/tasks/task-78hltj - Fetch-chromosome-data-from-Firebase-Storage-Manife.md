---
id: 78hltj
title: Fetch chromosome data from Firebase Storage / Manifest
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-07T16:02:45.366Z'
updatedAt: '2026-05-07T16:11:54.201Z'
timeSpent: 0
spec: specs/workspace-step-3-karyogram-data-fetch
fulfills:
  - AC-2
  - AC-3
---
# Fetch chromosome data from Firebase Storage / Manifest

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Fetch chromosome data by primarily attempting to download `manifest.json`. If unavailable, fallback to listing files in Firebase Storage directory `test_orders/{orderId}/ai_predict/{selectedImageId}/`, ignoring `*_detection.jpg`. Read chromosome label from Custom Metadata (`current_label`) and map to local `Chromosome` entities. Show loading state in KaryogramStep.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Add Firebase Storage dependency/repository.
- [ ] #2 Implement JSON Manifest fetching method.
- [ ] #3 Implement fallback Storage directory listing method and Metadata parsing.
- [ ] #4 Call fetch method when navigating to Step 3 and show loading state.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create `FirebaseStorageRepository` (if not exists) or add method to `WorkspaceRepository` to fetch chromosomes. Let's add it to `WorkspaceRepository` for simplicity, or maybe a dedicated class. Let's check `WorkspaceRepository`.
2. Add a `fetchChromosomesFromStorage(String orderId, String selectedImageId)` method. It should try to fetch `manifest.json`. If it fails, fallback to `Reference.listAll()` ignoring `_detection.jpg` and parsing CustomMetadata `current_label`.
3. Create `KaryogramCubit` or update `WorkspaceCubit` to handle loading chromosomes for Step 3. Let's see how Step 3 was currently planned to fetch data.
4. Update `KaryogramStep` to call this fetch method when it builds or is visible.
<!-- SECTION:PLAN:END -->

