---
name: mmd
description: Use when debugging, reproducing or verifying a bug in a running mobile app (iOS/Android simulator, emulator or device) with mobile-mcp — invoked as "mmd", "mobile mcp debug", or whenever a mobile-app problem must be observed live rather than guessed at from code.
---

# mmd — Mobile MCP Debug

## Overview

`mmd` means: **don't guess, drive the app**. Reproduce the problem on a real
device/simulator through `mobile-mcp`, understand it from what the app actually
does, fix it, then drive the app again to prove the fix.

Two non-negotiable moments of device interaction: **before the fix** (observe)
and **after the fix** (verify). Skipping either turns the work into speculation.

## Loop

1. **Connect** — `mobile_list_available_devices`, then `mobile_use_device`.
2. **Reproduce** — launch/navigate to the failing screen and make the bug happen.
3. **Understand** — read the screen and the logs, form a root-cause hypothesis.
   Only then touch the code.
4. **Fix** — edit, hot restart / rebuild, get the new build on the device.
5. **Verify** — re-run the exact reproduction steps on the device. State plainly
   what you saw. Never claim "fixed" from code reading alone.

## Screenshots cost time — read the tree instead

`mobile_take_screenshot` is slow. Default to
`mobile_list_elements_on_screen`: it gives labels, values and coordinates, which
is what you need to assert state *and* to know where to tap.

Take a screenshot only when:

- the bug is visual (layout, overflow, color, clipping, missing render)
- the element tree is empty or unreadable and you're stuck
- one final shot is genuinely worth showing the user

Budget: **one screenshot for the repro, one for the verification** — and only if
the bug is visual. Never screenshot after every tap to "see where I am".

## Quick reference

| Need | Tool |
|---|---|
| Pick a device | `mobile_list_available_devices` → `mobile_use_device` |
| Start / stop the app | `mobile_launch_app`, `mobile_terminate_app` |
| Read current screen state | `mobile_list_elements_on_screen` |
| Tap | `mobile_click_on_screen_at_coordinates` |
| Type | `mobile_type_keys` |
| Scroll | `swipe_on_screen` |
| Back / home | `mobile_press_button` |
| Deep link to a screen | `mobile_open_url` |
| Visual check (sparingly) | `mobile_take_screenshot` |

Jumping straight to the failing screen with `mobile_open_url` beats tapping
through five screens.

Runtime logs come from the platform, not from mobile-mcp: run
`flutter run` / `flutter logs`, `xcrun simctl spawn booted log stream`, or
`adb logcat` in a background shell and read from there.

## Red flags

- "The fix is obvious, I'll skip the repro" — then you're fixing a guess.
- "I'll screenshot each step to follow along" — use the element tree.
- "Code looks right, so it works now" — not verified. Drive the app.
- Retrying the same failing mobile-mcp call a third time — stop, tell the user
  what's wrong (no device booted, app not installed, tool erroring).
