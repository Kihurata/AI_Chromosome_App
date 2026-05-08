---
id: 9pxa91
title: Backend-Centric AI Firestore Updates
layer: project
category: convention
tags:
  - ai-server
  - architecture
  - security
createdAt: '2026-05-07T15:24:34.987Z'
updatedAt: '2026-05-07T15:24:34.987Z'
---

AI Server must remain a stateless inference engine returning JSON (`confidence`, `shapes`, `ai_image_url`). The FastAPI backend receives this JSON and is solely responsible for updating Firestore. Never expose Firebase Admin credentials to Colab environments. Full reference: @doc/learnings/ai-server-implementation-decisions
