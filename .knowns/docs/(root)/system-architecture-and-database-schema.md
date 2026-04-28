---
title: System Architecture and Database Schema
description: Overview of the system architecture, Firestore collections, and data design decisions.
createdAt: '2026-04-26T07:07:46.422Z'
updatedAt: '2026-04-27T08:03:21.107Z'
tags:
  - architecture
  - database
  - firestore
  - schema
---

# System Architecture & Database Schema
The app uses Firebase Firestore for real-time synchronization, driven by a FastAPI backend proxy and Flutter frontend.

## Database Design Decisions
1. **NoSQL Adaptation (Deep Nested Sub-collections)**: Images are stored as `test_orders/{orderId}/metaphase_images` and chromosomes are nested further under `.../chromosomes` to optimize read performance and reduce costs during workspace loading.
2. **Role-Based Separation**: Separating `users` from `doctors` allows fast basic auth/routing without fetching heavy specific logic.
3. **Real-time Sync**: The highly nested `chromosomes` sub-collection allows active Firestore listeners for real-time drag-and-drop workspace syncing.
4. **Asset Storage**: Image paths (`raw_image_url`, `mask_url`) store URI references to Firebase Cloud Storage, keeping document sizes under 1MB limit.
5. **Denormalization Strategy**: Core fields like `patient_name`, `patient_code`, and `doctor_name` are replicated to reduce reads for list views.
6. **Sample Lifecycle**: The `is_current` flag on `samples` tracks the active sample for a test order.

## Core Collections
- **Authentication**: `users`, `doctors`
- **Patient Management**: `patients`, `appointments`
- **Laboratory**: `test_orders`, `samples`
- **AI & Images**: `test_orders/{orderId}/metaphase_images` -> `.../chromosomes`
- **Audit**: `audit_logs`

## Architectural Decision: Event-Driven AI Integration (Microservices)
- **Decision:** The Flutter App acts purely as a reactive client. It uploads the raw `MetaphaseImage` to Firebase Cloud Storage and creates a record in Firestore with `status: 'UPLOADED'`.
- **Backend Role (Orchestrator):** The FastAPI backend (or Firebase Cloud Functions) listens to Firestore. It **DOES NOT** download the image. Instead, it makes a lightweight HTTP POST request to the external AI Server (Ngrok) passing the `raw_image_url` (Zero-copy). Upon receiving the JSON result, it bulk-inserts the `Chromosome` data into Firestore using the Firebase Admin SDK.
- **AI Server Role:** Hosted externally (e.g., via Ngrok), it downloads the image from the provided URL, processes it (PyTorch/OpenCV), and returns the JSON result.
- **Rationale:** 
  1. **UX:** Prevents the app from hanging or crashing during the 30-60s AI processing window.
  2. **Security:** Completely hides the Ngrok/AI Server URL and credentials from the client app, and keeps the AI Model secure on a separate server.
  3. **Data Integrity:** Prevents incomplete data insertions if the client loses connection.
  4. **Optimization:** Zero-copy pass-through on the Backend saves RAM and bandwidth.
