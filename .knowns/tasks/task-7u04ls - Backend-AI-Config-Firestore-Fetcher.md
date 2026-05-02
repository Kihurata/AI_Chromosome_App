---
id: 7u04ls
title: '[Backend] AI Config & Firestore Fetcher'
status: done
priority: high
labels:
  - backend
  - firestore
  - config
createdAt: '2026-05-01T09:46:13.955Z'
updatedAt: '2026-05-01T10:17:12.766Z'
timeSpent: 0
spec: specs/ai-backend-orchestrator
---
# [Backend] AI Config & Firestore Fetcher

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai logic đọc `api_url` từ Firestore `system_configs/ai_server`. Đảm bảo Backend có thể lấy URL động để gọi AI Server.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Tạo file `backend/app/core/ai_config.py`.
2. Triển khai hàm `get_ai_server_url()` sử dụng Firebase Admin SDK để đọc document `system_configs/ai_server`.
3. Thêm log thông báo khi lấy URL thành công hoặc thất bại.
4. Tạo script `backend/scripts/test_ai_config.py` để kiểm chứng logic.
<!-- SECTION:PLAN:END -->

