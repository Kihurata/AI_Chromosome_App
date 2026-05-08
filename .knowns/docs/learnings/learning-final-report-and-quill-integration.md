---
title: "Learning: Final Report and Quill Integration"
description: "Learnings from implementing final report editor, preview and flutter_quill v11 integration."
folder: learnings
tags: [learning, flutter, quill]
---

## Patterns

### Flutter Quill v11 API Pattern
- **What:** Pass `config` directly to `QuillSimpleToolbar` and `QuillEditor.basic` instead of using `QuillProvider`.
- **When to use:** When integrating `flutter_quill` v11+.
- **Source:** @task-drec59

### Preview Snapshot Pattern
- **What:** Create a read-only `QuillController` from the document delta to show a preview without affecting the editor.
- **When to use:** When needing a non-editable preview of rich text.
- **Source:** @task-drec59

## Decisions

### Render Karyotype as Widgets
- **Chose:** Rendering the Karyotype grid using Flutter Widgets on the fly.
- **Over:** Generating image files on the backend or capturing canvas screenshots.
- **Tag:** GOOD_CALL
- **Outcome:** Simplified architecture, no need for image storage or transfer for the report preview.
- **Recommendation:** Use this approach for dynamic layouts that don't strictly require image files.

### Widget-based Karyotype TRADEOFF
- **Chose:** Widget-based rendering.
- **Over:** Image-based rendering.
- **Tag:** TRADEOFF
- **Outcome:** Exporting to PDF or printing might need additional work (e.g., using `RepaintBoundary` to capture the widget).
- **Recommendation:** Keep in mind for future tasks involving export/print.

## Failures

### UnimplementedError (FlutterQuillLocalizations)
- **What went wrong:** Forgot to add `FlutterQuillLocalizations.delegate` to `MaterialApp`.
- **Root cause:** `flutter_quill` requires its own localization delegates for UI strings.
- **Time lost:** ~10 minutes.
- **Prevention:** Always check package documentation for localization requirements when adding UI packages.

### RenderFlex Overflow in Karyotype Grid
- **What went wrong:** Cells in `KaryotypeGrid` overflowed horizontally when a classification had many chromosomes (e.g., cell 11 had >5 chromosomes).
- **Root cause:** Used fixed width `60` and `Row` for images, which doesn't wrap.
- **Time lost:** ~5 minutes.
- **Prevention:** Use `Wrap` instead of `Row` for dynamic lists of widgets in confined spaces, and use `BoxConstraints` (min/max) instead of fixed dimensions.
