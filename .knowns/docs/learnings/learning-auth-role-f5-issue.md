---
title: 'Learning: Auth Role Reset on F5'
description: Learnings from debugging role reset on page refresh
folder: learnings
tags: [learning, auth, firestore]
---

## Patterns

### Forced Server Fetch for Critical Auth Data
- **What:** Use `GetOptions(source: Source.server)` when fetching critical user data (like roles) on startup or F5.
- **When to use:** In stream listeners or startup logic where stale cache can cause incorrect routing or fallback roles.
- **Source:** Current session

## Decisions

### Forced read from server in AuthCubit
- **Chose:** `GetOptions(source: Source.server)`
- **Over:** Default cache-first read
- **Tag:** GOOD_CALL
- **Outcome:** Ensured we read the latest data from the server, avoiding stale cache issues on F5.
- **Recommendation:** Always use for auth/role checks.

## Failures

### Role reverts to fallback on F5 due to partial document write
- **What went wrong:** Refreshing the page (F5) caused the user's role to revert to 'receptionist' because it read `'user'` from Firestore.
- **Root cause:** `NotificationCubit` called `set({'fcm_token': token}, SetOptions(merge: true))` on startup. This triggered *before* `AuthCubit` read the document. If the document didn't exist or was empty in the cache/server at that split second (or due to race condition), `set()` created a document with ONLY `fcm_token`. `AuthCubit` then read this partial document and defaulted to `'user'`.
- **Time lost:** 1 hour
- **Prevention:** Do not perform writes that can create partial documents on startup without verifying existence, or ensure the read is completed first. Better yet, handle missing fields gracefully and don't default to a valid role if data is incomplete.
