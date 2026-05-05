---
title: AI Server Colab Integration
description: Specification for setting up Colab AI Server with Ngrok
createdAt: '2026-05-05T08:29:56.018Z'
updatedAt: '2026-05-05T08:32:13.735Z'
tags:
  - spec
  - approved
---

## Overview
Specification for integrating the existing Python AI segmentation pipeline (Colab) into the main application via a FastAPI server exposed through Ngrok.

## Locked Decisions
- **D1 (Authentication):** Use a simple API Key passed via `X-API-Key` header to secure the Colab Ngrok endpoint.
- **D2 (Auto-sync):** AI Server will automatically update the Ngrok URL to Firestore (`system_configs/ai_server`) upon startup using the Firebase Admin SDK.
- **D3 (Karyogram Output):** The AI Server will return the LabelMe JSON format **and** upload the generated Karyogram PNG to Firebase Storage, returning its URL for reference.

## Requirements

### Functional Requirements
- **FR-1 (Ngrok Tunnel):** Implement `pyngrok` alongside `nest_asyncio` and `uvicorn` to expose the FastAPI app on Colab.
- **FR-2 (Security):** FastAPI endpoint `/analyze` must validate the `X-API-Key` header. Reject unauthorized requests.
- **FR-3 (Firestore Sync):** On startup, the script must authenticate via `firebase-admin` and update the `url` field in the `system_configs/ai_server` document.
- **FR-4 (Zero-copy Download):** Endpoint must accept `{"image_url": "...", "test_order_id": "..."}` and download the image directly into memory for processing.
- **FR-5 (Pipeline Execution):** Execute the existing 4-step pipeline (Background -> Detect -> StarDist -> Classify).
- **FR-6 (Upload Reference):** Generate the Denver standard Karyogram PNG, upload it to Firebase Storage (e.g., path: `ai_references/{test_order_id}.png`), and obtain its public URL.
- **FR-7 (Standardized Output):** Format the coordinate results strictly into the LabelMe JSON format (`shapes` array with `label` and `points` as `[[x,y]]`).

### Non-Functional Requirements
- **NFR-1 (Timeout):** The processing pipeline may take 2-5 seconds per image. The endpoint must remain open and not timeout prematurely.
- **NFR-2 (GPU Memory):** Models should remain loaded in memory globally (not reloaded per request) to ensure efficient inference on the T4 GPU.

## Acceptance Criteria
- [ ] **AC-1:** Starting the Colab cell automatically writes the active Ngrok URL to Firestore.
- [ ] **AC-2:** Requests lacking the correct `X-API-Key` receive an HTTP 401/403 Unauthorized response.
- [ ] **AC-3:** A valid POST request successfully triggers the pipeline and returns HTTP 200 with the correct LabelMe JSON structure.
- [ ] **AC-4:** The API response includes `reference_karyogram_url` pointing to an accessible image on Firebase Storage.
- [ ] **AC-5:** Chromosome polygons inside the JSON `shapes` array are formatted properly as lists of `[x, y]` coordinates.

## Scenarios

### Scenario 1: Happy Path Processing
**Given** the Colab server is running and synced its URL to Firestore
**When** the Backend Orchestrator sends a POST request with a valid image URL, test_order_id, and API Key
**Then** the Colab server downloads the image, processes it, uploads the reference Karyogram to Storage, and returns the structured JSON output.

### Scenario 2: Unauthorized Access Attempt
**Given** the Colab server is exposed via public Ngrok URL
**When** an external scanner or malicious user sends a request without the `X-API-Key` header
**Then** the server immediately rejects the request with HTTP 403 Forbidden without processing any images.

## Technical Notes
- To prevent Ngrok's browser warning block, ensure the orchestrator backend continues to send the `"ngrok-skip-browser-warning": "true"` header.
- Use `requests` or `aiohttp` to download the `image_url` directly into a numpy array / OpenCV format.
