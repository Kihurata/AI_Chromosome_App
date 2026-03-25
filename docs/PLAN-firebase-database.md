# Plan: Firebase Database Setup (Firestore)

## Overview
This plan outlines the steps to initialize and configure **Cloud Firestore** for the Chromosome Karyotyping App, including schema creation, security rules, and initial data seeding.

## Task Slug: `firebase-database`

---

## Phase 0: Socratic Gate (Discovery) - COMPLETED

### Strategic Decisions:
1. **Firestore Region**: `asia-southeast1` (Vietnam/Southeast Asia).
2. **Security Mode**: Initial setup in **Test Mode** (open access for development).
3. **Data Seeding**: Automatically create mock records (1 Specialist, 2-3 Patients, 1 Test Order).
4. **Architecture**: **Hybrid Model**
    - **Flutter SDK**: Handles simple CRUD like appointments and profile updates.
    - **FastAPI Proxy**: Handles AI image segmentation, classification, and secure state transitions (e.g., sample status updates).

---

## Phase 1: Console Configuration - COMPLETED
- **Steps Taken:**
    - Initialized Firestore in **Native Mode**.
    - Configured Location: **`asia-southeast1`**.
    - Initial provision completed.

## Phase 2: Security Rules & Indexes - COMPLETED
- **Steps Taken:**
    - Deployed `firestore.rules` in **Test Mode** (Expires 2026-04-30).
    - Initialized `firestore.indexes.json` (Empty).
    - Deployed `storage.rules` (Auth required).

---

## Phase 3: Schema Initialization & Seeding - COMPLETED (Re-architected)
- **Steps Taken:**
    - Created root collections: `users`, `doctors`, `patients`, `appointments`, `test_orders`, `samples`, `audit_logs`.
    - **Denormalization Applied**: `patient_name`, `patient_code`, and `doctor_name` added to appropriate collections.
    - **Mock Records**:
        - Specialist: `Dr. Nguyen Van A` (ID: `DOC_001`).
        - Patients: `Alpha`, `Beta`.
        - Order: `ORDER_001` with sub-collections for images and chromosomes.
        - Sample: `SMP_001` with `is_current: true`.
- **Verification:** Updated seeding script `backend/scripts/seed_db.py` executed successfully.

## Phase 4: Hybrid Integration & Frontend Architecture - IN PROGRESS
- **Agent:** `test-engineer`
- **Frontend Architecture Strategy:**
    - **Real-time Engine**: Use Riverpod **`StreamProvider`** to listen for raw Firestore snapshots (e.g., Chromosome positions).
    - **UI Controller**: Use **Cubit** to consume the Riverpod stream and manage "active" local UI changes (e.g., drag-and-drop deltas) before syncing back to the stream.
- **Tasks:**
    1. **Flutter Config**: Run `flutterfire configure` to generate `lib/core/firebase/firebase_options.dart`.
    2. **Lib Setup**: Update `main.dart` with the new options path.
    3. **Provider Layer**: Implement the `StreamProvider` for Test Orders and Workspace objects.
- **Verification:** Flutter app successfully logs in and listens to seeded `ORDER_001`.

---

## ✅ Phase X: Final Verification
- [ ] Firestore Enabled in Native Mode.
- [ ] `firestore.rules` deployed and blocking public access.
- [ ] `users` and `patients` collections initialized with test data.
- [ ] Backend Admin SDK verifies connection with `serviceAccountKey.json`.
