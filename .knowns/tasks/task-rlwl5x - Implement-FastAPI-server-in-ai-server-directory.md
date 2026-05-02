---
id: rlwl5x
title: Implement FastAPI server in ai_server/ directory
status: in-progress
priority: high
labels: []
createdAt: '2026-05-02T07:14:49.515Z'
updatedAt: '2026-05-02T07:15:05.794Z'
timeSpent: 0
assignee: '@me'
---
# Implement FastAPI server in ai_server/ directory

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement a FastAPI server in the `ai_server/` directory that fulfills the External AI Server requirements. The server must expose a `POST /analyze` endpoint that accepts an `image_url`, downloads the image, runs the existing chromosome inference pipeline, and returns the results in LabelMe JSON format.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Create ai_server/ directory and ai_server/requirements.txt
- [ ] #2 Implement ai_server/inference_wrapper.py to encapsulate models and generate LabelMe JSON output
- [ ] #3 Implement ai_server/main.py with FastAPI POST /analyze endpoint and image download logic
- [ ] #4 Test the AI Server endpoint with a sample image
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Setup**: Create `ai_server/` directory and define `requirements.txt` (FastAPI, uvicorn, httpx).
2. **Inference Wrapper**: Create `ai_server/inference_wrapper.py`. This class will load the models (Stage 1, 2, 3) once upon initialization, accept an image (numpy array), and return a LabelMe JSON structure (`shapes` with `label` and `points`) instead of saving visual reports to disk.
3. **API Server**: Create `ai_server/main.py`.
   - Setup FastAPI app and lifespan event to initialize `inference_wrapper`.
   - Implement `POST /analyze` endpoint.
   - Use `httpx` to download the image from the provided `image_url`.
   - Pass the image to the wrapper and return the JSON response.
   - Include error handling (timeout, invalid URL, inference errors).
4. **Validation**: Test the local server endpoint to ensure it returns the correct JSON format (as defined in @doc/learnings/ai-server-implementation-decisions).
<!-- SECTION:PLAN:END -->

