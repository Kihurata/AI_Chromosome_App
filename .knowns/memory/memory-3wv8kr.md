---
id: 3wv8kr
title: 'Firestore: cloud_firestore/failed-precondition — thiếu composite index cho where+orderBy'
layer: project
category: failure
tags:
  - debug
  - firestore
  - index
  - failed-precondition
createdAt: '2026-05-14T11:40:55.877Z'
updatedAt: '2026-05-14T11:40:55.877Z'
---

Firestore query kết hợp `.where()` trên một field VÀ `.orderBy()` trên field khác bắt buộc phải có composite index.

Trong project này, query `test_orders.where('patient_id').orderBy('created_at')` bị lỗi `cloud_firestore/failed-precondition` vì thiếu index.

Fix: Thêm index vào `firestore.indexes.json` rồi chạy `firebase deploy --only firestore:indexes`.

Các indexes hiện có trong project (test_orders):
- specialist_id ASC + created_at DESC
- status ASC + created_at DESC  
- patient_id ASC + created_at DESC  ← mới thêm

Khi gặp lỗi này, Firestore log sẽ cung cấp link tạo index trực tiếp — nhưng tốt hơn là deploy qua firestore.indexes.json để giữ trong version control.
