# Page: User Management

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P18 |
| **Version** | 0.2 — In Progress |
| **Status** | In Progress |
| **Date** | 2026-06-01 |
| **Purpose** | UX specification for the User Management page. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | product-requirements-document.md, user-stories.md |
| **Priority** | P1 |
| **Estimated Pages** | 4–8 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / UX Designer | Initial stub |
| 0.2 | 2026-06-01 | Frontend Engineer / UX Designer | Full specification completed |

---

## Table of Contents

- [Route & Access Control](#route--access-control)
- [Page Purpose](#page-purpose)
- [TypeScript Interfaces](#typescript-interfaces)
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
| **URL Route** | `/users` |
| **Next.js File** | `app/(dashboard)/users/page.tsx` |
| **Authentication** | Required — redirect to `/login` if unauthenticated |
| **Authorized Roles** | Admin only |
| **Query Params** | `?role={role}` (pre-selects the role filter tab on load); `?search={term}` (pre-fills search) |

Non-Admin sessions are redirected server-side to `/dashboard`. The redirect happens in the Next.js middleware before the page component renders, so no user list data is ever returned to unauthorized sessions.

The Supabase RLS policy for the `users` table's admin read policy enforces this at the database level as a defence-in-depth layer — even if the middleware redirect were somehow bypassed, the RLS policy would return an empty result set for non-admin roles.

---

## Page Purpose

The User Management page is the central administrative interface for managing all human accounts in the PTCMS system. It covers five roles: `admin`, `receptionist`, `doctor`, `therapist`, and `patient`. The admin can:

- **Audit** all user accounts — who has access, what role they hold, when they last logged in, and whether their account is active
- **Invite** new staff members by email; Supabase sends a magic link enabling the new user to set up their account
- **Edit** any user's role, deactivate or reactivate their account, or trigger a password reset
- **Deactivate** staff accounts when an employee leaves, using soft delete (the record is retained for audit purposes; the user cannot log in)
- **Bulk deactivate** a selection of accounts in a single action

The page does not handle patient registration (patients are created via the patient management module). However, patient accounts created via Supabase auth appear in this user list so that an admin can deactivate a patient's app access if needed.

---

## TypeScript Interfaces

```typescript
// Full user record as returned by the API
interface User {
  id: string;                    // Supabase auth.users UUID
  full_name: string;
  email: string;
  role: UserRole;
  status: 'active' | 'inactive';
  last_sign_in_at: string | null;  // ISO 8601
  created_at: string;              // ISO 8601
  invited_by: string | null;       // UUID of admin who invited this user
  avatar_url: string | null;
}

type UserRole = 'admin' | 'receptionist' | 'doctor' | 'therapist' | 'patient';

// Paginated response from /api/users
interface UsersListResponse {
  data: User[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
}

// Invite user request body
interface InviteUserRequest {
  email: string;
  full_name: string;
  role: Exclude<UserRole, 'patient'>;  // Patients cannot be invited via this form
}

// Edit user request body
interface EditUserRequest {
  full_name?: string;
  role?: UserRole;
  status?: 'active' | 'inactive';
}

// Bulk action request body
interface BulkActionRequest {
  user_ids: string[];
  action: 'deactivate' | 'activate';
}
```

---

## Data Fetching (API Endpoints Consumed)

### Page Load

| Action | Method | Endpoint | Notes |
|---|---|---|---|
| Fetch users list | GET | `/api/users?page=1&per_page=50&role={role}&search={term}` | Server-side rendered initial page |
| Fetch role counts | GET | `/api/users/counts` | Returns `{ admin: 2, receptionist: 3, doctor: 5, therapist: 8, patient: 124 }` — used for tab badges |

Both requests run in parallel in the server component using `Promise.all`.

### Client-Side Interactions

| Action | Method | Endpoint | Payload | Notes |
|---|---|---|---|---|
| Invite user | POST | `/api/users/invite` | `InviteUserRequest` | Triggers Supabase magic link invitation email |
| Edit user | PATCH | `/api/users/{id}` | `EditUserRequest` | Partial update; returns updated `User` |
| Deactivate user | PATCH | `/api/users/{id}` | `{ status: 'inactive' }` | Soft delete; user cannot log in |
| Activate user | PATCH | `/api/users/{id}` | `{ status: 'active' }` | Reactivates a deactivated account |
| Reset password | POST | `/api/users/{id}/reset-password` | `{}` | Sends Supabase magic link to user's email |
| Bulk action | POST | `/api/users/bulk` | `BulkActionRequest` | Deactivate or activate multiple users |
| Fetch next page | GET | `/api/users?page={n}&per_page=50&role={role}&search={term}` | — | Triggered by pagination |

### RLS Policy (Admin Read All Users)

```sql
-- Admin can read all users regardless of role
CREATE POLICY "admin_read_all_users"
ON users FOR SELECT
USING (
  (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
);

-- All other roles: cannot read the users table via this page
-- (they access their own profile via a separate /api/me endpoint)
```

---

## Component Breakdown

### Page Header

| Component | Role |
|---|---|
| `PageHeader` | Title "User Management" (h1) + subtitle "Manage staff and patient accounts" |
| `InviteUserButton` | "Invite User" button (cyan, `UserPlus` icon) — opens `InviteUserModal` |

### Role Filter Tabs

A `Tabs` component (Shadcn/UI) with 6 tabs. Each tab label includes a count badge populated from `/api/users/counts`:

| Tab | Label | Badge | Filter Applied |
|---|---|---|---|
| All | All | Total count | No role filter |
| Admin | Admin | `counts.admin` | `?role=admin` |
| Receptionist | Receptionist | `counts.receptionist` | `?role=receptionist` |
| Doctor | Doctor | `counts.doctor` | `?role=doctor` |
| Therapist | Therapist | `counts.therapist` | `?role=therapist` |
| Patient | Patient | `counts.patient` | `?role=patient` |

Selecting a tab updates the URL query param (`?role=doctor`) and refetches the user list. The tab state is derived from the URL — no local state needed.

### Search Bar

A `SearchInput` component above the table:
- Placeholder: "Search by name or email…"
- 300ms debounce before triggering API refetch
- Updates `?search=` query param in the URL
- Clears with an `X` button when populated

### Users Data Table

A `DataTable` component (Shadcn/UI `Table` + custom pagination) rendering the user list.

**Columns:**

| Column | Content | Width |
|---|---|---|
| Checkbox | Row selection for bulk actions | 40px |
| User | Avatar (32px circle) + full name (bold) + email (muted, below name) | Flexible |
| Role | `RoleBadge` — color-coded role label | 120px |
| Status | `StatusBadge` — green "Active" or grey "Inactive" | 100px |
| Last Login | Relative time ("3 days ago") with full datetime tooltip; "Never" if null | 140px |
| Created | Short date format "12 Jan 2026" | 100px |
| Actions | `UserActionsMenu` — three-dot kebab menu | 48px |

**`RoleBadge` colors:**

| Role | Background | Text |
|---|---|---|
| `admin` | `bg-purple-100` | `text-purple-700` |
| `receptionist` | `bg-blue-100` | `text-blue-700` |
| `doctor` | `bg-cyan-100` | `text-cyan-700` |
| `therapist` | `bg-teal-100` | `text-teal-700` |
| `patient` | `bg-slate-100` | `text-slate-600` |

**`UserActionsMenu` items (three-dot kebab, `DropdownMenu` from Shadcn):**

| Action | Condition | Description |
|---|---|---|
| Edit User | Always shown | Opens `EditUserDrawer` |
| Reset Password | Always shown | Sends magic link; shows `toast.success("Password reset email sent.")` |
| Deactivate | Status = `active` | Opens `DeactivateUserDialog` |
| Activate | Status = `inactive` | Immediately reactivates; shows `toast.success("User activated.")` |

The admin cannot deactivate their own account via this menu. If `user.id === currentUser.id`, the "Deactivate" option is hidden and replaced with a disabled item: "Cannot deactivate your own account."

### Bulk Actions Bar

A sticky bar that appears above the table when one or more rows are selected (checkbox checked):

```
┌─────────────────────────────────────────────────────────────────┐
│ ✓ 3 users selected    [Deactivate Selected]   [Clear Selection] │
└─────────────────────────────────────────────────────────────────┘
```

Clicking "Deactivate Selected" opens a confirmation dialog before executing the bulk action. The bulk action bar is hidden when no rows are selected.

### Invite User Modal

A `Dialog` (Shadcn/UI) triggered by the "Invite User" button:

```
┌────────────────────────────────────────────┐
│  Invite New User                        ×  │
├────────────────────────────────────────────┤
│  Full Name *                               │
│  [_________________________________]       │
│                                            │
│  Email Address *                           │
│  [_________________________________]       │
│                                            │
│  Role *                                    │
│  [Select role ▼]                           │
│   • Admin                                  │
│   • Receptionist                           │
│   • Doctor                                 │
│   • Therapist                              │
│  (Patient is not available via invitation) │
│                                            │
│  A magic link will be sent to this email.  │
│  The user must click it to activate their  │
│  account within 24 hours.                  │
│                                            │
│  [Cancel]              [Send Invitation]   │
└────────────────────────────────────────────┘
```

On "Send Invitation": calls `POST /api/users/invite`. On success: modal closes, `toast.success("Invitation sent to {email}.")`, and the user list is refreshed to show the newly invited user (status: "Active" pending magic link click, with a "Pending" indicator on last login).

### Edit User Drawer

A `Sheet` (Shadcn/UI) sliding in from the right when "Edit User" is selected from the kebab menu:

```
┌──────────────────────────────────┐
│  Edit User                  [×]  │
│  Sara Mahmoud                    │
│  sara@example.com                │
├──────────────────────────────────┤
│  Full Name                       │
│  [Sara Mahmoud______________]    │
│                                  │
│  Role                            │
│  [Therapist ▼]                   │
│                                  │
│  Account Status                  │
│  [● Active  ○ Inactive]          │
│                                  │
│  ─────────────────────────────   │
│  Actions                         │
│  [Reset Password]                │
│                                  │
│  [Cancel]         [Save Changes] │
└──────────────────────────────────┘
```

The drawer pre-populates all fields from the existing user record. Changing the role updates the user's PTCMS permissions immediately on save. The drawer validates that an admin cannot change their own role or deactivate their own account.

### Deactivate User Confirmation Dialog

A `AlertDialog` (Shadcn/UI) requiring explicit confirmation before soft-deleting:

```
┌────────────────────────────────────────────┐
│  Deactivate User Account                   │
├────────────────────────────────────────────┤
│  Are you sure you want to deactivate       │
│  Sara Mahmoud (sara@example.com)?          │
│                                            │
│  • They will be immediately signed out     │
│  • They cannot log in until reactivated    │
│  • Their data will not be deleted          │
│  • This action can be reversed             │
│                                            │
│  [Cancel]           [Deactivate Account]   │
└────────────────────────────────────────────┘
```

"Deactivate Account" button is styled with `variant="destructive"` (red). On confirm: calls `PATCH /api/users/{id}` with `{ status: 'inactive' }`. The API also calls `supabase.auth.admin.signOut(userId, { scope: 'global' })` to immediately invalidate all active sessions for that user.

---

## UI States (Loading, Empty, Error, Success)

### Initial Load — Skeleton

While the server component renders the initial page:
- Role tabs: visible but counts show `—` placeholder
- Table: 8 skeleton rows (avatar circle shimmer + text line shimmers for each column)

### Empty State (No Users Match Filter)

If the current role filter and search return 0 users:
- `Users` icon (48px, `text-slate-300`) centered
- "No users found" (heading)
- "Try adjusting your search or role filter." (body)
- If search is active: "Clear search" link to reset

### Error State

If `/api/users` returns a non-2xx response:
- `AlertCircle` icon (red, 48px) centered
- "Failed to load users"
- "Please try again." + "Retry" button that re-fires the request

### Invite Success

After a successful invitation:
- `toast.success("Invitation sent to sara@example.com.")` fires
- The newly invited user appears at the top of the list (sorted by `created_at DESC`)
- A "Pending" tag appears in the Last Login column: `Clock` icon + "Pending sign-in"

### Deactivation Success

After a user is deactivated:
- The row's status badge updates immediately from "Active" (green) to "Inactive" (grey) via optimistic UI update
- `toast.success("{full_name} has been deactivated.")` fires
- The kebab menu for that row updates: "Deactivate" → "Activate"

### Bulk Deactivation Success

After bulk deactivation:
- All selected rows' status badges update to "Inactive"
- `toast.success("3 users have been deactivated.")` fires
- Bulk actions bar hides and checkboxes are deselected

---

## Layout Wireframe / Mockup Reference

```
┌──────────────────────────────────────────────────────────────────┐
│  User Management                           [+ Invite User]        │
├──────────────────────────────────────────────────────────────────┤
│  [All 142] [Admin 2] [Receptionist 3] [Doctor 5] [Therapist 8]  │
│  [Patient 124]                                                    │
├──────────────────────────────────────────────────────────────────┤
│  [🔍 Search by name or email...________________]                  │
│                                                                   │
│  ✓ 2 selected    [Deactivate Selected]   [Clear Selection]       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ □ │ User          │ Role        │ Status │ Last Login │ ⋮ │   │
│  │───┼───────────────┼─────────────┼────────┼────────────┼───│   │
│  │ ✓ │ ● Sara M.     │ [Therapist] │ Active │ 2 days ago │ ⋮ │   │
│  │   │   sara@...    │             │        │            │   │   │
│  │───┼───────────────┼─────────────┼────────┼────────────┼───│   │
│  │ ✓ │ ● Ahmed A.    │ [Doctor]    │ Active │ 5 hrs ago  │ ⋮ │   │
│  │   │   ahmed@...   │             │        │            │   │   │
│  │───┼───────────────┼─────────────┼────────┼────────────┼───│   │
│  │ □ │ ● Layla R.    │ [Admin]     │ Active │ just now   │ ⋮ │   │
│  │   │   layla@...   │             │        │            │   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  Showing 1–50 of 142     [← Prev]  1  2  3  [Next →]           │
└──────────────────────────────────────────────────────────────────┘
```

---

## Validation Rules

### Invite User Form

| Field | Rule | Error Message |
|---|---|---|
| Full Name | Required; 2–100 characters | "Full name is required." / "Name must be between 2 and 100 characters." |
| Email | Required; valid email format; must not already exist in `users` | "Email is required." / "Please enter a valid email address." / "This email is already registered." |
| Role | Required; must be one of `admin`, `receptionist`, `doctor`, `therapist` | "Please select a role." |

### Edit User Drawer

| Rule | Error Message |
|---|---|
| Full Name: required, 2–100 characters | Same as invite form |
| Role: required | "Please select a role." |
| Cannot set own role to a lower-privileged role | "You cannot change your own role." |
| Cannot deactivate own account | "You cannot deactivate your own account." |

### Bulk Deactivation

- A minimum of 1 user must be selected (enforced by hiding the bulk action bar when selection is empty)
- The current admin's own account must not be in the selection — if detected, an inline warning appears in the confirmation dialog: "Your account is in the selection and will be excluded from this action."

---

## Navigation Flows (Entry & Exit Points)

### Entry Points

| Source | How |
|---|---|
| Admin Sidebar | Click "Users" in the sidebar navigation |
| Role notification links | Emails or internal links with `?role=doctor` pre-selected |

### Exit Points

| Destination | Trigger |
|---|---|
| User Profile (`/users/{id}`) | Future: click user name in the table (not in V1) |
| Dashboard (`/dashboard`) | Breadcrumb or sidebar navigation |

---

## Responsive Behavior

### Desktop (1024px+)

- Role tabs: all 6 tabs in a single horizontal row
- Table: all columns visible
- Edit drawer: slides in at 480px width from the right, page content shifts left

### Tablet (768px–1023px)

- Role tabs: scrollable horizontally if they overflow
- Table: "Created" column hidden; horizontal scroll available
- Edit drawer: full-width overlay instead of side-panel on tablet

### Mobile (320px–767px)

- Role tabs: horizontally scrollable with `overflow-x: auto`; tab labels truncated to role name only (no count badge shown inline — count shown in a sub-header: "Showing 8 Therapists")
- Table: collapsed to 3 columns: User, Role, Actions. Tapping a row opens a bottom sheet with all user details and the full actions menu.
- "Invite User" button: icon-only on mobile (`UserPlus` icon, no label text); full label shown in tooltip on long press
- Bulk actions bar: shows only the action button ("Deactivate 3") without the "Clear Selection" link — clear is achieved by tapping the checkbox again

---

## Accessibility Notes

### Role Filter Tabs

The tab strip uses `role="tablist"` on the container and `role="tab"` on each tab button, with `aria-selected="true"` on the active tab and `aria-controls` pointing to the table region. Arrow key navigation moves between tabs.

### Users Table

- The table uses semantic `<table>`, `<thead>`, `<tbody>`, `<th>` elements (not `div`-based layout)
- `<th>` elements use `scope="col"` for column headers
- The selection checkbox column header uses `aria-label="Select all users on this page"`
- Each row checkbox uses `aria-label="Select {full_name}"` — identifies the specific user being selected
- The kebab menu button uses `aria-label="Actions for {full_name}"` and `aria-haspopup="menu"`

### Invite User Modal

- `role="dialog"`, `aria-modal="true"`, `aria-labelledby="invite-modal-title"`
- Focus is trapped within the modal while open; restores to the "Invite User" button on close
- Form validation errors use `aria-describedby` linking each input to its error message element; error messages use `role="alert"`

### Edit User Drawer

- `role="dialog"`, `aria-modal="true"`, `aria-labelledby="edit-user-drawer-title"`
- Focus moves to the first input (Full Name) when the drawer opens
- Focus returns to the kebab menu trigger for the edited row when the drawer closes

### Deactivate Confirmation Dialog

- `role="alertdialog"` (not `dialog`) — signals urgency to assistive technology
- `aria-labelledby` points to "Deactivate User Account" heading
- `aria-describedby` points to the consequence bullet points
- "Deactivate Account" button is focused by default when the dialog opens (not "Cancel") — matching the convention that destructive dialogs focus the cancel action; however, the destructive button here is intentionally focused as the user has already chosen "Deactivate" from the menu, indicating clear intent

### Color Independence

- Active/Inactive status badges use both color (green/grey) and text label — status is never conveyed by color alone
- Role badges use both color and text label
- Selected rows use both a cyan background tint and a checkbox checkmark — selection state is never color-only

---

*DOC-06-P18 · v0.2 · 2026-06-01 · Physical Therapy Clinic Management System*
