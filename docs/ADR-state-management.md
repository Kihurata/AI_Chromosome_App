# Architectural Decision Record (ADR) - State Management

## Context
The Chromosome Karyotyping App requires both **real-time synchronization** with Firestore (for collaborative workspace editing) and **complex UI state management** (for drag-and-drop, rotations, and temporary edits in the Karyotype Workspace).

## Decision: Hybrid State Management (Riverpod + Cubit)
We have decided to use a hybrid approach combining **Riverpod** and **Bloc/Cubit**.

### 1. Riverpod (The "Data Pipe")
- **Role**: Data Source / Streaming Engine.
- **Why**: Riverpod's `StreamProvider` is natively optimized for Firestore listeners. It handles the "raw" data coming from the cloud efficiently and provides global dependency injection (DI) for repositories and services.
- **Usage**: 
    - `StreamProvider` to listen to `test_orders` and `chromosomes` collections.
    - `Provider` for Firebase Auth and Firestore instances.

### 2. Cubit (The "UI Controller")
- **Role**: Local Interaction Manager.
- **Why**: Cubit (part of the BLoC library) is excellent at managing **ephemeral/predictable** UI states. In the workspace, we need to track "active" drags, selections, and rotations that haven't been committed to the database yet. Cubit's state-driven nature provides a clear mental model for these transitions without overwhelming the global data stream.
- **Usage**:
    - `WorkspaceCubit`: Receives data from Riverpod, allows the user to manipulate it locally (drag-and-drop deltas), and manages "Selected Item" state.
    - `AuthCubit`: Manages the login flow and user session states.

## Decision: Data Denormalization Strategy
To optimize for **Read Performance** and **Cost Efficiency** in Firestore, we apply "Read-heavy" denormalization across key collections.

### 1. Replicated Fields
- **Appointments/Orders**: Replicate `patient_name`, `patient_code`, and `doctor_name`.
- **Why**: Listing views (e.g., Today's Schedule, Analysis Queue) would otherwise require `N*2` extra document reads (Patient + Doctor) for every single item. By denormalizing, a single query fetches all necessary display data.

### 2. Status Tracking
- **`samples.is_current` (Boolean)**: Identifies the active sample for a test order.
- **Why**: Allows FastAPI and AI engines to fetch the correct active sample directly without querying the entire history of failed/old samples for that patient.

### 3. AI Performance Metrics
- **`metaphase_images.processing_time`**: Replicate AI processing latency in the image metadata.
- **Why**: Fast sorting and reporting of AI performance without reading external logs.

## Benefits
1. **Separation of Concerns**: Data fetching logic is decoupled from interaction logic.
2. **Performance**: Only Interaction-heavy widgets rebuild via Cubit, while high-level data updates flow through Riverpod.
3. **Reliability**: Firestore snapshots don't "interrupt" a user in the middle of a drag; the Cubit holds the active session state until sync-back occurs.
4. **Latency Reduction**: Denormalization reduces rounds-trips to Fetch related metadata.

## Data Flow Pattern
```text
Firestore Snippet ➔ Riverpod StreamProvider ➔ Widget (Consumer) 
                                                ↓ (pushes to)
                                          WorkspaceCubit
                                                ↓ (emits UI state)
                                           CustomPainter / UI
```

---
**Date**: 2026-03-25
**Status**: Accepted
