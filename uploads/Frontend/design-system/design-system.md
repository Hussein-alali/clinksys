# Design System

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-DS1 |
| **Version** | 1.0 — Complete |
| **Status** | Review |
| **Date** | 2026-05-24 |
| **Purpose** | Single source of truth for all visual design decisions. |
| **Owner** | UX Designer / Frontend Engineer |
| **Dependencies** | personas.md |
| **Priority** | P1 |
| **Estimated Pages** | 20–35 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | UX Designer / Frontend Engineer | Initial stub |
| 1.0 | 2026-05-24 | UX Designer / Frontend Engineer | Full content added |

---

## Table of Contents

- [Design Philosophy](#design-philosophy)
- [Design Tokens](#design-tokens)
- [Color Palette (Brand, Semantic, Neutral, Status)](#color-palette-brand-semantic-neutral-status)
- [Typography Scale](#typography-scale)
- [Spacing System (4px Grid)](#spacing-system-4px-grid)
- [Grid System (12-column)](#grid-system-12-column)
- [Elevation / Shadow System](#elevation--shadow-system)
- [Border Radius Scale](#border-radius-scale)
- [Icon Library Reference](#icon-library-reference)
- [Motion & Animation Guidelines](#motion--animation-guidelines)

---

## Design Philosophy

The PTCMS design system is built on the **Accessible & Ethical** style — a medical-grade interface philosophy that prioritizes clarity, trust, and operational efficiency. Clinical staff use this system under time pressure and in high-stakes environments. Every design decision must reduce cognitive load and prevent errors.

### Core Principles

| Principle | Description | Applied As |
|---|---|---|
| **Trust First** | The interface must project clinical professionalism and reliability. | Clean whites, medical teal (#0891B2), slate neutrals. No neon, no gradient excess. |
| **Clarity Over Decoration** | Decoration exists only when it communicates. Never for aesthetics alone. | Minimal shadows, purposeful icons, generous whitespace. |
| **Efficiency** | Critical workflows (register patient, book appointment, log session) must be completable in ≤ 4 clicks or taps. | Streamlined forms, inline validation, contextual action menus. |
| **Accessibility** | The system serves patients and clinical staff across age groups and ability levels. Accessibility is a safety requirement, not a feature. | WCAG AAA for patient-critical data. WCAG AA universal minimum. |
| **Error Prevention** | In a medical context, errors can have real consequences. The UI must prevent mistakes before they happen. | Inline Zod validation, confirmation dialogs for destructive actions, read-only summary steps. |
| **Bilingual Parity** | Arabic and English are first-class citizens. RTL layout is not an afterthought. | Logical CSS properties, Noto Sans Arabic, full RTL mirror of every page. |

### Anti-Patterns

The following patterns are explicitly banned in PTCMS:

- Bright neon colors or AI-style purple/pink gradients
- Heavy motion or continuous animations that distract clinical focus
- Color-only status communication (always pair with icon + text)
- Hover-only interactions (must also be keyboard and touch accessible)
- Generic error messages ("Invalid input") without specific guidance

---

## Design Tokens

Design tokens are the single source of truth for visual properties. They are defined as CSS custom properties in `globals.css` and referenced via Tailwind CSS utilities throughout the application. This approach ensures all components stay in sync when a token value changes.

### Token Architecture

```
globals.css (CSS Custom Properties)
  └── tailwind.config.ts (maps tokens to Tailwind classes)
      └── Components (consume via Tailwind utility classes)
```

### Full Token Reference (`globals.css`)

```css
/* ============================================
   PTCMS Design Tokens — globals.css
   ============================================ */

:root {
  /* --- Primary Brand --- */
  --primary: 199 89% 48%;              /* #0891B2  cyan-600 */
  --primary-foreground: 0 0% 100%;     /* #FFFFFF  white */
  --primary-hover: 200 98% 39%;        /* #0E7490  cyan-700 */

  /* --- Success --- */
  --success: 142 71% 45%;              /* #22C55E  green-500 */
  --success-foreground: 0 0% 100%;     /* #FFFFFF */
  --success-muted: 141 79% 85%;        /* #BBF7D0  green-200 */

  /* --- Backgrounds & Surfaces --- */
  --background: 0 0% 100%;             /* #FFFFFF */
  --card: 0 0% 100%;                   /* #FFFFFF */
  --popover: 0 0% 100%;               /* #FFFFFF */
  --app-bg: 210 40% 98%;              /* #F8FAFC  slate-50 */

  /* --- Foreground (Text) --- */
  --foreground: 222 47% 11%;           /* #0F172A  slate-900 */
  --card-foreground: 222 47% 11%;      /* #0F172A */
  --popover-foreground: 222 47% 11%;   /* #0F172A */

  /* --- Muted --- */
  --muted: 215 16% 47%;               /* #475569  slate-600 */
  --muted-foreground: 215 16% 47%;    /* #475569 */
  --muted-bg: 214 32% 91%;           /* #E2E8F0  slate-200 */

  /* --- Border --- */
  --border: 213 27% 84%;              /* #CBD5E1  slate-300 */
  --input: 213 27% 84%;               /* #CBD5E1 */
  --ring: 199 89% 48%;               /* #0891B2  matches primary */

  /* --- Destructive --- */
  --destructive: 0 84% 60%;           /* #EF4444  red-500 */
  --destructive-foreground: 0 0% 100%;/* #FFFFFF */

  /* --- Status Colors --- */
  --status-confirmed: 221 83% 53%;    /* #2563EB  blue-600 */
  --status-completed: 142 71% 45%;    /* #22C55E  green-500 */
  --status-cancelled: 347 77% 50%;    /* #E11D48  rose-600 */
  --status-no-show: 25 95% 53%;       /* #F97316  orange-500 */
  --status-pending: 215 16% 47%;      /* #475569  slate-600 */

  /* --- Typography --- */
  --font-sans: var(--font-noto-sans), 'Noto Sans', system-ui, sans-serif;
  --font-heading: var(--font-figtree), 'Figtree', system-ui, sans-serif;
  --font-arabic: var(--font-noto-sans), 'Noto Sans Arabic', sans-serif;

  /* --- Border Radius --- */
  --radius: 0.5rem;                   /* 8px — default (inputs, buttons) */
  --radius-sm: 0.25rem;               /* 4px */
  --radius-md: 0.5rem;                /* 8px */
  --radius-lg: 0.75rem;               /* 12px — cards */
  --radius-full: 9999px;              /* pills, badges, avatars */

  /* --- Shadows --- */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.10);
  --shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.10);

  /* --- Transitions --- */
  --transition-fast: 150ms ease-in-out;
  --transition-normal: 200ms ease-in-out;
  --transition-slow: 300ms ease-in-out;
}
```

---

## Color Palette (Brand, Semantic, Neutral, Status)

### Brand Palette

| Token | Hex | Tailwind | HSL | Role |
|---|---|---|---|---|
| `--primary` | `#0891B2` | `cyan-600` | `199 89% 48%` | Primary actions, links, focus rings, active nav |
| `--primary-hover` | `#0E7490` | `cyan-700` | `200 98% 39%` | Hover state for primary buttons |
| Primary Light | `#ECFEFF` | `cyan-50` | — | Badge backgrounds, form hints, highlighted rows |
| Primary Dark | `#164E63` | `cyan-900` | — | High-contrast headings on light backgrounds |

### Semantic Colors

| Token | Hex | Tailwind | Role |
|---|---|---|---|
| `--success` | `#22C55E` | `green-500` | Success toasts, paid status, completed status |
| Success Muted | `#F0FDF4` | `green-50` | Success badge background |
| `--destructive` | `#EF4444` | `red-500` | Error states, delete actions, validation errors |
| Destructive Muted | `#FEF2F2` | `red-50` | Error banner background |
| Warning | `#F59E0B` | `amber-500` | Warning toasts, partial payment, near-expiry |
| Warning Muted | `#FFFBEB` | `amber-50` | Warning banner background |
| Info | `#3B82F6` | `blue-500` | Info toasts, confirmed status |
| Info Muted | `#EFF6FF` | `blue-50` | Info badge background |

### Neutral Palette

| Token | Hex | Tailwind | Role |
|---|---|---|---|
| `--foreground` | `#0F172A` | `slate-900` | Primary text, headings |
| `#1E293B` | `#1E293B` | `slate-800` | Secondary headings |
| `#334155` | `#334155` | `slate-700` | Body text |
| `--muted` | `#475569` | `slate-600` | Muted text, captions, table headers |
| `#64748B` | `#64748B` | `slate-500` | Placeholder text |
| `#94A3B8` | `#94A3B8` | `slate-400` | Disabled text (only use with dark bg for contrast) |
| `--border` | `#CBD5E1` | `slate-300` | Default borders, dividers |
| `#E2E8F0` | `#E2E8F0` | `slate-200` | Subtle borders, row stripes |
| `#F1F5F9` | `#F1F5F9` | `slate-100` | Hover backgrounds |
| `--app-bg` | `#F8FAFC` | `slate-50` | Application background |
| `--background` | `#FFFFFF` | white | Cards, modals, inputs |

### Status Color Map

| Status | Text Color | Background | Border | Hex Text |
|---|---|---|---|---|
| Completed / Paid | `green-800` | `green-50` | `green-200` | `#166534` on `#F0FDF4` |
| Confirmed | `blue-700` | `blue-50` | `blue-200` | `#1D4ED8` on `#EFF6FF` |
| Scheduled / Pending | `slate-700` | `slate-50` | `slate-200` | `#374151` on `#F9FAFB` |
| Cancelled | `rose-800` | `rose-50` | `rose-200` | `#9F1239` on `#FFF1F2` |
| No-show | `orange-800` | `orange-50` | `orange-200` | `#9A3412` on `#FFF7ED` |
| Partial | `yellow-800` | `yellow-50` | `yellow-200` | `#854D0E` on `#FEFCE8` |
| Overdue | `red-800` | `red-50` | `red-200` | `#991B1B` on `#FEF2F2` |

**Rule**: Status must never be communicated by color alone. Every status badge includes an icon and a text label.

---

## Typography Scale

### Font Families

| Role | Font | Weights | Fallback |
|---|---|---|---|
| Headings (Latin) | Figtree | 400, 500, 600, 700 | `system-ui, sans-serif` |
| Body (Latin) | Noto Sans | 400, 500, 700 | `system-ui, sans-serif` |
| Arabic (All text) | Noto Sans Arabic | 400, 500, 700 | `sans-serif` |
| Numbers / Codes | Noto Sans (ltr override) | 400, 600 | `monospace` fallback for codes |

**Loading**: Both fonts are loaded via `next/font/google` and self-hosted in the Next.js build for performance and privacy compliance.

### Type Scale

| Token | Size | Line Height | Weight | Tailwind | Usage |
|---|---|---|---|---|---|
| `xs` | 12px | 1.5 (18px) | 400 | `text-xs` | Timestamps, captions, badge labels |
| `sm` | 14px | 1.5 (21px) | 400–500 | `text-sm` | Table cells, helper text, secondary labels |
| `base` | 16px | 1.75 (28px) | 400 | `text-base` | Body text, form inputs, descriptions |
| `lg` | 18px | 1.75 (31.5px) | 500–600 | `text-lg` | Section subheadings, card titles (desktop) |
| `xl` | 20px | 1.5 (30px) | 600 | `text-xl` | Page titles (mobile), section headings |
| `2xl` | 24px | 1.4 (33.6px) | 600–700 | `text-2xl` | Page titles (tablet) |
| `3xl` | 30px | 1.3 (39px) | 700 | `text-3xl` | Page titles (desktop), KPI values (mobile) |
| `4xl` | 36px | 1.25 (45px) | 700 | `text-4xl` | KPI values (desktop), display numbers |
| `5xl` | 48px | 1.2 (57.6px) | 700 | `text-5xl` | Hero/display usage only |

### Heading Hierarchy

```
h1 — text-xl md:text-2xl lg:text-3xl font-bold font-heading
h2 — text-lg md:text-xl font-semibold font-heading
h3 — text-base md:text-lg font-semibold font-heading
h4 — text-sm md:text-base font-semibold
```

**Rule**: Only one `<h1>` per page. Never skip heading levels. Heading hierarchy must match DOM order.

### Arabic Typography

Arabic text uses Noto Sans Arabic at the same scale. Key adjustments:

- Line height for Arabic is increased by 0.15 to accommodate Arabic character ascenders: `leading-[1.9]` for body text.
- Arabic numerals in clinical contexts (dates, file numbers, phone numbers) use Western Arabic numerals (`0–9`), not Eastern Arabic (`٠–٩`), for consistency with international standards.
- The `dir="rtl"` attribute on `<html>` handles text alignment automatically.

---

## Spacing System (4px Grid)

All spacing in PTCMS uses the Tailwind default 4px base grid. This ensures visual rhythm and alignment consistency across all components.

### Spacing Scale Reference

| Tailwind Class | Pixels | Rem | Common Use |
|---|---|---|---|
| `space-1` / `p-1` | 4px | 0.25rem | Icon padding, tight gap between related elements |
| `space-2` / `p-2` | 8px | 0.5rem | Button internal padding (sm), badge padding |
| `space-3` / `p-3` | 12px | 0.75rem | Card inner padding (compact) |
| `space-4` / `p-4` | 16px | 1rem | Standard form field spacing, card padding (mobile) |
| `space-5` / `p-5` | 20px | 1.25rem | Section separation within cards |
| `space-6` / `p-6` | 24px | 1.5rem | Card padding (desktop), section spacing |
| `space-8` / `p-8` | 32px | 2rem | Page content padding, major section gaps |
| `space-10` / `p-10` | 40px | 2.5rem | Large section separation |
| `space-12` / `p-12` | 48px | 3rem | Page-level vertical rhythm |
| `space-16` / `p-16` | 64px | 4rem | Full-page section separation |

### Component Spacing Conventions

| Context | Spacing |
|---|---|
| Between form fields | `space-y-4` (16px) |
| Between form sections | `space-y-6` (24px) |
| Card content padding | `p-4` mobile, `p-6` desktop |
| Between cards in a grid | `gap-4` (16px) |
| Between table rows | Built into TableRow — `h-14` minimum |
| Sidebar nav item padding | `px-3 py-2` |
| Page content horizontal padding | `px-4 md:px-6 lg:px-8` |
| Top bar height | `h-16` (64px) |
| Sidebar width (expanded) | `w-60` (240px) |
| Sidebar width (rail) | `w-16` (64px) |

---

## Grid System (12-column)

PTCMS uses a 12-column grid system implemented via Tailwind CSS grid utilities. All grid containers use `gap-4` (16px) as the default gutter.

### Page Layout Grid

```tsx
{/* Main content area — responsive grid */}
<div className="grid grid-cols-12 gap-4 lg:gap-6">
  {/* Full-width section */}
  <section className="col-span-12">...</section>

  {/* Two-thirds / one-third split */}
  <main className="col-span-12 lg:col-span-8">...</main>
  <aside className="col-span-12 lg:col-span-4">...</aside>

  {/* Three equal columns */}
  <div className="col-span-12 md:col-span-6 lg:col-span-4">...</div>
  <div className="col-span-12 md:col-span-6 lg:col-span-4">...</div>
  <div className="col-span-12 md:col-span-12 lg:col-span-4">...</div>
</div>
```

### Form Grid

| Screen | Columns | Tailwind |
|---|---|---|
| Mobile (default) | 1 | `grid-cols-1` |
| Tablet (md) | 2 | `md:grid-cols-2` |
| Desktop (lg) | 2 (standard) or 3 (date+time groups) | `lg:grid-cols-2` or `lg:grid-cols-3` |

### KPI Cards Grid

```tsx
<div className="grid grid-cols-2 md:grid-cols-4 gap-4">
  <DataCard ... />
  <DataCard ... />
  <DataCard ... />
  <DataCard ... />
</div>
```

### Charts Grid

```tsx
<div className="grid grid-cols-1 gap-4">
  {/* Revenue Trend — always full width */}
  <RevenueTrendChart />
</div>
<div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
  <AppointmentStatusChart />
  <SessionProgressChart />
  <PaymentSummaryChart />
</div>
```

---

## Elevation / Shadow System

Shadows communicate depth and hierarchy. PTCMS uses a minimal 4-level shadow scale.

| Level | CSS Value | Tailwind | Applied To |
|---|---|---|---|
| `sm` | `0 1px 2px rgba(0,0,0,0.05)` | `shadow-sm` | Table rows on hover, subtle input focus glow |
| `md` | `0 4px 6px rgba(0,0,0,0.07)` | `shadow-md` | Cards (default), dropdowns, popovers |
| `lg` | `0 10px 15px rgba(0,0,0,0.10)` | `shadow-lg` | Modals/dialogs, sheets, elevated dropdowns |
| `xl` | `0 20px 25px rgba(0,0,0,0.10)` | `shadow-xl` | Command palette, full-screen overlays |

### Shadow Rules

- Cards: always `shadow-md` (not `shadow-lg` — cards are not floating elements).
- Modals: `shadow-lg`.
- Buttons: no shadow (flat design — rely on background color for differentiation).
- Table: no shadow on the table itself; individual row hover uses `shadow-sm` on the row.
- Sidebar: `shadow-lg` only when shown as an overlay on mobile.

### Z-Index Scale

| Layer | Z-Index | Elements |
|---|---|---|
| Base content | `z-0` | Page content, cards, tables |
| Sticky header | `z-10` | Table sort headers (sticky top) |
| Sidebar | `z-20` | Fixed sidebar on desktop |
| Dropdown / Popover | `z-30` | DropdownMenu, Popover, Combobox |
| Modal backdrop | `z-40` | Dialog/Sheet backdrop |
| Modal content | `z-50` | Dialog, Sheet, AlertDialog |
| Toast | `z-[100]` | Sonner toast notifications |

---

## Border Radius Scale

| Token | Value | Tailwind | Applied To |
|---|---|---|---|
| `none` | 0px | `rounded-none` | Tables (cells have no radius), dividers |
| `sm` | 4px | `rounded-sm` | Badges in tables, tight indicators |
| `md` (default) | 8px | `rounded-md` | Form inputs, buttons, select triggers |
| `lg` | 12px | `rounded-lg` | Cards, dialogs, sheets, filter panels |
| `xl` | 16px | `rounded-xl` | Large feature cards (rare — confirm with designer) |
| `full` | 9999px | `rounded-full` | Avatars, pill badges, status badges |

**Rules**:
- Inputs: `rounded-md` (8px).
- Buttons: `rounded-md` (8px) — matches inputs for visual alignment in forms.
- Cards: `rounded-lg` (12px).
- Badges: `rounded-full` (pill shape).
- Avatars: `rounded-full`.

---

## Icon Library Reference

PTCMS uses **Lucide React** exclusively for all icons. No other icon sets are permitted.

**Import**

```tsx
import { Users, Calendar, ClipboardList, CreditCard } from 'lucide-react';
```

**Standard Sizes**

| Context | Size | Tailwind |
|---|---|---|
| Button icon (default) | 16×16px | `h-4 w-4` |
| Button icon (lg button) | 20×20px | `h-5 w-5` |
| Sidebar nav icon | 20×20px | `h-5 w-5` |
| Bottom nav icon | 24×24px | `h-6 w-6` |
| DataCard icon | 24×24px | `h-6 w-6` |
| Status badge icon | 12×12px | `h-3 w-3` |
| Toast icon | 16×16px | `h-4 w-4` |
| Empty state illustration | 48×48px | `h-12 w-12` |

### Icon Usage Rules

1. All decorative icons (inside buttons with text, inside badges) must have `aria-hidden="true"`.
2. Icon-only buttons must have `aria-label` describing the action.
3. Do not use emojis as icons. Use Lucide icons only.
4. Icons do not flip in RTL (e.g., a right-pointing chevron stays right-pointing in RTL). This is correct behavior for most icons. Exception: text-direction arrows and quote icons may need manual RTL flip.

### Icon Catalog by Module

| Module | Icon | Lucide Name |
|---|---|---|
| Dashboard | `LayoutDashboard` | Home overview |
| Patients | `Users` | Patient list |
| Appointments | `Calendar` | Appointment calendar |
| Treatment Plans | `ClipboardList` | Clinical plans |
| Session Log | `ActivitySquare` | Session tracking |
| Payments | `CreditCard` | Payment records |
| Invoices | `FileText` | Invoice documents |
| Reports | `BarChart2` | Analytics |
| Settings | `Settings` | System config |
| Campaigns | `Megaphone` | Marketing |
| Add/Create | `Plus` | Create action |
| Edit | `Pencil` | Edit action |
| Delete/Remove | `Trash2` | Destructive action |
| View | `Eye` | View/open |
| Search | `Search` | Search fields |
| Filter | `Filter` | Filter panels |
| Download | `Download` | Export/PDF download |
| Upload | `Upload` | File upload |
| Phone | `Phone` | Phone numbers |
| Email | `Mail` | Email fields |
| Date/Calendar | `CalendarDays` | Date inputs |
| Time | `Clock` | Time inputs |
| Payment Method | `Banknote` | Cash; `CreditCard` visa |

---

## Motion & Animation Guidelines

### Philosophy

PTCMS uses minimal, purposeful motion. Animations exist only to:
1. Orient the user (where did this element come from / go to?).
2. Indicate system state (loading, saving, success).
3. Provide feedback (button pressed, item selected).

Heavy animations, auto-playing videos, and decorative carousels are never used.

### Duration Scale

| Name | Duration | Easing | Use Case |
|---|---|---|---|
| `fast` | 150ms | `ease-in-out` | Hover state transitions (background color, border color) |
| `normal` | 200ms | `ease-in-out` | Component enter/exit (fade-in, slide-up, scale) |
| `slow` | 300ms | `ease-in-out` | Modal and sheet open/close |

**Rule**: Always animate `transform` and `opacity`. Never animate `width`, `height`, `top`, `left`, or layout-affecting properties — these trigger layout recalculation and cause jank.

### Named Animations

```css
/* In globals.css */

/* Skeleton shimmer */
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
.animate-shimmer {
  background: linear-gradient(90deg, #E2E8F0 25%, #F1F5F9 50%, #E2E8F0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s linear infinite;
}

/* Fade in */
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}
.animate-fade-in {
  animation: fade-in 200ms ease-in-out forwards;
}

/* Slide up (for modals, toasts, popovers entering from below) */
@keyframes slide-up {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-slide-up {
  animation: slide-up 200ms ease-in-out forwards;
}
```

### Reduced Motion

Respect users who have configured `prefers-reduced-motion: reduce` in their OS settings:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

This is required in `globals.css`. No exceptions.

### Loading Spinner

```tsx
{/* Used inside buttons and data-loading states */}
<Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
```

The `animate-spin` class from Tailwind provides a 1s linear infinite rotation. This does NOT fall under the reduced-motion rule (it is a functional indicator, not decorative motion), but its speed should not cause distress — the 1s spin rate is intentionally slow.

---

*DOC-06-DS1 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*
