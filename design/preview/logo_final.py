"""Preview board for the final Virya logo kit -> design/preview/logo_final.html (+ .png via render_png.py).

Run from repo root: python design/preview/logo_final.py
then: python <logo-design>/scripts/render_png.py design/preview/logo_final.html -o design/preview/logo_final.png --width 1400 --height 1500
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "logo"))
import build_kit as kit  # noqa: E402

SMALL = os.path.join(HERE, "small")
os.makedirs(SMALL, exist_ok=True)
for px in (16, 24, 32, 48):
    kit.save(kit.render(px, kit.LEGACY_FRAC, bg=kit.PAPER, radius=0.18), os.path.join(SMALL, f"icon_{px}.png"))
    kit.save(kit.render(px, kit.ICON_FRAC, ink=kit.WHITE, accent=kit.SIGNAL), os.path.join(SMALL, f"mark_{px}.png"))
# themed-icon simulation: launcher tints the monochrome layer's alpha
kit.save(kit.render(432, kit.ADAPTIVE_FRAC, ink="#BFE3CF", accent="#BFE3CF"), os.path.join(SMALL, "themed_fg.png"))

RES = "../../android/app/src/main/res"
FG = f"{RES}/mipmap-xxxhdpi/ic_launcher_foreground.png"
MONO = f"{RES}/mipmap-xxxhdpi/ic_launcher_monochrome.png"


def adaptive(shape, size=96, theme=False):
    # foreground canvas is 108dp; the visible icon is the central 72dp -> scale 1.5x and centre
    if theme:
        return (f'<div class="ai {shape}" style="width:{size}px;height:{size}px;background:#24362f">'
                f'<img src="small/themed_fg.png"></div>')
    return (f'<div class="ai {shape}" style="width:{size}px;height:{size}px;background:{kit.PAPER}">'
            f'<img src="{FG}"></div>')


apps = "".join(
    f'<div class="app"><div class="ai circle" style="width:64px;height:64px;background:{c}"></div><span>{n}</span></div>'
    for n, c in (("Kamera", "#3fa45f"), ("Pesan", "#5878c8"))
)
home = (apps + f'<div class="app">{adaptive("circle", 64)}<span>Virya</span></div>'
        f'<div class="app"><div class="ai circle" style="width:64px;height:64px;background:#dd8a4a"></div><span>Galeri</span></div>')
PLAIN_THEMED = '<div class="ai circle" style="width:64px;height:64px;background:#24362f"></div>'
themed = "".join(
    f'<div class="app">{adaptive("circle", 64, theme=True) if n == "Virya" else PLAIN_THEMED}<span>{n}</span></div>'
    for n in ("Kamera", "Pesan", "Virya", "Galeri")
)
small = "".join(
    f'<div class="sm"><img src="small/icon_{px}.png" width="{px}" height="{px}"><span>{px}px</span></div>'
    for px in (16, 24, 32, 48)
) + "".join(
    f'<div class="sm"><img src="small/icon_{px}.png" width="{px * 4}" height="{px * 4}" style="image-rendering:pixelated"><span>{px}px x4</span></div>'
    for px in (16, 24)
)
small_dark = "".join(
    f'<div class="sm"><img src="small/mark_{px}.png" width="{px}" height="{px}"><span>{px}px</span></div>'
    for px in (16, 24, 32)
)

html = f"""<!doctype html><html><head><meta charset="utf-8"><style>
@font-face {{ font-family: Anton; src: url(../../assets/fonts/Anton-Regular.ttf); }}
body {{ margin:0; background:#e2dccb; font-family: monospace; color:#141414; }}
.wrap {{ padding:40px; }}
h1 {{ font-family: Anton; font-size:56px; margin:0 0 4px; letter-spacing:1px; }}
.sub {{ font-size:12px; letter-spacing:1px; color:#6b6457; margin-bottom:28px; }}
.panel {{ background:#EFE9DC; border:2px solid #141414; padding:24px; margin-bottom:24px; display:flex; gap:28px; flex-wrap:nowrap; }}
.col {{ display:flex; flex-direction:column; gap:12px; }}
.lbl {{ font-size:11px; letter-spacing:2px; color:#6b6457; text-transform:uppercase; }}
.row {{ display:flex; gap:20px; align-items:center; }}
.ai {{ position:relative; overflow:hidden; flex:none; }}
.ai img {{ position:absolute; width:150%; height:150%; left:-25%; top:-25%; }}
.strip {{ background:#5a6472; padding:14px 16px; }}
.circle {{ border-radius:50%; }}
.squircle {{ border-radius:32%; }}
.rsq {{ border-radius:16%; }}
.teardrop {{ border-radius:50% 50% 50% 12%; }}
.phone {{ width:260px; height:520px; border-radius:26px; padding:22px 16px; box-sizing:border-box; }}
.home {{ background:linear-gradient(160deg,#55606f,#2d343d); display:flex; gap:10px; align-content:flex-start; flex-wrap:wrap; }}
.app {{ width:60px; display:flex; flex-direction:column; align-items:center; gap:6px; color:#fff; font:12px sans-serif; }}
.splash {{ background:#EFE9DC; border:8px solid #141414; display:flex; align-items:center; justify-content:center; }}

.sm {{ display:flex; flex-direction:column; align-items:center; gap:6px; font-size:10px; }}
.dark {{ background:#141414; padding:12px 16px; color:#ccc; }}
</style></head><body><div class="wrap">
<h1>VIRYA - LOGO FINAL (STREAK SEL)</h1>
<div class="sub">sel 40 . celah 4 . pitch 44 . tanda 216x128 dalam kotak 256 . kertas #EFE9DC . tinta #141414 . sinyal #FF4F00</div>

<div class="panel">
  <div class="col"><div class="lbl">Tanda</div><img src="../../assets/branding/virya_mark_512.png" width="220" style="background:#EFE9DC;border:1px solid #d6cfbe"></div>
  <div class="col"><div class="lbl">Wordmark</div><img src="../../assets/branding/virya_wordmark.svg" height="90"><div class="lbl" style="margin-top:20px">Mono / putih</div>
    <div class="row"><img src="../../assets/branding/virya_mark_mono.svg" width="110"><div style="background:#141414;padding:8px"><img src="../../assets/branding/virya_mark_white.svg" width="96"></div><div style="background:#FF4F00;padding:8px"><img src="../../assets/branding/virya_mark_white.svg" width="96"></div></div></div>
</div>

<div class="panel">
  <div class="col"><div class="lbl">Adaptive icon - bentuk mask</div>
    <div class="row strip">{adaptive("circle")}{adaptive("squircle")}{adaptive("rsq")}{adaptive("teardrop")}</div>
    <div class="lbl" style="margin-top:12px">Themed icon (Android 13, monokrom)</div>
    <div class="row strip">{adaptive("circle", theme=True)}{adaptive("squircle", theme=True)}</div>
    <div class="lbl" style="margin-top:12px">iOS / legacy</div>
    <div class="row strip"><img src="../../ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png" width="96" style="border-radius:22%"><img src="{RES}/mipmap-xxxhdpi/ic_launcher.png" width="96"><img src="{RES}/mipmap-xxxhdpi/ic_launcher_round.png" width="96"></div>
    <div class="lbl" style="margin-top:12px">Ukuran kecil (1:1 dan diperbesar)</div>
    <div class="row strip" style="color:#fff">{small}</div>
    <div class="row dark">{small_dark}</div>
  </div>
  <div class="col"><div class="lbl">Layar utama</div><div class="phone home">{home}</div></div>
  <div class="col"><div class="lbl">Themed</div><div class="phone home" style="background:linear-gradient(160deg,#1b2a24,#0e1512)">{themed}</div></div>
  <div class="col"><div class="lbl">Splash</div><div class="phone splash"><img src="{RES}/drawable-xxxhdpi/launch_mark.png" style="width:128px"></div></div>
</div>
</div></body></html>"""
with open(os.path.join(HERE, "logo_final.html"), "w", encoding="utf-8") as fh:
    fh.write(html)
print("wrote logo_final.html")
