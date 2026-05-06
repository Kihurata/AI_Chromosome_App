---
title: Sample Management Table View
description: Specification for updating Sample Management list to a table layout
tags:
  - spec
  - approved
---

# Sample Management Table View

## Overview

Update the Sample Management page's list to display samples in a row-based table format (using `Expanded` widgets to align columns) to match the visual style and structure of the `Test Order` list on the Specialist Dashboard. 

## Locked Decisions

Decisions extracted during exploring phase:
- **D1**: The columns will be aligned using `Expanded` with specific flex values: Mã mẫu & Loại mẫu (flex: 3), Bệnh nhân (flex: 2), Ngày thu nhận (flex: 2), Trạng thái (flex: 2), and Hành động (flex: 3). The Action column will only contain the "Update Status" dropdown. All content is center-aligned.
- **D2**: There will be a sticky table header row matching the style of the Dashboard table, with the list below it inside a rounded border container.
- **D3**: The visual style of each row will match the Dashboard's `SpecialistOrderCard` — flat design with no borders or shadows, relying on list separators and hover effects.

## Requirements

### Functional Requirements
- **FR-1**: Refactor `SampleCard` to use a `Row` with `Expanded` children instead of a block/card layout.
- **FR-2**: Remove the outer styling (borders, shadow) from `SampleCard` and apply an `InkWell` with a hover effect, matching `SpecialistOrderCard`.
- **FR-3**: Ensure the entire row is clickable and navigates to the Sample Detail route.
- **FR-4**: Restrict the actions column to only show the "Update Status" popup menu.

### Non-Functional Requirements
- **NFR-1**: Layout must be responsive without overflowing on smaller screens, using appropriate text truncation or scaling if necessary.

## Acceptance Criteria

- [ ] AC-1: `SampleCard` renders as a flat, bordered-less row that changes background color on hover.
- [ ] AC-2: Data is aligned horizontally in 5 columns: ID/Type, Patient, Date, Status, and Action.
- [ ] AC-3: The Action column contains only the status update menu (the standalone 'info' button is removed).
- [ ] AC-4: Clicking anywhere on the row navigates to `specialist-sample-detail` using the sample's `testOrderId`.
- [ ] AC-5: `SampleManagementPage` uses `ListView.separated` to draw standard dividers between the flat rows.

## Scenarios

### Scenario 1: Viewing the list
**Given** a specialist is on the Sample Management page
**When** the list of samples is loaded
**Then** the samples are displayed in a clean, row-based format with columns neatly aligned, without heavy card shadows or borders.

### Scenario 2: Interacting with a sample
**Given** a specialist is viewing the table
**When** they click on any text or empty space within a sample's row
**Then** the application navigates to the Sample Detail view.
**When** they click specifically on the "more_vert" icon in the actions column
**Then** the update status menu opens without triggering navigation.

## Technical Notes

- Use `Expanded` with flex values (e.g., 2, 3, 2, 2, 1) inside the `Row` of `SampleCard` to align with the proposed columns.
- Ensure the `PopupMenuButton` consumes the tap event so clicking it doesn't also trigger the row's `onTap` navigation.
