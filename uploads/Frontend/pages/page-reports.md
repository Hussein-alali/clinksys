# Page: Reports

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P17 |
| **Version** | 0.2 — In Progress |
| **Status** | In Progress |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Reports page. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | product-requirements-document.md, user-stories.md |
| **Priority** | P2 |
| **Estimated Pages** | 4–8 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / UX Designer | Initial stub |
| 0.2 | 2026-05-24 | Frontend Engineer / UX Designer | Full specification completed |

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

| Field | Value |
|---|---|
| **URL Route** | `/reports` |
| **Next.js File** | `app/(dashboard)/reports/page.tsx` |
| **Authentication** | Required — redirect to `/login` if unauthenticated |
| **Authorized Roles** | Admin, Doctor |

### Role-Based Tab Visibility

| Tab | Admin | Doctor | Receptionist | Therapist |
|---|---|---|---|---|
| Medical | Visible | Visible | Hidden | Hidden |
| Financial | Visible | **Hidden** | Hidden | Hidden |
| Operational | Visible | Hidden | Hidden | Hidden |

Access control is enforced at two levels: the server-side route guard redirects unauthorized roles entirely, and the tab rendering logic conditionally omits the Financial tab for Doctor-role sessions. A Doctor navigating directly to `/reports?tab=financial` is silently redirected to the Medical tab — no 403 page is shown, as this avoids disclosing sensitive financial data exists.

---

## Page Purpose

The Reports page is the clinic's primary data-export and analysis surface. It consolidates three categories of structured reporting — Medical, Financial, and Operational — behind a unified tab interface with a flexible date-filter and report-selector workflow.

**Core jobs this page performs:**

1. **Medical reports** — Allow Admin and Doctor roles to generate patient-centric reports: full patient history, treatment progress per therapist or patient, and therapist activity summaries. These reports support clinical review, quality assurance, and patient continuity of care.

2. **Financial reports** — Allow Admin to audit revenue by day or month, identify outstanding payment balances, and break down revenue by treatment package. These reports feed the financial oversight workflow alongside the Dashboard KPI cards.

3. **Operational reports** — Allow Admin to measure appointment volume, session attendance rates, and treatment method utilization over any date range, providing the data needed to optimize scheduling and staffing.

4. **Data export** — All generated reports can be exported as CSV (for spreadsheet analysis) or PDF (for printing and sharing), supporting the clinic's Google Sheets integration and external reporting needs.

The page is intentionally stateless between visits: no report is auto-generated on load. Users must actively select a report type, apply a date filter, and click "Generate Report." This prevents accidental data exposure and keeps initial page load fast.

---

## Data Fetching (API Endpoints Consumed)

### Report Generation Endpoints

All report endpoints accept query parameters for filtering and return paginated JSON arrays. Date parameters use ISO 8601 format (`YYYY-MM-DD`).

| Report Type | Method | Endpoint | Key Params |
|---|---|---|---|
| Patient History | GET | `/api/reports/medical/patient-history` | `patient_id`, `date_from`, `date_to`, `page`, `limit` |
| Treatment Progress | GET | `/api/reports/medical/treatment-progress` | `patient_id?`, `therapist_id?`, `date_from`, `date_to` |
| Therapist Activity | GET | `/api/reports/medical/therapist-activity` | `therapist_id`, `date_from`, `date_to` |
| Daily Revenue | GET | `/api/reports/financial/daily-revenue` | `date` |
| Monthly Revenue | GET | `/api/reports/financial/monthly-revenue` | `month`, `year` |
| Outstanding Payments | GET | `/api/reports/financial/outstanding-payments` | `status?` (overdue / partial / pending) |
| Package Revenue Breakdown | GET | `/api/reports/financial/package-revenue` | `package_id?`, `date_from`, `date_to` |
| Appointment Statistics | GET | `/api/reports/operational/appointment-stats` | `date_from`, `date_to` |
| Session Attendance Rate | GET | `/api/reports/operational/attendance-rate` | `therapist_id?`, `date_from`, `date_to` |
| Treatment Method Usage | GET | `/api/reports/operational/method-usage` | `date_from`, `date_to` |

### Export Endpoints

| Export | Method | Endpoint | Response |
|---|---|---|---|
| CSV Export | GET | `/api/reports/export/csv` | `Content-Disposition: attachment; filename="report-YYYY-MM-DD.csv"` with `Content-Type: text/csv` |
| PDF Export | POST | `/api/reports/export/pdf` | Server renders PDF, returns a signed URL; client opens URL in new browser tab |

### Supporting Data Endpoints (for filter dropdowns)

| Data | Method | Endpoint |
|---|---|---|
| Patient list (for selector) | GET | `/api/patients?fields=id,full_name&status=active` |
| Therapist list (for selector) | GET | `/api/staff?role=therapist&fields=id,full_name` |
| Package list (for selector) | GET | `/api/packages?fields=id,name` |

All GET requests are performed via React Query (`useQuery`) with a `staleTime` of 0 — report data is never served from cache; a fresh server request fires on every "Generate" click.

---

## Component Breakdown

### Page Shell Components

| Component | Source | Role |
|---|---|---|
| `PageHeader` | Internal | Displays page title "Reports" / "التقارير", breadcrumb, and optional subtitle |
| `TabGroup` | Shadcn/UI `Tabs` | Houses Medical / Financial / Operational tab panels |
| `TabList` | Shadcn/UI `TabsList` | Renders tab triggers; Financial tab conditionally rendered based on user role |
| `TabPanel` | Shadcn/UI `TabsContent` | Contains the report selector + filter + results for each tab |

### Report Controls

| Component | Source | Role |
|---|---|---|
| `ReportSelector` | Internal (`Select` + Shadcn) | Dropdown listing available report types for the active tab |
| `DateRangePicker` | Internal (wraps `react-day-picker`) | "From" and "To" date inputs; validates that `From` is not after `To` |
| `PatientSearchSelect` | Internal | Combobox with search for patient selection (Medical reports) |
| `TherapistSelect` | Internal | Dropdown of therapist staff members |
| `PackageSelect` | Internal | Dropdown of treatment packages |
| `StatusFilterSelect` | Internal | Dropdown for payment status filter (Outstanding Payments report) |
| `GenerateButton` | Internal (Button variant=primary) | Triggers API call; shows `Loader2` icon spinning during request |

### Results Area

| Component | Source | Role |
|---|---|---|
| `SummaryCards` | Internal | Row of 4 `DataCard` components shown only on Financial tab; displays Total Revenue, Outstanding Balance, Collected This Month, Overdue Count |
| `DataTable` | Internal (TanStack Table) | Sortable, paginated table; columns vary per report type |
| `TablePagination` | Internal | Page controls (Previous / Next / page selector); shows "Showing X–Y of Z results" |
| `ExportCSVButton` | Internal | Button with `Download` Lucide icon; triggers CSV export |
| `ExportPDFButton` | Internal | Button with `FileText` Lucide icon; triggers PDF generation and opens result URL in new tab |
| `SkeletonTableRows` | Internal | 3-row skeleton placeholder displayed during report loading |
| `EmptyStateIllustration` | Internal | SVG illustration + descriptive message for empty states |

### Financial Tab Only

| Component | Source | Role |
|---|---|---|
| `DataCard` (Total Revenue) | Internal | Displays sum of revenue for the selected period; cyan-600 accent |
| `DataCard` (Outstanding) | Internal | Displays total outstanding balance; amber accent |
| `DataCard` (Collected Today) | Internal | Displays payments received today; green accent |
| `DataCard` (Overdue Count) | Internal | Count of overdue invoices; red accent |

---

## UI States (Loading, Empty, Error, Success)

### Initial State (No Report Generated)

When the page first loads — or when the user switches tabs — no report results are shown. The results area displays an empty-state illustration with instructional copy:

```
[Chart icon — Lucide BarChart3, 64×64, slate-300]

Select a date range and click Generate Report
to view data.

اختر نطاقاً زمنياً واضغط "إنشاء التقرير" لعرض البيانات.
```

The "Generate Report" button is disabled until both a date range (From + To) is provided and a report type is selected.

### Loading State

After the user clicks "Generate Report," the results area transitions immediately to a skeleton state:

- The `GenerateButton` shows a spinning `Loader2` icon and its label changes to "Generating…" / "جارٍ الإنشاء…"
- The table area renders 3 skeleton rows (grey shimmer blocks matching the expected column widths)
- Summary Cards (Financial tab) show skeleton rectangles in place of values
- The date range and report selector remain interactive so the user can adjust filters without waiting

Skeleton rows use Tailwind `animate-pulse` with `bg-slate-200` shimmer blocks. Row heights match the expected data row height (48px) to prevent layout shift when real data arrives.

### Success State

- Skeleton rows are replaced with the populated `DataTable`
- Row count label appears above the table: "Showing 1–25 of 143 results" / "عرض 1–25 من 143 نتيجة"
- Export buttons (`Export CSV`, `Export PDF`) become active and visible below the table
- Financial tab Summary Cards populate with live values

### Empty State (No Data in Range)

When the API returns an empty array for the selected filters:

```
[SearchX icon — Lucide, 64×64, slate-300]

No data found for the selected period.
Try a different date range.

لا توجد بيانات للفترة المحددة. جرّب نطاقاً زمنياً مختلفاً.
```

Export buttons are hidden in this state — there is nothing to export.

### Error State

If the API call fails (network error, 5xx, or authorization failure):

```
[AlertCircle icon — Lucide, 64×64, red-400]

Failed to generate report. Please try again.

فشل إنشاء التقرير. يرجى المحاولة مرة أخرى.

[Retry button]
```

A `toast.error()` notification also fires from the top-right corner with the same message. The "Retry" button re-fires the last API request with the same parameters.

### CSV Export States

- **Loading:** The `Export CSV` button shows a `Loader2` spinning icon; button is disabled
- **Success:** Browser native save dialog appears (the response uses `Content-Disposition: attachment`)
- **Error:** `toast.error("Export failed. Please try again.")` fires; button re-enables

### PDF Export States

- **Loading:** The `Export PDF` button shows a `Loader2` spinning icon; button is disabled
- **Success:** A new browser tab opens with the PDF URL returned by the server
- **Error:** `toast.error("PDF generation failed. Please try again.")` fires; button re-enables

---

## Layout Wireframe / Mockup Reference

```
┌─────────────────────────────────────────────────────────┐
│  PageHeader: "Reports" / "التقارير"                     │
│  Breadcrumb: Dashboard > Reports                        │
├─────────────────────────────────────────────────────────┤
│  [Medical]  [Financial]  [Operational]                  │
│   ← Financial tab hidden entirely for Doctor role →     │
├─────────────────────────────────────────────────────────┤
│  Report Type:  [Patient History          ▼]             │
│  Patient:      [Search patient...        ▼]  (Medical)  │
│  Date range:   [From: DD/MM/YYYY] [To: DD/MM/YYYY]      │
│                                  [Generate Report ▶]    │
├─────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────┐  │
│  │ Total Revenue   │ Outstanding  │ Collected │ Overdue│ │  ← Financial tab only
│  │    25,400 EGP   │  3,200 EGP  │ 1,800 EGP │   7   │ │
│  └───────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  Showing 1–25 of 143 results                            │
│  ┌──────────────────────────────────────────────────┐   │
│  │ Col A ▲   │ Col B    │ Col C    │ Col D    │ ...  │   │
│  ├───────────┼──────────┼──────────┼──────────┼──────┤   │
│  │ Row 1     │ ...      │ ...      │ ...      │ ...  │   │
│  │ Row 2     │ ...      │ ...      │ ...      │ ...  │   │
│  │ Row 3 (skeleton during load)                     │   │
│  └──────────────────────────────────────────────────┘   │
│  [← Prev]  Page 1 of 6  [Next →]                       │
│                                                         │
│  [↓ Export CSV]   [↓ Export PDF]                       │
└─────────────────────────────────────────────────────────┘
```

### Report-Specific Column Definitions

**Medical Tab — Patient History**

| Column | Type | Sortable |
|---|---|---|
| Date | Date | Yes |
| Appointment Type | Text | No |
| Therapist | Text | Yes |
| Status | Badge | No |
| Sessions Used | Number | Yes |
| Notes | Text (truncated) | No |

**Medical Tab — Treatment Progress**

| Column | Type | Sortable |
|---|---|---|
| Patient Name | Text | Yes |
| Diagnosis | Text | No |
| Sessions Completed | Number | Yes |
| Sessions Remaining | Number | Yes |
| Last Session Date | Date | Yes |
| Progress % | Progress bar | No |

**Medical Tab — Therapist Activity**

| Column | Type | Sortable |
|---|---|---|
| Therapist Name | Text | Yes |
| Total Sessions | Number | Yes |
| Completed | Number | Yes |
| Cancelled | Number | Yes |
| No-Show | Number | Yes |
| Avg Session Duration | Text | No |

**Financial Tab — Daily Revenue**

| Column | Type | Sortable |
|---|---|---|
| Patient Name | Text | Yes |
| Invoice # | Text | No |
| Package | Text | No |
| Amount | Currency | Yes |
| Payment Method | Badge | No |
| Time | Time | Yes |

**Financial Tab — Outstanding Payments**

| Column | Type | Sortable |
|---|---|---|
| Patient Name | Text | Yes |
| Invoice # | Text | No |
| Original Amount | Currency | Yes |
| Amount Paid | Currency | Yes |
| Balance Due | Currency | Yes |
| Due Date | Date | Yes |
| Status | Badge | No |

**Operational Tab — Appointment Statistics**

| Column | Type | Sortable |
|---|---|---|
| Date | Date | Yes |
| Total Booked | Number | Yes |
| Completed | Number | Yes |
| Cancelled | Number | Yes |
| No-Show | Number | Yes |
| Utilization % | Number | Yes |

---

## Validation Rules

### Date Range

- `date_from` is required when `date_to` is provided (and vice versa); neither field alone triggers a report
- `date_from` must be a valid calendar date (no future dates allowed for historical reports)
- `date_to` must be equal to or after `date_from`; if `date_to` is before `date_from`, an inline error reads: "End date must be after start date" / "تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية"
- Maximum date range span: 366 days; if exceeded, inline error: "Date range cannot exceed one year" / "لا يمكن أن يتجاوز النطاق الزمني عاماً واحداً"
- Date format display: `DD/MM/YYYY` in Arabic locale; `MM/DD/YYYY` in English locale

### Report-Specific Filters

- **Patient History:** Patient selection is required; without it, the Generate button stays disabled
- **Treatment Progress:** Either patient or therapist selection is required (not both mandatory)
- **Therapist Activity:** Therapist selection is required
- **Daily Revenue:** Single date selection is required (not a range)
- **Monthly Revenue:** Month and year selection is required
- **Package Revenue Breakdown:** Date range is required; package filter is optional

### Export

- Export buttons are only active when a successful report result is present
- CSV and PDF exports re-use the same filter parameters sent during the last Generate call; they do not re-query unless filters changed
- A second export click while one export is in progress is ignored (button disabled state)

---

## Navigation Flows (Entry & Exit Points)

### Entry Points

| Source | How |
|---|---|
| Sidebar navigation | "Reports" link under the Analytics section |
| Dashboard KPI card | "View Full Report" link from the Revenue card opens `/reports?tab=financial` |
| Patient profile page | "View History" link opens `/reports?tab=medical&report=patient-history&patient_id={id}` |
| Deep link (Admin) | Direct URL with query params pre-populates the form and auto-generates the report |

### Pre-Population via Query Params

When the page loads with query params present (`?tab=medical&report=patient-history&patient_id=123&date_from=2026-01-01&date_to=2026-05-24`), the following happens automatically:
1. The correct tab is activated
2. The report type dropdown is set
3. Filter inputs are populated
4. `Generate Report` fires immediately without requiring a button click

### Exit Points

| Destination | Trigger |
|---|---|
| Patient Profile (`/patients/:id`) | Clicking a patient's name in any Medical report row |
| Invoice Detail (`/invoices/:id`) | Clicking an invoice number in a Financial report row |
| Dashboard (`/dashboard`) | Breadcrumb navigation |

---

## Responsive Behavior

### Desktop (1024px+)

- Full layout as shown in the wireframe
- Filter controls sit in a single horizontal row
- Summary cards display in a 4-column grid
- Table fills available width; column widths distribute proportionally

### Tablet (768px–1023px)

- Filter controls wrap to two rows: report selector + patient/therapist filter on row 1; date range + Generate button on row 2
- Summary cards shift to a 2-column grid
- Table remains full-width with horizontal scroll if content overflows

### Mobile (320px–767px)

- Tab list scrolls horizontally (`overflow-x: auto`; tabs do not wrap or stack)
- Filter controls stack vertically (each control is full-width)
- Summary cards stack in a single column
- Data table scrolls horizontally within a full-width wrapper (`overflow-x: auto`)
- Export buttons stack vertically below the table, each full-width
- The Generate button is full-width
- Pagination controls are simplified: Previous / Next only (page number selector hidden)

---

## Accessibility Notes

### Tab Panel Structure

Each tab panel uses proper ARIA roles:

```html
<div role="tabpanel"
     id="panel-medical"
     aria-labelledby="tab-medical"
     tabindex="0">
  <!-- tab content -->
</div>
```

The hidden Financial tab panel (`role="tabpanel"`) is removed from the DOM entirely for Doctor-role sessions — it is not merely `display:none` — to prevent screen readers from announcing hidden content.

### Interactive Elements

| Element | ARIA Attribute |
|---|---|
| Report type dropdown | `aria-label="Select report type"` |
| Date From input | `aria-label="Report start date"` |
| Date To input | `aria-label="Report end date"` |
| Generate button | `aria-label="Generate report"` / `aria-busy="true"` while loading |
| Export CSV button | `aria-label="Export report as CSV"` |
| Export PDF button | `aria-label="Export report as PDF"` |
| Sortable column header | `aria-sort="ascending"` / `aria-sort="descending"` / `aria-sort="none"` |
| Pagination Previous | `aria-label="Go to previous page"` / `aria-disabled="true"` on first page |
| Pagination Next | `aria-label="Go to next page"` / `aria-disabled="true"` on last page |

### Data Table

- The `<table>` element includes `role="grid"` to signal interactive sorting
- Column headers use `<th scope="col">` with `aria-sort` updated on click
- Table caption (visually hidden): `<caption className="sr-only">Report results</caption>`
- Empty state container uses `role="status"` so screen readers announce when it appears

### Keyboard Navigation

- Tab → moves between tab triggers, filter controls, table headers, pagination, and export buttons in DOM order
- Arrow keys → navigate between tab triggers when a tab trigger has focus
- Enter / Space → activates the focused tab or button
- Sortable column headers activate on Enter or Space

### Color Independence

- Status badges in report tables include text labels alongside color (e.g., "Completed" badge uses green background but also shows the word, never color alone)
- Summary cards include descriptive labels, not only numbers and colors

### RTL Notes

- When the UI language is Arabic, the layout direction switches to `dir="rtl"` on the `<html>` element
- Numeric values (revenue amounts, counts) remain `dir="ltr"` within their cells using `unicode-bidi: isolate` to prevent digit reversal
- Date fields display in `DD/MM/YYYY` format for Arabic locale
- Column order in the table is preserved (left-to-right column progression becomes right-to-left in RTL); the first column in the data model appears on the right edge in Arabic layout
- The "From" / "To" date range direction: in Arabic, the "From" field (من) is on the right, "To" (إلى) is on the left
- Arabic number formatting: Arabic-Indic numerals (`٠١٢٣٤٥٦٧٨٩`) are used for data values when the locale is `ar-EG`

---

*DOC-06-P17 · v0.2 · 2026-05-24 · Physical Therapy Clinic Management System*
