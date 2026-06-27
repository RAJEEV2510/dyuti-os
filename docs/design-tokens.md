# Dyuti OS — Design Tokens

**Single source of truth.** Every theme asset (Plasma color scheme, Kvantum, SDDM/QML, Plymouth, GTK CSS, wallpaper, icons) reads from these tokens. Direction: *Premium dark, restrained accent.* Near-black charcoal base, crisp neutral light variant, saffron `#ff9d4d` used rarely and intentionally. High contrast, sharp, generous spacing, depth via shadow not border.

Token naming: `--dy-{category}-{role}`. Hex is 6-digit unless alpha is required (then `rgba()` or 8-digit). Dark is the default theme.

---

## 1. Color — Dark theme (default)

Cool-charcoal neutral ramp. Surfaces lighten as they rise toward the user; text is near-white on the darkest field for flagship contrast.

### Neutral ramp

| Token | Hex | Use |
|---|---|---|
| `--dy-bg-sunken` | `#08090b` | Base/sunken: app canvas, text-input wells, scroll troughs |
| `--dy-bg-window` | `#0d0f12` | Window background (default desktop/app chrome) |
| `--dy-surface-1` | `#14171c` | Cards, list rows, low panels (elevation 1) |
| `--dy-surface-2` | `#1b1f26` | Raised cards, sidebars, toolbars (elevation 2) |
| `--dy-surface-3` | `#232831` | Menus, popovers, dialogs, tooltips (elevation 3) |

### Interaction overlays (composite over the surface beneath)

| Token | Value | Use |
|---|---|---|
| `--dy-overlay-hover` | `rgba(255,255,255,0.045)` | Hover on any interactive surface |
| `--dy-overlay-active` | `rgba(255,255,255,0.085)` | Pressed / active / current row |
| `--dy-overlay-scrim` | `rgba(0,0,0,0.55)` | Modal backdrop dimming |

### Borders & dividers

| Token | Value | Use |
|---|---|---|
| `--dy-border-subtle` | `#262b33` | Default 1px dividers, card outlines |
| `--dy-border-strong` | `#3a414c` | Inputs, focus-adjacent edges, emphasized separation |

### Text

| Token | Hex | Use |
|---|---|---|
| `--dy-text-primary` | `#f2f4f7` | Body, headings, primary labels |
| `--dy-text-secondary` | `#a4adba` | Captions, helper text, inactive labels |
| `--dy-text-disabled` | `#5b636f` | Disabled controls, placeholder text |

### Semantic (muted for dark premium)

| Role | Foreground | Tint background |
|---|---|---|
| Success | `#3ea76f` | `rgba(62,167,111,0.14)` |
| Warning | `#d9a441` | `rgba(217,164,65,0.14)` |
| Error | `#db5b54` | `rgba(219,91,84,0.15)` |
| Info | `#5491d4` | `rgba(84,145,212,0.14)` |

---

## 2. Color — Light theme

Crisp neutral grey-white. Same slots, same semantics. Surfaces rise toward white; depth is carried by shadow, so elevated surfaces stay light rather than darkening.

### Neutral ramp

| Token | Hex | Use |
|---|---|---|
| `--dy-bg-sunken` | `#e4e8ed` | Base/sunken: input wells, scroll troughs |
| `--dy-bg-window` | `#eef1f5` | Window background |
| `--dy-surface-1` | `#f7f9fb` | Cards, list rows (elevation 1) |
| `--dy-surface-2` | `#ffffff` | Raised cards, toolbars, sidebars (elevation 2) |
| `--dy-surface-3` | `#ffffff` | Menus, popovers, dialogs (elevation 3, separated by shadow) |

### Interaction overlays

| Token | Value | Use |
|---|---|---|
| `--dy-overlay-hover` | `rgba(20,23,28,0.045)` | Hover |
| `--dy-overlay-active` | `rgba(20,23,28,0.075)` | Pressed / active / current row |
| `--dy-overlay-scrim` | `rgba(20,23,28,0.35)` | Modal backdrop dimming |

### Borders & dividers

| Token | Value | Use |
|---|---|---|
| `--dy-border-subtle` | `#dce1e8` | Default 1px dividers, card outlines |
| `--dy-border-strong` | `#c2cad4` | Inputs, emphasized separation |

### Text

| Token | Hex | Use |
|---|---|---|
| `--dy-text-primary` | `#14171c` | Body, headings |
| `--dy-text-secondary` | `#565e6b` | Captions, helper text |
| `--dy-text-disabled` | `#9aa3b0` | Disabled, placeholder |

### Semantic (darkened for white-field contrast)

| Role | Foreground | Tint background |
|---|---|---|
| Success | `#1f8f5a` | `rgba(31,143,90,0.12)` |
| Warning | `#b07414` | `rgba(176,116,20,0.12)` |
| Error | `#c43c34` | `rgba(196,60,52,0.12)` |
| Info | `#2f6fc0` | `rgba(47,111,192,0.12)` |

---

## 3. Accent system — Saffron

Saffron is the brand's "light in the dark." One hue, used as a precision instrument.

### Ramp (identical hex in both themes; tints differ by alpha)

| Token | Value | Use |
|---|---|---|
| `--dy-accent` | `#ff9d4d` | The accent. Focus rings, active/selected, key CTA fill |
| `--dy-accent-hover` | `#ffad66` | Hover state of an accent control |
| `--dy-accent-pressed` | `#f08a35` | Pressed state of an accent control |
| `--dy-accent-tint` (dark) | `rgba(255,157,77,0.12)` | Selected-row wash, subtle highlight on dark |
| `--dy-accent-tint` (light) | `rgba(255,157,77,0.16)` | Selected-row wash on light |
| `--dy-accent-focus-ring` | `rgba(255,157,77,0.45)` | 2px focus outline (offset 2px) |
| `--dy-on-accent` | `#1a1206` | Text/icon on a saffron fill (near-black for AA contrast) |

### Rules — where accent MAY appear

- Keyboard/focus ring on the focused control (always, every theme).
- The single primary CTA in a view (one filled saffron button max per screen).
- Active/selected state: current nav item, selected list row (as `--dy-accent-tint` wash + 2px leading bar in `--dy-accent`), toggle-on, checkbox/radio checked, slider fill, progress fill.
- Text-cursor / caret, and inline text-selection handle.
- Small status accents: unread dot, active-link text.

### Rules — where accent MUST NOT appear

- No large fills: no saffron title bars, headers, panels, sidebars, or full-width banners.
- Not on more than one CTA per view; secondary actions use neutral surfaces.
- Never as a decorative gradient, glow, or background texture.
- Not in body text, not in icons that aren't conveying active state.
- Not for semantic meaning (success/warn/error/info own those colors — accent ≠ status).
- Wallpaper: saffron appears only as a small radiant highlight, never the dominant field.

---

## 4. Typography

**UI:** Inter. **Mono:** Fira Code. Negative letter-spacing tightens large display sizes; caption/overline get a touch of positive tracking.

| Role | Font | Size / Line-height | Weight | Letter-spacing |
|---|---|---|---|---|
| Display | Inter | 40 / 48 px | 700 | -0.02em |
| H1 | Inter | 32 / 40 px | 700 | -0.02em |
| H2 | Inter | 24 / 32 px | 600 | -0.01em |
| H3 | Inter | 20 / 28 px | 600 | -0.01em |
| Body Large | Inter | 16 / 24 px | 400 | 0 |
| Body (default) | Inter | 14 / 22 px | 400 | 0 |
| Caption | Inter | 12 / 16 px | 500 | +0.01em |
| Overline | Inter | 11 / 16 px | 600 | +0.06em (uppercase) |
| Mono | Fira Code | 13 / 20 px | 400 | 0 |
| Mono (UI label) | Fira Code | 12 / 18 px | 500 | 0 |

Notes: UI default weight is 400; emphasis is 600 (not 700) in dense UI. Numerals: enable `tnum` (tabular figures) in tables and system monitors.

---

## 5. Radius scale

Tight-but-soft — softened corners, never bubbly.

| Token | px | Use |
|---|---|---|
| `--dy-radius-xs` | 4 | Tags, checkboxes, tiny chips, focus outline rounding |
| `--dy-radius-sm` | 6 | Buttons, inputs, menu items |
| `--dy-radius-md` | 10 | Cards, popovers, toolbars |
| `--dy-radius-lg` | 14 | Dialogs, modals, large panels, login card |
| `--dy-radius-pill` | 999 | Toggles, badges, slider thumbs, search fields |

---

## 6. Spacing scale

Base unit **4px**, 4/8 rhythm. Generous by default — prefer the larger step when unsure.

| Token | px |
|---|---|
| `--dy-space-0` | 0 |
| `--dy-space-1` | 4 |
| `--dy-space-2` | 8 |
| `--dy-space-3` | 12 |
| `--dy-space-4` | 16 |
| `--dy-space-5` | 20 |
| `--dy-space-6` | 24 |
| `--dy-space-8` | 32 |
| `--dy-space-10` | 40 |
| `--dy-space-12` | 48 |
| `--dy-space-16` | 64 |

Defaults: control padding `8 / 12` (v/h), card padding `16`, dialog padding `24`, section gap `32`.

---

## 7. Elevation / shadow scale

Tuned for dark: soft, deep, low-opacity — depth without heaviness. Light theme uses the same geometry at slightly higher opacity so shadows remain visible on white.

| Token | Dark value | Light value | Use |
|---|---|---|---|
| `--dy-elev-1` | `0 1px 2px rgba(0,0,0,0.40)` | `0 1px 2px rgba(20,23,28,0.08)` | Resting cards, list rows |
| `--dy-elev-2` | `0 2px 8px rgba(0,0,0,0.45)` | `0 2px 8px rgba(20,23,28,0.10)` | Toolbars, raised cards, dropdown triggers |
| `--dy-elev-3` | `0 8px 24px rgba(0,0,0,0.55)` | `0 8px 24px rgba(20,23,28,0.14)` | Menus, popovers, tooltips |
| `--dy-elev-4` | `0 16px 48px rgba(0,0,0,0.60)` | `0 16px 48px rgba(20,23,28,0.18)` | Modals, dialogs, login card |

Borders are not used to fake elevation; an optional `1px` inset hairline `rgba(255,255,255,0.04)` (dark) may sit on `--dy-surface-3+` for crispness.

---

## 8. Blur / translucency

Restrained. Translucency communicates layering, never obscures content.

| Token | Background fill | Blur radius |
|---|---|---|
| `--dy-panel-bg` (dark) | `rgba(13,15,18,0.72)` | 24 px |
| `--dy-panel-bg` (light) | `rgba(238,241,245,0.78)` | 24 px |
| `--dy-popup-bg` (dark) | `rgba(35,40,49,0.86)` | 32 px |
| `--dy-popup-bg` (light) | `rgba(255,255,255,0.88)` | 32 px |
| `--dy-scrim-blur` | — | 8 px (behind modals, with `--dy-overlay-scrim`) |

Fallback when compositing is unavailable: drop blur, raise alpha to `0.96` (panels) / `0.98` (popups).

---

## 9. Motion

Crisp, decisive, never bouncy. Use the standard easing for almost everything.

### Durations

| Token | ms | Use |
|---|---|---|
| `--dy-dur-instant` | 80 | State flips (checkbox, toggle thumb start) |
| `--dy-dur-fast` | 120 | Hover, focus ring, button press |
| `--dy-dur-base` | 200 | Standard transitions, expand/collapse, tab switch |
| `--dy-dur-slow` | 320 | Dialog/menu enter, drawer slide |

### Easing

| Token | Curve | Use |
|---|---|---|
| `--dy-ease-standard` | `cubic-bezier(0.2, 0, 0, 1)` | Default for moves and size changes |
| `--dy-ease-decel` | `cubic-bezier(0, 0, 0, 1)` | Elements entering the screen |
| `--dy-ease-accel` | `cubic-bezier(0.3, 0, 1, 1)` | Elements leaving the screen |
| `--dy-ease-emphasized` | `cubic-bezier(0.2, 0, 0, 1.05)` | Login reveal only (slight, controlled overshoot) |

### Choreographed reveals

- **Plymouth boot:** logo fade-in 600 ms `--dy-ease-decel`, hold, then 1px saffron progress hairline fills with `--dy-ease-standard`; on handoff, 400 ms cross-fade to SDDM (no flash to black).
- **SDDM/login reveal:** background settles 480 ms `--dy-ease-decel`; login card rises 16px + fades over 320 ms `--dy-ease-emphasized`, delayed 120 ms after background.
- **Reduced motion:** if disabled, all of the above collapse to a 120 ms opacity fade; no translation.

---

## 10. Mapping table — what each asset consumes

| Asset | Tokens consumed |
|---|---|
| **Plasma color scheme** (`.colors`) | `bg-window`→BackgroundNormal (Window/View), `bg-sunken`→View Background, `surface-1/2/3`→Button/Tooltip/complementary backgrounds, `text-primary`→ForegroundNormal, `text-secondary`→ForegroundInactive, `text-disabled`→ForegroundInactive(disabled), `border-subtle`→DecorationFocus off / separators, `accent`→DecorationFocus + DecorationHover + selection background, `on-accent`→selection foreground, all semantic FGs→Foreground{Positive,Neutral,Negative,Active}. |
| **Kvantum** (`.kvconfig` + SVG) | Neutral ramp for frame/interior fills; `border-subtle/strong` for `.frame` outlines; `radius-sm/md` for `[GeneralButton]`/`[PanelButtonCommand]` corner radius; `accent` + `accent-focus-ring` for focus/selection; `elev-2/3` baked into menu/tooltip SVG shadow; `overlay-hover/active` for hover/press states; `panel-bg`/`popup-bg` alpha + blur for translucent menus. |
| **SDDM / QML login** | `bg-window` (or wallpaper) base; `surface-3` + `radius-lg` + `elev-4` for the login card; `text-primary/secondary`; `accent` for login button fill + field focus ring, `on-accent` for button label; Inter Body/H2 type tokens; motion reveal tokens (§9); `popup-bg` blur for the card if over wallpaper. |
| **Plymouth boot splash** | `bg-sunken` background; `text-secondary` for any label; `accent` for the progress hairline only; logo asset; motion: 600 ms fade + handoff cross-fade (§9). Single dark value only (no theme switch at boot). |
| **GTK CSS** (`gtk-3.0`/`gtk-4.0`) | Full neutral ramp → `@define-color` (`theme_bg_color`, `theme_base_color`, `theme_fg_color`, `insensitive_fg_color`); `surface-1/2/3` for `.card`/headerbar/menu; `border-subtle/strong`→`borders`; `accent`→`@accent_bg_color`/`@accent_color`, `on-accent`→`@accent_fg_color`; semantic FGs→`@success/warning/error_color`; `radius-sm/md/lg`; `elev-2/3`; Inter/Fira Code font tokens; `overlay-hover/active`. |
| **Wallpaper** | `bg-sunken`→`bg-window` as the dark field gradient; `accent` permitted only as a single small radiant highlight (per §3 rules); light variant uses `bg-window`→`surface-1`. No large saffron fields. Ship matched dark + light files. |
| **Icon theme** | Neutral ramp for surfaces/strokes; `text-primary/secondary` for monochrome symbolic icons; `accent` only on active/selected symbolic states and the system-busy/notification dot; semantic colors for status-emblem icons (sync/error/warning). Symbolic icons inherit `text-secondary` at rest, `accent` when active. |

---

### Quick reference — core hex

`Dark:` bg `#0d0f12` · sunken `#08090b` · surf `#14171c`/`#1b1f26`/`#232831` · text `#f2f4f7`/`#a4adba`/`#5b636f` · border `#262b33`/`#3a414c`
`Light:` bg `#eef1f5` · sunken `#e4e8ed` · surf `#f7f9fb`/`#ffffff` · text `#14171c`/`#565e6b`/`#9aa3b0` · border `#dce1e8`/`#c2cad4`
`Accent:` `#ff9d4d` · hover `#ffad66` · pressed `#f08a35` · on-accent `#1a1206`
