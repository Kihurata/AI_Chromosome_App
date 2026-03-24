# MedCore Hospital CRM: UI Design System

This document outlines the design tokens, component styles, and layout principles extracted from the provided MedCore design mockup. It serves as the single source of truth for the Frontend team to implement the UI consistently.

## 1. Deep Design Thinking & Identity

*   **Sector:** Healthcare CRM / Hospital Management
*   **Target Emotion:** Trust, Clarity, Efficiency, and Professionalism.
*   **Design Identity:** A clean, high-contrast, data-heavy dashboard that avoids unnecessary clutter. Relies on strict grid layouts and clear semantic badging.
*   **Geometry:** Rounded but structured (`rounded-xl` for cards, `rounded-full` for badges/search). This bridges "friendly" with "clinical precision".

## 2. Color Palette (Tailwind Reference)

### Brand & Primary
The primary color establishes trust (Clinical Blue).
*   **Primary Blue:** `#0D6EFD` (Tailwind: `blue-600`) — Used for the core brand logo, active sidebar items, and primary Call-To-Action (CTA) buttons like "+ Thêm bệnh nhân".
*   **Primary Hover:** `#0B5ED7` (Tailwind: `blue-700`)
*   **Active Background:** `#EFF6FF` (Tailwind: `blue-50`) — Used for the selected sidebar item background.

### Neutrals & Backgrounds
*   **App Background:** `#F8F9FA` (Tailwind: `gray-50`) — Main content working area.
*   **Surface / Cards:** `#FFFFFF` (Tailwind: `white`) — Sidebar, Topbar, Data Cards, and Table containers.
*   **Borders & Dividers:** `#E9ECEF` (Tailwind: `gray-200`) — Used for structural separation (sidebar right border, header bottom border, table row borders).

### Typography Colors
*   **Primary Text (Headings/Data):** `#212529` (Tailwind: `gray-900`)
*   **Secondary Text (Labels/Subtitles):** `#6C757D` (Tailwind: `gray-500`)
*   **Placeholder Text:** `#ADB5BD` (Tailwind: `gray-400`)

### Semantic Colors (Badges, Stats, Avatars)
Used to instantly convey medical/task status.
*   **Success (Hoàn thành / Positive Stats):** 
    *   Text: `#198754` (`green-700`)
    *   Bg: `#D1E7DD` (`green-100`)
*   **Danger/Urgency (Khẩn cấp / Negative Stats / Notifications):** 
    *   Text: `#DC3545` (`red-600`)
    *   Bg: `#F8D7DA` (`red-100`)
*   **Processing (Đang xử lý):** 
    *   Text: `#0D6EFD` (`blue-600`)
    *   Bg: `#CFF4FC` (`cyan-100` or `blue-100`)

*(Note: Per the strict Purple Ban guidelines, violet/purple will not be used as a primary or structural color. It is strictly limited here ONLY to auto-generated user avatar backgrounds to differentiate users, e.g., "Jane Smith".)*

---

## 3. Typography

*   **Font Family:** `Inter`, `Roboto`, or system-ui (Clean, modern sans-serif).
*   **H1 (Page Title):** 24px, Font Weight: 700 (Bold). Example: *"Tổng quan của Bác sĩ"*.
*   **H2 (Card/Section Titles):** 16px, Font Weight: 600 (Semi-bold). Example: *"Hoạt động bệnh nhân gần đây"*.
*   **Stat Numbers:** 32px, Font Weight: 700 (Bold). Example: *"24"*, *"12"*.
*   **Body Text:** 14px, Font Weight: 400 (Regular). Example: Patient names, row data.
*   **Table Headers:** 12px, Font Weight: 600 (Semi-bold), Uppercase, Color: `gray-500`.

---

## 4. Layout & Spacing (8-Point Grid)

The layout uses a standard highly-functional SaaS shell.
*   **Sidebar Navigation:** Fixed width (approx 260px), full height, white background, right border.
*   **Top Header:** Fixed height (approx 72px), white background, bottom border. Flexbox layout `justify-between`.
*   **Main Workspace:** Light gray background (`bg-gray-50`), with generous padding (`p-6` or `p-8`).

### Grid Setup
*   **Top Stats Cards:** 3 equally sized columns `grid-cols-3` with `gap-6`.

---

## 5. Component Patterns

### 5.1 Buttons & Inputs
*   **Primary Button:** Blue (`bg-blue-600`), White text, padding `px-4 py-2`, `rounded-lg`. Icon on the left.
*   **Search Bar:** `bg-gray-100`, text `gray-600`, icon left, `rounded-full`, no visible border unless focused.

### 5.2 Navigation Sidebar
*   **Items:** `px-4 py-3`, Icon + Text, `rounded-lg` margin.
*   **Default State:** Transparent bg, `gray-600` text/icon.
*   **Active State:** `bg-blue-50` background, `blue-600` text/icon. Font-weight slightly bolder.

### 5.3 Data Cards (Stat Cards)
*   **Container:** `bg-white`, `rounded-xl`, subtle shadow (`shadow-sm`), padding `p-5`.
*   **Layout:** Vertical stacking. Top row: description text + icon block. Middle row: Massive numbers. Bottom row: Trend indicator (+/-).
*   **Icon Blocks:** `w-10 h-10` container, `rounded-lg`, background is a 10% opacity version of the icon color (e.g., `bg-blue-50` with `text-blue-600`).

### 5.4 Data Tables
*   **Container:** `bg-white`, `rounded-xl`, `shadow-sm`, border `border-gray-200`.
*   **Header Row:** Height approx 48px, bottom border. Text `uppercase text-xs text-gray-500 tracking-wider`.
*   **Data Rows:** Height approx 64px, bottom alignment via `border-b border-gray-100` except the last row.
*   **Avatars:** Circular `rounded-full`, `w-8 h-8`, displays initials, random soft background colors.
*   **Badges (Trạng thái):** Highly rounded pill shape (`rounded-full`), padding `px-3 py-1`, text size `text-xs font-medium`. Semantic colors applied based on status logic.

---

## 6. Implementation Notes for Frontend Team
1.  **Tailwind Configuration:** Ensure to extend the Tailwind theme with the exact semantic colors mapped above. Don't rely on defaults to perfectly match the mockup's soft reds and greens.
2.  **Icons:** The mockup uses a sleek, unified icon set (like Phosphor Icons, Lucide, or Heroicons Outline). Ensure consistent stroke widths (usually 1.5px or 2px) across the entire app.
3.  **Responsiveness:** While this is a desktop view, the 3-column stats should collapse to 1 column on mobile (`grid-cols-1 md:grid-cols-3`). The sidebar should transition to a hidden drawer on mobile.
