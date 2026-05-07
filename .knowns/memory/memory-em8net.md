---
id: em8net
title: 'AI Server Integration Setup & Security'
layer: project
category: convention
tags:
  - ai-server
  - backend
  - config
createdAt: '2026-05-07T07:55:47.811Z'
updatedAt: '2026-05-07T07:55:47.811Z'
---

Khi thiết lập Backend gọi AI Server qua Ngrok, bắt buộc dùng header 'ngrok-skip-browser-warning: true' và đồng bộ hóa 'X-API-Key'. URL được cấu hình tại 'system_configs/ai_server' trường 'url'. Chi tiết: @doc/learnings/ai-server-implementation-decisions
