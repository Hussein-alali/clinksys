# Page: Login

---

| Field | Value |
|---|---|
| **Document ID** | DOC-06-P01 |
| **Version** | 0.1 — Draft |
| **Status** | Draft |
| **Date** | 2026-05-24 |
| **Purpose** | UX specification for the Login page. |
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
| **URL Route** | `/` (root) |
| **Auth Required** | No — this is the public authentication entry point |
| **Authenticated Redirect** | Users already holding a valid session are immediately redirected to their role-appropriate home page (see Navigation Flows below). The redirect fires in a Next.js middleware before the page renders, preventing the login form from flashing. |
| **Allowed Roles** | Public (unauthenticated only) |
| **RTL Support** | Yes — layout mirrors when `lang=ar` is detected via `next-intl` locale |

---

## Page Purpose

The Login page is the single authentication entry point for all PTCMS users regardless of role (Admin, Receptionist, Doctor, Therapist, Patient). Its responsibilities are:

1. **Identity verification** — collect email + password credentials and submit them to Supabase Auth.
2. **Session establishment** — on success, store the JWT/session cookie and redirect the user to their role-specific landing page.
3. **Security feedback** — surface lockout warnings, remaining-attempt counters, and locked-account messages without leaking internal system details.
4. **Bilingual entry** — render labels and error messages in Arabic (RTL) or English (LTR) based on the active locale.

The page must never be reachable for authenticated users. It carries no application chrome (no sidebar, no top nav) — only the branding card, form, and a minimal language-toggle link.

---

## Data Fetching (API Endpoints Consumed)

| Call | Method | Endpoint / SDK Call | Trigger |
|---|---|---|---|
| Sign in | POST | `supabase.auth.signInWithPassword({ email, password })` | Form submit |
| Get session (SSR check) | — | `supabase.auth.getSession()` in Next.js middleware | Every page request |
| Fetch user role | SELECT | `profiles` table: `select role where id = auth.uid()` | After sign-in success, before redirect |

No additional REST API calls are made on this page. The role lookup is a single lightweight Supabase query executed server-side immediately after session creation to determine the redirect destination.

---

## Component Breakdown

| Component | Source | Props / Notes |
|---|---|---|
| `<LoginCard>` | Custom | `max-w-md`, centered, `rounded-2xl shadow-lg bg-white` wrapper |
| `<ClinicLogo>` | Custom | SVG logo + clinic name in Figtree; 80×80px logo mark above form |
| `<Input>` (email) | Shadcn/UI | `type="email"`, `autoComplete="email"`, `inputMode="email"`, full-width |
| `<PasswordInput>` | Custom (wraps Shadcn `<Input>`) | `type` toggles `password`/`text`; right-side `Eye` / `EyeOff` Lucide icon button (44×44px tap target) |
| `<Button>` (submit) | Shadcn/UI | `variant="default"`, full-width, `bg-cyan-600 hover:bg-cyan-700 text-white`; shows `<Loader2 className="animate-spin">` inline when loading |
| `<Alert>` (error) | Shadcn/UI | `variant="destructive"`, `border-red-500 bg-red-50 text-red-700`; rendered above the form on auth failure |
| `<ForgotPasswordLink>` | Custom | Anchor styled as text link `text-cyan-600 underline-offset-2`; right-aligned below password field (left-aligned in RTL) |
| `<LanguageToggle>` | Custom | Small link at card bottom: "العربية / English" — sets `next-intl` locale cookie |
| `<FormLabel>` | Shadcn/UI | Figtree font, `text-slate-900`, 14px |

---

## UI States (Loading, Empty, Error, Success)

### Default / Idle State
Form renders with empty inputs, no alerts, submit button enabled.

### Loading State
Triggered on form submit. The submit button replaces its label with a `<Loader2>` spinner icon (`animate-spin`) and the text "Signing in…" / "جارٍ تسجيل الدخول…". All inputs and the button become `disabled` to prevent double-submission. The loading state persists until the Supabase response resolves.

### Error State — Invalid Credentials
A `<Alert variant="destructive">` banner appears above the form:

- **English:** "Invalid email or password. X attempt(s) remaining before your account is temporarily locked."
- **Arabic:** "البريد الإلكتروني أو كلمة المرور غير صحيحة. تبقى X محاولة/محاولات قبل قفل الحساب مؤقتاً."

The remaining-attempts count is derived from Supabase Auth's built-in rate-limiting response or a custom `failed_logins` counter in the `profiles` table. The alert uses `role="alert"` and `aria-live="assertive"` so screen readers announce it immediately.

### Error State — Account Locked
When the lockout threshold is exceeded:

- **English:** "Account temporarily locked. Please try again in 15 minutes."
- **Arabic:** "تم قفل الحساب مؤقتاً. يرجى المحاولة مرة أخرى بعد 15 دقيقة."

The submit button is disabled. A countdown timer (MM:SS) is displayed below the alert if the unlock time is available from the API response.

### Error State — Network / Server Error
"Unable to connect. Please check your internet connection and try again." The alert uses `variant="destructive"` with a `WifiOff` Lucide icon prepended.

### Success State
No visible success state on this page — the user is immediately redirected. A brief 150ms fade-out transition plays on the card before navigation.

---

## Layout Wireframe / Mockup Reference

```
┌─────────────────────────────────────────────────────────┐
│            Background: gradient teal-50 → white          │
│                                                           │
│           ┌─────────────────────────────────┐            │
│           │         [Clinic Logo]           │            │
│           │      Physical Therapy CMS       │            │
│           │                                 │            │
│           │  [!] Error alert (conditional)  │            │
│           │                                 │            │
│           │  Email Address                  │            │
│           │  ┌─────────────────────────┐    │            │
│           │  │ email@example.com       │    │            │
│           │  └─────────────────────────┘    │            │
│           │                                 │            │
│           │  Password              [Eye]    │            │
│           │  ┌─────────────────────────┐    │            │
│           │  │ ••••••••••••••          │    │            │
│           │  └─────────────────────────┘    │            │
│           │                 Forgot Password?│            │
│           │                                 │            │
│           │  ┌─────────────────────────┐    │            │
│           │  │       Sign In           │    │            │
│           │  └─────────────────────────┘    │            │
│           │                                 │            │
│           │         العربية / English       │            │
│           └─────────────────────────────────┘            │
└─────────────────────────────────────────────────────────┘
```

- Card: `max-w-md w-full mx-auto`, `p-8`, `rounded-2xl`, `shadow-lg`, `bg-white`
- Background: full-viewport `min-h-screen flex items-center justify-center bg-gradient-to-b from-teal-50 to-white`
- Logo mark: 64×64px centered, below it clinic name in Figtree 600 24px `text-slate-900`
- Spacing between sections: 24px (gap-6)

**RTL (Arabic) mirror:**
- All labels right-aligned
- Eye toggle button moves to the left side of the password field
- "Forgot Password?" link aligns to the left
- Alert icon on right side

---

## Validation Rules

| Field | Rule | Error Message (EN) | Error Message (AR) |
|---|---|---|---|
| Email | Required | "Email is required." | "البريد الإلكتروني مطلوب." |
| Email | Valid email format (`/^[^\s@]+@[^\s@]+\.[^\s@]+$/`) | "Please enter a valid email address." | "يرجى إدخال بريد إلكتروني صحيح." |
| Password | Required | "Password is required." | "كلمة المرور مطلوبة." |
| Password | Min length 6 chars | "Password must be at least 6 characters." | "يجب أن تكون كلمة المرور 6 أحرف على الأقل." |

Validation runs on-submit only (not on blur) to avoid premature error messages on the login page. Zod schema used client-side:

```ts
const loginSchema = z.object({
  email: z.string().min(1, "Email is required").email("Invalid email"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});
```

---

## Navigation Flows (Entry & Exit Points)

### Entry Points
- Direct URL navigation to `/`
- Any unauthenticated user attempting to access a protected route is redirected here by Next.js middleware. A `?redirect=/original-path` query param preserves the intended destination.

### Post-Login Redirects (by role)

| Role | Redirect Target |
|---|---|
| Admin | `/dashboard` |
| Receptionist | `/appointments` |
| Doctor | `/patients` |
| Therapist | `/schedule` |
| Patient | `/my-appointments` |

If a `?redirect=` param is present and the destination path is on the same origin and allowed for the user's role, the user is sent there instead of the default.

### Other Exits
- "Forgot Password?" → `/forgot-password` (separate page, not in scope of this document)
- Language toggle → reloads page with updated locale cookie; form state is cleared

---

## Responsive Behavior

| Breakpoint | Behavior |
|---|---|
| Mobile (`< 640px`) | Card goes full-width with `mx-4` horizontal padding. Background gradient still fills viewport. Font sizes unchanged. Touch targets 44×44px enforced on Eye toggle and submit button. |
| Tablet (`640px–1024px`) | Card `max-w-md` centered, same as desktop. |
| Desktop (`> 1024px`) | Card `max-w-md` centered. Background gradient fills entire viewport. |

The page has no horizontal scroll at any breakpoint. The card never exceeds the viewport height on standard mobile screens (812px and above) — if content overflows, the page becomes scrollable rather than the card.

---

## Accessibility Notes

- All inputs have associated `<label>` elements linked via `htmlFor` / `id` — no `placeholder`-only labels.
- Error alert uses `role="alert"` and `aria-live="assertive"` for immediate screen reader announcement.
- Submit button has `aria-busy="true"` during loading state.
- Password show/hide toggle has `aria-label="Show password"` / `aria-label="Hide password"` that updates on toggle.
- Focus management: on page load, focus is placed on the email input (`autoFocus`). On error, focus moves to the alert container.
- Color is never the sole differentiator: error states also use icons (`AlertCircle` Lucide) and text labels.
- Contrast ratios: `text-slate-900` on `bg-white` = 16.1:1 (AAA). `text-cyan-700` on `bg-white` = 4.7:1 (AA). Error red `#EF4444` on white = 4.5:1 (AA minimum met for UI components).
- Keyboard flow: `Tab` → Email → Password → Eye Toggle → Forgot Password → Submit → Language Toggle. All focusable elements reachable without mouse.
- Landmark: entire card is wrapped in `<main>` with `aria-label="Login"` (or `aria-label="تسجيل الدخول"` in Arabic).

### RTL Considerations
- When `lang=ar`, the `dir="rtl"` attribute is set on `<html>`.
- Tailwind RTL utilities (`rtl:text-right`, `rtl:flex-row-reverse`) are used for icon positioning.
- The password eye-toggle button uses `rtl:left-3 ltr:right-3` for positioning within the input.
- Figtree is used for headings; Noto Sans Arabic renders all Arabic body text at 16px base.
- Numeric fields (email) remain LTR even in RTL layout using `dir="ltr"` on the input element.

---

*DOC-06-P01 · v0.1 · 2026-05-24 · Physical Therapy Clinic Management System*
