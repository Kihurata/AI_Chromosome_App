---
title: AI Server Implementation Decisions
description: Learnings and decisions from setting up the External AI Server integration.
createdAt: '2026-05-02T07:14:11.199Z'
updatedAt: '2026-05-07T15:24:28.167Z'
tags:
  - learning
  - ai-server
  - integration
---

# Learning: AI Server Implementation Decisons

## Patterns

### Zero-copy Proxy Integration
- **What:** Backend passes only the `image_url` to the AI Server; the AI Server downloads the image directly from storage.
- **When to use:** When processing large binary assets (images/videos) to avoid overloading the backend orchestrator with data transfer.
- **Source:** @doc/specs/ai-backend-orchestrator

### LabelMe-to-Firestore Mapping
- **What:** Standardizing on LabelMe JSON output (`shapes` with `label` and `points`) for seamless consumption by the `DataMapper` service.
- **When to use:** When integrating heterogenous AI models into a Firestore-based system.
- **Source:** @doc/specs/ai-backend-orchestrator

## Decisions

### Dedicated AI Server Folder
- **Chose:** Creating a new, isolated directory `ai_server/` for all server-related logic.
- **Over:** Modifying existing inference scripts in `src/`.
- **Tag:** GOOD_CALL
- **Outcome:** Ensures the core research codebase remains clean and untouched while providing a specialized environment for the production-ready API.
- **Recommendation:** Keep all server dependencies (FastAPI, Uvicorn, etc.) isolated in this folder.

## Failures

### Coordinate Array Flattening
- **What went wrong:** Firestore does not support nested arrays (arrays of arrays). 
- **Root cause:** Initial AI output provided `[[x1, y1], [x2, y2]]`.
- **Prevention:** The `DataMapper` now flattens polygons into `[x1, y1, x2, y2, ...]` before persistence. AI Server should continue providing `[[x,y]]` as per LabelMe standard; backend handles the flattening.


## Patterns (Updated 2026-05-07)

### Dynamic Config via Firestore
- **What:** Storing Ngrok/AI Server URL in `system_configs/ai_server` -> `url`.
- **When to use:** When using dynamic tunnels like Ngrok where the URL changes frequently.
- **Source:** @task-3pasee

### Dynamic Storage Path Syncing
- **What:** Backend constructs and sends `storage_path` (e.g., `test_orders/{id}/ai_predict/{file}`) to AI Server.
- **When to use:** When the AI Server handles its own uploads but the App needs to maintain a synchronized directory structure.
- **Source:** @task-3pasee

## Decisions (Updated 2026-05-07)

### Ngrok Bypass Header
- **Chose:** Adding `ngrok-skip-browser-warning: true` to headers.
- **Over:** Manual interaction or using non-Ngrok tunnels.
- **Tag:** GOOD_CALL
- **Outcome:** Bypasses the Ngrok splash screen that would otherwise break automated JSON requests.
- **Recommendation:** Always include this header when calling an Ngrok-proxied API.

## Failures (Updated 2026-05-07)

### Missing Security Headers (403 Forbidden)
- **What went wrong:** AI Server rejected requests with 403 error.
- **Root cause:** Backend production code was missing the `X-API-Key` header which was present in the simulation script.
- **Prevention:** Always synchronize `AIClient` logic with `simulate_colab.py` or equivalent testing scripts.
- **Time lost:** 15 mins.

### Service Account Key Visibility
- **What went wrong:** Firebase SDK failed to initialize (`ValueError: The default Firebase app does not exist`).
- **Root cause:** `serviceAccountKey.json` was missing or named incorrectly in the `backend/` root folder.
- **Prevention:** Ensure the key file is present and matches the `FIREBASE_KEY_PATH` env variable.
## Patterns (Updated 2026-05-07 - AI Score and Orchestration)

### Sequential Background Analysis
- **What:** Backend processes images sequentially within a background task (`asyncio.create_task`), rather than parallel `asyncio.gather`, to prevent GPU resource exhaustion on the AI Server and avoid `DioException` timeouts on the frontend.
- **When to use:** When triggering batch processing of images against a resource-constrained Colab/GPU server.
- **Source:** Recent refactor of `OrchestratorService`.

### AI Score Normalization & Delegation
- **What:** The AI Server returns a raw `confidence` float (0-1.0). The backend `OrchestratorService` converts this to an `ai_score` integer (0-100) and writes it directly to the `metaphase_images` document in Firestore. The UI then listens to this field.
- **When to use:** When bridging raw ML inference output with UI-friendly display metrics.

## Decisions (Updated 2026-05-07)

### Backend-Centric Firestore Updates
- **Chose:** The AI Server returns JSON results (`confidence`, `shapes`, `ai_image_url`) back to the Backend API, which then updates Firestore.
- **Over:** Having the AI Server write directly to Firestore.
- **Tag:** GOOD_CALL
- **Outcome:** The Colab AI Server remains a stateless inference engine and doesn't require `serviceAccountKey.json` credentials. This improves security and keeps business logic centralized in the FastAPI backend.
- **Recommendation:** Never pass Firebase Admin credentials to external/Colab environments. Always use the internal backend as a proxy for database writes.
