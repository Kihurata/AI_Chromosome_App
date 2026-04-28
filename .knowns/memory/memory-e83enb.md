---
id: e83enb
title: 'Clean Architecture: Model fromEntity Factory Convention'
layer: project
category: convention
tags:
  - architecture
  - flutter
  - clean-architecture
  - data-layer
createdAt: '2026-04-27T06:56:55.737Z'
updatedAt: '2026-04-27T06:56:55.737Z'
---

Trong tầng Data (Data Layer) của kiến trúc Clean Architecture, các class Model phải luôn định nghĩa một phương thức `factory Model.fromEntity(Entity entity)`. 
Ví dụ: `factory PatientModel.fromEntity(Patient patient)`.
Điều này giúp việc chuyển đổi từ Domain Entity sang Data Model dễ dàng, gọn gàng hơn và tránh lặp lại logic mapping thủ công trong các Repository Implementation.
