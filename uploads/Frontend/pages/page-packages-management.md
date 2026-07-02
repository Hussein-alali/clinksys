# Page: Packages Management

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P11 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Packages Management page. |
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
| **URL Route** | `/packages` |
| **Auth Required** | Yes |
| **Allowed Roles** | Admin only |
| **Unauthorized Redirect** | All other roles → role-home page; unauthenticated → `/` |
| **RTL Support** | Yes |

---

## Page Purpose

The Packages Management page is the Admin's tool for defining and maintaining the clinic's service packages — the bundled session offerings sold to patients. Packages form the foundation of the billing system: when a payment is created, staff select a package, which determines the session count and default price. This page allows Admins to create new packages, edit existing ones, toggle their availability (active/inactive), and monitor purchase frequency.

Key behaviors:
- Inactive packages are hidden from the payment creation form but preserve all historical purchase records.
- Deactivating a package does not affect existing purchased packages or patient sessions.

---

## Data Fetching (API Endpoints Consumed)

| Data | Query | Trigger |
|---|---|---|
| All packages | `packages` SELECT `id, name, sessions_count, price, status, description, created_at` + subquery count of `payments WHERE package_id = id` AS `total_purchases` ORDER BY `status desc, name asc` | Page load |
| Create package | INSERT into `packages` | Add dialog submit |
| Update package | PATCH `packages` WHERE `id = [id]` | Edit dialog submit |
| Toggle status | PATCH `packages` SET `status = active/inactive` WHERE `id = [id]` | Toggle confirmation |
| Name uniqueness check | SELECT count WHERE `name ilike [name] AND id != [currentId]` | Debounced on name input |

---

## Component Breakdown

### Page Header
- `<h1>` "Packages" (Figtree 700 24px) + `<Button>` "Add Package" (`Plus` icon, `bg-cyan-600`) — right-aligned

### Packages Table
`<DataTable>` with:

| Column | Width | Content |
|---|---|---|
| Name | auto | Package name — Figtree 500 `text-slate-900`. Inactive packages: `opacity-60 text-slate-400` |
| Sessions | 100px | Integer (e.g., "12 sessions") |
| Price | 120px | Formatted: "3,000 EGP" — `font-mono text-slate-700` |
| Status | 100px | `<StatusBadge>`: Active = `bg-green-100 text-green-700` / Inactive = `bg-slate-100 text-slate-400` |
| Total Purchases | 110px | Integer count — `text-slate-600` |
| Actions | 100px | Two icon buttons: `<Button variant="ghost" size="icon">` `Pencil` (edit) + `<Button variant="ghost" size="icon">` `ToggleLeft`/`ToggleRight` (toggle status) |

Inactive rows rendered with `opacity-60` on the entire row to visually de-emphasize without hiding.

### Add / Edit Package Dialog
Shadcn `<Dialog>` (same component for add and edit, pre-populated for edit):

**Dialog title:** "Add Package" / "Edit Package"

| Field | Component | Notes |
|---|---|---|
| Package Name * | `<Input>` | Required, unique. Shows `<Loader2>` during uniqueness check, then `<CheckCircle>` green or `<XCircle>` red. |
| Number of Sessions * | `<Input type="number">` | Min 1, max 500. Step 1. |
| Price (EGP) * | `<Input type="number">` | Min 1. No decimals (integer EGP). Formats with commas on blur. |
| Description | `<Textarea>` | Optional. 2 rows. Max 300 chars. |

Dialog footer: `[Cancel]` `[Save Package]` (disabled during loading or validation error).

On submit (add): INSERT + success toast "Package created." + dialog closes + table refreshes.
On submit (edit): PATCH + success toast "Package updated." + dialog closes + table refreshes.

### Toggle Status Confirmation Dialog
Shadcn `<AlertDialog>`:
- **Deactivate:** "Deactivate '[Package Name]'? This package will no longer be available for new payments. **This will not affect existing purchased packages.**" → [Cancel] [Deactivate]
- **Activate:** "Activate '[Package Name]'? It will become available for new payment records." → [Cancel] [Activate]

---

## UI States (Loading, Empty, Error, Success)

### Page Load — Loading
Table body shows 5 skeleton rows, each with skeleton bars at column widths.

### Empty State
```
        [Package icon (Box) — 64px — text-slate-300]
        No packages defined.
        Create your first service package to get started.
        [+ Add Package] (cyan button)
```
Centered in the table body area.

### Dialog — Name Already Taken
`<XCircle className="text-red-500">` inline indicator + field error: "A package with this name already exists."

### Toggle — Loading
Toggle icon button shows `<Loader2 animate-spin>` (same size) during the PATCH request. Other actions in the row disabled.

### Toggle — Success
Status badge updates immediately (optimistic update). Toast: "'[Package Name]' has been deactivated." / "activated."

### Table Action — Error
Toast (red): "Failed to update package. Please try again."

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │  Packages                             [+ Add Package]   │
│            │  ──────────────────────────────────────────────────     │
│            │  ┌────────────────┬────────┬──────────┬──────┬───────┐  │
│            │  │ Name           │Sessions│ Price    │Status│Actions│  │
│            │  ├────────────────┼────────┼──────────┼──────┼───────┤  │
│            │  │ Basic Plan     │ 10     │ 2,000 EGP│Active│[✏][⊙]│  │
│            │  │ Premium Plan   │ 20     │ 3,500 EGP│Active│[✏][⊙]│  │
│            │  │ Starter Pack   │  5     │   900 EGP│Inact.│[✏][⊙]│  │
│            │  └────────────────┴────────┴──────────┴──────┴───────┘  │
└──────────────────────────────────────────────────────────────────────┘

  ┌──── Add Package Dialog ──────────────────────────────────────┐
  │  Package Name *     [________________________]  [✓ Available] │
  │  Sessions *         [  12  ]                                  │
  │  Price (EGP) *      [  3,000  ]                               │
  │  Description        [textarea (optional)]                     │
  │                               [Cancel]  [Save Package]        │
  └──────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

| Field | Rule | Error Message |
|---|---|---|
| Package Name | Required, 2–100 chars | "Package name is required." |
| Package Name | Unique (server check, debounced) | "A package with this name already exists." |
| Sessions | Required, integer 1–500 | "Sessions must be between 1 and 500." |
| Price | Required, integer ≥ 1 | "Price must be at least 1 EGP." |
| Description | Optional, max 300 chars | "Description must not exceed 300 characters." |

Zod schema client + server. React Hook Form. Submit blocked on any error.

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Sidebar navigation (Admin only — "Packages" menu item under Billing or Settings section)
- Direct URL `/packages`

### Exit Points
- "Add Package" → opens dialog (no navigation)
- Edit icon → opens dialog (no navigation)
- Toggle icon → opens AlertDialog (no navigation)
- Sidebar links → respective pages

The Packages page has no child pages. All interactions are dialog-based.

---

## Responsive Behavior

| Breakpoint | Layout |
|---|---|
| Mobile (`< 640px`) | Table becomes card list. Each package = card: Name (bold), Sessions + Price in a row, Status badge, Edit + Toggle icon buttons. "Add Package" button full-width at top. Dialogs become full-width bottom `<Sheet>` drawers. |
| Tablet (`640px–1024px`) | Full table, slightly compressed columns. Dialogs as centered modals. |
| Desktop (`> 1024px`) | Full layout as designed. |

---

## Accessibility Notes

- Table has `<caption className="sr-only">Service packages</caption>`.
- Status badge uses text + color.
- Toggle button: `aria-label="Deactivate [Package Name]"` / `"Activate [Package Name]"` — updates dynamically with package name.
- Edit button: `aria-label="Edit [Package Name]"`.
- Dialog: `aria-labelledby` points to dialog title. Focus trapped within dialog. Escape closes.
- Name uniqueness: status announced via `aria-live="polite"` region adjacent to input.
- Price input: `aria-label="Price in Egyptian Pounds"`. No currency symbol inside the input (shown as suffix label).
- AlertDialog: `role="alertdialog"`, `aria-describedby` points to the body text.

### RTL Considerations
- Table column order mirrors in RTL (Name on right, Actions on left).
- Dialog fields: labels right-aligned, inputs `dir="ltr"` for numeric fields (sessions, price), `dir="rtl"` for name and description.
- Status badge text in Arabic: "نشط" (Active) / "غير نشط" (Inactive).
- Price formatting in Arabic: "٣٬٠٠٠ ج.م" using `ar-EG` locale.
- Toggle icon uses `ToggleRight` (active) / `ToggleLeft` (inactive) — semantics preserved in both directions.

---

*DOC-06-P11 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
