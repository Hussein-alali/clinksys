# Page: Patient Profile

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P04 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Patient Profile page. |
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
| **URL Route** | `/patients/[id]` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin (full edit), Receptionist (edit personal info only), Doctor (edit medical info), Therapist (view assigned patients + log sessions), Patient (own profile — read-only, scoped via RLS) |
| **RLS Enforcement** | Supabase RLS ensures: Therapists can only select rows where `assigned_therapist_id = auth.uid()`. Patient role can only select their own row. |
| **RTL Support** | Yes — all 7 tabs and content sections mirror in RTL |

---

## Page Purpose

The Patient Profile is the single source of truth for all information related to a patient. It consolidates personal demographics, medical history, appointment history, active and historical treatment plans, session progress, payment records, and uploaded documents into a unified, tabbed interface. Staff can access, edit (role-permitting), and act on all patient information from this page without navigating away.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| Patient core record | `patients` WHERE `id = [id]` JOIN `profiles` (therapist, doctor) | Page load |
| Personal info | Included in patient record | Page load |
| Medical info | `patient_medical_info` WHERE `patient_id = [id]` | Personal/Medical tab render |
| Appointments | `appointments` WHERE `patient_id = [id]` ORDER BY `date desc` | Appointments tab render |
| Treatment plans | `treatment_plans` WHERE `patient_id = [id]` JOIN `plan_methods` JOIN `treatment_methods` | Treatment Plans tab render |
| Session logs | `session_logs` WHERE `patient_id = [id]` ORDER BY `session_date desc` JOIN `appointments` | Sessions tab render |
| Payments | `payments` WHERE `patient_id = [id]` ORDER BY `created_at desc` JOIN `packages` JOIN `invoices` | Payments tab render |
| Documents | `patient_documents` WHERE `patient_id = [id]` | Documents tab render |
| Signed URLs (docs) | `supabase.storage.from('patient-docs').createSignedUrl(path, 3600)` | On view/download click |

Tabs use lazy loading — data for a tab is only fetched when that tab is first activated, then cached for the session duration.

---

## Component Breakdown

### Sticky Profile Header
- `<Avatar>`: 72×72px circular image (patient photo) or initials fallback (`bg-cyan-100 text-cyan-700`, Figtree 700 28px). `object-cover`.
- Patient full name: Figtree 700 22px `text-slate-900`
- File number: `text-sm text-slate-500 font-mono`
- `<StatusBadge>`: Active / Discharged / On Hold (same color scheme as Patients List)
- `<Button>` "Edit": shown only to authorized roles (Admin, Receptionist, Doctor depending on active tab). `Pencil` Lucide icon. Clicking switches the active tab to edit mode.
- On scroll, the header compresses to a slim bar (64px) showing only name + status badge + edit button (using `position: sticky top-0`).

### Tab Navigation
Horizontal scrollable `<Tabs>` (Shadcn) — 7 tabs. On mobile, tabs are scrollable horizontally with a fade mask on the right edge.

| Tab Index | Label (EN) | Label (AR) | Icon |
|---|---|---|---|
| 1 | Personal Info | المعلومات الشخصية | `User` |
| 2 | Medical Info | المعلومات الطبية | `Stethoscope` |
| 3 | Appointments | المواعيد | `Calendar` |
| 4 | Treatment Plans | خطط العلاج | `ClipboardList` |
| 5 | Sessions | الجلسات | `Activity` |
| 6 | Payments | المدفوعات | `CreditCard` |
| 7 | Documents | الوثائق | `FileText` |

Active tab: `border-b-2 border-cyan-600 text-cyan-600`. Inactive: `text-slate-500 hover:text-slate-700`.

### Tab 1 — Personal Info
Two-column grid (`grid-cols-2 gap-4` on desktop, `grid-cols-1` on mobile). Each field: label (`text-xs text-slate-500 uppercase`) above value (`text-sm text-slate-900`). Fields: Full Name, Phone, Date of Birth, Age (calculated), Gender, Address, Job, How Heard About Us, Registration Date, Assigned Therapist.

Edit mode (Admin/Receptionist): fields become inline `<Input>` / `<Select>` components. "Save Changes" and "Cancel" buttons appear at the bottom of the section. Uses React Hook Form + Zod.

### Tab 2 — Medical Info
Fields: Diagnosis (editable by Doctor/Admin), Chief Complaint, Chronic Diseases, Previous Surgeries. In view mode: each field in a `<Card>` with label + text value. In edit mode: `<Textarea>` components with character counts.

### Tab 3 — Appointments
`<DataTable>` of all appointments for this patient. Columns: Date | Time | Doctor | Therapist | Status (StatusBadge) | Actions (link to appointment detail side sheet). Sorted newest-first. Paginated at 10 rows. Inline "New Appointment" button in table header (Admin/Receptionist only).

### Tab 4 — Treatment Plans
`<Accordion>` — active plan first (expanded by default), historical plans collapsed below. Each plan accordion item contains:
- Plan header: status badge + date range + "X of Y sessions completed"
- `<Progress>` bar: `value={(sessions_completed/sessions_prescribed)*100}`, `className="bg-cyan-600"`, height 8px
- Treatment methods: chips (`<Badge variant="outline">` per method, category color border)
- "View Plan" button → `/treatment-plans/[planId]`

### Tab 5 — Sessions
Vertical timeline of session logs. Each entry: left dot (color = progress assessment color) + date + therapist name + pain before/after values + progress assessment badge. At the top, a mini Recharts `<LineChart>` showing `pain_level_before` trend over all sessions (x = session number, y = 0–10). Empty state: "No sessions logged yet."

### Tab 6 — Payments
Payment cards stacked vertically. Each card: package name + total price + paid amount + balance remaining + payment method badge + status (Partial/Paid). "Add Installment" `<Button>` on each card with outstanding balance (Admin/Receptionist only). Invoice number shown as a link to the invoice preview dialog.

### Tab 7 — Documents
Responsive `<Grid>` (3 cols desktop, 2 cols tablet, 1 col mobile) of document cards. Each card: thumbnail preview (image) or file icon (PDF/other) + file type label + upload date + action buttons (`Eye` / `Download` / `Trash2`). Upload button in section header: "Upload Document" (`Upload` icon, Admin/Receptionist/Doctor). Max file size 10MB. Accepted: PNG, JPG, PDF.

---

## UI States (Loading, Empty, Error, Success)

### Initial Load (Page)
Full-page skeleton: header area shows avatar skeleton + name skeleton + badge skeleton. Tab bar renders immediately (no skeleton). Tab content shows skeleton matching the tab's layout.

### Tab Loading (Lazy Fetch)
Each tab shows a loading spinner (`<Loader2 animate-spin>`) centered in the tab content area while its data fetches.

### Empty States (Per Tab)
- Appointments: "No appointments recorded yet." + "Schedule Appointment" button (role-gated)
- Treatment Plans: "No treatment plans created yet." + "Create Plan" button (Doctor/Admin)
- Sessions: "No sessions logged yet."
- Payments: "No payment records found." + "Record Payment" button (Admin/Receptionist)
- Documents: "No documents uploaded." + "Upload Document" button

### Error State
Per-tab `<Alert variant="destructive">`: "Failed to load [tab name]. Try refreshing." + "Retry" button. Does not affect other tabs.

### Edit Mode Success
Toast notification (Sonner): "Changes saved successfully." (green, top-right, auto-dismiss 4s). Form exits edit mode and returns to view mode.

### Edit Mode Error
Inline field-level validation errors in red below each field. Toast on submit failure: "Failed to save changes. Please try again."

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │  ← Back to Patients                                     │
│            │ ┌──────────────────────────────────────────────────┐    │
│            │ │ [Avatar 72px]  Ahmed Ali         [Active]  [Edit]│    │
│            │ │               PT-0042                             │    │
│            │ └──────────────────────────────────────────────────┘    │
│            │ [Personal][Medical][Appts][Plans][Sessions][Pay][Docs]   │
│            │ ──────────────────────────────────────────────────────   │
│            │ ┌──────────────────────┐ ┌──────────────────────────┐   │
│            │ │ Full Name            │ │ Phone                    │   │
│            │ │ Ahmed Mohamed Ali    │ │ 0501234567               │   │
│            │ ├──────────────────────┤ ├──────────────────────────┤   │
│            │ │ Date of Birth / Age  │ │ Gender                   │   │
│            │ │ 15 Mar 1985 / 41     │ │ Male                     │   │
│            │ └──────────────────────┘ └──────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

### Personal Info Edit
| Field | Rule |
|---|---|
| Full Name | Required, 2–100 chars |
| Phone | Required, valid Egyptian mobile format (`/^(010|011|012|015)\d{8}$/`), unique check via API |
| Date of Birth | Valid date, not in the future, not older than 120 years |
| Gender | Required, one of: Male / Female |

### Medical Info Edit
| Field | Rule |
|---|---|
| Diagnosis | Min 10 chars if provided |
| Chief Complaint | Required when first creating, 10–500 chars |

All edit forms use React Hook Form with Zod schemas shared between client and server. Submit is blocked while any field has a validation error.

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Click any row in `/patients` list
- Direct URL `/patients/[id]`
- Links from Appointments table / Session Log / Payment records referencing this patient
- Dashboard activity feed patient name link

### Exit Points
- "← Back to Patients" breadcrumb → `/patients`
- "View Plan" in Treatment Plans tab → `/treatment-plans/[planId]`
- Appointment row → opens `<AppointmentDetailSheet>` (side sheet, no navigation)
- "Add Installment" → opens payment dialog (no navigation)
- Sidebar links → respective pages

---

## Responsive Behavior

| Breakpoint | Behavior |
|---|---|
| Mobile (`< 640px`) | Sticky header compresses after scroll. Tabs are horizontally scrollable with fade mask. All grids become single column. Edit forms stack vertically. Document grid = 1 column. |
| Tablet (`640px–1024px`) | Two-column info grids, 2-column document grid, tab bar fully visible or scrollable. |
| Desktop (`> 1024px`) | Full layout as described. Sticky header always shows full patient info. |

---

## Accessibility Notes

- Sticky header uses `role="banner"` scoped to the patient context, not the global `<header>`.
- Tab navigation: Shadcn `<Tabs>` uses WAI-ARIA `tablist` / `tab` / `tabpanel` semantics. Arrow keys navigate tabs. Tab content panels have `tabIndex={0}`.
- Edit mode: when entering edit mode, focus moves to the first editable field. On save/cancel, focus returns to the "Edit" button.
- `<Avatar>` has `alt="[Patient name] profile photo"` or `alt="[Patient name] initials"` for fallback.
- Timeline entries in Sessions tab use `<ol>` list semantics.
- Document cards: `<Button>` icons have descriptive `aria-label` ("View document", "Download document", "Delete document").
- Pain trend chart: visually hidden data table alternative provided for screen readers.
- All status badges use text + color (never color-only).

### RTL Considerations
- In RTL, the sticky header mirrors: avatar on the right, name left-aligned from right, Edit button on the left.
- Tab scroll direction reverses.
- Two-column info grid: left column becomes right column.
- Timeline dots appear on the right side of the vertical line.
- Document grid layout unchanged (grid is direction-agnostic).
- Arabic date formatting uses `ar-EG` locale throughout.
- Form labels and inputs use Noto Sans Arabic; numeric fields (`dir="ltr"`) are preserved.

---

*DOC-06-P04 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
