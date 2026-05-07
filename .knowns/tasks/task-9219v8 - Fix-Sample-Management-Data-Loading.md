---
id: 9219v8
title: Fix Sample Management Data Loading
status: done
priority: high
labels: []
createdAt: '2026-05-07T20:14:51.775Z'
updatedAt: '2026-05-07T20:27:44.723Z'
timeSpent: 180
---
# Fix Sample Management Data Loading

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Change sorting field from 'created_at' to 'collected_at' in SampleRemoteDataSource to match Firestore schema and fix empty list issue. Add error handling to SampleManagementPage.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Fixed sample data loading by changing 'created_at' to 'collected_at' in Firestore queries. Added error handling and retry UI to SampleManagementPage. Verified with dart analyze.
🐛 Debug: Fixed TypeError in SampleModel.fromFirestore by safely handling both String and DocumentReference for ID fields. This resolves the crash when encountering inconsistent data types in Firestore.
<!-- SECTION:NOTES:END -->

