# Navigation Structure

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-002 |
| **Version** | 1.0 |
| **Status** | Complete |
| **Date** | 2026-05-24 |
| **Purpose** | Complete navigation architecture: sidebar, breadcrumbs, routing, role visibility. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | role-comparison-matrix.md |
| **Priority** | P1 |
| **Estimated Pages** | 8–12 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / UX Designer | Initial stub |
| 1.0 | 2026-05-24 | Frontend Engineer / UX Designer | Full documentation |

---

## Table of Contents

- [Route Map (all routes + access roles)](#route-map-all-routes--access-roles)
- [Sidebar Navigation Tree per Role](#sidebar-navigation-tree-per-role)
- [Breadcrumb Rules](#breadcrumb-rules)
- [Redirect Rules](#redirect-rules)
- [Active State Logic](#active-state-logic)
- [Mobile Navigation (Hamburger, Bottom Nav)](#mobile-navigation-hamburger-bottom-nav)

---

## Route Map (all routes + access roles)

All routes are protected by Next.js middleware (cookie presence check) and server-side role verification. Unauthenticated users are redirected to `/login`. Authenticated users who access a route outside their role are redirected to their default landing page.

| Route | Page | Admin | Receptionist | Doctor | Therapist | Patient |
|---|---|---|---|---|---|---|
| `/login` | Login | Public | Public | Public | Public | Public |
| `/dashboard` | Admin Dashboard | Full | Simplified | — | — | — |
| `/patients` | Patient List | Full | Full | Read | Assigned only | — |
| `/patients/new` | Create Patient | Full | Full | — | — | — |
| `/patients/[id]` | Patient Profile | Full | Full | Read (clinical tabs) | Assigned only | Own only |
| `/appointments` | Appointment Calendar | Full | Full | Own | Own schedule | — |
| `/appointments/today` | Today's Schedule | Full | Full | Own | Own | — |
| `/appointments/[id]` | Appointment Detail | Full | Full | Own | Own | Own (read) |
| `/treatment-plans` | Treatment Plans List | Full | Read | Full | Read (assigned) | — |
| `/treatment-plans/new` | Create Treatment Plan | Full | — | Full | — | — |
| `/treatment-plans/[id]` | Treatment Plan Detail | Full | Read | Full | Read | — |
| `/sessions` | Session Log List | Full | Read | Read | Own | — |
| `/sessions/[id]` | Session Detail | Full | Read | Read | Own | — |
| `/packages` | Package Management | Full | Read | — | — | — |
| `/payments` | Payment List | Full | Full | — | — | Own (read) |
| `/payments/new` | Create Payment | Full | Full | — | — | — |
| `/invoices` | Invoice List | Full | Full | — | — | Own (read) |
| `/reports` | Reports Hub | Full | Financial only | Clinical only | — | — |
| `/campaigns` | Campaign List | Full | — | — | — | — |
| `/campaigns/new` | Campaign Builder | Full | — | — | — | — |
| `/campaigns/[id]` | Campaign Detail | Full | — | — | — | — |
| `/users` | User Management | Full | — | — | — | — |
| `/settings` | Clinic Settings | Full | — | — | — | — |
| `/my-appointments` | Patient Portal | — | — | — | — | Full |

### Notation

- **Full** — Read + Write + Delete where applicable
- **Read** — View only, no create/edit/delete
- **—** — Route is inaccessible; hidden from nav and returns redirect

---

## Sidebar Navigation Tree per Role

The sidebar is 260px wide on desktop. Each nav item uses `min-h-[44px]` to satisfy touch target requirements. Inactive items that are inaccessible to the current role are **hidden**, never greyed out.

### Visual Structure

```
┌──────────────────────────────────┐
│  [Clinic Logo]  PTCMS           │   h-16 top bar
│                                  │
│  ──────────────────────────────  │
│                                  │
│  [Icon] Nav Item Label           │   h-11 each item
│  [Icon] Nav Item (Active)  ████  │   active: right border + bg-cyan-50
│  [Icon] Nav Item Label           │
│                                  │
│  ── Section Divider ──           │   section grouping
│                                  │
│  [Icon] Nav Item Label           │
│                                  │
│  ──────────────────────────────  │
│                                  │
│  [Avatar] User Name              │   user footer
│           Role Badge             │
│  [LogOut icon]                   │
└──────────────────────────────────┘
```

### Admin Navigation (Full)

```
[LayoutDashboard]  Dashboard
[Users]            Patients
[Calendar]         Appointments
[ClipboardList]    Treatment Plans
[Activity]         Sessions
[Package]          Packages
[CreditCard]       Payments
[FileText]         Invoices
[BarChart2]        Reports
[Megaphone]        Campaigns
[UserCog]          Users
[Settings]         Settings
```

### Receptionist Navigation

```
[CalendarDays]     Appointments
[Users]            Patients
[CreditCard]       Payments
[FileText]         Invoices
[BarChart2]        Reports
```

> Receptionist's Dashboard is a simplified version at `/dashboard` showing only today's appointments and daily payment summary — not the full KPI admin view.

### Doctor Navigation

```
[Users]            Patients
[Calendar]         Appointments
[ClipboardList]    Treatment Plans
[Activity]         Sessions (read)
[BarChart2]        Reports (clinical)
```

### Therapist Navigation

```
[CalendarCheck]    Today's Schedule
[Calendar]         Appointments
[Activity]         Sessions
[Users]            Patients (assigned)
```

### Patient Navigation (Simplified Portal)

```
[CalendarDays]     My Appointments
[FileText]         My Invoices
```

### Nav Item TypeScript Interface

```tsx
interface NavItem {
  label: string;        // Displayed label (localized)
  labelAr: string;      // Arabic label
  href: string;         // Route path
  icon: LucideIcon;     // Lucide icon component
  roles: Role[];        // Roles that can see this item
  badge?: number;       // Optional notification count
  exact?: boolean;      // Use exact match for active state (default: false)
}

type Role = 'admin' | 'receptionist' | 'doctor' | 'therapist' | 'patient';
```

---

## Breadcrumb Rules

Breadcrumbs appear on all pages below the sidebar. They reflect the current location in the hierarchy. The final segment (current page) is not a link.

### Breadcrumb Component

```tsx
// Located at the top of the main content area, below the page header
<nav aria-label="Breadcrumb">
  <ol className="flex items-center gap-1.5 text-sm text-slate-500">
    <li>
      <Link href="/dashboard" className="hover:text-cyan-700 transition-colors">
        Home
      </Link>
    </li>
    <li aria-hidden="true"><ChevronRight className="h-3.5 w-3.5" /></li>
    <li>
      <Link href="/patients" className="hover:text-cyan-700 transition-colors">
        Patients
      </Link>
    </li>
    <li aria-hidden="true"><ChevronRight className="h-3.5 w-3.5" /></li>
    <li aria-current="page" className="text-slate-900 font-medium">
      Fatima Ahmed
    </li>
  </ol>
</nav>
```

### Breadcrumb Hierarchy

| Page | Breadcrumb |
|---|---|
| Dashboard | Home |
| Patients List | Home › Patients |
| Patient Profile | Home › Patients › [Patient Name] |
| Create Patient | Home › Patients › New Patient |
| Appointments | Home › Appointments |
| Appointment Detail | Home › Appointments › [Date & Time] |
| Treatment Plans List | Home › Treatment Plans |
| Treatment Plan Detail | Home › Patients › [Name] › Treatment Plan |
| Create Treatment Plan | Home › Treatment Plans › New Plan |
| Session Detail | Home › Patients › [Name] › Sessions › Session [#] |
| Packages | Home › Packages |
| Payments | Home › Payments |
| Create Payment | Home › Payments › New Payment |
| Invoices | Home › Invoices |
| Reports | Home › Reports |
| Campaigns | Home › Campaigns |
| Campaign Detail | Home › Campaigns › [Campaign Name] |
| Users | Home › Settings › Users |
| Settings | Home › Settings |

### RTL Breadcrumbs

When `dir="rtl"`, breadcrumb chevrons flip direction automatically via `transform: scaleX(-1)` or replace with `ChevronLeft`. The reading order remains logical left-to-right in LTR and right-to-left in RTL.

---

## Redirect Rules

### Post-Login Redirect

After successful login, users are redirected based on role:

| Role | Default Landing Page | Rationale |
|---|---|---|
| Admin | `/dashboard` | Immediate operational overview |
| Receptionist | `/appointments` | First task is managing today's appointments |
| Doctor | `/patients` | Clinical work starts with patient lookup |
| Therapist | `/appointments/today` | Therapist needs today's schedule first |
| Patient | `/my-appointments` | Patient sees their own appointments |

If the login URL contains a `?next=/path` query parameter (set by middleware on unauthorized access), redirect there instead of the default — after verifying the path is within the user's allowed routes.

### Unauthorized Access Redirect

When a user accesses a route not in their allowed list:

1. Middleware (edge level) detects cookie presence
2. Server component performs full role check
3. If role mismatch: call `redirect(getRoleDefaultRoute(role))`
4. Toast displayed on arrival: "You don't have access to that page."

```tsx
function getRoleDefaultRoute(role: Role): string {
  const defaults: Record<Role, string> = {
    admin: '/dashboard',
    receptionist: '/appointments',
    doctor: '/patients',
    therapist: '/appointments/today',
    patient: '/my-appointments',
  };
  return defaults[role];
}
```

### Post-Action Redirects

| Action | Redirect Destination |
|---|---|
| Create patient → Save | `/patients/[new-id]` (profile page) |
| Create treatment plan → Save | `/treatment-plans/[new-id]` |
| Log session → Save | Back to appointment detail (`/appointments/[id]`) |
| Create payment → Save | `/invoices/[auto-generated-id]` |
| Delete patient (soft delete) | `/patients` list |
| Logout | `/login` |

---

## Active State Logic

### Sidebar Active Item

A nav item is considered "active" when the current pathname matches the item's `href`. By default, a prefix match is used (e.g., `/patients/123` activates the `Patients` nav item). Items with `exact: true` only activate on exact match.

```tsx
function isNavItemActive(href: string, pathname: string, exact = false): boolean {
  if (exact) return pathname === href;
  return pathname === href || pathname.startsWith(href + '/');
}
```

**Active styles:**
```
bg-cyan-50 text-cyan-700 border-s-2 border-cyan-600 font-medium
```

**Inactive styles:**
```
text-slate-600 hover:bg-slate-50 hover:text-slate-900
```

**Icon color:**
- Active: `text-cyan-600`
- Inactive: `text-slate-400`
- Hover: `text-slate-600`

### Collapsible Sidebar (Icon-only at Tablet)

At the 768px–1023px breakpoint, the sidebar collapses to 64px width showing icons only. The active state is preserved visually via the left border on the icon. A tooltip appears on hover showing the nav item label.

```tsx
<Tooltip>
  <TooltipTrigger asChild>
    <Link href={item.href} className={navItemClasses}>
      <item.icon className="h-5 w-5" />
      {!isCollapsed && <span className="ms-3">{item.label}</span>}
    </Link>
  </TooltipTrigger>
  {isCollapsed && (
    <TooltipContent side="end">
      <p>{item.label}</p>
    </TooltipContent>
  )}
</Tooltip>
```

---

## Mobile Navigation (Hamburger, Bottom Nav)

### Mobile Layout (< 768px)

On mobile, the sidebar is hidden by default. Navigation is provided via:
1. **Top bar hamburger** — opens a full-height drawer from the left (RTL: from the right)
2. **Bottom navigation bar** — shows the 4–5 most important nav items for the current role

### Hamburger Drawer

```
┌──────────────────────┐
│  [×]  PTCMS         │   top bar with close button
│                      │
│  ─────────────────   │
│                      │
│  [Icon] Dashboard    │
│  [Icon] Patients     │
│  [Icon] Appointments │
│  [Icon] Payments     │
│  [Icon] Reports      │
│                      │
│  ─────────────────   │
│                      │
│  [Avatar] Name       │
│  Role: Admin         │
│  [LogOut] Logout     │
│                      │
└──────────────────────┘
```

**Specs:**
- Width: 280px (leaves partial overlay on the right for visual context)
- Overlay: `bg-slate-900/50` backdrop behind the drawer
- Open animation: `translate-x-0` from `-translate-x-full` (LTR) or `translate-x-full` (RTL)
- Duration: `duration-250 ease-out`
- Close: tap outside, tap `×`, or press `Escape`
- Focus trap active while open

**Accessibility:**
```tsx
<Sheet>
  <SheetTrigger asChild>
    <Button variant="ghost" size="icon" aria-label="Open navigation menu">
      <Menu className="h-5 w-5" />
    </Button>
  </SheetTrigger>
  <SheetContent side="left" aria-label="Navigation menu">
    {/* Nav items */}
  </SheetContent>
</Sheet>
```

### Bottom Navigation Bar

Visible only on mobile (`md:hidden`). Shows role-appropriate shortcuts:

**Admin bottom nav:**
```
[LayoutDashboard]  [Users]  [Calendar]  [CreditCard]  [Menu]
   Dashboard      Patients  Appointments  Payments    More
```

**Receptionist bottom nav:**
```
[Calendar]  [Users]  [CreditCard]  [FileText]  [Menu]
Appointments Patients  Payments    Invoices    More
```

**Therapist bottom nav:**
```
[CalendarCheck]  [Calendar]  [Activity]  [Users]  [Menu]
   Today         Calendar    Sessions   Patients  More
```

**Bottom nav specs:**
- Fixed to bottom: `fixed bottom-0 inset-x-0 z-20`
- Height: 56px (accommodates 44px touch targets + padding)
- Background: `bg-white border-t border-slate-200`
- Active item: `text-cyan-600` icon + label
- Inactive: `text-slate-500`
- "More" item opens the hamburger drawer for secondary nav items

### Keyboard Navigation

The sidebar and bottom nav support full keyboard navigation:

| Key | Behavior |
|---|---|
| `Tab` | Move focus to next nav item |
| `Shift+Tab` | Move focus to previous nav item |
| `Enter` / `Space` | Activate the focused nav item |
| `Escape` | Close hamburger drawer if open |
| `Home` | Move to first nav item (when sidebar focused) |
| `End` | Move to last nav item |

The sidebar has `role="navigation"` and `aria-label="Main navigation"`. The bottom nav has `role="navigation"` and `aria-label="Mobile navigation"`.

---

*DOC-06-002 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*
