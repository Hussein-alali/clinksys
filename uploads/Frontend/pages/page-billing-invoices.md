# Page: Billing & Invoices

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P12 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Billing & Invoices page. |
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
| **URL Route** | `/invoices` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin (all invoices), Receptionist (all invoices), Patient (own invoices only — RLS enforced) |
| **RLS Enforcement** | Patient role: `invoices WHERE patient_id = auth.uid()`. Admin/Receptionist: all rows. |
| **RTL Support** | Yes |

---

## Page Purpose

The Billing & Invoices page provides a complete, filterable record of all clinic invoices. Staff use it to track payment status, preview and print invoices for patients, download PDFs for record-keeping, and audit the financial state of individual accounts. Patients accessing the page see only their own invoices in a simplified view.

Key capabilities:
- Filter by patient name, invoice number, date range, and status.
- Preview formatted invoices in a modal without leaving the page.
- Download a clinic-branded PDF via a server-generated signed URL.
- Print directly from the browser with print-optimized CSS.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| Invoice list (paginated) | `invoices` JOIN `patients` (name) WHERE filters applied, ORDER BY `created_at desc`, LIMIT 25 OFFSET | Page load, filter changes |
| Total count | Same query with `.count('exact', { head: true })` | Same as list |
| Search by patient / invoice# | `.or('invoice_number.ilike.%q%').or('patients.full_name.ilike.%q%')` | Debounced 300ms |
| Date range filter | `.gte('created_at', from).lte('created_at', to)` | Date picker confirm |
| Status filter | `.eq('status', status)` | Tab click |
| Invoice detail (preview) | `invoices WHERE id = [id]` JOIN `invoice_line_items` JOIN `patients` JOIN `payments` | Preview dialog open |
| Generate PDF | POST `/api/invoices/[id]/generate-pdf` → returns `{ signedUrl }` | Download button click |

---

## Component Breakdown

### Page Header
- `<h1>` "Invoices" (Figtree 700 24px)
- No primary action button (invoices are created automatically by the payment system)

### Filter Bar
- `<SearchInput>` — search by patient name or invoice number, debounced 300ms, with clear `X` button
- `<DateRangePicker>` — date range for invoice creation date
- Status tabs (`<Tabs>`): **All | Issued | Paid | Cancelled** — clicking a tab filters the table. Active tab: `border-b-2 border-cyan-600`.

### Invoices Table
`<DataTable>`:

| Column | Content |
|---|---|
| Invoice # | `invoice_number` — monospace, `text-slate-600`, e.g., "INV-2026-0042" |
| Patient Name | Full name — `text-slate-900`, clickable → `/patients/[id]` |
| Date | `created_at` formatted `DD MMM YYYY` |
| Amount | `total_amount` formatted "3,000 EGP" |
| Paid | `paid_amount` formatted "2,000 EGP" |
| Balance | `total_amount - paid_amount` formatted "1,000 EGP". Balance > 0: `text-red-600 font-medium`. Balance = 0: `text-green-600`. |
| Status | `<StatusBadge>`: Draft = `bg-slate-100 text-slate-500` / Issued = `bg-blue-100 text-blue-700` / Paid = `bg-green-100 text-green-700` / Cancelled = `line-through text-slate-400 bg-red-50 border-red-200` |
| Actions | Three `<Button variant="ghost" size="icon">` buttons: `Eye` (preview) + `Download` (PDF) + `Printer` (print) |

25 rows per page, pagination strip below.

### Invoice Preview Dialog
Shadcn `<Dialog className="max-w-2xl">`:

**Dialog header:** Invoice number + close X button.

**Formatted invoice layout** inside the dialog:
```
  ┌──────────────────────────────────────────────┐
  │  [Clinic Logo]     Physical Therapy Clinic    │
  │  Address • Phone • Email                      │
  │                                               │
  │  INVOICE                    INV-2026-0042     │
  │  Issue Date: 24 May 2026                      │
  │  Patient: Ahmed Mohamed Ali                   │
  │  Phone: 0501234567                            │
  │                                               │
  │  ┌──────────────────────┬────────┬─────────┐  │
  │  │ Description          │Sessions│ Amount  │  │
  │  ├──────────────────────┼────────┼─────────┤  │
  │  │ Premium Package      │  20    │3,500 EGP│  │
  │  └──────────────────────┴────────┴─────────┘  │
  │                                               │
  │  Total:    3,500 EGP                          │
  │  Paid:     2,000 EGP                          │
  │  Balance:  1,500 EGP                          │
  │                                               │
  │  Payment Method: Cash                         │
  │  Status: Issued                               │
  └──────────────────────────────────────────────┘
```

Dialog footer: `[Close]` `[Download PDF]` `[Print]`.

### PDF Download Flow
1. User clicks `Download` icon button.
2. Button shows `<Loader2 animate-spin>` + `aria-busy="true"` (replaced download icon).
3. POST `/api/invoices/[id]/generate-pdf` called.
4. On success: opens `signedUrl` in a new browser tab (the PDF file with `Content-Disposition: attachment`).
5. Button reverts to normal state.
6. On error: toast "Failed to generate PDF. Try again."

### Print Flow
1. User clicks `Printer` icon button.
2. Page adds `?print=[id]` to URL, which triggers a `useEffect` that opens the preview dialog.
3. Dialog has a `print:block` CSS class that makes it full-width and print-only visible.
4. Navigation sidebar, filter bar, and table all have `print:hidden` CSS.
5. `window.print()` is called programmatically after dialog renders.
6. After print dialog closes, the `?print` param is removed and the dialog closes.

---

## UI States (Loading, Empty, Error, Success)

### Page Load — Loading
Table body: 8 skeleton rows. Status tab badges show placeholder counts.

### Empty State — No Invoices
```
      [Receipt icon — 64px — text-slate-300]
      No invoices found.
      Invoices are created automatically when payments are recorded.
```
No CTA (invoices are system-generated).

### Empty State — Filtered, No Results
```
      [Search icon — 48px — text-slate-300]
      No invoices match your filters.
      [Clear Filters]
```

### PDF Generation — Loading
Download button: spinner replaces icon. Duration: typically 2–5 seconds.

### PDF Generation — Success
New browser tab opens with the PDF. Button returns to normal. No toast (tab opening is the confirmation).

### Error States
- PDF generation failure: toast (red): "Failed to generate PDF. Please try again."
- Table load failure: `<Alert variant="destructive">` in table area + "Retry" button.

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │  Invoices                                               │
│            │  ──────────────────────────────────────────────────    │
│            │  [🔍 Search patient or invoice#]  [📅 Date range]      │
│            │  [All (142)] [Issued (38)] [Paid (96)] [Cancelled (8)] │
│            │  ──────────────────────────────────────────────────    │
│            │  ┌──────────┬─────────┬────────┬──────┬──────┬──────┐  │
│            │  │Invoice # │ Patient │  Date  │Amount│ Paid │Bal.  │  │
│            │  ├──────────┼─────────┼────────┼──────┼──────┼──────┤  │
│            │  │INV-2026-0│Ahmed A. │24 May  │3,500 │2,000 │1,500 │  │
│            │  │0042      │         │2026    │EGP   │EGP   │EGP   │  │
│            │  │          │         │        │      │      │[👁][⬇][🖨]│
│            │  └──────────┴─────────┴────────┴──────┴──────┴──────┘  │
│            │  [← Prev]  1  2  3  [Next →]                            │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

No form submission on this page. All data is read-only. PDF generation uses server-side signing — no user input required. Print uses browser-native `window.print()`.

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Sidebar "Invoices" navigation item
- "View Invoice" button from Payment Create success state
- Patient Profile → Payments tab → Invoice link

### Exit Points
- Patient name link → `/patients/[id]`
- Preview dialog close → returns to table (no navigation)
- PDF download → new browser tab (no navigation away from invoices)
- Sidebar links → respective pages

---

## Responsive Behavior

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Table becomes card list. Each invoice = card: Invoice# + Patient Name + Amount / Paid / Balance in rows + Status badge + action buttons (row of 3 icon buttons). Status tabs become a horizontal scrollable tab strip. Filter bar: search visible, date range in `<Sheet>` drawer. |
| Tablet (`640px–1024px`) | Full table; "Paid" and "Balance" columns may be compressed. Date range inline. |
| Desktop (`> 1024px`) | Full layout. Invoice preview dialog 2xl width centered. |

Print styles (`@media print`): only the invoice content inside the dialog prints. All navigation, filters, and table hidden. Invoice rendered in black/white-friendly styling.

---

## Accessibility Notes

- Table: `<caption className="sr-only">Invoice records</caption>`.
- Status tabs: `role="tablist"`, each tab `role="tab"`, `aria-selected`, `aria-controls`.
- Balance column: negative balance (>0) communicated by both red color and text value — screen readers read "1,500 EGP" and the column header "Balance Outstanding".
- Cancelled invoice status badge: strikethrough is a visual enhancement; screen reader reads "Status: Cancelled" from the badge text.
- Preview dialog: `aria-labelledby` → invoice number heading. Focus trapped. Escape closes.
- Download button during loading: `aria-busy="true"`, `aria-label="Generating PDF, please wait"`.
- Print button: `aria-label="Print invoice [invoice number]"`.
- Action buttons in each row include the invoice number in their `aria-label` for context.

### RTL Considerations
- Table column order mirrors in RTL.
- Invoice preview dialog: clinic logo on left, invoice details right-aligned.
- Amount formatting: Arabic-Indic numerals + "ج.م" suffix in `ar-EG` locale.
- Status tabs scroll direction reverses in RTL.
- Search icon in input field moves to right side.
- Date range picker uses Arabic calendar locale.

---

*DOC-06-P12 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
