"""Build the Virya logo kit (concept C "Streak Sel").

Generates SVG masters, PNG renders, Android launcher/splash resources and iOS icons
from one geometry definition. Run from the repo root:  python design/logo/build_kit.py
Requires: Pillow, fontTools (for the wordmark letters from assets/fonts/Anton-Regular.ttf).
"""
import math
import os

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BRAND = os.path.join(ROOT, "assets", "branding")
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
IOS = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets")

PAPER, INK, SIGNAL = "#EFE9DC", "#141414", "#FF4F00"
WHITE = "#FFFFFF"

# ---------------------------------------------------------------- geometry
# Units: mark bbox is 5 columns x 3 rows of cells on a 44-unit pitch.
CELL, GAP = 40, 4
PITCH = CELL + GAP
MARK_W, MARK_H = 5 * CELL + 4 * GAP, 3 * CELL + 2 * GAP  # 216 x 128
INK_CELLS = [(0, 0), (1, 1), (2, 2), (3, 1)]
ACCENT_CELL = (4, 0)
# Placement in the 256 master box: centred horizontally, nudged 4 units below the
# geometric centre so the top-heavy V sits optically centred.
BOX = 256
OX, OY = (BOX - MARK_W) / 2, (BOX - MARK_H) / 2 + 4  # 20, 68


def hexrgb(h, a=255):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (a,)


# ---------------------------------------------------------------- SVG
def svg_rects(ox, oy, ink, accent, s=1.0):
    out = []
    for (c, r) in INK_CELLS + [ACCENT_CELL]:
        fill = accent if (c, r) == ACCENT_CELL else ink
        x, y = ox + c * PITCH * s, oy + r * PITCH * s
        out.append(f'  <rect x="{x:g}" y="{y:g}" width="{CELL * s:g}" height="{CELL * s:g}" fill="{fill}"/>')
    return "\n".join(out)


def write_mark_svg(name, ink, accent, title):
    body = svg_rects(OX, OY, ink, accent)
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {BOX} {BOX}" width="{BOX}" height="{BOX}">\n'
           f'  <title>{title}</title>\n{body}\n</svg>\n')
    path = os.path.join(BRAND, name)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(svg)
    return path


def wordmark_svg(ink=INK, accent=SIGNAL):
    font = TTFont(os.path.join(ROOT, "assets", "fonts", "Anton-Regular.ttf"))
    gs, cmap = font.getGlyphSet(), font.getBestCmap()
    cap = font["OS/2"].sCapHeight
    k = MARK_H / cap  # letters' cap height == mark height
    tracking = 0.04 * cap  # slight open tracking, in font units
    x = MARK_W + 1.25 * PITCH  # gap between mark and letters
    paths = []
    for ch in "VIRYA":
        gname = cmap[ord(ch)]
        pen = SVGPathPen(gs)
        # font units (y-up) -> svg units (y-down), baseline at y = MARK_H
        tp = TransformPen(pen, (k, 0, 0, -k, x, MARK_H))
        gs[gname].draw(tp)
        paths.append(f'  <path d="{pen.getCommands()}" fill="{ink}"/>')
        x += (gs[gname].width + tracking) * k
    width = math.ceil(x - tracking * k)
    body = svg_rects(0, 0, ink, accent)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {MARK_H}" '
            f'width="{width}" height="{MARK_H}">\n  <title>Virya</title>\n{body}\n'
            + "\n".join(paths) + "\n</svg>\n")


# ---------------------------------------------------------------- raster
SS = 8  # supersampling factor


def draw_mark(img, cx, cy, mark_w, ink, accent, snap=True):
    """Draw the mark centred on (cx, cy) with total width mark_w (px), on a SS-scaled canvas.

    With snap=True cell/gap are rounded to whole output pixels so small icons stay crisp.
    """
    d = ImageDraw.Draw(img)
    pitch = mark_w / (MARK_W / PITCH)
    if snap:
        p = max(2, round(pitch / SS))
        g = max(1, round(p * GAP / PITCH)) if p >= 4 else 0
        cell, pitch = (p - g) * SS, p * SS
        w, h = 4 * pitch + cell, 2 * pitch + cell
        x0 = round((cx - w / 2) / SS) * SS
        y0 = round((cy - h / 2) / SS) * SS
    else:
        cell = pitch * CELL / PITCH
        w, h = 4 * pitch + cell, 2 * pitch + cell
        x0, y0 = cx - w / 2, cy - h / 2
    for (c, r) in INK_CELLS + [ACCENT_CELL]:
        fill = accent if (c, r) == ACCENT_CELL else ink
        x, y = x0 + c * pitch, y0 + r * pitch
        d.rectangle([x, y, x + cell - 1, y + cell - 1], fill=hexrgb(fill))


def render(size, mark_frac, ink=INK, accent=SIGNAL, bg=None, radius=0.0, dy_units=4, snap=True):
    """Square raster, mark width = mark_frac * size, optical nudge dy_units (in 256-box units)."""
    S = size * SS
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    if bg:
        d = ImageDraw.Draw(img)
        if radius:
            d.rounded_rectangle([0, 0, S - 1, S - 1], radius=radius * S, fill=hexrgb(bg))
        else:
            d.rectangle([0, 0, S - 1, S - 1], fill=hexrgb(bg))
    mark_w = mark_frac * S
    dy = dy_units * mark_w / MARK_W
    draw_mark(img, S / 2, S / 2 + dy, mark_w, ink, accent, snap=snap)
    return img.resize((size, size), Image.BOX)


def save(img, path, rgb=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if rgb:
        img = img.convert("RGB")
    img.save(path, optimize=True)


# ---------------------------------------------------------------- outputs
DENS = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
ICON_FRAC = MARK_W / BOX  # 0.84: mark width inside a full-bleed icon square (legacy/iOS)
LEGACY_FRAC = 0.66  # legacy launcher icon: mark inside a rounded paper tile
ADAPTIVE_FRAC = 50 / 108  # adaptive foreground: 50dp-wide mark in the 108dp canvas (fits 66dp circle)
IOS_FRAC = 0.66


def build_branding():
    os.makedirs(BRAND, exist_ok=True)
    write_mark_svg("virya_mark.svg", INK, SIGNAL, "Virya")
    write_mark_svg("virya_mark_mono.svg", INK, INK, "Virya (mono)")
    write_mark_svg("virya_mark_white.svg", WHITE, WHITE, "Virya (white)")
    with open(os.path.join(BRAND, "virya_wordmark.svg"), "w", encoding="utf-8") as fh:
        fh.write(wordmark_svg())
    for sz in (512, 1024):
        save(render(sz, ICON_FRAC, snap=False), os.path.join(BRAND, f"virya_mark_{sz}.png"))
        save(render(sz, ICON_FRAC, bg=PAPER, snap=False), os.path.join(BRAND, f"virya_icon_{sz}.png"), rgb=True)


def build_android():
    for q, k in DENS.items():
        mip = os.path.join(RES, f"mipmap-{q}")
        legacy = round(48 * k)
        save(render(legacy, LEGACY_FRAC, bg=PAPER, radius=0.18), os.path.join(mip, "ic_launcher.png"))
        circ = render(legacy, LEGACY_FRAC * 0.92, bg=None)
        base = Image.new("RGBA", circ.size, (0, 0, 0, 0))
        S = legacy * SS
        disc = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        ImageDraw.Draw(disc).ellipse([0, 0, S - 1, S - 1], fill=hexrgb(PAPER))
        base.alpha_composite(disc.resize((legacy, legacy), Image.BOX))
        base.alpha_composite(circ)
        save(base, os.path.join(mip, "ic_launcher_round.png"))
        fg = round(108 * k)
        save(render(fg, ADAPTIVE_FRAC), os.path.join(mip, "ic_launcher_foreground.png"))
        save(render(fg, ADAPTIVE_FRAC, ink=WHITE, accent=WHITE), os.path.join(mip, "ic_launcher_monochrome.png"))
        # pre-Android-12 splash bitmap: 120dp-wide mark
        sp = render(round(128 * k), 120 / 128, dy_units=0)
        save(sp, os.path.join(RES, f"drawable-{q}", "launch_mark.png"))


def build_ios():
    import json
    icon_dir = os.path.join(IOS, "AppIcon.appiconset")
    with open(os.path.join(icon_dir, "Contents.json"), encoding="utf-8") as fh:
        spec = json.load(fh)
    for im in spec["images"]:
        pt = float(im["size"].split("x")[0])
        px = round(pt * int(im["scale"][0]))
        save(render(px, IOS_FRAC, bg=PAPER), os.path.join(icon_dir, im["filename"]), rgb=True)
    launch = os.path.join(IOS, "LaunchImage.imageset")
    for sfx, k in (("", 1), ("@2x", 2), ("@3x", 3)):
        save(render(round(128 * k), 120 / 128, dy_units=0), os.path.join(launch, f"LaunchImage{sfx}.png"))


if __name__ == "__main__":
    build_branding()
    build_android()
    build_ios()
    print("logo kit built")
