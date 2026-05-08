---
id: qis0p8
title: Firestore Schema Verification Failure
layer: project
category: failure
tags:
  - models
  - schema
  - firestore
createdAt: '2026-05-07T20:45:45.230Z'
updatedAt: '2026-05-07T20:45:45.230Z'
---

Assumed 'created_at' existed in Firestore but schema used 'collected_at'. This caused silent data loss in queries. Always verify model properties against DB console before coding. Full reference: @doc/learnings/learning-specialist-dashboard-and-firestore-indexing
