---
title: AI Server Implementation Decisions
description: Learnings and decisions from setting up the External AI Server integration.
createdAt: '2026-05-02T07:14:11.199Z'
updatedAt: '2026-05-02T07:14:11.199Z'
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
