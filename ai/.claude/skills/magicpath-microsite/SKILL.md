---
name: magicpath-microsite
description: Use when the user wants a marketing microsite, demo site, landing page or "motion design website" for an app whose design lives in MagicPath, hosted on Vercel. Triggers on "demo website", "site that plays the app like a video", "ghost finger", "buy button that sends a PostHog event", "deploy it on Vercel at <domain>", or any ask to turn a MagicPath canvas into a public web page.
---

# MagicPath microsite

A mobile-first single page that plays a short, auto-running demo of the app
(screens animate, a ghost finger taps through onboarding and the main
screen) and ends on an offer card whose buy button sends a PostHog event and
opens a popup. The screens are built from the app's own MagicPath design
source, driven by a scene timeline instead of user input. Hosted on Vercel.

**Core rule:** the site reuses the design as-is (colors, fonts, components,
string tables, mock data). It must look like the app, never like a landing
page about the app.

## Where the work goes

Create a new folder called `microsite` at the root of the app's repository
and work inside it: every file of the site (package.json, config, src,
tests, README, vercel.json) is created there, nothing at the repo root. Run
every command from inside `microsite/`.

```
microsite/
  .gitignore                 # node_modules, dist, .vercel, .env*, api_keys.json
  index.html  package.json  vite.config.ts  tsconfig*.json  vercel.json
  api_keys.example.json      # committed; api_keys.json is git-ignored
  README.md
  public/favicon.svg
  src/
    main.tsx  App.tsx  index.css  lang.ts  analytics.ts
    test/setup.ts            # jsdom stubs
    magicpath/               # verbatim install of the design, never edited
    demo/
      timeline.ts            # scene list, durations, reducer
      useTimeline.ts         # requestAnimationFrame loop
      Stage.tsx              # progress, tap zones, hold-to-pause, skip
      beats.ts  motion.ts  GhostFinger.tsx  strings.ts
      BuyConfirm.tsx  BuyPopup.tsx
      scenes/                # one file per scene + index.ts + parts/
```

The `.gitignore` lives inside `microsite/`; the app's own `.gitignore` is
not touched.

**Ask the user only for** the offer price and period, and the domain. The
design answers everything else (screens, copy, languages, colors); the
PostHog and Vercel conventions below answer the rest.

## 1. Pull the design from MagicPath

**REQUIRED SUB-SKILL:** magicpath:magicpath (MCP rules and recovery).

1. `get_context`, then `get_selection` and `get_active_projects`: the user's
   open project and component are the design. Ask for an id only when
   nothing is selected and `list_projects` / `list_components` is ambiguous.
2. `inspect_component` to list the files; `get_component_code_context` to
   get `result.editableFiles[]` (`path`, `content`). The `.css` files only
   exist in this call, not in the install plan. The result exceeds the tool
   output limit and lands in a results file: extract with `jq`, never paste.
3. Install every editable file verbatim under `src/magicpath/`. Rename only
   a file that collides case-insensitively with another (`ninjaUpcoming.ts`
   next to `NinjaUpcoming.tsx` breaks macOS checkouts) and fix its imports.
   `components/ui/*` and `@/lib/utils` are not needed when every import in
   the generated files is relative; check before adding shadcn.
4. Record project id, component id, `generatedName` and revision id in the
   README. A later "new design" request installs the new revision over the
   folder and adapts the scenes.

`src/magicpath/` is the reference and the parts bin. Never edit it. A block
the design does not export (a private icon, a string table, a footer pill)
is copied into `src/demo/scenes/parts/` with the same geometry, colors,
radii, fonts and copy. No redesign.

## 2. Stack

MagicPath components are Vite + React + TypeScript, so that is the stack:

- Vite, React 19, TypeScript, `@tailwindcss/vite` with Tailwind v4
  (`@import 'tailwindcss'`, plus `@plugin "tailwindcss-animate"` when the
  design's css uses it), `motion` (`motion/react`), `posthog-js`.
- Vitest + jsdom + Testing Library; oxlint.
- Scripts: `dev`, `build` (`tsc -b && vite build`), `test` (`vitest run`),
  `lint`, `typecheck`, `preview`.
- `src/test/setup.ts` stubs `matchMedia` (for `useReducedMotion`) and
  `ResizeObserver` (design components measure themselves) and silences the
  expected "PostHog key missing" warning.

Not Next.js: there is no server, routing or image pipeline to justify it,
and the design does not drop into it unchanged.

## 3. The player

**Scene list:** splash, welcome, one scene per onboarding step as the
design has them (merge a repeated step, such as one habit picker per
category, into one scene), one "a day in the app" scene showing the main
action and its reward, one "later" scene showing progress (a streak, a
calendar), then the offer. Around 30 seconds before the offer.

**Timeline** (`timeline.ts`): `SCENES: { id, duration }[]`, the last scene
(the offer) has `duration: null`: the reducer never auto-advances past it.
A pure reducer handles `tick` (dt clamped to 100 ms), `next`, `prev`,
`pause`, `resume`, `replay`, `skipToEnd`; state is `{ index, t, paused,
run }` where `t` is the scene-local clock and `run` bumps on every scene
change so a revisited scene remounts at `t = 0`. `useTimeline` drives it
from `requestAnimationFrame` with real frame deltas. On the held scene it
keeps ticking for 4 seconds (so the offer's own beats fire) and then stops
the frame loop, so an idle tab costs nothing.

**Scenes are pure functions of `t`.** No `setTimeout`, no chained
`useAnimate`: a scene gets `{ t, lang, reduced, onReplay }` and decides
what has happened from a `BEATS` table.

```tsx
const BEATS = { bubble: 0, cards: 180, button: 500, finger: 1100, tap: 1700 };
const TAP_MS = 180;

export const Appearance = ({ t, lang, reduced }: SceneProps) => {
  const b = beats(t, BEATS);                 // { bubble: true, cards: false, ... }
  const cards = useRef<Record<string, HTMLButtonElement | null>>({});
  const settled = b.tap;                     // the tap happened: show the picked state
  return (
    <div className="relative flex h-full flex-col">
      <Beat on={b.cards} preset={rise(reduced)}>…cards, with ref={(el) => (cards.current[mode] = el)}…</Beat>
      <Beat on={b.button} preset={rise(reduced)}>…the design's Continue button…</Beat>
      <GhostFinger
        target={cards.current[PICK] ?? null}
        tapping={b.tap && t < BEATS.tap + TAP_MS}
        visible={b.finger && t < BEATS.tap + TAP_MS + 300 && !reduced}
      />
    </div>
  );
};
```

- `beats(t, starts)` returns which beats have started. `<Beat on preset>`
  is always mounted (stable layout) and animates in when its beat fires;
  pointer-inert before.
- `motion.ts` holds the shared vocabulary: `EASE`, `CUT` (the scene cut)
  and presets `rise`, `slideIn`, `pop`, each returning a plain fade when
  `reduced` is true. Match the design's own keyframes (`ninja-rise`,
  `ninja-pop`, ...) so the site moves like the app.
- `GhostFinger({ target, tapping, visible, offset })` measures the target's
  rect in a layout effect (re-measured when `visible`, `target` or
  `tapping` changes, so the target has finished its entrance) and glides
  there with `motion`. Never hard-code finger coordinates. A drag passes
  `offset`; after a swipe, retarget the finger to where it should rest.
- `Stage.tsx`: progress segments on top (one per scene), the scene in an
  `AnimatePresence mode="wait"` wrapper keyed on `index-run`, three pointer
  zones (left 20 % rewinds, right 40 % advances, middle only holds), hold
  250 ms to pause with a ❚❚ badge, a 52 px strip under the scene with the
  "Skip to offer" pill so it never covers a scene's own button, and
  keyboard ArrowLeft / ArrowRight / Space. `touch-action: none` on the
  zones so a drifting thumb does not cancel the hold.
- `prefers-reduced-motion`: fades only, no ghost finger.

**Strings:** everything shown inside the app screens comes from the
design's string tables (its `Lang` type decides the languages). `strings.ts`
holds only site copy (skip, replay, offer price, popup) in the same
languages; `lang.ts` detects the browser language.

**Offer scene:** the app's paywall look and copy with the demo's own price.
Buy button → `capture('buy:button:first:click', { price_eur, period, lang,
source: 'demo_end_card' })` once per page load → confirm dialog
(`buy:popup:confirm:click` / `buy:popup:cancel:click { via }`) → popup
saying the premium version arrives in a few days, with the support email
as a `mailto:` link (`buy:popup:dismiss:click { via }` for ok, scrim,
escape). A replay link restarts the timeline. The Stage also sends
`welcome:screen:view`, `intro:screen:half` and `intro:screen:finished
{ skipped }` once each. Event names follow the `object:element:action`
colon style throughout. Add the events to the app's `ANALYTICS.md` when
it has one.

**Page chrome:** `App.tsx` is a header (the app icon, the app name in the
design's display font, language pills made from the design's pill
components), the Stage, and a footer with the company name and the support
email. The icon comes from the design's logo component when the project has
one, otherwise from the app's own icon asset; it is also `public/favicon.svg`.
`index.html` sets `viewport-fit=cover`, `theme-color` to the design's
background, a `description` meta with the app's tagline, and the app name as
title.

## 4. Layout

- Phone: the stage is the viewport minus the site header (`100dvh`,
  `flex: 1 1 0; min-height: 0`), footer hidden. Desktop (`min-width:
  768px`): a 390 px column, `height: min(844px, calc(100dvh - 216px))`,
  rounded with the design's border and glow.
- Short phones (iPhone SE class) cut off wizard screens. Add a Tailwind
  variant and give secondary lines `short:hidden`, tighter `short:` paddings:

  ```css
  @custom-variant short {
    @media (max-height: 700px) and (max-width: 767px) {
      @slot;
    }
  }
  ```

  The one-line `@custom-variant short (@media ...)` form compiles without
  the media wrapper; use the block form.
- The offer's buy button lives in a `shrink-0` block under a scrolling
  `min-h-0 flex-1 overflow-y-auto` body, so it never leaves the stage.

## 5. Analytics keys

`analytics.ts` wraps PostHog cookieless (`persistence: 'memory'`,
`autocapture: false`, `capture_pageview: true`) and degrades to a no-op with
one warning when the key is empty. `vite.config.ts` reads the git-ignored
`api_keys.json` (`{ "posthog": { "key", "host" } }`, with an
`api_keys.example.json` committed) into `import.meta.env.VITE_POSTHOG_*`;
env vars override; under Vitest the key is forced empty so tests never init
the live client.

Provision the PostHog project yourself, through the PostHog MCP (`exec`
with the `project` commands) or the API with the personal key the user's
instructions name: look for a project named like the app, create it when
missing (Pixelita projects live on the EU cloud, host
`https://eu.i.posthog.com`), read its project key back and write key and
host into `api_keys.json`. The personal token never reaches a file. Add
`VITE_POSTHOG_KEY` and `VITE_POSTHOG_HOST` to the Vercel project as
production env vars (`vercel env add`), since `api_keys.json` is not
uploaded.

## 6. Tests and verification

**REQUIRED SUB-SKILL:** superpowers:test-driven-development.

- Reducer: durations advance, the last scene holds, `skipToEnd`, `replay`
  bumps `run`, dt clamp.
- Each scene rendered at chosen `t` values: what is visible, `aria-pressed`
  on the picked card, the ghost finger present or not, `fr` copy.
- Offer: event payload sent once on a double click, every dismiss `via`.
- Design cells carry no test ids: put `data-testid` / `data-*` on the
  scene's own wrappers, not on the installed components.

Then watch it in the browser, not only in jsdom: `npm run dev`, open at
390×844 and 320×568, step scenes with ArrowRight, check nothing is clipped
and the finger lands on the right control. When the browser window cannot
shrink that far, inject a 320×568 iframe of the dev URL with the browser
tools and dispatch the keydown into `iframe.contentWindow`.

## 7. README and deploy

README: what the demo shows and how long it runs, run instructions
(`api_keys.json`), the layout above, the MagicPath ids and revision, and the
deploy command.

`vercel.json`:

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "framework": "vite",
  "installCommand": "npm ci",
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "cleanUrls": true,
  "headers": [
    { "source": "/assets/(.*)", "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }] }
  ]
}
```

From inside `microsite/`, with the user logged in to the Vercel CLI. The
team scope is `pixelita` and the project is named like the app, lowercase
(`ninjaroutine`); `vercel teams ls` confirms the scope when in doubt:

```sh
vercel link --yes --scope pixelita --project <app>   # writes the ignored .vercel/
vercel --prod --yes --scope pixelita
```

`--yes` only skips the prompts; the CLI uploads the working tree, so run
`npm run build` and the tests first. Attach the domain in the Vercel
dashboard or with `vercel domains add`; certificates issue on their own once
the nameservers point at Vercel. Preview deploys (`vercel --yes`) for review;
production only when the user asks.

## Common mistakes

| Mistake | Fix |
|---|---|
| Files at the repo root | Everything under `microsite/`; `cd` there first |
| Next.js, Playwright, a `<video>` | Vite + motion; the demo is live DOM so the buy button is real |
| Scenes sequenced with `setTimeout` | Pure functions of `t` with a `BEATS` table; the reducer owns time |
| Finger at percentage coordinates | `GhostFinger` measures the target element |
| Editing `src/magicpath/` for parity | Copy the block into `scenes/parts/`, same styles |
| A landing page with headlines about the app | The app itself, playing |
| Asking which screens, languages, region | Read the design: its components, string tables, `Lang` type; the PostHog project tells its region |
| `.env.local` with the key | `api_keys.json` (ignored) + Vercel env vars |
| Mixed `background` and `backgroundImage` on one element | `backgroundColor` + `backgroundImage: 'none'` (React warns otherwise) |
| Done after jsdom passes | Open it at 390×844 and 320×568 first |
