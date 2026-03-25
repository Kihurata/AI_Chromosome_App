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

## Phase 3: Schema Initialization & Seeding - COMPLETED
- **Steps Taken:**
    - Created root collections: `users`, `doctors`, `patients`, `test_orders`, `audit_logs`.
    - **Mock Specialist**: `specialist@hospital.med` (ID: `DOC_001`).
    - **Mock Patients**: `Patient Alpha`, `Patient Beta`.
    - **Mock Test Order**: `ORDER_001` for Alpha (Status: `PENDING`).
- **Verification:** Seeding script `backend/scripts/seed_db.py` executed successfully.

## Phase 4: Hybrid Integration Verification
- **Agent:** `test-engineer`
- **Task:** Verify Backend (FastAPI) and Frontend (Flutter) connectivity.
- **Steps:**
    1. **Flutter Write**: Test creating a simple appointment record from the app.
    2. **FastAPI Proxy**: Test a status update endpoint (`CULTURING` -> `HARVESTED`).
    3. **AI Proxy**: Verify image receipt and metadata return through FastAPI.
- **Verification:** Firestore history reflects writes from both Flutter SDK and FastAPI Admin SDK.

---

## ✅ Phase X: Final Verification
- [ ] Firestore Enabled in Native Mode.
- [ ] `firestore.rules` deployed and blocking public access.
- [ ] `users` and `patients` collections initialized with test data.
- [ ] Backend Admin SDK verifies connection with `serviceAccountKey.json`.
