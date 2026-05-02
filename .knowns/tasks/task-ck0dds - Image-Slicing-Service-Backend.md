---
id: ck0dds
title: Image Slicing Service (Backend)
status: done
priority: high
labels:
  - backend
  - python
  - opencv
  - fastapi
createdAt: '2026-04-29T15:03:18.030Z'
updatedAt: '2026-04-29T18:14:53.856Z'
timeSpent: 76
spec: specs/specialist-workspace
fulfills:
  - AC-2
  - NFR-1
---
# Image Slicing Service (Backend)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai service Python FastAPI để nhận toạ độ Vector/Polygon từ App (Bước 2). Sử dụng OpenCV để crop ảnh gốc thành 46 ảnh PNG trong suốt. Đẩy ảnh lên Firebase Storage và trả URLs về cho Flutter để render ở Bước 3.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create a `backend` directory at the project root for the Image Slicing Service.
2. Define `requirements.txt` with FastAPI, OpenCV, Numpy, and Firebase Admin.
3. Write `main.py` with an endpoint `/api/slice` that receives `image_url` and `polygons`.
4. Implement OpenCV logic to read the image, apply mask based on polygon coordinates, crop the bounding box, and save as transparent PNG.
5. Add placeholder Firebase Storage upload logic and return URLs.
6. Include a simple `Dockerfile` for deployment.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented backend service endpoint `/api/slice` in FastAPI. It uses OpenCV to decode the image from URL, apply masks using Polygon coordinates from the request, crop to bounding boxes, encode as PNG, and returns mock storage URLs. Added numpy, opencv-python-headless, and httpx to requirements.txt.
<!-- SECTION:NOTES:END -->

