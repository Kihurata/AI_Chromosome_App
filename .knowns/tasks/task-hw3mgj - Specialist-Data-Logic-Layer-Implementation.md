---
id: hw3mgj
title: 'Specialist Data & Logic Layer Implementation'
status: todo
priority: high
labels:
  - domain
  - data
  - logic
  - specialist
  - event-driven
createdAt: '2026-04-27T07:52:20.362Z'
updatedAt: '2026-04-27T07:52:29.073Z'
timeSpent: 0
---
# Specialist Data & Logic Layer Implementation

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement the Domain, Data, and Logic layers for the Lab Specialist role using an Event-Driven architecture for AI integration. The Flutter app will act as a reactive client—uploading images and listening for results—while offloading the heavy Ngrok/FastAPI calls entirely to the Backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Core Entities: Update/Create `MetaphaseImage` and `Chromosome` entities/models.
- [ ] #2 Data (Storage): Implement `ImageStorageRepository` to handle uploading raw images to Firebase Cloud Storage.
- [ ] #3 Data (Firestore): Implement `LabProcessingRepository` (to update sample processing status).
- [ ] #4 Data (Firestore): Implement `WorkspaceRepository` (to stream the `chromosomes` sub-collection for real-time Riverpod updates).
- [ ] #5 Domain (Usecases): Implement `UploadImageForAiAnalysis` (uploads to Storage and creates a Firestore record with `status: 'UPLOADED'`).
- [ ] #6 Domain (Usecases): Implement `UpdateSampleLabStatus`, `UpdateChromosomePosition`, and `SubmitResultForApproval`.
- [ ] #7 Logic (Cubit): Implement `AiAnalysisCubit` to handle the asynchronous UI state (Uploading -> Waiting for Backend -> Success/Failure).
- [ ] #8 Logic (Cubit): Implement `WorkspaceCubit` to handle hybrid state management (offline drag-and-drop before Firestore sync).
<!-- AC:END -->

