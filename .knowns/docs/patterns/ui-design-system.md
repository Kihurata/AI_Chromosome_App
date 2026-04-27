---
title: UI Design System
description: Design tokens, color palette, typography, and component patterns for the application frontend.
createdAt: '2026-04-26T07:07:53.646Z'
updatedAt: '2026-04-26T07:07:53.646Z'
tags:
  - ui
  - design-system
  - frontend
  - styling
---

# UI Design System
The frontend follows a clean, high-contrast, data-heavy dashboard design optimized for Healthcare CRM (Trust, Clarity, Efficiency).

## Color Palette
- **Brand/Primary**: Clinical Blue (`#0D6EFD`, Tailwind: `blue-600`), Hover (`blue-700`), Active Bg (`blue-50`).
- **Neutrals**: App Bg (`gray-50`), Surfaces/Cards (`white`), Borders (`gray-200`).
- **Typography**: Primary Text (`gray-900`), Secondary Text (`gray-500`), Placeholders (`gray-400`).
- **Semantic Badges**:
  - Success: Text (`green-700`), Bg (`green-100`)
  - Danger/Urgency: Text (`red-600`), Bg (`red-100`)
  - Processing: Text (`blue-600`), Bg (`cyan-100` or `blue-100`)

*Note: Violet/Purple is strictly banned as a primary/structural color, limited only to auto-generated user avatars.*

## Typography
- **Font**: Inter, Roboto, or system-ui.
- **Sizes**: Page Title (24px, Bold), Card Titles (16px, Semi-bold), Stat Numbers (32px, Bold), Body Text (14px, Regular), Table Headers (12px, Semi-bold, Uppercase).

## Layout & Component Patterns
- **Grid**: 8-Point Grid system. Standard SaaS shell with fixed sidebar, top header, and main workspace.
- **Cards**: White bg, rounded-xl, subtle shadow, p-5.
- **Tables**: White bg, rounded-xl, border. Headers are uppercase. Avatars are rounded-full. Badges use pill shape (`rounded-full`).
- **Buttons**: Primary buttons are Blue, rounded-lg, with icons on the left.
