---
id: hw3mgj
title: 'Specialist Data & Logic Layer Implementation'
status: done
priority: high
labels:
  - domain
  - data
  - logic
  - specialist
  - event-driven
createdAt: '2026-04-27T07:52:20.362Z'
updatedAt: '2026-04-29T09:37:59.696Z'
timeSpent: 448
assignee: '@me'
---
# Specialist Data & Logic Layer Implementation

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement the Domain, Data, and Logic layers for the Lab Specialist role using an Event-Driven architecture for AI integration. The Flutter app will act as a reactive client—uploading images and listening for results—while offloading the heavy Ngrok/FastAPI calls entirely to the Backend.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Core Entities: Update/Create `MetaphaseImage` and `Chromosome` entities/models.
- [x] #2 Data (Storage): Implement `ImageStorageRepository` to handle uploading raw images to Firebase Cloud Storage.
- [x] #3 Data (Firestore): Implement `LabProcessingRepository` (to update sample processing status).
- [x] #4 Data (Firestore): Implement `WorkspaceRepository` (to stream the `chromosomes` sub-collection for real-time Riverpod updates).
- [x] #5 Domain (Usecases): Implement `UploadImageForAiAnalysis` (uploads to Storage and creates a Firestore record with `status: 'UPLOADED'`).
- [x] #6 Domain (Usecases): Implement `UpdateSampleLabStatus`, `UpdateChromosomePosition`, and `SubmitResultForApproval`.
- [x] #7 Logic (Cubit): Implement `AiAnalysisCubit` to handle the asynchronous UI state (Uploading -> Waiting for Backend -> Success/Failure).
- [x] #8 Logic (Cubit): Implement `WorkspaceCubit` to handle hybrid state management (offline drag-and-drop before Firestore sync).
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create `Chromosome` and `MetaphaseImage` entities in `lib/domain/entities/`.
2. Refactor `ChromosomeModel` and create `MetaphaseImageModel` in `lib/data/models/` implementing the `fromEntity` convention (see @memory/e83enb).
3. Create Domain Repository Interfaces in `lib/domain/repositories/`: `ImageStorageRepository`, `LabProcessingRepository`, and `WorkspaceRepository`.
4. Create Data Repository Implementations in `lib/data/repositories/`: `ImageStorageRepositoryImpl`, `LabProcessingRepositoryImpl`, and `WorkspaceRepositoryImpl` with Firestore and Storage integration.
5. Create Domain Usecases in `lib/domain/usecases/specialist/`: `UploadImageForAiAnalysis`, `UpdateSampleLabStatus`, `UpdateChromosomePosition`, and `SubmitResultForApproval`.
6. Implement `AiAnalysisCubit` in `lib/logic/bloc/specialist/` to manage the async states of image upload and AI waiting.
7. Refactor `WorkspaceCubit` in `lib/logic/bloc/workspace/` to use the new `Chromosome` entity and integrate with `UpdateChromosomePosition` usecase.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Created Chromosome and MetaphaseImage entities. Refactored ChromosomeModel and created MetaphaseImageModel with fromEntity convention.
Done: Created Domain Repository Interfaces and Data Repository Implementations for ImageStorage, LabProcessing, and Workspace.
Done: Created Domain Usecases: UploadImageForAiAnalysis, UpdateSampleLabStatus, UpdateChromosomePosition, and SubmitResultForApproval.
Done: Implemented AiAnalysisCubit to manage async AI processing states and refactored WorkspaceCubit for hybrid state management using the new entities and usecases.
Done: Passed dart analyze. All requirements for Domain, Data, and Logic layers implemented.
<!-- SECTION:NOTES:END -->

