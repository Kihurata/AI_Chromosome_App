---
id: yliqkd
title: Backend Orchestrator for AI Server (Microservice)
status: todo
priority: high
labels:
  - backend
  - microservice
  - ai-integration
  - event-driven
createdAt: '2026-04-27T08:03:04.531Z'
updatedAt: '2026-04-27T08:03:21.021Z'
timeSpent: 0
---
# Backend Orchestrator for AI Server (Microservice)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement a lightweight Backend service (Cloud Function/FastAPI Proxy) that orchestrates the workflow between the Flutter App and the dedicated AI Server (Ngrok). See architectural decision at @doc/(root)/system-architecture-and-database-schema.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Setup a Firestore trigger listening for `status: 'UPLOADED'` on `metaphase_images`.
- [ ] #2 Implement HTTP client to send a JSON payload containing ONLY the `raw_image_url` and `orderId` to the external AI Server (Ngrok). *(Do not download the image)*
- [ ] #3 Set appropriate timeouts (e.g., 120s) and handle `ngrok-skip-browser-warning` headers.
- [ ] #4 Parse the returned AI JSON result.
- [ ] #5 Implement Firebase Admin SDK bulk-write logic to securely insert `Chromosome` documents into Firestore.
- [ ] #6 Update the `MetaphaseImage` status to `COMPLETED` and trigger the App's UI to update.
<!-- AC:END -->

