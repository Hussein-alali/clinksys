# Page: Treatment Plan Detail

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P09 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Treatment Plan Detail page. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | product-requirements-document.md, user-stories.md |
| **Priority** | P1 |
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
| **URL Route** | `/treatment-plans/[id]` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin (full — edit + complete), Doctor (edit if plan is active), Therapist (view assigned plans + see session logs), Patient (view own plan — read-only via RLS) |
| **RLS Enforcement** | Supabase RLS: Therapist sees only plans where `therapist_id = auth.uid()`. Patient sees only plans where `patient_id = auth.uid()`. |
| **RTL Support** | Yes |

---

## Page Purpose

The Treatment Plan Detail page is the clinical reference document for a single treatment plan. It communicates the prescription (diagnosis, goals, methods, session targets) and tracks progress (sessions completed vs. prescribed, pain trend, individual session log history). Staff use this page to monitor adherence, review clinical progress, and formally close a plan when treatment is complete.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| Plan record | `treatment_plans` WHERE `id = [id]` JOIN `patients` (name, id) JOIN `profiles` (therapist, doctor) | Page load |
| Treatment methods | `plan_treatment_methods` JOIN `treatment_methods` WHERE `plan_id = [id]` | Page load |
| Session logs | `session_logs` WHERE `treatment_plan_id = [id]` ORDER BY `session_date asc` JOIN `profiles` (therapist) | Page load |
| Complete plan | PATCH `treatment_plans` SET `status = completed, completed_at = now()` | "Complete Plan" confirmation |
| Pain trend data | Derived from `session_logs.pain_level_before` array (client-side Recharts) | Page load |

---

## Component Breakdown

### Page Header
- Breadcrumb: "Patients → [Patient Name] → Treatment Plans → Plan #[id]"
- `<h1>` Plan title or patient name + "Treatment Plan" (e.g., "Ahmed Ali — Treatment Plan")
- `<StatusBadge>`: Active = `bg-cyan-100 text-cyan-700` / Completed = `bg-green-100 text-green-700` / Cancelled = `bg-slate-100 text-slate-500`
- "Edit" `<Button variant="outline">` (`Pencil` icon) — visible to Doctor/Admin when `status = active` → navigates to `/treatment-plans/[id]/edit`

### Progress Section
Large, prominent progress display positioned below the header:

**Option A (Linear — primary):**
- `<Progress value={pct} className="h-4 rounded-full bg-cyan-600">` — full width bar
- Below: "5 of 12 sessions completed" — Figtree 600 18px
- Below: "(7 sessions remaining)" — `text-sm text-slate-500`
- Percentage: "42%" large pill badge to the right

**Option B (Circular — secondary, shown on desktop alongside linear):**
- `<svg>` circular progress ring (SVG stroke-dashoffset technique), 80×80px, stroke `#0891B2`
- Center text: "5/12" Figtree 700 16px

### Info Cards Row
4 `<Card>` info cards in a `grid grid-cols-2 gap-4` (desktop: 4 cols):

| Card | Icon | Content |
|---|---|---|
| Diagnosis | `Stethoscope` | Diagnosis text (truncated to 3 lines, expand link) |
| Goals | `Target` | Goals text (truncated, expand link) |
| Assigned Therapist | `User` | Therapist name |
| Date Range | `Calendar` | "DD MMM YYYY → DD MMM YYYY" or "Start: DD MMM YYYY (no end date)" |

Notes card (full width, if notes exist): `<Card>` with `FileText` icon + notes text.

### Treatment Methods Section
Section heading: "Treatment Methods" with method count badge.

Methods displayed as `<Badge variant="outline">` chips in a flex-wrap row. Each chip: `[category color border] [method name] — [duration]`. Category color coding:
- Manual Therapy: teal border
- Electrotherapy: blue border
- Exercise Therapy: green border
- Hydrotherapy: cyan border
- Other: slate border

### Session History Table
Section heading: "Session History" + "(5 sessions)" count. Table:

| Column | Content |
|---|---|
| # | Session number (1, 2, 3…) |
| Date | `DD MMM YYYY` |
| Pain Before → After | "7 → 4" with `TrendingDown` green icon (if after < before) or `TrendingUp` red icon (if after > before) |
| Progress | `<Badge>`: Improved (green) / Same (yellow) / Declined (orange) / Completed (teal) |
| Therapist | Therapist name |
| Actions | `<Button variant="ghost" size="icon">` `Eye` → `/appointments/[appointmentId]/session-log` |

Table: 10 rows per page, sorted ascending by session number.

### Pain Trend Mini-Chart
Below the session table, a Recharts `<LineChart>`:
- x-axis: session number (1, 2, 3…)
- y-axis: pain level (0–10)
- One line: `pain_level_before` (`stroke="#EF4444"`, label "Pain Before")
- Optional second line: `pain_level_after` (`stroke="#22C55E"`, label "Pain After")
- Dots on each data point, tooltips on hover
- Height: 160px, full width
- Title: "Pain Level Trend" `text-sm text-slate-600`

### Complete Plan Button
Shown only when `status = active` and role = Admin. Positioned at the bottom of the page or in the page header action area:
`<Button variant="outline" className="border-green-500 text-green-600 hover:bg-green-50">` `CheckCircle` icon + "Complete Treatment Plan"

Click → `<AlertDialog>`: "Mark this treatment plan as completed? This action cannot be undone." → [Cancel] [Complete Plan] (green button).

---

## UI States (Loading, Empty, Error, Success)

### Page Load — Loading
Full-page skeleton: header skeleton, progress bar skeleton (gray bar), 4 info card skeletons, methods section skeleton (3 placeholder chips), session table skeleton (5 rows).

### Empty Session History
"No sessions have been logged for this plan yet." with `Activity` icon (48px, `text-slate-300`).

### Pain Trend — Insufficient Data
If fewer than 2 session logs exist, chart is replaced with: "Pain trend will appear after 2 or more sessions are logged." (`text-sm text-slate-400` centered).

### Complete Plan — Loading
Alert dialog "Complete Plan" button shows `<Loader2 animate-spin>`. Dialog cannot be closed during request.

### Complete Plan — Success
Dialog closes. Status badge updates to "Completed" (green). "Edit" and "Complete Plan" buttons disappear. Toast: "Treatment plan marked as completed."

### Error State
`<Alert variant="destructive">` at page top: "Failed to load treatment plan." + "Retry" button.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar] │  Patients > Ahmed Ali > Treatment Plans  [● Active][Edit]│
│           │  ────────────────────────────────────────────────────    │
│           │  Progress                                                 │
│           │  ████████████░░░░░░░░░░  5 of 12 sessions  42%           │
│           │  (7 sessions remaining)                                   │
│           │  ────────────────────────────────────────────────────    │
│           │  ┌────────────┐ ┌────────────┐ ┌────────┐ ┌──────────┐  │
│           │  │Diagnosis   │ │Goals       │ │Therapis│ │Date Range│  │
│           │  │Lower back  │ │Reduce pain │ │Sara K. │ │1 May —   │  │
│           │  │disc hernia │ │to < 3/10   │ │        │ │1 Aug 26  │  │
│           │  └────────────┘ └────────────┘ └────────┘ └──────────┘  │
│           │  ────────────────────────────────────────────────────    │
│           │  Treatment Methods (4)                                    │
│           │  [TENS] [Manual Therapy] [Exercise] [Ultrasound]         │
│           │  ────────────────────────────────────────────────────    │
│           │  Session History (5)                                      │
│           │  # │ Date    │ Pain    │ Progress  │ Therapist │ Actions  │
│           │  1 │ 1 May   │ 8 → 6  │ Improved  │ Sara K.   │ [View]  │
│           │  ────────────────────────────────────────────────────    │
│           │  Pain Level Trend  [LineChart]                            │
│           │                                                           │
│           │                        [Complete Treatment Plan]          │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

No form input on this page in view mode. The "Complete Plan" action requires only a confirmation click (no text input). The Edit page (`/treatment-plans/[id]/edit`) carries its own validation (same rules as create).

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Patient Profile → Treatment Plans tab → "View Plan" button
- Direct URL `/treatment-plans/[id]`
- Session Log → breadcrumb back to plan
- Treatment Plans list (if implemented)

### Exit Points
- Breadcrumb "← [Patient Name]" → `/patients/[id]`
- Session Actions "View" → `/appointments/[appointmentId]/session-log`
- "Edit" button → `/treatment-plans/[id]/edit`
- Patient name link → `/patients/[id]`
- Sidebar links → respective pages

---

## Responsive Behavior

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Info cards: 2×2 grid. Progress section full-width. Methods chips wrap. Session table: horizontal scroll or simplified card list (Date + Pain + Progress only). Chart full-width, 120px height. |
| Tablet (`640px–1024px`) | Info cards 2×2 grid. Session table full columns. Chart full-width. |
| Desktop (`> 1024px`) | Info cards 4-column row. All columns visible. |

---

## Accessibility Notes

- Progress bar: `<progress value={5} max={12} aria-label="5 of 12 sessions completed">`. Linear progress `role="progressbar"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, `aria-valuetext="5 of 12 sessions completed"`.
- Info cards: each `<Card>` has `role="region"` + `aria-label="[Card Title]"`.
- Treatment method chips: `aria-label="[Method name], [duration], [category]"`.
- Session table: `<caption className="sr-only">Session history for this treatment plan</caption>`.
- Pain icons (`TrendingUp`/`TrendingDown`): `aria-label="Pain increased" / "Pain decreased"` — not conveyed by icon alone.
- Pain trend chart: visually hidden `<table>` with session number and pain values as fallback for screen readers.
- "Complete Plan" button: `aria-label="Complete this treatment plan (irreversible)"`.
- AlertDialog for completion: `aria-modal="true"`, focus trapped.

### RTL Considerations
- Progress bar fills from right to left in RTL (CSS `direction: rtl` on the progress container).
- Info cards grid: same structure but text right-aligned.
- Methods chips wrap from right.
- Session table: columns mirror (# on right, Actions on left).
- Pain trend chart: x-axis numbers use Arabic-Indic numerals in `ar-EG` locale.
- Breadcrumb separators reverse direction.

---

*DOC-06-P09 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
