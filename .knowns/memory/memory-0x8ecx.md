---
id: 0x8ecx
title: 'Manager Dashboard: Cubit/State Naming Convention'
layer: project
category: convention
tags:
  - debug
  - flutter-bloc
  - naming-convention
createdAt: '2026-05-02T09:47:05.579Z'
updatedAt: '2026-05-02T09:47:05.579Z'
---

Root cause: UI calling outdated method names. Convention: ManagerDashboardCubit uses initialize() for stream setup. ManagerDashboardLoaded uses filteredOrders (List of TestOrder) for the main table display. Avoid using fetchPendingOrders or pendingOrders in the UI.
