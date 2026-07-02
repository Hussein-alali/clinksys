# Page: Appointments Calendar

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P06 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Appointments Calendar page. |
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
| **URL Route** | `/appointments` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin (all appointments), Receptionist (all appointments), Doctor (own appointments only), Therapist (own schedule only), Patient (own appointments only) |
| **RLS Enforcement** | Doctor/Therapist/Patient rows are scoped by Supabase RLS to their own `user_id`/`patient_id`. |
| **"New Appointment" Button** | Visible to Admin and Receptionist only |
| **RTL Support** | Yes — calendar grid mirrors in RTL |

---

## Page Purpose

The Appointments Calendar provides a visual, time-based overview of all clinic appointments. It serves two distinct use cases:

1. **Scheduling overview (Admin/Receptionist)** — see the full clinic schedule, spot conflicts, confirm or cancel appointments, and create new bookings.
2. **Personal schedule view (Doctor/Therapist/Patient)** — see only their own appointments in calendar form for orientation and planning.

The page offers two views (Monthly and Day) with smooth navigation, real-time color-coded status, and a slide-in detail sheet for appointment actions — all without requiring full-page navigation.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| Monthly appointments | `appointments` WHERE `date >= first_of_month AND date <= last_of_month` JOIN `patients` (name) JOIN `profiles` (therapist initials, doctor name) | Page load, month navigation |
| Day view appointments | `appointments` WHERE `date = selected_date` (same joins) | Day view toggle or day cell click |
| Therapist filter options | `profiles` WHERE `role = therapist AND status = active` | Page load |
| Doctor filter options | `profiles` WHERE `role = doctor AND status = active` | Page load |
| Filtered appointments | Same query + `.eq('therapist_id', id)` or `.eq('doctor_id', id)` | Filter dropdown change |
| "New Appointment" form data | `patients` (searchable combobox), `profiles` (doctors + therapists) | New Appointment dialog open |
| Create appointment | INSERT into `appointments` | Form submit |

Active month/day and filters are serialized in URL params (`?month=2026-05&view=month&therapist=&doctor=`) for bookmarkability.

---

## Component Breakdown

### Calendar Header Bar
- `<Button variant="outline" size="icon">` `ChevronLeft` — previous month/day
- `<h2>` "May 2026" / "Sunday, 24 May 2026" — Figtree 700 20px `text-slate-900`
- `<Button variant="outline" size="icon">` `ChevronRight` — next month/day
- `<Button variant="outline" size="sm">` "Today" — navigates to current date, scrolls to it in day view
- View toggle: `<ToggleGroup>` — "Month" | "Day" (Shadcn). Selected = `bg-cyan-600 text-white`.
- `<Select>` Therapist filter (width 150px), `<Select>` Doctor filter (width 150px) — Admin/Receptionist only
- `<Button>` "New Appointment" (`CalendarPlus` icon, `bg-cyan-600`) — Admin/Receptionist only

### Monthly Calendar Grid
- 7-column grid (Sunday–Saturday or Saturday–Friday depending on locale/RTL).
- Day-of-week headers: abbreviated day names, `text-xs text-slate-500 uppercase`.
- Each day cell: `min-h-[80px] border border-slate-200 p-1`. Background `bg-white`, today's date: `bg-cyan-50 ring-1 ring-cyan-400`.
- Day number: `text-sm text-slate-700`, today: `text-cyan-600 font-700 rounded-full bg-cyan-100 w-6 h-6 flex items-center justify-center`.
- Days outside the current month: `bg-slate-50 text-slate-300`.
- **Appointment cards** (inside each cell):
  - `rounded px-1 py-0.5 text-xs truncate cursor-pointer`
  - Content: `[HH:mm] [Patient name truncated] · [Therapist initials]`
  - Status color left border (3px): Pending=`border-slate-400` / Confirmed=`border-cyan-500` / Completed=`border-green-500` / Cancelled=`border-red-400` / No-show=`border-orange-400`
  - Background matches status at 10% opacity.
  - If more than 3 appointments in a cell: show `+X more` link that switches to Day view for that date.
- Click on a card → opens `<AppointmentDetailSheet>` (slide-in from right, 480px)
- Click on an empty cell → if Admin/Receptionist, opens New Appointment dialog pre-filled with that date

### Day View Timeline
- Vertical timeline: 08:00–20:00, 30-minute slots, each slot = 40px height.
- Left column: time labels `text-xs text-slate-400` at each hour mark.
- Right area: appointments rendered as colored blocks at their time position, height proportional to duration (30min = 40px, 60min = 80px, etc.).
- Each block: patient name + therapist name + status badge. Background = status color at 20% opacity, left border 4px = status solid color.
- Overlapping appointments: side-by-side columns within the timeline.
- "Current time" red line indicator (today only).

### Appointment Detail Side Sheet
Implemented via Shadcn `<Sheet side="right" className="w-[480px]">`. See dedicated spec: `page-appointment-detail.md`.

### Color Legend
Fixed legend bar below the calendar header (or bottom of viewport on mobile):
`<span>` boxes: Pending (slate) / Confirmed (cyan) / Completed (green) / Cancelled (red) / No-show (orange). Each: 12×12px colored dot + label text.

---

## UI States (Loading, Empty, Error, Success)

### Loading State
Month view: calendar grid structure renders immediately with skeleton appointment cards (2–3 gray bars per day for a "busy clinic" impression). Header bar is interactive.

Day view: timeline renders immediately; appointment blocks replaced by skeleton cards.

### Empty — Month with No Appointments
Calendar grid renders normally. Cells with no appointments show no content. No special empty state (empty cells are natural). If the entire month has zero appointments, a subtle centered note: "No appointments this month" appears in the grid area.

### Empty — Day View with No Appointments
"No appointments scheduled for [Day, Date]." centered in the timeline area with a `Calendar` icon (48px, `text-slate-300`).

### Error State
`<Alert variant="destructive">` above the calendar: "Failed to load appointments. Refresh the page to try again." Calendar grid hidden, header remains.

### New Appointment — Success
Toast: "Appointment scheduled for [Date, Time]." Calendar refreshes to show the new card.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │  [<] May 2026 [>]  [Today]  [Month|Day]                 │
│            │  [Therapist▼] [Doctor▼]          [+ New Appointment]    │
│            │  ──────────────────────────────────────────────────     │
│            │  Sun   Mon   Tue   Wed   Thu   Fri   Sat                │
│            │  ┌───┬─────┬─────┬─────┬─────┬─────┬─────┐            │
│            │  │   │     │     │  1  │  2  │  3  │  4  │            │
│            │  │   │     │     │     │09:00│     │     │            │
│            │  │   │     │     │     │Ahmed│     │     │            │
│            │  ├───┼─────┼─────┼─────┼─────┼─────┼─────┤            │
│            │  │ 5 │  6  │  7  │  8  │  9  │ 10  │ 11  │            │
│            │  │   │10:00│     │09:00│     │11:00│     │            │
│            │  │   │Mona │     │Sara │     │Yous.│     │            │
│            │  └───┴─────┴─────┴─────┴─────┴─────┴─────┘            │
│            │  ● Pending  ● Confirmed  ● Completed  ● Cancelled  ● No-show │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

### New Appointment Form (Dialog)
| Field | Rule |
|---|---|
| Patient | Required, must exist in `patients` table |
| Date | Required, must not be in the past for new appointments |
| Time | Required, must be within business hours (08:00–20:00) |
| Doctor | Required, must be an active doctor |
| Therapist | Required, must be an active therapist |
| Duration | Default 60min; options: 30 / 45 / 60 / 90 min |
| Conflict check | Server validates no overlapping appointment for the same therapist at the same time slot |

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Sidebar "Appointments" nav item
- Post-login redirect for Receptionist role
- Dashboard "Appointments Today" KPI card link

### Exit Points
- Click appointment card → opens `<AppointmentDetailSheet>` (no navigation, slide-in panel)
- In sheet: "View Patient" → `/patients/[id]`
- In sheet: "View Session Log" → `/appointments/[id]/session-log`
- "New Appointment" → opens dialog (no navigation)
- Sidebar links → respective pages

---

## Responsive Behavior

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Month view: calendar grid compresses to 7 narrow columns. Appointment cards show only a colored dot (no text). Tap on dot → opens detail sheet. Day view is the recommended primary view on mobile. "Today" and view toggle are prominent in the header. Filter dropdowns move to a `<Sheet>` drawer. |
| Tablet (`640px–1024px`) | Month view shows truncated patient names in cards. Day view fully functional. Filters inline in header. |
| Desktop (`> 1024px`) | Full layout as described. Detail sheet slides in at 480px without obscuring the full calendar. |

On mobile, the default view is Day view (switched automatically for `< 640px` viewport), since the monthly grid is too dense for meaningful interaction on small screens.

---

## Accessibility Notes

- Calendar grid uses `role="grid"` with `<thead>` day-of-week headers as `role="columnheader"`.
- Each day cell: `role="gridcell"` with `aria-label="[Weekday], [Month Day Year], [N] appointments"`.
- Appointment cards: `role="button"` + `aria-label="Appointment: [patient name], [time], status: [status]"`.
- Today's date cell: `aria-current="date"`.
- Month navigation buttons: `aria-label="Previous month"` / `aria-label="Next month"`.
- View toggle: `role="group"` + `aria-label="Calendar view"`.
- Color legend items: each color swatch has `aria-hidden="true"` (decorative), with text label always visible.
- Status colors are never the sole differentiator — each card also contains status text in the detail sheet.
- Side sheet: trap focus within sheet when open; Escape closes it; focus returns to the triggering card.

### RTL Considerations
- Calendar week starts on Saturday (Arabic convention). Day column order reverses.
- Month/year display in Arabic: "مايو ٢٠٢٦" using `ar-EG` locale.
- Appointment card text right-aligned in RTL.
- Day view timeline: time labels move to right side.
- Side sheet slides in from the left in RTL (`side="left"`).
- "New Appointment" button aligns to the left in RTL header.
- Navigation chevrons swap (right chevron = previous month in RTL).

---

*DOC-06-P06 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
