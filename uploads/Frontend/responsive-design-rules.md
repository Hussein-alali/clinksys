# Responsive Design Rules

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-003 |
| **Version** | 1.0 — Complete |
| **Status** | Review |
| **Date** | 2026-05-24 |
| **Purpose** | Breakpoint system, responsive behavior, and device-specific adaptations. |
| **Owner** | Frontend Engineer / UX Designer |
| **Dependencies** | design-system.md |
| **Priority** | P2 |
| **Estimated Pages** | 8–12 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | Frontend Engineer / UX Designer | Initial stub |
| 1.0 | 2026-05-24 | Frontend Engineer / UX Designer | Full content added |

---

## Table of Contents

- [Breakpoint Definitions (Mobile/Tablet/Desktop/Wide)](#breakpoint-definitions-mobiletabletdesktopwide)
- [Component Responsive Behavior Matrix](#component-responsive-behavior-matrix)
- [Mobile-Critical Touch Rules](#mobile-critical-touch-rules)
- [Typography Responsive Scale](#typography-responsive-scale)
- [Image Responsive Strategy](#image-responsive-strategy)

---

## Breakpoint Definitions (Mobile/Tablet/Desktop/Wide)

The PTCMS breakpoint system uses five named breakpoints aligned with Tailwind CSS v3 prefix conventions. All breakpoints are `min-width` (mobile-first).

| Breakpoint Name | Min Width | Tailwind Prefix | Primary Device Target |
|---|---|---|---|
| `mobile-sm` | 375px | (no prefix — default) | Small smartphones (iPhone SE) |
| `mobile-lg` | 640px | `sm:` | Large smartphones, phablets |
| `tablet` | 768px | `md:` | Tablets (iPad portrait) |
| `desktop-sm` | 1024px | `lg:` | Small laptops, iPads landscape |
| `desktop-lg` | 1440px | `xl:` | Standard clinic desktop monitors |

### Tailwind Config Extension

```js
// tailwind.config.ts
module.exports = {
  theme: {
    screens: {
      sm: '640px',   // mobile-lg
      md: '768px',   // tablet
      lg: '1024px',  // desktop-sm
      xl: '1440px',  // desktop-lg
      // Default 2xl: '1536px' retained for ultra-wide monitors
    },
  },
};
```

### Layout Shifts at Each Breakpoint

#### Default (< 640px) — Small Mobile

- **Navigation**: Sidebar collapses entirely. Bottom navigation bar with 5 icon tabs appears (Home, Appointments, Patients, Sessions, Menu).
- **Content area**: Full viewport width. No side padding above 16px.
- **Page header**: Title + action button stacked vertically.
- **Forms**: Single-column layout. All form fields full-width.
- **Tables**: Horizontally scrollable within a scroll container (`overflow-x: auto`). Minimum table width 640px preserved.
- **Calendar**: Switches from monthly grid to chronological list view (day groups). FAB (+) button visible bottom-right.
- **KPI cards**: 2 per row (half-width).
- **Charts**: Full width, stacked vertically.
- **Modals/Sheets**: Full-screen (100vw, 100vh) with close button top-right.

#### sm: (640px–767px) — Large Mobile

- **Navigation**: Bottom nav retained.
- **Content area**: Horizontal padding increases to 24px.
- **Page header**: Title left, actions right (flex row).
- **Forms**: Single-column maintained.
- **Tables**: Horizontal scroll continues. Priority columns visible; secondary columns hidden with `hidden sm:table-cell`.
- **KPI cards**: 2 per row.
- **Modals**: Full-screen maintained.

#### md: (768px–1023px) — Tablet

- **Navigation**: Sidebar appears as a collapsible icon rail (64px wide, icons only). Tap to expand to 240px full sidebar.
- **Content area**: Sidebar offset applied. Main content fills remaining width.
- **Page header**: Title + breadcrumb left, actions right.
- **Forms**: 2-column grid where layout permits (patient create, payment create).
- **Tables**: Horizontal scroll removed for tables ≤ 6 columns. Wide tables remain scrollable.
- **Calendar**: Monthly grid view restored. Each cell shows up to 3 appointment cards; overflow shows "+N more" link.
- **KPI cards**: 4 per row.
- **Charts**: 2-column grid (Revenue Trend full-width, 3 smaller charts in 3-column below).
- **Modals**: Centered with max-width 560px, backdrop dimmed.
- **Sheets (Side Drawers)**: 400px wide, slides in from right.

#### lg: (1024px–1439px) — Desktop Small

- **Navigation**: Full sidebar expanded by default (240px). Toggle to rail mode with collapse button.
- **Content area**: Main content area with 32px horizontal padding.
- **Forms**: 2-column standard. 3-column only for tightly grouped fields (time + date).
- **Tables**: All columns visible. Sort, filter bar visible above table.
- **KPI cards**: 4 per row.
- **Sheets**: 500px wide.
- **Text line length**: Max 75ch on body text blocks (`max-w-[75ch]`).

#### xl: (1440px+) — Desktop Large

- **Navigation**: Full sidebar with text labels always visible.
- **Content area**: Max content width 1280px, centered (`max-w-[1280px] mx-auto`).
- **KPI cards**: 4 per row, larger card padding (p-6).
- **Charts row**: Revenue Trend full-width. Below: 3 charts in `grid-cols-3`.
- **Tables**: Row density increases (compact mode available).
- **Dashboard**: 2-column split (70% main content, 30% activity feed) on very wide screens.

---

## Component Responsive Behavior Matrix

| Component | Default Mobile | sm: | md: Tablet | lg: Desktop | Notes |
|---|---|---|---|---|---|
| **AppSidebar** | Hidden — bottom nav | Hidden — bottom nav | Icon rail (64px) | Full (240px) | Toggle persisted in localStorage |
| **BottomNav** | Visible (5 tabs) | Visible | Hidden | Hidden | z-index: 50 |
| **PageHeader** | Stacked (title above, actions below) | Row layout | Row layout | Row layout with breadcrumb | |
| **DataTable** | Horizontal scroll | Horizontal scroll | Priority cols only | All cols visible | Use `hidden md:table-cell` for secondary cols |
| **Calendar** | List view | List view | Monthly grid | Monthly grid | List view uses `<AppointmentDayList>` |
| **KPI DataCard grid** | `grid-cols-2` | `grid-cols-2` | `grid-cols-4` | `grid-cols-4` | Cards expand on xl |
| **Charts grid** | `grid-cols-1` stacked | `grid-cols-1` | Revenue full-width, then `grid-cols-3` | Same | Charts have `min-h-[200px]` |
| **Form grid** | `grid-cols-1` | `grid-cols-1` | `grid-cols-2` | `grid-cols-2` | Override per form section |
| **Dialog/Modal** | Full-screen | Full-screen | Centered 560px max | Centered 600px max | Always has backdrop |
| **Sheet (Drawer)** | Full-screen | Full-screen | 400px slide-in | 500px slide-in | Appointment detail, patient notes |
| **FilterBar** | Collapsed behind "Filters" button | Expanded | Expanded inline | Expanded inline | |
| **Pagination** | Compact (prev/next only) | Show page numbers | Show page numbers | Show page numbers | |
| **PainSlider** | Full-width, large thumb (44px) | Full-width | Full-width | Max-width 480px centered | Touch optimized |
| **SignatureCanvas** | Full-width, 160px tall | Full-width 200px tall | 400px wide | 480px wide | Touch-enabled via pointer events |
| **FileUpload** | Tap-to-upload button (no drag zone) | Tap-to-upload | Drag-drop zone + browse | Drag-drop zone + browse | Drag-drop not reliable on touch |

---

## Mobile-Critical Touch Rules

All interactive elements on PTCMS must comply with the following touch target standards. These apply regardless of breakpoint but are validated and tested at the 375px mobile-sm breakpoint.

### Minimum Touch Target Size

**Rule**: Every tappable element must have a clickable area of at least **44×44 pixels** (WCAG 2.5.5 Target Size AAA).

Implementation patterns:

```tsx
// Pattern 1: padding on small elements
<button className="p-3 min-h-[44px] min-w-[44px]">
  <ChevronRight className="h-5 w-5" />
</button>

// Pattern 2: invisible hit area extension
<button className="relative p-2 before:absolute before:inset-[-10px]">
  <X className="h-4 w-4" />
</button>

// Pattern 3: explicit size override
<IconButton className="h-11 w-11 flex items-center justify-center" />
```

### Touch Target Spacing

- Minimum gap between adjacent touch targets: **8px** (to prevent mis-taps).
- On mobile, action buttons in table rows are replaced with a 3-dot `MoreHorizontal` menu (DropdownMenu) to consolidate touch targets.
- Radio card options (Progress Assessment in Session Log) have `min-h-[60px]` to make them thumb-friendly.

### Scrolling Behavior

- Use `overflow-y: auto` with `-webkit-overflow-scrolling: touch` (momentum scrolling on iOS).
- No horizontal scrolling on any page-level container. Horizontal scroll permitted only inside explicitly constrained `overflow-x-auto` wrappers (tables, code blocks).
- Pull-to-refresh is NOT implemented in v1.0 — use an explicit "Refresh" button for the activity feed.

### Form Input on Mobile

- All text inputs use `fontSize: 16px` minimum to prevent iOS Safari auto-zoom on focus.
- `inputmode` attributes applied:
  - Phone fields: `inputmode="tel"`
  - Number fields: `inputmode="numeric"`
  - Email fields: `inputmode="email"`
- Keyboard-aware scrolling: forms wrapped in containers that scroll to focused field (`scroll-mt-4`).
- Date pickers use native `<input type="date">` on mobile for OS-native date wheel pickers.

### Gesture Conflicts

- Horizontal swipe is NOT used for navigation (conflicts with browser back gesture).
- Long-press is NOT used as a primary action — all long-press actions have visible equivalents.
- Pinch-to-zoom is preserved (never `user-scalable=no` in viewport meta).

### Viewport Meta

```html
<!-- Required in Next.js layout.tsx head -->
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
```

`viewport-fit=cover` ensures content extends to the safe area on notched phones (iPhone X+). Use `pb-safe` (safe-area-inset-bottom) on the bottom nav component.

---

## Typography Responsive Scale

Font sizes adapt across breakpoints to maintain readability and hierarchy on all screen sizes.

| Token | Mobile (default) | Tablet md: | Desktop lg: | Tailwind Classes |
|---|---|---|---|---|
| Page Title | 20px / font-semibold | 24px / font-bold | 30px / font-bold | `text-xl md:text-2xl lg:text-3xl font-bold` |
| Section Heading | 16px / font-semibold | 18px / font-semibold | 20px / font-semibold | `text-base md:text-lg lg:text-xl font-semibold` |
| Card Heading | 14px / font-semibold | 16px / font-semibold | 16px / font-semibold | `text-sm md:text-base font-semibold` |
| Body Text | 16px / font-normal | 14px / font-normal | 14px / font-normal | `text-base md:text-sm` |
| Table Cell | 14px | 14px | 13px | `text-sm lg:text-xs` |
| Caption / Timestamp | 12px | 12px | 12px | `text-xs` |
| KPI Number | 28px / font-bold | 32px / font-bold | 36px / font-bold | `text-3xl md:text-4xl font-bold` |
| Badge Label | 11px / font-medium | 12px / font-medium | 12px / font-medium | `text-[11px] md:text-xs font-medium` |

**Absolute Rule**: No text element may be smaller than **12px rendered size** at any breakpoint. Body text on mobile must be ≥ 16px.

### Line Length

On desktop (lg: and above), constrain body text and form helper text to `max-w-[75ch]` to maintain comfortable reading line length (50–75 characters is optimal for prose).

Tables, code blocks, and data grids are exempt from the 75ch limit.

### Font Loading Strategy

```tsx
// app/layout.tsx — Next.js font loading
import { Figtree } from 'next/font/google';
import { Noto_Sans } from 'next/font/google';

const figtree = Figtree({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  variable: '--font-heading',
  display: 'swap',
});

const notoSans = Noto_Sans({
  subsets: ['latin'],
  weight: ['400', '500', '700'],
  variable: '--font-body',
  display: 'swap',
});
```

Arabic text uses `Noto Sans Arabic` loaded via the same mechanism with `subsets: ['arabic']`. The `lang="ar"` attribute on Arabic content nodes triggers automatic font fallback.

---

## Image Responsive Strategy

### Profile Photos

Patient profile photos are displayed at different sizes across breakpoints:

| Context | Mobile Size | Desktop Size | Implementation |
|---|---|---|---|
| Patient list table | 32×32px avatar | 40×40px avatar | `<Avatar className="h-8 w-8 md:h-10 md:w-10">` |
| Patient profile header | 64×64px | 80×80px | `<Avatar className="h-16 w-16 md:h-20 md:w-20">` |
| Session log | Not shown | Not shown | Name only in mobile-optimized form |

### Next.js Image Component

All patient images use `next/image` with:

```tsx
<Image
  src={signedUrl}
  alt={`Profile photo of ${patient.full_name}`}
  width={80}
  height={80}
  className="rounded-full object-cover"
  sizes="(max-width: 768px) 64px, 80px"
/>
```

### Document Preview Images (X-rays, Reports)

- Displayed in a responsive grid: `grid-cols-2 sm:grid-cols-3 lg:grid-cols-4`.
- Each thumbnail is 120×120px with `object-cover` and a click-to-expand action (opens in a lightbox modal or downloads the signed URL).
- PDFs show a document icon thumbnail (not rendered inline for performance).

### Clinic Logo

- Displayed in the sidebar header and on the login page.
- Logo max-height: 40px on sidebar, 64px on login.
- SVG format preferred. PNG fallback.
- Never use `<img>` without explicit `width` and `height` attributes (prevents layout shift).

### Image Loading States

All images use `blur` placeholder during loading:

```tsx
<Image
  src={url}
  alt={alt}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,..."
  // ... other props
/>
```

Skeleton shimmer is shown for avatar slots before the signed URL resolves.

### No-Image Fallback

When a patient has no profile photo:
- Avatar shows patient initials in a teal background (`bg-cyan-100 text-cyan-800`).
- Initials are derived from `full_name` — first letter of first word + first letter of last word.

```tsx
function getInitials(name: string): string {
  const parts = name.trim().split(' ');
  if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
  return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
}
```

---

*DOC-06-003 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*
