# Page: Admin Dashboard

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P02 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Admin Dashboard page. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | product-requirements-document.md, user-stories.md |
| **Priority** | P0 |
| **Estimated Pages** | 4–8 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / UX Designer | Initial stub |

---

## Table of Contents

- [Route & Access Control](#route--access-control)
- [Page Purpose](#page-purpose)
- [Data Fetching (API Endpoints Consumed)](#data-fetching-api-endpoints-consumed)
- [Component Breakdown](#component-breakdown)
- [UI States (Loading, Empty, Error, Success)](#ui-states-loading-empty-error-success)
- [Layout Wireframe / Mockup Reference](#layout-wireframe--mockup-reference)
- [Validation Rules](#validation-rules)
- [Navigation Flows (Entry & Exit Points)](#navigation-flows-entry--exit-points)
- [Responsive Behavior](#responsive-behavior)
- [Accessibility Notes](#accessibility-notes)

---

## Route & Access Control

| Property | Value |
|---|---|
| **URL Route** | `/dashboard` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin (full view), Receptionist (limited — today's appointments table only, no KPIs, no charts) |
| **Unauthorized Redirect** | Other roles are redirected to their respective home pages by middleware |
| **RTL Support** | Yes — full mirror when `lang=ar` |

---

## Page Purpose

The Admin Dashboard is the operational command center for clinic management. It gives the Admin a real-time, at-a-glance view of clinic performance across three layers:

1. **KPI Summary** — 8 data cards covering today's activity, monthly revenue, active staff, and outstanding financials.
2. **Trend Visualization** — 5 Recharts charts revealing patterns in revenue, appointment load, package sales, and treatment method usage.
3. **Live Activity Feed** — a real-time table of today's appointments with inline action buttons (Confirm, Complete, No-show) powered by Supabase Realtime.

The Receptionist variant omits KPI cards and charts entirely and shows only the Today's Activity Feed, making it a focused work queue rather than an analytics surface.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| KPI — Patients Today | `appointments` count where `date = today AND status != cancelled` | Page load |
| KPI — Appointments Today | `appointments` count where `date = today` | Page load |
| KPI — Total Revenue | `payments` SUM of `paid_amount` | Page load |
| KPI — Monthly Revenue | `payments` SUM of `paid_amount` where `created_at` in current month | Page load |
| KPI — Active Therapists | `profiles` count where `role = therapist AND status = active` | Page load |
| KPI — Remaining Sessions | `patient_sessions` SUM of `sessions_remaining` | Page load |
| KPI — New Patients (Month) | `patients` count where `created_at` in current month | Page load |
| KPI — Outstanding Balance | `payments` SUM of `(total_price - paid_amount)` | Page load |
| Revenue Trend | `payments` grouped by month, last 12 months | Page load |
| Appointments Bar | `appointments` count grouped by day, last 30 days | Page load |
| Package Sales Donut | `payments` grouped by package name | Page load |
| Treatment Methods HBar | `session_treatment_methods` count grouped by method | Page load |
| Today's Activity Feed | `appointments` JOIN `patients` JOIN `profiles` where `date = today` | Page load + Realtime |
| Realtime subscription | `supabase.channel('appointments').on('postgres_changes', ...)` | Mounted — live updates |

All KPI and chart queries are server-side fetched (Next.js Server Components) on initial load. The activity feed additionally subscribes to Supabase Realtime on the client for live status changes without page refresh.

---

## Component Breakdown

### KPI DataCards (8 total)

| Card | Icon (Lucide) | Value Type | Trend |
|---|---|---|---|
| Patients Today | `Users` | Integer | None |
| Appointments Today | `CalendarCheck` | Integer | vs. yesterday (arrow up/down) |
| Total Revenue | `DollarSign` | EGP formatted | None |
| Monthly Revenue | `TrendingUp` | EGP formatted | vs. last month % |
| Active Therapists | `UserCheck` | Integer | None |
| Remaining Sessions | `Activity` | Integer | None |
| New Patients (Month) | `UserPlus` | Integer | vs. last month |
| Outstanding Balance | `AlertCircle` | EGP formatted | — (always shown in amber if > 0) |

Each `<DataCard>` component:
- Container: `rounded-xl border border-slate-200 bg-white p-5 shadow-sm`
- Icon: 40×40px circle `bg-cyan-50 text-cyan-600`, Lucide icon 20px inside
- Label: Figtree 13px `text-slate-500 uppercase tracking-wide`
- Value: Figtree 700 28px `text-slate-900`
- Trend arrow: `TrendingUp` (green) / `TrendingDown` (red) + percentage label, 12px

### Charts

| Chart | Component | Config |
|---|---|---|
| Revenue Trend | `<LineChart>` Recharts | Full width, 12-month x-axis, EGP y-axis, `stroke="#0891B2"`, tooltips, dot on hover |
| Appointments Bar | `<BarChart>` Recharts | 30-day x-axis, count y-axis, `fill="#0891B2"`, responsive container |
| Package Sales Donut | `<PieChart>` Recharts | Donut (inner radius 60), legend below, 5 brand colors |
| Treatment Methods HBar | `<BarChart layout="vertical">` | Method names on y-axis, count on x-axis, sorted descending |

Charts section layout (desktop): Revenue Trend full-width row, then a 3-column grid: Appointments Bar | Package Sales Donut | Treatment Methods HBar.

### Today's Activity Feed

`<DataTable>` with columns:

| Column | Content |
|---|---|
| Time | `HH:mm` formatted appointment start time |
| Patient | Patient full name (clickable → `/patients/[id]`) |
| Therapist | Therapist name |
| Status | `<StatusBadge>` component: Pending=slate / Confirmed=cyan / Completed=green / Cancelled=red / No-show=orange |
| Actions | Inline `<Button>` set — context-sensitive per status (see User Interactions) |

Realtime updates animate new/changed rows with a 300ms `bg-cyan-50` flash using CSS transition.

---

## UI States (Loading, Empty, Error, Success)

### Loading State
On initial page load, all 8 KPI cards display a `<Skeleton>` placeholder (animated pulse, same dimensions as the card value). Charts show a `<Skeleton>` block at the correct height. The activity table shows 5 skeleton rows. Loading resolves per-section as Server Components stream in.

### Empty State — No Appointments Today
Activity Feed shows a centered illustration (calendar icon, `text-slate-300`, 64px) + text: "No appointments scheduled for today." No action CTA — the table is read-only from the dashboard.

### Empty State — No Revenue Data
Revenue Trend chart renders with empty state text inside the chart area: "No revenue data for the selected period." rendered as a Recharts `<CustomizedLabel>`.

### Error State
If a Supabase query fails, the affected card or chart displays an inline error: `<Alert variant="destructive">` with "Failed to load data. Refresh to try again." + a `<RefreshCw>` icon button. Other sections continue rendering normally (isolated error boundaries per section).

### Realtime Disconnected
A sticky banner at the top of the activity table: `bg-amber-50 text-amber-700 border-amber-200` — "Live updates paused. Reconnecting…" with a `<Loader2 animate-spin>`. Disappears when connection restores.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar Nav]   │  Dashboard                              [Profile]  │
│                 │  ─────────────────────────────────────────────     │
│  Dashboard      │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐            │
│  Patients       │  │KPI 1 │ │KPI 2 │ │KPI 3 │ │KPI 4 │            │
│  Appointments   │  └──────┘ └──────┘ └──────┘ └──────┘            │
│  Treatment Plans│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐            │
│  Payments       │  │KPI 5 │ │KPI 6 │ │KPI 7 │ │KPI 8 │            │
│  Reports        │  └──────┘ └──────┘ └──────┘ └──────┘            │
│  Settings       │                                                    │
│                 │  ┌────────────────────────────────────────────┐   │
│                 │  │          Revenue Trend (Line Chart)         │   │
│                 │  │                    12 months                │   │
│                 │  └────────────────────────────────────────────┘   │
│                 │                                                    │
│                 │  ┌──────────────┐ ┌──────────────┐ ┌──────────┐  │
│                 │  │ Appointments │ │Package Sales │ │Treatment │  │
│                 │  │  Bar Chart   │ │   Donut      │ │Methods   │  │
│                 │  │  (30 days)   │ │              │ │HBar      │  │
│                 │  └──────────────┘ └──────────────┘ └──────────┘  │
│                 │                                                    │
│                 │  Today's Activity                                  │
│                 │  ┌────┬──────────┬───────────┬────────┬────────┐  │
│                 │  │Time│ Patient  │ Therapist │ Status │Actions │  │
│                 │  ├────┼──────────┼───────────┼────────┼────────┤  │
│                 │  │9:00│ Ahmed M. │ Sara K.   │Pending │[Confirm│  │
│                 │  │    │          │           │        │][Cancel│  │
│                 │  └────┴──────────┴───────────┴────────┴────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

The dashboard is a read-only analytics surface. No form input validation applies. The only interactive inputs are the action buttons in the activity feed — these open confirmation dialogs (see Appointment Detail spec). No inline validation on this page.

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Post-login redirect for Admin role
- Sidebar "Dashboard" nav item
- Browser back navigation from any admin sub-page

### Exit Points
- Click patient name in activity feed → `/patients/[id]`
- Sidebar navigation items → respective pages
- Action buttons in activity feed → open `<AppointmentDetailSheet>` (slide-in panel, does not navigate away)
- KPI card click (optional, if implemented) → filtered list page (e.g., Patients Today → `/patients?filter=today`)

---

## Responsive Behavior

| Breakpoint | KPI Grid | Charts | Activity Table |
|---|---|---|---|
| Mobile (`< 640px`) | 1 column | Full-width stacked, charts collapsible | Horizontal scroll with sticky first column |
| Tablet (`640px–1024px`) | 2 columns | Revenue Trend full-width; other 3 charts stacked 1-col | Full width, actions in dropdown menu |
| Desktop (`> 1024px`) | 4 columns | Revenue Trend full-width; 3-col chart row | Full width table |

On mobile, KPI cards are rendered first (above the fold), charts are collapsed into an accordion ("View Analytics"), and the activity feed is the primary focus.

### Receptionist Variant (All Breakpoints)
KPI cards and all chart sections are not rendered. The page contains only the page heading "Today's Appointments" and the activity table. This keeps the page lightweight for receptionist workflows.

---

## Accessibility Notes

- Each KPI card has `role="region"` and `aria-label="[Card Name] statistic"`.
- Trend arrows have `aria-label="Increased by X%" / "Decreased by X%"` — not conveyed by color alone.
- Recharts: each chart has an `aria-label` on the `<ResponsiveContainer>` wrapper and a visually hidden `<table>` summary of the chart data for screen readers.
- Action buttons in the activity table have `aria-label="Confirm appointment for [patient name]"` etc.
- Realtime status banner has `role="status"` and `aria-live="polite"`.
- Sidebar navigation: `<nav aria-label="Main navigation">` with current page indicated via `aria-current="page"`.
- Color-coded status badges always include a text label (never color-only).

### RTL Considerations
- Sidebar moves to the right in RTL layout; main content area shifts left.
- Recharts tooltips and axis labels use `dir="rtl"` wrapper when `lang=ar`.
- EGP currency formatting: "3,000 ج.م" in Arabic locale vs "3,000 EGP" in English.
- KPI card icon remains on the right in RTL (Tailwind `rtl:flex-row-reverse`).
- Chart legends use Noto Sans Arabic for Arabic labels.

---

*DOC-06-P02 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
