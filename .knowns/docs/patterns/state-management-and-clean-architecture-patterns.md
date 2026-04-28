---
title: State Management and Clean Architecture Patterns
description: Implementation patterns for Hybrid State Management (Riverpod + Cubit) and Clean Architecture.
createdAt: '2026-04-26T07:07:52.727Z'
updatedAt: '2026-04-28T05:22:00.000Z'
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

---

## Real-Time Firestore Stream via Cubit (BlocBuilder Pattern)

**Context**: Receptionist module refactor (tasks a3m4u4, 2tou5t — 2026-04-28).
Replace `StreamBuilder<QuerySnapshot>` in UI with Cubit-managed streams for Clean Architecture compliance.

### Pattern 1: `await for` Stream in Cubit

```dart
// CORRECT — use await for with isClosed guard
Future<void> listenToTodayAppointments() async {
  emit(AppointmentLoading());
  await for (final result in watchTodayAppointments()) {
    if (isClosed) break; // mandatory: prevent emit after Cubit is closed
    result.fold(
      (failure) => emit(AppointmentError(failure.message)),
      (data) => emit(AppointmentLoaded(data)),
    );
  }
}
```

> **CRITICAL PITFALL**: `emit.forEach()` does **NOT exist** in `flutter_bloc` Cubit API.
> Only `Bloc` (not `Cubit`) has special emit methods. Using it causes a compile error.
> Always use `await for` loop with `isClosed` guard for Cubit streams.

### Pattern 2: Dual State for Multi-Screen Cubit

When a single Cubit serves multiple screens needing **different data contexts**, use distinct state classes:

```dart
// State for today's real-time stream (dashboard)
class AppointmentLoaded extends AppointmentState {
  final List<Appointment> appointments;
}

// State for date-range query (calendar page)
class RangeAppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;
}
```

`BlocBuilder` in each screen filters on its own state type — no ambiguity, no shared mutable flag.

### Pattern 3: BlocBuilder Replaces StreamBuilder

**Before (Clean Architecture violation):**
```dart
StreamBuilder<QuerySnapshot>(
  stream: clinicalRepo.getTodayAppointments(), // UI directly accessing Firestore!
  builder: (context, snapshot) { ... },
)
```

**After (Clean Architecture compliant):**
```dart
// initState:
context.read<AppointmentCubit>().listenToTodayAppointments();

// build:
BlocBuilder<AppointmentCubit, AppointmentState>(
  builder: (context, state) {
    if (state is AppointmentLoading) return const CircularProgressIndicator();
    if (state is AppointmentError) return Text('Error: ${state.message}');
    if (state is AppointmentLoaded) return _buildList(state.appointments);
    return const SizedBox.shrink();
  },
)
```

### Pattern 4: Model to Entity Bridge for Legacy Widgets

When a legacy destination widget still expects a `Model` but source is a domain `Entity`:

```dart
// PatientDetailScreen still takes PatientModel
Navigator.push(MaterialPageRoute(
  builder: (_) => PatientDetailScreen(
    patient: PatientModel.fromEntity(p), // p is Patient entity from Cubit
  ),
));
```

**When to use**: Incremental refactoring only. Requires `Model extends Entity` + `fromEntity()` factory.
**Long-term**: Refactor destination widget to accept the entity directly.

### Pattern 5: One-Shot Range Fetch for Calendar

For non-streaming date-range queries, use a Future method with a distinct state:

```dart
// Cubit
Future<void> fetchAppointmentsInRange(DateTime start, DateTime end) async {
  emit(AppointmentLoading());
  final result = await getAppointmentsInRange(start, end);
  result.fold(
    (failure) => emit(AppointmentError(failure.message)),
    (appointments) => emit(RangeAppointmentsLoaded(appointments)),
  );
}

// UI — called on day tap in TableCalendar
onDaySelected: (selectedDay, focusedDay) {
  setState(() => _selectedDay = selectedDay);
  final start = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  final end = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59);
  context.read<AppointmentCubit>().fetchAppointmentsInRange(start, end);
},
```
