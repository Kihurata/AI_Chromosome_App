---
id: smptbl
title: Implement Sample Management Table View UI
status: done
priority: medium
labels:
  - from-spec
  - go-mode
  - ui
createdAt: '2026-05-06T16:25:00.000Z'
updatedAt: '2026-05-06T16:25:00.000Z'
timeSpent: 0
spec: specs/sample-management-table-view.md
fulfills:
  - AC-1
  - AC-2
  - AC-3
  - AC-4
  - AC-5
---
# Implement Sample Management Table View UI

## Description

Refactor the `SampleCard` into a flat, bordered-less row that aligns horizontally into 5 columns using `Expanded` flex values. Adjust `SampleManagementPage` to render standard list dividers and ensure the row is clickable for navigation while preserving the status dropdown.

## Acceptance Criteria
- [x] AC-1: `SampleCard` renders as a flat, bordered-less row that changes background color on hover.
- [x] AC-2: Data is aligned horizontally in 5 columns: ID/Type, Patient, Date, Status, and Action.
- [x] AC-3: The Action column contains only the status update menu (the standalone 'info' button is removed).
- [x] AC-4: Clicking anywhere on the row navigates to `specialist-sample-detail` using the sample's `testOrderId`.
- [x] AC-5: `SampleManagementPage` uses `ListView.separated` to draw standard dividers between the flat rows.

## Implementation Plan

1. Update `SampleCard` (frontend/lib/presentation/screens/specialist/widgets/sample_card.dart)
    - Remove outer `Container` decoration (border, shadow).
    - Add `InkWell` for hover effect and navigation (`context.pushNamed('specialist-sample-detail', ...)`).
    - Restructure `Row` into 5 `Expanded` widgets:
        - `flex: 2`: Sample ID & Type
        - `flex: 3`: Patient Name
        - `flex: 2`: Collected Date
        - `flex: 2`: Status Badge
        - `flex: 1`: Action (Update Status Menu)
2. Update `SampleManagementPage` (frontend/lib/presentation/screens/specialist/sample_management_page.dart)
    - Remove the `InkWell` wrapping `SampleCard` in `_buildSampleList` because navigation is moved to the card itself to prevent the popup menu from triggering row clicks improperly.
    - Ensure `ListView.separated` is providing standard dividers (it already has a `SizedBox(height: 16)` separator, change it to `Divider(height: 1, color: Colors.grey.shade200)` and remove vertical padding inside the list item if necessary).

## Implementation Notes
