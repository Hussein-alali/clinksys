# Page: Patients List

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P03 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Patients List page. |
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
| **URL Route** | `/patients` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin (all patients), Receptionist (all patients), Doctor (all patients, read-only), Therapist (assigned patients only — enforced via Supabase RLS) |
| **Unauthorized Redirect** | Patient role → `/my-appointments`; unauthenticated → `/` |
| **RLS Note** | Therapist-scoped rows are filtered server-side: `patient.assigned_therapist_id = auth.uid()`. UI does not display a filter for therapists — they see their patient subset without controls to broaden scope. |
| **RTL Support** | Yes — full layout mirror when `lang=ar` |

---

## Page Purpose

The Patients List page is the primary directory for locating and managing patient records across the clinic. It provides:

1. **Instant lookup** — debounced real-time search across full name, phone number, and file number simultaneously without a submit action.
2. **Compound filtering** — refine by patient status, assigned therapist, and registration date range to isolate specific cohorts.
3. **Navigational hub** — every row links to the patient's full profile. The role-gated "Add Patient" CTA opens the patient creation flow.
4. **Paginated browsing** — server-side pagination at 25 rows per page keeps response times fast for clinics with hundreds of patients.

This page is the standard first stop for any staff member needing to look up, verify, or act on a patient record. It must load the first page in under 1 second on a 10 Mbps connection.

---

## Data Fetching (API Endpoints Consumed)

| Data | Supabase Query | Trigger |
|---|---|---|
| Patient list (paginated) | `patients` JOIN `profiles` (therapist name) — select `id, file_number, full_name, phone, created_at, assigned_therapist_id, status` with `order by created_at desc`, `limit 25 offset (page-1)*25` | Page load, any filter/search change |
| Search | Append `.or('full_name.ilike.%q%,phone.ilike.%q%,file_number.ilike.%q%')` | 300ms debounce after keystroke |
| Status filter | Append `.eq('status', value)` | Status select change |
| Therapist filter | Append `.eq('assigned_therapist_id', value)` | Therapist select change |
| Date range | Append `.gte('created_at', from).lte('created_at', to)` | Date picker confirm |
| Row count (for pagination) | Same query with `.count('exact', { head: true })` | Same as list query |
| Therapist options (dropdown) | `profiles` where `role = therapist AND status = active`, select `id, full_name` | Page load (once, cached) |

All active filters are serialized into URL query params (`?q=&status=&therapist=&from=&to=&page=`) so state is bookmarkable, shareable, and preserved on browser back navigation.

---

## Component Breakdown

### Page Header
- `<PageHeader>`: `<h1>` "Patients" (Figtree 700 24px `text-slate-900`) + right-side `<Button>` "Add Patient" (`Plus` Lucide icon, `bg-cyan-600 hover:bg-cyan-700 text-white`, 44px height). Button is conditionally rendered for Admin and Receptionist roles only.

### Search & Filter Toolbar
- `<SearchInput>`: Shadcn `<Input>` with `Search` Lucide icon prefix (16px, `text-slate-400`), `placeholder` localized. Debounced 300ms. Shows `X` `<Button variant="ghost" size="icon">` (`XCircle` icon) when input is non-empty to clear.
- `<StatusSelect>`: Shadcn `<Select>` with options: All Statuses / Active / Discharged / On Hold. Width 160px.
- `<TherapistSelect>`: Shadcn `<Select>` dynamically populated. Hidden for Therapist role. Width 180px.
- `<DateRangePicker>`: Shadcn `<Popover>` + dual `<Calendar>` view. Displays "Registration date: from — to". Clears with a reset link inside the popover.

### Data Table
`<DataTable>` using Shadcn table primitives:

| Column | Approx. Width | Content |
|---|---|---|
| File # | 100px | `file_number` — `font-mono text-sm text-slate-500` |
| Full Name | auto | `full_name` — Figtree 500 `text-slate-900`; underline on hover |
| Phone | 130px | `phone` — always `dir="ltr"` regardless of page locale |
| Registration Date | 140px | `created_at` formatted as `DD MMM YYYY` |
| Assigned Therapist | 160px | Therapist full name, or `<span class="text-slate-400">—</span>` if none |
| Status | 110px | `<StatusBadge>`: Active = `bg-green-100 text-green-700 border-green-200` / Discharged = `bg-slate-100 text-slate-500 border-slate-200` / On Hold = `bg-yellow-100 text-yellow-700 border-yellow-200` |
| Actions | 60px | `<Button variant="ghost" size="icon">` with `Eye` Lucide icon 18px; `aria-label="View [fullName]'s profile"` |

Entire `<tr>` is interactive: `cursor-pointer hover:bg-slate-50 transition-colors`. Clicking anywhere on a row (except the explicit Actions button, which is the same destination) navigates to `/patients/[id]`.

### Pagination Strip
- "Showing 1–25 of 142 patients" — `text-sm text-slate-500`
- `<Pagination>` component: Previous button (`ChevronLeft`) / numbered pages (up to 7 shown, ellipsis for large sets) / Next button (`ChevronRight`). Current page button: `bg-cyan-600 text-white`. Disabled state: `opacity-40 cursor-not-allowed`.

---

## UI States (Loading, Empty, Error, Success)

### Loading State
Table body replaced by 8 skeleton rows. Each skeleton row contains gray animated-pulse blocks at the same column widths as the data table. The toolbar remains interactive. The row count label shows "Loading…" in `text-slate-400`.

### Empty State — No Patients Exist (Zero Records in DB)
```
        [UserPlus icon — 64px — text-slate-300]
        No patients yet.
        Start by registering your first patient.
        [+ Add Patient] (cyan button, Admin/Receptionist only)
```
Centered in the table body area, `py-16`.

### Empty State — Search/Filter Returns No Results
```
        [Search icon — 48px — text-slate-300]
        No patients found.
        Try adjusting your search or clearing filters.
        [Clear Filters] (text link, text-cyan-600)
```
"Clear Filters" resets all query params and re-fetches.

### Error State
`<Alert variant="destructive">` replaces the table body:
"Failed to load patients. Please try again." + `<Button variant="outline" size="sm">` "Retry" (`RefreshCw` icon). Page header and toolbar remain rendered.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │  Patients                              [+ Add Patient]  │
│            │  ──────────────────────────────────────────────────     │
│            │  [🔍 Search name, phone, file#...]  [Status▼][Ther.▼]  │
│            │  [📅 Registration date: from — to      ]                │
│            │  ──────────────────────────────────────────────────     │
│            │  Showing 1–25 of 142 patients                           │
│            │  ┌──────┬────────────┬──────────┬──────┬───────┬──────┐ │
│            │  │File# │ Full Name  │ Phone    │Reg.  │Therap.│Status│ │
│            │  ├──────┼────────────┼──────────┼──────┼───────┼──────┤ │
│            │  │PT-001│ Ahmed Ali  │0501234567│1 Jan │Sara K.│Active│ │
│            │  │PT-002│ Mona Hassan│0509876543│15 Jan│  —    │OnHold│ │
│            │  │PT-003│ Youssef B. │0555000111│22 Jan│Omar S.│Disch.│ │
│            │  └──────┴────────────┴──────────┴──────┴───────┴──────┘ │
│            │  [← Prev]  1  [2]  3 … 6  [Next →]                     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

No form submission exists on this page. Date range picker enforces `from ≤ to`: if the user selects an end date before the start, the picker auto-swaps values. URL query params are server-sanitized before passing to Supabase queries. Search term is trimmed and truncated to 100 characters before the query is issued.

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Sidebar "Patients" navigation item (all permitted roles)
- Post-login redirect for Doctor and Therapist roles
- "View All Patients" link from Dashboard KPI card (Admin only)
- Browser back from Patient Profile

### Exit Points
- Click table row or eye-icon → `/patients/[id]`
- Click "Add Patient" button → `/patients/new`
- Sidebar links → respective pages

---

## Responsive Behavior

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Table collapses to card list. Each patient = stacked card: Name (bold) + File# + Phone + Status badge + "View" button (full-width, ghost). Toolbar: search bar visible; other filters collapse into a bottom `<Sheet>` drawer opened by a `SlidersHorizontal` icon button. |
| Tablet (`640px–1024px`) | Table visible; Assigned Therapist and Registration Date columns hidden. Toolbar wraps to two lines. |
| Desktop (`> 1024px`) | All columns visible, single-row toolbar. |

The "Add Patient" button remains in the page header at all breakpoints. On mobile it shows icon-only (`Plus`) to preserve space, with a tooltip "Add Patient".

---

## Accessibility Notes

- `<table>` has a `<caption className="sr-only">Patient directory</caption>`.
- Row `<tr>` has `tabIndex={0}`, `role="button"`, `onKeyDown` (Enter/Space → navigate).
- `<StatusBadge>` uses both background color and text — never color alone.
- Column headers for sortable columns carry `aria-sort="ascending|descending|none"` (future sort feature).
- Search input: `aria-label="Search patients"`, `aria-controls="patients-table"`.
- Result count updates use `aria-live="polite"` on the count label so screen readers announce "Showing 1–25 of 142 patients" after filter changes.
- Pagination buttons: `aria-label="Go to page 3"`, current page: `aria-current="page"`.

### RTL Considerations
- In RTL mode the column order reverses: Actions column appears on the left, File# on the right.
- Search icon moves to the right-hand side of the input.
- "Add Patient" button appears at the left end of the page header.
- Date formatting uses `ar-EG` locale: Arabic-Indic numerals and Arabic month names.
- Phone numbers retain `dir="ltr"` inline in the RTL layout.
- StatusBadge and all labels render in Noto Sans Arabic when `lang=ar`.

---

*DOC-06-P03 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
