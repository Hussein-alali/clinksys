# Page: Payment Create

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P13 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Payment Create page. |
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
| **URL Route** | `/payments/new` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin, Receptionist |
| **Unauthorized Redirect** | Other roles → role-home page; unauthenticated → `/` |
| **Pre-fill Support** | `?patientId=[id]` query param pre-selects the patient combobox |
| **RTL Support** | Yes |

---

## Page Purpose

The Payment Create page is the billing entry point for recording a patient's package purchase and initial payment. A single submission creates three linked records atomically:

1. A `payments` record (total, paid amount, method, balance, due date).
2. A `patient_sessions` record (session credits added based on the package).
3. An `invoices` record (auto-numbered, PDF-ready).

The page is designed for speed and accuracy: selecting a package auto-populates price and session count, the summary panel provides an instant financial preview, and real-time paid-amount validation prevents over-payment errors.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| Patient search | `patients` WHERE `full_name.ilike.%q% OR file_number.ilike.%q%` LIMIT 10 | Combobox type, 300ms debounce |
| Outstanding balance | `payments` SUM `(total_price - paid_amount)` WHERE `patient_id = [id] AND status != paid` | Patient selected |
| Active packages | `packages` WHERE `status = active` ORDER BY `name` | Page load |
| Package detail (auto-fill) | Read from `packages` WHERE `id = [selectedId]` (already in memory from packages query) | Package select change |
| Submit — create payment | POST to server action: INSERT `payments` + INSERT `patient_sessions` + INSERT `invoices` (all in a single DB transaction) | Form submit |

---

## Component Breakdown

### Page Header
- `<h1>` "New Payment" (Figtree 700 24px) + breadcrumb "Payments → New"

### Form Layout
Desktop: `grid grid-cols-3 gap-8` — form occupies 2 cols, summary panel occupies 1 col.
Mobile: single column, summary panel below the form.

### Form Field 1 — Patient (Required)
`<Combobox>` — searchable. On select:
- Shows patient chip with `X` to clear.
- If patient has an outstanding balance > 0, shows `<Alert className="border-amber-400 bg-amber-50">` `<AlertTriangle className="text-amber-500">` "This patient has an outstanding balance of **1,500 EGP**." This is informational — it does not block submission.

### Form Field 2 — Package (Optional)
`<Select>` — options: active packages listed as "Package Name (X sessions — Y,000 EGP)". Plus a "Custom (no package)" option at the top. On package select:
- `total_price` input auto-fills with the package price.
- A read-only hint below: "This package includes X sessions." in `text-sm text-slate-500`.
- On "Custom": price and session count inputs are both enabled for manual entry.

### Form Field 3 — Total Price (Required)
`<Input type="number" min="1">` labeled "Total Price (EGP)". Pre-filled from package. Editable (allows custom pricing for one-off adjustments). Formatted with thousands separator on blur.

### Form Field 4 — Paid Amount (Required)
`<Input type="number" min="0">` labeled "Paid Amount (EGP)". Real-time validation:
- If `paid_amount > total_price`: red border + error "Paid amount cannot exceed total price."
- If `paid_amount == total_price`: green border + `<CheckCircle>` "Paid in full."
- If `paid_amount < total_price`: amber border + `<AlertCircle>` "Partial payment — balance of X EGP will remain."

### Form Field 5 — Payment Method (Required)
5 icon cards in a horizontal row (wraps on mobile), each 44×44px minimum touch target:

| Option | Icon | Label |
|---|---|---|
| Cash | `Banknote` | Cash |
| Visa | `CreditCard` | Visa |
| Instapay | `Smartphone` | Instapay |
| Vodafone Cash | `Phone` | Vodafone Cash |
| Bank Transfer | `Building2` | Bank Transfer |

Card style: `border-2 rounded-xl p-3 flex flex-col items-center gap-1 text-xs`. Selected: `border-cyan-600 bg-cyan-50 text-cyan-700`. Unselected: `border-slate-200 bg-white hover:border-slate-300`.

### Form Field 6 — Due Date (Optional)
`<DatePicker>` labeled "Due Date (for partial payments)". Hint: "Only needed if the patient has a remaining balance." Renders below the payment method cards. Must be a future date.

### Form Field 7 — Notes (Optional)
`<Textarea>` 2 rows. "Internal notes (not shown on invoice)." Max 300 chars.

### Summary Panel (Right Column / Bottom on Mobile)
`<Card className="sticky top-6 bg-slate-50 border-slate-200">` "Payment Summary" heading.

| Row | Content |
|---|---|
| Package | Package name or "Custom" |
| Sessions | "X sessions will be added to patient account" |
| Total Price | "X,000 EGP" |
| Paid Amount | "X,000 EGP" (updates live as user types) |
| Balance | "X,000 EGP" (red if > 0, green if 0) |
| Invoice Preview | "Invoice #INV-2026-XXXX will be created" (`text-xs text-slate-400`) |

---

## UI States (Loading, Empty, Error, Success)

### Patient Outstanding Balance Warning
`<Alert>` appears below the patient combobox immediately on patient select (if applicable). Does not block form.

### Paid Amount — Real-Time Validation
Three states: over-payment (red), partial (amber), full (green) — described above. Updates on every keystroke in the paid amount field.

### Submit — Loading
All form inputs disabled. Submit button: `<Loader2 animate-spin>` + "Processing…". Duration: typically under 1 second (single DB transaction).

### Submit — Success
Three post-submit actions happen in sequence:
1. Toast (green, bottom-right, 8s duration): "Payment recorded. Invoice **INV-2026-0043** created."
2. Page transitions to a success state showing three action buttons:

```
        ┌─────────────────────────────────────┐
        │  ✓ Payment recorded successfully.   │
        │  Invoice INV-2026-0043 created.     │
        │                                     │
        │  [View Invoice]                     │
        │  [Add Another Payment]              │
        │  [Go to Patient Profile]            │
        └─────────────────────────────────────┘
```

- "View Invoice" → opens invoice preview dialog (from `/invoices`) or navigates to `/invoices?highlight=[invoiceId]`
- "Add Another Payment" → resets the form to empty state (or pre-fills with same patient)
- "Go to Patient Profile" → `/patients/[patientId]`

### Submit — Error
Toast (red): "Failed to record payment. Please try again." Form re-enabled. If the error is a DB transaction conflict (e.g., duplicate), a specific message is shown.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │  Payments > New Payment                                  │
│            │  ──────────────────────────────────────────────────     │
│            │  ┌────────────────────────────────┐ ┌─────────────┐    │
│            │  │ 1. Patient *                   │ │  Summary    │    │
│            │  │  [Search patient...       ▼]   │ │             │    │
│            │  │  [⚠ Outstanding: 1,500 EGP]   │ │ Package: —  │    │
│            │  │                                │ │ Sessions: — │    │
│            │  │ 2. Package                     │ │ Total: —    │    │
│            │  │  [Select package...       ▼]   │ │ Paid: —     │    │
│            │  │  "12 sessions included"        │ │ Balance: —  │    │
│            │  │                                │ └─────────────┘    │
│            │  │ 3. Total Price (EGP) *         │                     │
│            │  │  [  3,500  ]                   │                     │
│            │  │                                │                     │
│            │  │ 4. Paid Amount (EGP) *         │                     │
│            │  │  [  2,000  ] ⚠ Balance 1,500  │                     │
│            │  │                                │                     │
│            │  │ 5. Payment Method *            │                     │
│            │  │  [Cash][Visa][Insta][VF][Bank] │                     │
│            │  │                                │                     │
│            │  │ 6. Due Date (optional)         │                     │
│            │  │  [date picker]                 │                     │
│            │  │                                │                     │
│            │  │ 7. Notes                       │                     │
│            │  │  [textarea]                    │                     │
│            │  │                                │                     │
│            │  │      [Cancel]  [Record Payment]│                     │
│            │  └────────────────────────────────┘                     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

| Field | Rule | Error |
|---|---|---|
| Patient | Required | "Please select a patient." |
| Total Price | Required, integer ≥ 1 | "Total price must be at least 1 EGP." |
| Paid Amount | Required, integer 0–total_price | "Paid amount cannot exceed total price." / "Paid amount is required." |
| Payment Method | Required, one of 5 options | "Please select a payment method." |
| Due Date | Optional; if provided, must be ≥ today | "Due date must be today or in the future." |
| Due Date | Required if `paid_amount < total_price` (enforced by business logic, shown as warning) | Not hard-blocked — warning only |
| Notes | Optional, max 300 chars | "Notes must not exceed 300 characters." |

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Sidebar "New Payment" quick-action or Payments section
- Patient Profile → Payments tab → "Record Payment" button (pre-fills `?patientId=[id]`)
- Direct URL `/payments/new`

### Exit Points
- Submit success → success state with 3 action buttons (described above)
- "Cancel" → `/payments` list or previous page
- Dirty form guard: confirmation dialog on unsaved exit

---

## Responsive Behavior

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Single column. Summary panel moves to the bottom of the form (not sticky — scrolls with content). Payment method cards wrap to 3+2 layout. All inputs full-width. Submit/Cancel full-width stacked. |
| Tablet (`640px–1024px`) | 2/3 form + 1/3 sticky summary panel. Payment method cards in a 3+2 wrap. |
| Desktop (`> 1024px`) | 2/3 + 1/3 grid. Payment method cards in a single 5-card row. |

---

## Accessibility Notes

- Patient combobox: `role="combobox"`, `aria-expanded`, `aria-autocomplete="list"`.
- Outstanding balance alert: `role="status"` (not `alert`) — informational, not an error.
- Paid amount field: `aria-describedby` points to the real-time validation message below it. Validation messages use `role="status"` and update on each keystroke.
- Payment method cards: `role="radiogroup"` + `aria-label="Payment method"`. Each card = `<label>` wrapping `<input type="radio">`.
- Summary panel balance: reads "Balance: 1,500 EGP" for screen readers, not styled color-only.
- Submit button: `aria-busy="true"` + `aria-disabled="true"` during loading.
- Success state: focuses the "View Invoice" button when the success state renders.

### RTL Considerations
- Form columns reverse in RTL: summary panel on the left.
- Payment method cards: icon + label both right-aligned.
- Price inputs always `dir="ltr"` (numbers are LTR).
- All labels, hints, and alert text in Noto Sans Arabic when `lang=ar`.
- Outstanding balance alert: amount formatted as "١٬٥٠٠ ج.م" in `ar-EG` locale.
- Date picker uses Arabic locale calendar.
- Success state buttons stack in RTL alignment.

---

*DOC-06-P13 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
