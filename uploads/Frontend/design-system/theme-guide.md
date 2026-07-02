# Theme Guide

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-DS2 |
| **Version** | 1.0 — Complete |
| **Status** | Review |
| **Date** | 2026-05-24 |
| **Purpose** | Clinical color theme: light mode, dark mode readiness, and Tailwind config. |
| **Owner** | UX Designer |
| **Dependencies** | design-system.md |
| **Priority** | P2 |
| **Estimated Pages** | 8–12 pages |

---

## Revision History

| Version | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-24 | UX Designer | Initial stub |
| 1.0 | 2026-05-24 | UX Designer | Full content added |

---

## Table of Contents

- [Light Mode Theme](#light-mode-theme)
- [Dark Mode Considerations](#dark-mode-considerations)
- [High-Contrast Accessibility Theme](#high-contrast-accessibility-theme)
- [CSS Custom Properties](#css-custom-properties)
- [Tailwind Config](#tailwind-config)
- [Shadcn/UI Theming](#shadcnui-theming)
- [RTL Theme Adjustments](#rtl-theme-adjustments)

---

## Light Mode Theme

PTCMS v1.0 ships exclusively in light mode. The light theme is designed to project clinical professionalism and is optimized for use in clinic environments under fluorescent or natural lighting.

### Theme Overview

| Attribute | Value | Rationale |
|---|---|---|
| Application background | `#F8FAFC` (slate-50) | Slightly warm off-white reduces eye strain vs. pure white |
| Card surface | `#FFFFFF` (white) | Cards "pop" off the app background, creating clear content containers |
| Primary action color | `#0891B2` (cyan-600) | Medical teal — professional, trustworthy, distinct from alert colors |
| Text (primary) | `#0F172A` (slate-900) | Near-black for maximum contrast and legibility |
| Text (muted) | `#475569` (slate-600) | Sufficient contrast (5.74:1 on white) for secondary information |
| Border color | `#CBD5E1` (slate-300) | Subtle separation without visual weight |
| Sidebar background | `#FFFFFF` (white) | Clean; relies on active state highlight for context |
| Active sidebar item | `#ECFEFF` (cyan-50) bg + `#0E7490` (cyan-700) text | Clear active state without overuse of primary color |

### Installation Steps

#### Step 1: Initialize Shadcn/UI

```bash
npx shadcn-ui@latest init
```

When prompted:
- **Style**: Default
- **Base color**: Slate
- **CSS variables**: YES
- **Tailwind config path**: `tailwind.config.ts`
- **Components alias**: `@/components`
- **Utils alias**: `@/lib/utils`

#### Step 2: Install Required Packages

```bash
npm install tailwindcss-rtl next-themes
npm install @radix-ui/react-slot class-variance-authority clsx tailwind-merge
npm install react-hook-form @hookform/resolvers zod
npm install sonner react-signature-canvas
npm install recharts lucide-react
npm install date-fns
```

#### Step 3: Load Fonts in `app/layout.tsx`

```typescript
import { Figtree, Noto_Sans } from 'next/font/google';

const figtree = Figtree({
  subsets: ['latin'],
  variable: '--font-figtree',
  weight: ['400', '500', '600', '700'],
  display: 'swap',
});

const notoSans = Noto_Sans({
  subsets: ['latin', 'arabic'],
  variable: '--font-noto-sans',
  weight: ['400', '500', '700'],
  display: 'swap',
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="ar"
      dir="rtl"
      className={`${figtree.variable} ${notoSans.variable}`}
    >
      <body className="font-sans bg-slate-50 text-slate-900 antialiased">
        {children}
      </body>
    </html>
  );
}
```

---

## Dark Mode Considerations

PTCMS v1.0 does **not** ship with dark mode enabled. The decision is deferred to v1.1 for the following reasons:
1. Clinical environments require high contrast for accurate patient record review.
2. Staff feedback during UAT will determine whether dark mode is operationally needed.
3. All current components must work correctly in light mode — dark mode will be added without disrupting the existing token system.

### Dark Mode Architecture (Prepared, Not Active)

The dark mode strategy is **class-based** (`className="dark"`), configured in `tailwind.config.ts` as `darkMode: 'class'`. This means dark mode activates only when the `dark` class is present on `<html>`.

The token system is pre-structured to support dark mode via a `.dark` CSS rule block that will override the `:root` tokens:

```css
/* In globals.css — NOT active in v1.0 — prepared for v1.1 */
/*
.dark {
  --background: 222 47% 11%;
  --card: 224 71% 4%;
  --foreground: 213 31% 91%;
  --muted: 215 20% 65%;
  --border: 216 34% 17%;
  --primary: 199 89% 48%;
  --primary-foreground: 0 0% 100%;
}
*/
```

**Developer Rule**: When building components, do not hardcode colors. Always use CSS variable tokens or Tailwind semantic classes (e.g., `bg-background`, `text-foreground`, `border-border`) so that dark mode token overrides apply automatically in v1.1.

---

## High-Contrast Accessibility Theme

PTCMS supports the operating system `prefers-contrast: more` media query. When active, borders are thickened, text becomes darker, and the focus ring is more prominent.

```css
@media (prefers-contrast: more) {
  :root {
    --border: 222 47% 11%;      /* Near-black borders */
    --muted: 222 47% 11%;       /* Fully dark muted text */
    --ring: 222 47% 11%;        /* Black focus ring */
  }

  /* Thicker focus rings */
  *:focus-visible {
    outline: 3px solid #0F172A !important;
    outline-offset: 3px !important;
  }

  /* More prominent status badge borders */
  [data-status-badge] {
    border-width: 2px !important;
  }
}
```

This is applied in `globals.css`. No component-level changes are required.

---

## CSS Custom Properties

The complete `globals.css` file content for PTCMS. Paste this into `app/globals.css` after the Tailwind directives, replacing the default Shadcn-generated CSS variables.

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* ============================================================
   PTCMS — Design Tokens (globals.css)
   Physical Therapy Clinic Management System
   ============================================================ */

@layer base {
  :root {
    /* Brand */
    --primary: 199 89% 48%;
    --primary-foreground: 0 0% 100%;

    /* Backgrounds */
    --background: 0 0% 100%;
    --card: 0 0% 100%;
    --card-foreground: 222 47% 11%;
    --popover: 0 0% 100%;
    --popover-foreground: 222 47% 11%;

    /* Foreground */
    --foreground: 222 47% 11%;

    /* Secondary */
    --secondary: 210 40% 96%;
    --secondary-foreground: 222 47% 11%;

    /* Muted */
    --muted: 210 40% 96%;
    --muted-foreground: 215 16% 47%;

    /* Accent */
    --accent: 199 89% 96%;
    --accent-foreground: 199 89% 30%;

    /* Destructive */
    --destructive: 0 84% 60%;
    --destructive-foreground: 0 0% 100%;

    /* Success (custom — not in Shadcn default) */
    --success: 142 71% 45%;
    --success-foreground: 0 0% 100%;

    /* Warning (custom) */
    --warning: 38 92% 50%;
    --warning-foreground: 0 0% 100%;

    /* Border & Input */
    --border: 213 27% 84%;
    --input: 213 27% 84%;
    --ring: 199 89% 48%;

    /* Border Radius */
    --radius: 0.5rem;

    /* Chart colors */
    --chart-1: 199 89% 48%;
    --chart-2: 142 71% 45%;
    --chart-3: 38 92% 50%;
    --chart-4: 0 84% 60%;
    --chart-5: 258 90% 66%;
  }

  /* Dark mode — prepared, not active in v1.0 */
  /*
  .dark {
    --background: 222 84% 5%;
    --foreground: 210 40% 98%;
    --card: 222 47% 11%;
    --card-foreground: 210 40% 98%;
    --primary: 199 89% 48%;
    --primary-foreground: 0 0% 100%;
    --border: 217 33% 17%;
    --input: 217 33% 17%;
    --ring: 199 89% 48%;
    --muted: 217 33% 17%;
    --muted-foreground: 215 20% 65%;
  }
  */

  * {
    @apply border-border;
  }

  body {
    @apply bg-slate-50 text-foreground font-sans antialiased;
  }

  /* Skip link for keyboard/screen reader users */
  .skip-link {
    @apply sr-only focus:not-sr-only focus:fixed focus:top-4 focus:start-4
           focus:z-[200] focus:px-4 focus:py-2 focus:bg-primary
           focus:text-primary-foreground focus:rounded-md;
  }
}

/* ============================================================
   Animations
   ============================================================ */

@keyframes shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position:  200% 0; }
}

@keyframes fade-in {
  from { opacity: 0; }
  to   { opacity: 1; }
}

@keyframes slide-up {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0);   }
}

@layer utilities {
  .animate-shimmer {
    background: linear-gradient(90deg, #E2E8F0 25%, #F1F5F9 50%, #E2E8F0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s linear infinite;
  }
  .animate-fade-in  { animation: fade-in  200ms ease-in-out forwards; }
  .animate-slide-up { animation: slide-up 200ms ease-in-out forwards; }
}

/* ============================================================
   Reduced Motion
   ============================================================ */

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration:       0.01ms !important;
    animation-iteration-count: 1     !important;
    transition-duration:      0.01ms !important;
    scroll-behavior:          auto   !important;
  }
}

/* ============================================================
   High Contrast
   ============================================================ */

@media (prefers-contrast: more) {
  :root {
    --border: 222 47% 11%;
    --muted-foreground: 222 47% 11%;
    --ring: 222 47% 11%;
  }
  *:focus-visible {
    outline: 3px solid hsl(var(--ring)) !important;
    outline-offset: 3px !important;
  }
}
```

---

## Tailwind Config

Complete `tailwind.config.ts` for PTCMS. This file extends the Tailwind defaults with PTCMS custom tokens, font families, and required plugins.

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';
import { fontFamily } from 'tailwindcss/defaultTheme';

const config: Config = {
  darkMode: ['class'],                  // Class-based dark mode (prepared, not active in v1.0)
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: '1rem',
      screens: { '2xl': '1400px' },
    },
    screens: {
      sm:  '640px',    // mobile-lg
      md:  '768px',    // tablet
      lg:  '1024px',   // desktop-sm
      xl:  '1440px',   // desktop-lg
      '2xl': '1536px', // ultra-wide
    },
    extend: {
      colors: {
        /* Shadcn/UI semantic tokens mapped to CSS variables */
        border:       'hsl(var(--border))',
        input:        'hsl(var(--input))',
        ring:         'hsl(var(--ring))',
        background:   'hsl(var(--background))',
        foreground:   'hsl(var(--foreground))',
        primary: {
          DEFAULT:    'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT:    'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT:    'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT:    'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT:    'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        card: {
          DEFAULT:    'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
        popover: {
          DEFAULT:    'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        /* Custom tokens */
        success: {
          DEFAULT:    'hsl(var(--success))',
          foreground: 'hsl(var(--success-foreground))',
        },
        warning: {
          DEFAULT:    'hsl(var(--warning))',
          foreground: 'hsl(var(--warning-foreground))',
        },
        /* Chart colors */
        chart: {
          '1': 'hsl(var(--chart-1))',
          '2': 'hsl(var(--chart-2))',
          '3': 'hsl(var(--chart-3))',
          '4': 'hsl(var(--chart-4))',
          '5': 'hsl(var(--chart-5))',
        },
      },
      borderRadius: {
        lg:   'var(--radius)',              /* 0.5rem = 8px */
        md:   'calc(var(--radius) - 2px)',  /* 6px */
        sm:   'calc(var(--radius) - 4px)',  /* 4px */
      },
      fontFamily: {
        sans: ['var(--font-noto-sans)', 'Noto Sans', ...fontFamily.sans],
        heading: ['var(--font-figtree)', 'Figtree', ...fontFamily.sans],
      },
      keyframes: {
        'accordion-down': {
          from: { height: '0' },
          to:   { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to:   { height: '0' },
        },
        shimmer: {
          '0%':   { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0'  },
        },
        'fade-in': {
          from: { opacity: '0' },
          to:   { opacity: '1' },
        },
        'slide-up': {
          from: { opacity: '0', transform: 'translateY(8px)' },
          to:   { opacity: '1', transform: 'translateY(0)'   },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up':   'accordion-up 0.2s ease-out',
        shimmer:          'shimmer 1.5s linear infinite',
        'fade-in':        'fade-in 0.2s ease-in-out forwards',
        'slide-up':       'slide-up 0.2s ease-in-out forwards',
      },
      boxShadow: {
        sm: '0 1px 2px rgba(0, 0, 0, 0.05)',
        md: '0 4px 6px rgba(0, 0, 0, 0.07)',
        lg: '0 10px 15px rgba(0, 0, 0, 0.10)',
        xl: '0 20px 25px rgba(0, 0, 0, 0.10)',
      },
    },
  },
  plugins: [
    require('tailwindcss-animate'),
    require('tailwindcss-rtl'),        // Adds logical property utilities (ms-*, me-*, ps-*, pe-*)
  ],
};

export default config;
```

---

## Shadcn/UI Theming

Shadcn/UI components are generated into `components/ui/`. The generated code uses `hsl(var(--token))` syntax, which integrates seamlessly with the CSS custom properties defined above.

### Adding a New Component

```bash
npx shadcn-ui@latest add button
npx shadcn-ui@latest add input
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add calendar
# etc.
```

Generated files land in `components/ui/` and can be customized directly.

### Customization Pattern

When Shadcn component defaults do not match PTCMS design specs, extend them by wrapping rather than modifying the generated file:

```tsx
// components/ui/ptcms-button.tsx
// Extension of the generated Shadcn Button with PTCMS-specific variants
import { Button as ShadcnButton, ButtonProps } from '@/components/ui/button';
import { cn } from '@/lib/utils';

export function Button({ className, ...props }: ButtonProps) {
  return (
    <ShadcnButton
      className={cn(
        'font-medium transition-colors duration-150',
        className
      )}
      {...props}
    />
  );
}
```

**Rule**: Never regenerate (overwrite) a customized `components/ui/` file with `shadcn-ui add`. Keep customizations in wrapper components.

### Component Generation Log

| Component | Command | Customizations |
|---|---|---|
| button | `shadcn-ui add button` | Added `loading` prop wrapper |
| input | `shadcn-ui add input` | Added `dir="ltr"` for phone/number types |
| label | `shadcn-ui add label` | None — use as-is |
| select | `shadcn-ui add select` | None — use as-is |
| checkbox | `shadcn-ui add checkbox` | None — use as-is |
| radio-group | `shadcn-ui add radio-group` | Extended for radio card variant |
| slider | `shadcn-ui add slider` | Extended as PainSlider |
| textarea | `shadcn-ui add textarea` | Added auto-resize wrapper |
| dialog | `shadcn-ui add dialog` | None — Radix handles focus trap |
| sheet | `shadcn-ui add sheet` | RTL side prop wrapper |
| tabs | `shadcn-ui add tabs` | None — use as-is |
| card | `shadcn-ui add card` | None — use as-is |
| badge | `shadcn-ui add badge` | Extended as StatusBadge |
| avatar | `shadcn-ui add avatar` | Added initials fallback logic |
| calendar | `shadcn-ui add calendar` | Added Arabic locale support |
| popover | `shadcn-ui add popover` | None — use as-is |
| dropdown-menu | `shadcn-ui add dropdown-menu` | None — use as-is |
| table | `shadcn-ui add table` | Added SortableHeader |
| form | `shadcn-ui add form` | None — use with react-hook-form |
| separator | `shadcn-ui add separator` | None — use as-is |
| skeleton | `shadcn-ui add skeleton` | Added shimmer animation class |
| sonner | `shadcn-ui add sonner` | None — configured in layout.tsx |

---

## RTL Theme Adjustments

PTCMS is deployed as a primarily Arabic-language application. The `dir="rtl"` attribute is set on `<html>` globally. The following adjustments ensure full RTL parity.

### 1. Tailwind RTL Plugin

The `tailwindcss-rtl` plugin replaces directional Tailwind utilities with logical equivalents:

| Physical (LTR-only) | Logical (RTL-safe) | Description |
|---|---|---|
| `ml-*` / `mr-*` | `ms-*` / `me-*` | Margin start/end |
| `pl-*` / `pr-*` | `ps-*` / `pe-*` | Padding start/end |
| `left-*` / `right-*` | `start-*` / `end-*` | Position start/end |
| `border-l` / `border-r` | `border-s` / `border-e` | Border start/end |
| `text-left` / `text-right` | `text-start` / `text-end` | Text alignment |
| `rounded-l-*` / `rounded-r-*` | `rounded-s-*` / `rounded-e-*` | Border radius start/end |
| `float-left` / `float-right` | `float-start` / `float-end` | Float direction |

**Rule**: All PTCMS component code must use logical properties. Physical directional properties (`ml-`, `mr-`, `pl-`, `pr-`, `left-`, `right-`) are forbidden unless explicitly documented with a justification comment.

### 2. LTR Exceptions

The following elements must always use `dir="ltr"` regardless of page direction:

| Element | Reason |
|---|---|
| Phone number inputs | Egyptian mobile numbers are left-to-right numeric |
| File number display | Auto-generated alphanumeric codes are LTR |
| Invoice numbers | Numeric/alphanumeric codes render LTR |
| Date inputs (`<input type="date">`) | Browser-native date pickers in LTR format |
| URLs | Always LTR |
| Code blocks | Programming code is LTR |

```tsx
{/* Always apply dir="ltr" for phone number inputs */}
<Input
  type="tel"
  inputMode="tel"
  dir="ltr"
  className="text-start"  /* Logical: text aligns to start (left in LTR) */
  placeholder="01XXXXXXXXX"
/>
```

### 3. Icon Direction

Lucide icons do not flip in RTL by default. This is correct behavior for most UI icons (arrows, chevrons). The only exceptions are:

| Icon | RTL Treatment |
|---|---|
| `ChevronRight` / `ChevronLeft` (navigation) | Swap: in RTL, "next" is ChevronLeft |
| `ArrowRight` / `ArrowLeft` (progress) | Swap for directional context |
| `Quote` | Flip horizontally for Arabic typography convention |

All other icons (action icons, status icons, decorative icons) remain unchanged in RTL.

### 4. Role-Based Navigation Rendering

Navigation items are rendered conditionally based on the authenticated user's role:

```typescript
// hooks/use-nav-items.ts
import { useAuth } from '@/hooks/use-auth';

const ALL_NAV_ITEMS = [...]; // full list

export function useNavItems() {
  const { role } = useAuth();

  return ALL_NAV_ITEMS.filter((item) => {
    if (!item.allowedRoles) return true;  // visible to all
    return item.allowedRoles.includes(role);
  });
}
```

| Role | Visible Nav Items |
|---|---|
| `admin` | All: Dashboard, Patients, Appointments, Treatment Plans, Sessions, Payments, Invoices, Reports, Campaigns, Users, Settings |
| `receptionist` | Dashboard, Patients, Appointments, Payments, Invoices |
| `doctor` | Dashboard, Patients, Appointments, Treatment Plans |
| `therapist` | Dashboard, Patients (assigned only), Appointments, Sessions |

### 5. Date and Number Formatting

| Format | Arabic (RTL) | English (LTR) | Implementation |
|---|---|---|---|
| Date | `DD/MM/YYYY` | `MM/DD/YYYY` or `YYYY-MM-DD` | `format(date, 'dd/MM/yyyy', { locale: ar })` |
| Currency | `١٢٠٠ ج.م.` or `1,200 EGP` | `1,200 EGP` | `Intl.NumberFormat('ar-EG', { style: 'currency', currency: 'EGP' })` |
| Numbers in Arabic | Western Arabic numerals (0–9) | Western Arabic numerals (0–9) | Consistent across both languages |

---

*DOC-06-DS2 · v1.0 · 2026-05-24 · Physical Therapy Clinic Management System*
