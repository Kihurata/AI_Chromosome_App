---
title: State Management and Clean Architecture Patterns
description: Implementation patterns for Hybrid State Management (Riverpod + Cubit) and Clean Architecture.
createdAt: '2026-04-26T07:07:52.727Z'
updatedAt: '2026-04-26T07:07:52.727Z'
tags:
  - pattern
  - state-management
  - riverpod
  - cubit
  - clean-architecture
---

# State Management and Clean Architecture Patterns

## Hybrid State Management
The project utilizes a hybrid approach to handle both real-time Firestore sync and complex UI interactions (like drag-and-drop).

### 1. Riverpod ("Data Pipe")
- **Role**: Data Source and Streaming Engine.
- **Why**: `StreamProvider` is highly optimized for Firestore real-time listeners. It handles raw cloud data and provides dependency injection.

### 2. Cubit / BLoC ("UI Controller")
- **Role**: Local Interaction Manager.
- **Why**: Manages ephemeral/predictable UI states (e.g., active drags, rotations, selections) before they are committed to the database.
- **Example**: `WorkspaceCubit` receives data from Riverpod, handles user interaction locally, and emits UI states without overwhelming the global stream.

## Clean Architecture Integration
The Flutter application strictly follows Clean Architecture:
- **Presentation Layer**: Screens and UI widgets built with Riverpod Providers and Cubit BlocBuilders.
- **Logic Layer**: Business logic, use cases, Cubits.
- **Data Layer**: Repositories, models, and data sources (Firebase integration).
- **Core Layer**: App routing, constants, theme, config.

## Read-Heavy Denormalization Pattern
To optimize Firestore reads, data is replicated in strategic places:
- **`appointments`/`test_orders`**: Replicate `patient_name`, `patient_code`, `doctor_name` to prevent N+1 queries in list views.
- **`samples.is_current`**: Flags the active physical sample to avoid querying historical failed samples.
- **`metaphase_images.processing_time`**: Replicates AI performance metrics for fast reporting.
