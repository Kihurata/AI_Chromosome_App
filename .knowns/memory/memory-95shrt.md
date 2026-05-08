---
id: 95shrt
title: Dio Base URL Duplication Hazard
layer: project
category: failure
tags:
  - dio
  - api
  - failure
createdAt: '2026-05-08T01:40:38.385Z'
updatedAt: '2026-05-08T01:40:38.385Z'
---

Avoid hardcoding `/api` in repository URLs. The `Dio` instance is already configured with a base URL that includes `/api`. Adding it again causes 404 errors like `/api/api/v1/...`. Full reference: @doc/learnings/learning-step-3-persistence-and-step-4-suggestions
