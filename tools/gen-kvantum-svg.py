#!/usr/bin/env python3
"""Generate the Dyuti Kvantum SVGs (dark + light) from the design tokens.

Kvantum renders each widget from named SVG elements:
  <element>-<status>-<segment>   for frames (segment = the 9-slice piece)
  <element>-<status>-interior    for the fill
  <element>-<status>             for indicators (checkbox/radio/arrow)

statuses: normal | focused (hover/kbd) | pressed | toggled (checked)

We own both the element names (here) and the kvconfig that references them, so
the only contract that matters is that the two agree. Geometry: a rounded
9-slice where corner/edge pieces carry a `b`-thick border on their outer sides
plus the fill band; the interior carries the fill. When b == f the frame is a
solid band (used for thin accent rings). QtSvg can't blur, so elevation is
carried by surface contrast + Kvantum's own menu/tooltip shadow depth.

Both themes share element names + geometry; only the palette changes, so a
single SVG element set drives the dark Dyuti and light DyutiLight kvconfigs.

Run:  python tools/gen-kvantum-svg.py
Out:  branding/dyuti-branding/usr/share/Kvantum/Dyuti/Dyuti.svg
      branding/dyuti-branding/usr/share/Kvantum/DyutiLight/DyutiLight.svg
"""
import os

# ---- design tokens -------------------------------------------------------
# One dict per theme. Keys map design-tokens.md roles onto the names the
# widget table below consumes. Derived values (BTN_HOVER/PRESS, the popup
# alphas, scroll greys) are precomputed approximations of the overlay tokens
# composited over their base surface — QtSvg can't blend live.
DARK = {
    "SUNKEN": "#08090b", "WINDOW": "#0d0f12",
    "S1": "#14171c", "S2": "#1b1f26", "S3": "#232831",
    "BORDER": "#262b33", "BORDER_STRONG": "#3a414c",
    "TXT": "#f2f4f7", "TXT2": "#a4adba", "TXT_DIS": "#5b636f",
    "ACC": "#ff9d4d", "ACC_H": "#ffad66", "ACC_P": "#f08a35", "ON_ACC": "#1a1206",
    # composited approximations (overlay-hover/active baked over the base surface)
    "BTN": "#1b1f26",          # = S2
    "BTN_HOVER": "#20242c",    # S2 + ~4.5% white
    "BTN_PRESS": "#161a20",    # S2 - active
    "TINT": ("#ff9d4d", 0.12),       # accent-tint wash
    "TINT_STRONG": ("#ff9d4d", 0.18),
    "MENU_FILL": ("#232831", 0.86),  # popup-bg dark
    "TIP_FILL": ("#232831", 0.94),
    # scrollbar slider greys (normal / hover / pressed)
    "SCROLL_N": "#232831", "SCROLL_F": "#3a414c", "SCROLL_P": "#5b636f",
}

LIGHT = {
    "SUNKEN": "#e4e8ed", "WINDOW": "#eef1f5",
    "S1": "#f7f9fb", "S2": "#ffffff", "S3": "#ffffff",
    "BORDER": "#dce1e8", "BORDER_STRONG": "#c2cad4",
    "TXT": "#14171c", "TXT2": "#565e6b", "TXT_DIS": "#9aa3b0",
    "ACC": "#ff9d4d", "ACC_H": "#ffad66", "ACC_P": "#f08a35", "ON_ACC": "#1a1206",
    # composited approximations (overlay rgba(20,23,28,..) baked over white)
    "BTN": "#ffffff",          # = S2 (raised, separated by border + shadow)
    "BTN_HOVER": "#f4f5f7",    # white - ~4.5% (20,23,28)
    "BTN_PRESS": "#edeef0",    # white - ~7.5%
    "TINT": ("#ff9d4d", 0.16),       # accent-tint wash (light)
    "TINT_STRONG": ("#ff9d4d", 0.24),
    "MENU_FILL": ("#ffffff", 0.88),  # popup-bg light
    "TIP_FILL": ("#ffffff", 0.94),
    # scrollbar slider greys (normal / hover / pressed)
    "SCROLL_N": "#c2cad4", "SCROLL_F": "#9aa3b0", "SCROLL_P": "#565e6b",
}

NONE = ("#000000", 0.0)

E = 20   # edge length (stretched by Kvantum)
IS = 20  # interior size (stretched)


def col(c):
    """c -> (fill_attr_string). Accepts '#hex' or ('#hex', alpha)."""
    if isinstance(c, tuple):
        return f'fill="{c[0]}" fill-opacity="{c[1]:g}"'
    return f'fill="{c}"'


def corner(frags, idn, which, f, b, r, fill, border, ox, oy):
    """One f x f corner piece. `which` in tl,tr,bl,br."""
    if border is None:
        border = fill
    ri = max(r - b, 0)
    out = []
    if r <= 0:
        # square corner: border on the two outer sides
        out.append(f'<rect x="0" y="0" width="{f}" height="{f}" {col(border)}/>')
        if which == "tl":
            ix, iy, iw, ih = b, b, f - b, f - b
        elif which == "tr":
            ix, iy, iw, ih = 0, b, f - b, f - b
        elif which == "bl":
            ix, iy, iw, ih = b, 0, f - b, f - b
        else:  # br
            ix, iy, iw, ih = 0, 0, f - b, f - b
        out.append(f'<rect x="{ix}" y="{iy}" width="{iw}" height="{ih}" {col(fill)}/>')
    else:
        if which == "tl":
            po = f"M {f},0 L {r},0 A {r},{r} 0 0 0 0,{r} L 0,{f} L {f},{f} Z"
            pi = f"M {f},{b} L {r},{b} A {ri},{ri} 0 0 0 {b},{r} L {b},{f} L {f},{f} Z"
        elif which == "tr":
            po = f"M 0,0 L {f-r},0 A {r},{r} 0 0 1 {f},{r} L {f},{f} L 0,{f} Z"
            pi = f"M 0,{b} L {f-r},{b} A {ri},{ri} 0 0 1 {f-b},{r} L {f-b},{f} L 0,{f} Z"
        elif which == "bl":
            po = f"M 0,0 L {f},0 L {f},{f} L {r},{f} A {r},{r} 0 0 1 0,{f-r} L 0,0 Z"
            pi = f"M {b},0 L {f},0 L {f},{f-b} L {r},{f-b} A {ri},{ri} 0 0 1 {b},{f-r} L {b},0 Z"
        else:  # br
            po = f"M 0,0 L {f},0 L {f},{f-r} A {r},{r} 0 0 1 {f-r},{f} L 0,{f} L 0,0 Z"
            pi = f"M 0,0 L {f-b},0 L {f-b},{f-r} A {ri},{ri} 0 0 1 {f-r},{f-b} L 0,{f-b} L 0,0 Z"
        out.append(f'<path d="{po}" {col(border)}/>')
        if not (isinstance(fill, tuple) and fill[1] == 0.0):
            out.append(f'<path d="{pi}" {col(fill)}/>')
        elif b > 0 and b < f:
            out.append(f'<path d="{pi}" {col(fill)}/>')
    frags.append(f'<g id="{idn}" transform="translate({ox},{oy})">{"".join(out)}</g>')


def edge(frags, idn, which, f, b, fill, border, ox, oy):
    if border is None:
        border = fill
    out = []
    if which == "top":
        out.append(f'<rect x="0" y="0" width="{E}" height="{b}" {col(border)}/>')
        out.append(f'<rect x="0" y="{b}" width="{E}" height="{f-b}" {col(fill)}/>')
    elif which == "bottom":
        out.append(f'<rect x="0" y="0" width="{E}" height="{f-b}" {col(fill)}/>')
        out.append(f'<rect x="0" y="{f-b}" width="{E}" height="{b}" {col(border)}/>')
    elif which == "left":
        out.append(f'<rect x="0" y="0" width="{b}" height="{E}" {col(border)}/>')
        out.append(f'<rect x="{b}" y="0" width="{f-b}" height="{E}" {col(fill)}/>')
    else:  # right
        out.append(f'<rect x="0" y="0" width="{f-b}" height="{E}" {col(fill)}/>')
        out.append(f'<rect x="{f-b}" y="0" width="{b}" height="{E}" {col(border)}/>')
    frags.append(f'<g id="{idn}" transform="translate({ox},{oy})">{"".join(out)}</g>')


def interior(frags, idn, fill, ox, oy):
    frags.append(
        f'<g id="{idn}" transform="translate({ox},{oy})">'
        f'<rect x="0" y="0" width="{IS}" height="{IS}" {col(fill)}/></g>')


class Builder:
    """Lays out all SVG fragments for one theme."""

    def __init__(self, theme):
        self.t = theme
        self.frags = []
        self.y = 0

    def frame_state(self, name, status, f, b, r, fill, border):
        """Emit all 9 frame pieces + interior for one element+status."""
        y = self.y
        pre = f"{name}-{status}"
        x = 0; gap = f + 6
        corner(self.frags, f"{pre}-topleft", "tl", f, b, r, fill, border, x, y); x += gap
        corner(self.frags, f"{pre}-topright", "tr", f, b, r, fill, border, x, y); x += gap
        corner(self.frags, f"{pre}-bottomleft", "bl", f, b, r, fill, border, x, y); x += gap
        corner(self.frags, f"{pre}-bottomright", "br", f, b, r, fill, border, x, y); x += gap
        edge(self.frags, f"{pre}-top", "top", f, b, fill, border, x, y); x += E + 6
        edge(self.frags, f"{pre}-bottom", "bottom", f, b, fill, border, x, y); x += E + 6
        edge(self.frags, f"{pre}-left", "left", f, b, fill, border, x, y); x += f + 6
        edge(self.frags, f"{pre}-right", "right", f, b, fill, border, x, y); x += f + 6
        interior(self.frags, f"{pre}-interior", fill, x, y)
        self.y = y + max(f, E) + 12

    def widget(self, name, f, b, r, states):
        """states: dict status -> (fill, border)."""
        for status, (fill, border) in states.items():
            self.frame_state(name, status, f, b, r, fill, border)

    def check_box(self, idn, fill, border, mark, ox, oy, radius):
        s = 16; b = 1.5; on = self.t["ON_ACC"]
        out = [f'<rect x="0.75" y="0.75" width="{s-1.5}" height="{s-1.5}" rx="{radius}" '
               f'ry="{radius}" {col(fill)} stroke="{border}" stroke-width="{b}"/>']
        if mark == "check":
            out.append('<path d="M4.5,8.3 L7,10.8 L11.7,5.3" fill="none" '
                       f'stroke="{on}" stroke-width="2" stroke-linecap="round" '
                       'stroke-linejoin="round"/>')
        elif mark == "dot":
            out.append(f'<circle cx="8" cy="8" r="3.4" {col((on,1))}/>')
        elif mark == "dash":
            out.append(f'<rect x="4.3" y="7" width="7.4" height="2" rx="1" {col((on,1))}/>')
        self.frags.append(f'<g id="{idn}" transform="translate({ox},{oy})">{"".join(out)}</g>')

    def indicators(self, name, radius, marks):
        t = self.t
        y = self.y; x = 0
        # checked variants -> accent fill, dark mark
        for st in ("normal", "focused", "pressed"):
            fill = t["ACC"] if st == "normal" else (t["ACC_H"] if st == "focused" else t["ACC_P"])
            self.check_box(f"{name}-checked-{st}", fill, fill, marks[0], x, y, radius); x += 22
        for st in ("normal", "focused", "pressed"):
            bd = t["BORDER_STRONG"] if st == "normal" else t["ACC"]
            self.check_box(f"{name}-unchecked-{st}", t["SUNKEN"], bd, None, x, y, radius); x += 22
        self.check_box(f"{name}-tristate-normal", t["ACC"], t["ACC"], marks[1], x, y, radius); x += 22
        self.y = y + 24

    def arrow(self, idn, d, color, ox, oy):
        self.frags.append(f'<g id="{idn}" transform="translate({ox},{oy})">'
                          f'<path d="{d}" fill="none" stroke="{color}" stroke-width="1.6" '
                          'stroke-linecap="round" stroke-linejoin="round"/></g>')

    def arrows(self, base):
        t = self.t
        y = self.y; x = 0
        paths = {
            "down":  "M3,5 L7,9 L11,5",
            "up":    "M3,9 L7,5 L11,9",
            "left":  "M9,3 L5,7 L9,11",
            "right": "M5,3 L9,7 L5,11",
        }
        for dirn, d in paths.items():
            for st in ("normal", "focused", "pressed"):
                c = t["TXT2"] if st == "normal" else (t["TXT"] if st == "focused" else t["ACC"])
                self.arrow(f"{base}-{dirn}-{st}", d, c, x, y); x += 16
        self.y = y + 16


def build(theme):
    """Build the full fragment set for a theme; returns the SVG string."""
    t = theme
    NONE_ = NONE
    bd = Builder(theme)

    # ---- buttons / inputs ------------------------------------------------
    bd.widget("button", 6, 1, 6, {
        "normal":  (t["BTN"], t["BORDER_STRONG"]),
        "focused": (t["BTN_HOVER"], t["ACC"]),
        "pressed": (t["BTN_PRESS"], t["BORDER_STRONG"]),
        "toggled": (t["TINT"], t["ACC"]),
    })
    bd.widget("tbutton", 6, 1, 6, {
        "normal":  (NONE_, NONE_),
        "focused": (t["BTN_HOVER"], t["BORDER_STRONG"]),
        "pressed": (t["BTN_PRESS"], t["BORDER_STRONG"]),
        "toggled": (t["TINT"], t["ACC"]),
    })
    bd.widget("combo", 6, 1, 6, {
        "normal":  (t["BTN"], t["BORDER_STRONG"]),
        "focused": (t["BTN_HOVER"], t["ACC"]),
        "pressed": (t["BTN_PRESS"], t["ACC"]),
        "toggled": (t["BTN_PRESS"], t["ACC"]),
    })
    bd.widget("lineedit", 6, 1, 6, {
        "normal":  (t["SUNKEN"], t["BORDER_STRONG"]),
        "focused": (t["SUNKEN"], t["ACC"]),
        "pressed": (t["SUNKEN"], t["ACC"]),
        "toggled": (t["SUNKEN"], t["ACC"]),
    })

    # ---- tabs ------------------------------------------------------------
    bd.widget("tab", 6, 1, 6, {
        "normal":  (NONE_, NONE_),
        "focused": (t["BTN_HOVER"], t["BORDER"]),
        "pressed": (t["BTN_PRESS"], t["BORDER"]),
        "toggled": (t["S2"], t["ACC"]),
    })
    bd.widget("tabframe", 10, 1, 10, {"normal": (t["WINDOW"], t["BORDER"])})

    # ---- containers ------------------------------------------------------
    bd.widget("genframe", 10, 1, 10, {"normal": (NONE_, t["BORDER"])})
    bd.widget("group", 10, 1, 10, {"normal": (t["S1"], t["BORDER"])})
    bd.widget("toolbar", 1, 1, 0, {"normal": (t["S1"], t["BORDER"])})
    bd.widget("itemview", 10, 1, 10, {"normal": (NONE_, t["BORDER"])})
    bd.widget("statusbar", 1, 1, 0, {"normal": (t["S1"], t["BORDER"])})

    # ---- popups ----------------------------------------------------------
    bd.widget("menu", 10, 1, 10, {"normal": (t["MENU_FILL"], t["BORDER"])})
    bd.widget("tooltip", 8, 1, 8, {"normal": (t["TIP_FILL"], t["BORDER_STRONG"])})
    bd.widget("menuitem", 6, 0, 6, {
        "normal":  (NONE_, NONE_),
        "focused": (t["TINT"], t["TINT"]),
        "pressed": (t["TINT_STRONG"], t["TINT_STRONG"]),
    })

    # ---- progress / sliders / scrollbar ---------------------------------
    bd.widget("progress", 4, 1, 4, {"normal": (t["SUNKEN"], t["BORDER"])})
    bd.widget("progressindicator", 4, 0, 4, {"normal": (t["ACC"], t["ACC"])})
    bd.widget("slidergroove", 3, 0, 3, {"normal": (t["BORDER_STRONG"], t["BORDER_STRONG"])})
    bd.widget("sliderfill", 3, 0, 3, {"normal": (t["ACC"], t["ACC"])})
    bd.widget("slidercursor", 9, 0, 9, {
        "normal":  (t["TXT"], t["TXT"]),
        "focused": (t["ACC_H"], t["ACC_H"]),
        "pressed": (t["ACC"], t["ACC"]),
    })
    bd.widget("scrollslider", 6, 0, 6, {
        "normal":  (t["SCROLL_N"], t["SCROLL_N"]),
        "focused": (t["SCROLL_F"], t["SCROLL_F"]),
        "pressed": (t["SCROLL_P"], t["SCROLL_P"]),
    })

    # ---- focus ring (b == f -> solid 2px band) --------------------------
    bd.widget("focus", 2, 2, 2, {"normal": (("#ff9d4d", 0.55), ("#ff9d4d", 0.55))})

    # ---- indicators: checkbox / radio -----------------------------------
    bd.indicators("checkbox", 4, ("check", "dash"))
    bd.indicators("radio", 8, ("dot", "dot"))

    # ---- arrows ----------------------------------------------------------
    bd.arrows("arrow")

    # ---- assemble --------------------------------------------------------
    W = 520
    H = bd.y + 10
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
        f'viewBox="0 0 {W} {H}">\n'
        '<!-- Dyuti Kvantum theme assets. Generated by tools/gen-kvantum-svg.py '
        'from docs/design-tokens.md. Do not edit by hand. -->\n'
        + "\n".join(bd.frags) +
        "\n</svg>\n"
    ), len(bd.frags)


def write(theme, folder, name):
    svg, n = build(theme)
    out_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        "branding", "dyuti-branding", "usr", "share", "Kvantum", folder, name)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(svg)
    print(f"wrote {out_path} ({n} elements, {len(svg)} bytes)")


if __name__ == "__main__":
    write(DARK, "Dyuti", "Dyuti.svg")
    write(LIGHT, "DyutiLight", "DyutiLight.svg")
