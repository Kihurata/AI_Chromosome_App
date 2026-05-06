---
title: Dynamic Action Buttons for Sample Management
description: Replace generic dropdown menu with contextual, dynamic action buttons and confirmation dialogs in the Sample Management table.
tags:
  - spec
  - approved
---

## Overview

Replace the generic `more_vert` dropdown menu in the Sample Management table with context-aware, dynamic action buttons. This update aligns the UI with the Dashboard's flat design, guides the Specialist through the correct Karyotyping workflow, and introduces explicit confirmation steps ("safety nets") to prevent accidental state changes.

## Locked Decisions

Decisions extracted during exploring phase:
- **D1**: The Action column will display context-aware buttons based on the sample's current status:
  - `collected` -> `[Bắt đầu nuôi cấy]`
  - `culturing` -> `[Thu hoạch]` (Primary) and `[Thất bại]` (Secondary/Icon)
  - `harvested` or `failed` -> Empty cell
- **D2**: The "Thất bại" (Failed) action must trigger a Confirmation Dialog requiring the user to select a specific failure reason (e.g., "Mẫu bị nhiễm khuẩn", "Không đủ tế bào phân chia") before the status is updated.
- **D3**: The "Bắt đầu nuôi cấy" (Start Culturing) action must trigger a simple confirmation dialog ("Bạn có chắc chắn muốn bắt đầu nuôi cấy mẫu này?") before proceeding.

## Requirements

### Functional Requirements
- **FR-1**: The UI must display different action buttons corresponding strictly to the sample's current state.
- **FR-2**: Tapping an action button must consume the tap event and NOT trigger the parent row's navigation to the Sample Detail view.
- **FR-3**: Tapping `[Bắt đầu nuôi cấy]` must open a simple confirmation dialog. Confirming it updates the sample status to `culturing`.
- **FR-4**: Tapping `[Thất bại]` must open a specialized dialog with radio buttons or a dropdown for failure reasons. Confirming it updates the sample status to `failed` and saves the reason.
- **FR-5**: Tapping `[Thu hoạch]` directly opens the existing Bulk Upload Dialog.

### Non-Functional Requirements
- **NFR-1**: The UI must maintain the `Expanded(flex: 3)` constraints established in the table layout without overflowing.

## Acceptance Criteria

- [ ] AC-1: The action column shows `[Bắt đầu nuôi cấy]` for `collected` samples, `[Thu hoạch]` and `[Thất bại]` for `culturing` samples, and is blank otherwise.
- [ ] AC-2: Clicking any action button prevents navigation to the detail screen.
- [ ] AC-3: Clicking `[Bắt đầu nuôi cấy]` shows a simple confirmation dialog before executing the state change.
- [ ] AC-4: Clicking `[Thất bại]` shows a dialog requiring a reason selection before executing the state change.
- [ ] AC-5: Clicking `[Thu hoạch]` successfully opens the `BulkUploadDialog`.

## Scenarios

### Scenario 1: Starting the Culturing Process
**Given** a sample is in the `collected` state
**When** the user clicks the `[Bắt đầu nuôi cấy]` button
**Then** a simple confirmation dialog appears
**When** the user confirms
**Then** the status changes to `culturing`.

### Scenario 2: Failing a Sample with a Reason
**Given** a sample is in the `culturing` state
**When** the user clicks the `[Thất bại]` button
**Then** a dialog appears requiring a failure reason
**When** the user selects "Mẫu bị nhiễm khuẩn" and confirms
**Then** the status changes to `failed` and the UI updates to show an empty action cell.

## Technical Notes
- Replace the `_buildPopupMenu` method in `SampleCard` with a `_buildActionCell` method.
- Create a `FailureReasonDialog` widget to encapsulate the reason selection UI.
- Use `ElevatedButton` for primary actions (Bắt đầu nuôi cấy, Thu hoạch) and `IconButton` or `OutlinedButton` with a danger color for `Thất bại`.

## Open Questions
- Where exactly is the failure reason stored on the backend model? Do we need to update the `Sample` entity to include a `failureReason` string field?
