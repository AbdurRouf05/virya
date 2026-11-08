"""Generate Virya mockup HTML pages and render them to PNG (2x) with headless Chrome.

Usage: python build.py [name ...]   (no args = all screens + overview)
"""
import datetime as dt
import os
import random
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE)
# Path to an HTML→PNG screenshot script (headless Chrome); set RENDER_PNG.
RENDER = os.environ.get("RENDER_PNG", "render_png.py")

C = dict(bike="#FF4F00", run="#141414", walk="#2F7D4F", gym="#3B5BDB",
         paper="#EFE9DC", paper2="#E3DBC9", line="#CFC6B2", ink="#141414",
         ink2="#3A3A36", mute="#77736A", acid="#C6FF00", ok="#2F7D4F", cau="#E8B23A")

# ---------------------------------------------------------------- icons
def svg(body, size=20, stroke="currentColor", sw=2, fill="none", vb=24):
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 {vb} {vb}" fill="{fill}" stroke="{stroke}" '
            f'stroke-width="{sw}" stroke-linecap="square" stroke-linejoin="miter">{body}</svg>')

I_TODAY = '<circle cx="12" cy="12" r="4.5"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M4.9 19.1 7 17M17 7l2.1-2.1"/>'
I_CAL = '<rect x="3" y="3" width="5" height="5"/><rect x="9.5" y="3" width="5" height="5"/><rect x="16" y="3" width="5" height="5"/><rect x="3" y="9.5" width="5" height="5"/><rect x="9.5" y="9.5" width="5" height="5" fill="currentColor"/><rect x="16" y="9.5" width="5" height="5"/><rect x="3" y="16" width="5" height="5" fill="currentColor"/><rect x="9.5" y="16" width="5" height="5"/><rect x="16" y="16" width="5" height="5"/>'
I_DUMB = '<path d="M2 10v4M5 7v10M8 7v10M8 12h8M16 7v10M19 7v10M22 10v4"/>'
I_USER = '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4.4 3.6-7 8-7s8 2.6 8 7"/>'
I_PIN = '<path d="M9 3h6l-1 6 3.5 3.5h-11L10 9z"/><path d="M12 12.5V21"/>'
I_CAM = '<rect x="3" y="7" width="18" height="13"/><circle cx="12" cy="13.5" r="3.5"/><path d="M8.5 7l1.5-3h4l1.5 3"/>'
I_GPS = '<circle cx="12" cy="12" r="7"/><circle cx="12" cy="12" r="2" fill="currentColor"/><path d="M12 1v4M12 19v4M1 12h4M19 12h4"/>'
I_CHECK = '<path d="M5 12.5l4.5 4.5L19 7.5"/>'
I_PLUS = '<path d="M12 4v16M4 12h16"/>'
I_BACK = '<path d="M20 12H5M11 5l-7 7 7 7"/>'
I_SEND = '<path d="M3 20l18-8L3 4l3 8zM6 12h8"/>'
I_CLOCK = '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/>'
I_TASK = '<rect x="3" y="4" width="18" height="17"/><path d="M7 10l2.5 2.5L14 8M7 16h10"/>'
I_MORE = '<circle cx="5" cy="12" r="1.2" fill="currentColor"/><circle cx="12" cy="12" r="1.2" fill="currentColor"/><circle cx="19" cy="12" r="1.2" fill="currentColor"/>'
I_SEARCH = '<circle cx="10.5" cy="10.5" r="6.5"/><path d="M15.5 15.5 21 21"/>'
I_CHEV = '<path d="M9 5l7 7-7 7"/>'
I_CHEVL = '<path d="M15 5l-7 7 7 7"/>'
I_LOCK = '<rect x="4" y="10" width="16" height="11"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/>'


def check(color="#EFE9DC", size=13):
    return svg(I_CHECK, size, color, 3)


# ---------------------------------------------------------------- frame
def status_bar(dark=False, time="09:41"):
    col = "#EFE9DC" if dark else "#141414"
    sig = f'<svg width="16" height="12" viewBox="0 0 16 12"><rect x="0" y="8" width="3" height="4" fill="{col}"/><rect x="4.3" y="5.5" width="3" height="6.5" fill="{col}"/><rect x="8.6" y="3" width="3" height="9" fill="{col}"/><rect x="12.9" y="0" width="3" height="12" fill="{col}"/></svg>'
    wifi = f'<svg width="15" height="12" viewBox="0 0 15 12"><path d="M7.5 12 0 3.2A11.5 11.5 0 0 1 15 3.2z" fill="{col}"/></svg>'
    bat = f'<svg width="24" height="12" viewBox="0 0 24 12"><rect x=".75" y=".75" width="20" height="10.5" fill="none" stroke="{col}" stroke-width="1.5"/><rect x="3" y="3" width="13" height="6" fill="{col}"/><rect x="21.5" y="4" width="2" height="4" fill="{col}"/></svg>'
    return f'<div class="status" style="color:{col}"><span>{time}</span><span class="ic">{sig}{wifi}{bat}<span class="mono" style="font-size:11px;font-weight:500">78%</span></span></div>'


def nav(active, close=False):
    tabs = [("hari", "HARI INI", I_TODAY), ("kal", "KALENDER", I_CAL), None,
            ("lat", "LATIHAN", I_DUMB), ("pro", "PROFIL", I_USER)]
    out = []
    for t in tabs:
        if t is None:
            if close:
                inner = svg('<path d="M6 6l12 12M18 6 6 18"/>', 24, "#EFE9DC", 3)
                out.append(f'<div class="mid"><div class="fab close">{inner}</div><div class="fablbl">TUTUP</div></div>')
            else:
                inner = svg(I_PLUS, 26, "#FFFFFF", 3.4)
                out.append(f'<div class="mid"><div class="fab">{inner}</div><div class="fablbl">MULAI</div></div>')
            continue
        key, label, icon = t
        on = " on" if key == active else ""
        out.append(f'<div class="tab{on}">{svg(icon, 20)}<span>{label}</span></div>')
    return f'<div class="nav"><div class="tabs">{"".join(out)}</div><div class="gest"><i></i></div></div>'


def device(inner, dark=False, extra_cls="", style=""):
    return f'<div class="device" style="{style}"><div class="screen {"dark" if dark else ""} {extra_cls}">{inner}</div></div>'


def page(name, body, w, h, extra_css=""):
    html = f"""<!doctype html><html class="x2"><head><meta charset="utf-8">
<link rel="stylesheet" href="common.css"><style>body{{width:{w}px;height:{h}px}}{extra_css}</style></head>
<body>{body}</body></html>"""
    path = os.path.join(HERE, name + ".html")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(html)
    return path, w, h


def hexa(hx, a):
    hx = hx.lstrip("#")
    r, g, b = int(hx[0:2], 16), int(hx[2:4], 16), int(hx[4:6], 16)
    return f"rgba({r},{g},{b},{a})"


def cell_bg(cats, alpha=1.0):
    cols = [hexa(C[c], alpha) for c in cats]
    if len(cols) == 1:
        return f"background:{cols[0]}"
    if len(cols) == 2:
        return f"background:linear-gradient(135deg,{cols[0]} 50%,{cols[1]} 50%)"
    q = cols + cols[:4 - len(cols)]
    return (f"background:conic-gradient({q[0]} 0 25%,{q[1]} 0 50%,{q[2]} 0 75%,{q[3]} 0)")


# ================================================================ 1. HARI INI
def week_strip():
    days = [("SEN", "2", ["gym"]), ("SEL", "3", ["gym", "bike"]), ("RAB", "4", ["run"]),
            ("KAM", "5", ["gym"]), ("JUM", "6", ["walk"]), ("SAB", "7", ["bike", "run"]), ("MIN", "8", None)]
    cells = []
    for d, n, cats in days:
        if cats:
            st = cell_bg(cats) + ";border:1.5px solid #141414"
            ncol = "#EFE9DC"
        else:
            st = "background:repeating-linear-gradient(45deg,transparent 0 4px,rgba(20,20,20,.12) 4px 5px);border:2px solid #FF4F00"
            ncol = "#141414"
        cells.append(f'<div style="flex:1;text-align:center"><div style="height:32px;{st};display:flex;align-items:flex-end;padding:3px 4px">'
                     f'<span class="mono" style="font-size:10px;font-weight:700;color:{ncol}">{n}</span></div>'
                     f'<div class="lbl" style="margin-top:5px;font-size:9px;{"color:#FF4F00;font-weight:700" if not cats else ""}">{d}</div></div>')
    return f'<div style="display:flex;gap:5px">{"".join(cells)}</div>'


def legend_inline(size=9):
    items = [("bike", "SEPEDA"), ("run", "LARI"), ("walk", "JALAN"), ("gym", "GYM")]
    s = "".join(f'<span style="display:flex;align-items:center;gap:4px"><i style="width:{size}px;height:{size}px;background:{C[k]};display:block"></i>{l}</span>' for k, l in items)
    s += f'<span style="display:flex;align-items:center;gap:4px"><i style="width:{size}px;height:{size}px;{cell_bg(["gym","bike"])};display:block"></i>CAMPUR</span>'
    return f'<div class="lbl" style="display:flex;gap:10px;font-size:8.5px;letter-spacing:.1em">{s}</div>'


def hari_ini_content():
    tasks = [(True, "Bayar listrik", ""), (False, "Servis rantai sepeda", "pin"),
             (False, "Kirim laporan mingguan", "16:00"), (False, "Beli protein bar", "pin")]
    rows = []
    for done, t, meta in tasks:
        cb = f'<div class="cb on">{check()}</div>' if done else '<div class="cb"></div>'
        if meta == "pin":
            m = f'<span style="color:#FF4F00">{svg(I_PIN, 15, "#FF4F00", 2)}</span>'
        elif meta:
            m = f'<span class="mono" style="font-size:10px;font-weight:500;color:#3A3A36;display:flex;gap:4px;align-items:center">{svg(I_CLOCK, 12, "#3A3A36", 2)}{meta}</span>'
        else:
            m = ""
        rows.append(f'<div class="row" style="padding:6px 10px">{cb}<span style="flex:1;font-size:14px" class="{"done" if done else ""}">{t}</span>{m}</div>')

    def focus_row(name, used, lim, warn=False):
        pct = used / lim * 100
        col = C["cau"] if warn else C["ink"]
        tag = f'<span class="tag" style="background:{C["cau"]};border-color:#141414;margin-left:6px">SISA {lim-used}</span>' if warn else f'<span class="mono mute" style="font-size:10px;margin-left:6px">SISA {lim-used}</span>'
        return (f'<div style="padding:6px 10px 7px;border-bottom:1px solid #CFC6B2">'
                f'<div style="display:flex;align-items:baseline;margin-bottom:5px"><span class="sb" style="font-size:13.5px;flex:1">{name}</span>'
                f'<span class="mono" style="font-size:11.5px;font-weight:700">{used}<span class="mute" style="font-weight:500"> / {lim} MNT</span></span>{tag}</div>'
                f'<div class="bar"><i style="width:{pct:.0f}%;background:{col}"></i></div></div>')

    return f"""
<div style="display:flex;justify-content:space-between;align-items:flex-end;margin:2px 0 10px">
  <div><div class="lbl">Selamat pagi · minggu ke-45</div>
  <div class="anton" style="font-size:36px;margin-top:6px">MINGGU, 8 NOV <span style="color:#77736A">2026</span></div></div>
</div>
<div class="card"><div class="hd"><span>Tugas hari ini</span><span class="r">1/4 · semua &rarr;</span></div>{''.join(rows)}</div>
<div class="card"><div class="hd"><span>Fokus</span><span class="r">pemakaian hari ini</span></div>
  {focus_row("TikTok", 23, 30)}{focus_row("Instagram", 41, 45, True)}<div style="margin-bottom:-1px">{focus_row("YouTube", 10, 60)}</div></div>
<div class="card" style="display:flex">
  <div style="flex:1;padding:8px 10px">
    <div class="lbl b" style="display:flex;align-items:center;gap:6px"><i style="width:9px;height:9px;background:#3B5BDB;display:block"></i>Latihan hari ini</div>
    <div class="sb" style="font-size:17px;margin-top:6px">Gym: Push day</div>
    <div class="mute" style="font-size:12.5px;margin-top:1px">5 gerakan · ±55 mnt</div>
    <div style="display:flex;gap:8px;margin-top:7px;align-items:center"><span class="tag">BELUM</span>
      <span class="btn or" style="height:26px;padding:0 10px;font-size:10px">MULAI &rarr;</span></div>
  </div>
  <div style="width:104px;border-left:2px solid #141414;background:#141414;color:#EFE9DC;padding:9px 10px;display:flex;flex-direction:column;justify-content:space-between">
    <div class="lbl" style="color:#C6FF00">Streak</div>
    <div><div class="anton" style="font-size:44px;color:#EFE9DC">12</div><div class="lbl" style="color:#EFE9DC">hari</div></div>
  </div>
</div>
<div class="card"><div class="hd"><span>Minggu ini</span><span class="r">6/7 aktif</span></div>
  <div style="padding:9px 10px 8px">{week_strip()}</div></div>
<div class="card" style="display:flex;align-items:stretch;border-color:#141414">
  <div style="width:6px;background:#FF4F00"></div>
  <div style="display:flex;align-items:center;gap:10px;padding:8px 10px;flex:1">{svg(I_CAM, 20)}
   <div style="flex:1"><div class="sb" style="font-size:13.5px">Foto progres tubuh: Minggu ini</div><div class="mute mono" style="font-size:10px">CHECK-IN KE-13 · TERAKHIR 1 NOV</div></div>
   <span class="mono" style="font-size:10px;font-weight:700;letter-spacing:.12em">FOTO &rarr;</span></div>
</div>"""


def build_hari_ini():
    inner = status_bar() + f'<div class="content">{hari_ini_content()}</div>' + nav("hari")
    return page("hari_ini", f'<div class="stage">{device(inner)}</div>', 462, 916)


# ================================================================ 2. KALENDER
TODAY = dt.date(2026, 11, 8)


def activity_map():
    rnd = random.Random(45)
    data = {}
    d = dt.date(2026, 1, 1)
    while d <= TODAY:
        r = rnd.random()
        if r < 0.66:
            cats = [rnd.choices(["gym", "bike", "run", "walk"], [35, 30, 20, 15])[0]]
            if rnd.random() < 0.16:
                other = rnd.choice([c for c in ["gym", "bike", "run", "walk"] if c != cats[0]])
                cats.append(other)
            data[d] = (cats, rnd.choice([0.4, 0.7, 1.0, 1.0]))
        d += dt.timedelta(days=1)
    # current streak Oct 27 - Nov 7, Oct 26 empty, today empty
    data.pop(dt.date(2026, 10, 26), None)
    data.pop(TODAY, None)
    fixed = {27: ["bike"], 28: ["gym"], 29: ["run"], 30: ["gym", "walk"], 31: ["bike"]}
    for k, v in fixed.items():
        data[dt.date(2026, 10, k)] = (v, [0.7, 1.0, 0.4, 1.0, 1.0][k - 27])
    nov = {2: (["gym"], 1.0), 3: (["gym", "bike"], 1.0), 4: (["run"], 0.7), 5: (["gym"], 0.7),
           6: (["walk"], 0.4), 7: (["bike", "run"], 1.0)}
    for k, v in nov.items():
        data[dt.date(2026, 11, k)] = v
    data[dt.date(2026, 11, 1)] = (["walk"], 0.7)
    return data


def year_heatmap(data):
    start = dt.date(2025, 12, 29)
    cols = []
    months = []
    for w in range(53):
        cells = []
        for k in range(7):
            d = start + dt.timedelta(days=w * 7 + k)
            if d.year != 2026:
                cells.append('<i style="background:transparent"></i>')
            elif d > TODAY:
                cells.append('<i style="background:transparent;outline:1px solid #CFC6B2;outline-offset:-1px"></i>')
            elif d in data:
                cats, a = data[d]
                cells.append(f'<i style="{cell_bg(cats, a)}"></i>')
            elif d == TODAY:
                cells.append('<i style="outline:1.5px solid #FF4F00;outline-offset:-1px"></i>')
            else:
                cells.append('<i style="background:#E3DBC9"></i>')
        cols.append(f'<div class="wk">{"".join(cells)}</div>')
        first = start + dt.timedelta(days=w * 7)
        if any((first + dt.timedelta(days=k)).day == 1 for k in range(7)):
            mdate = [first + dt.timedelta(days=k) for k in range(7) if (first + dt.timedelta(days=k)).day == 1][0]
            if mdate.year == 2026:
                months.append((w, ["JAN", "FEB", "MAR", "APR", "MEI", "JUN", "JUL", "AGU", "SEP", "OKT", "NOV", "DES"][mdate.month - 1]))
    mlabels = "".join(f'<span style="position:absolute;left:{w*6.75:.1f}px">{m}</span>' for w, m in months)
    return (f'<div class="lbl" style="position:relative;height:12px;font-size:7.5px;letter-spacing:.06em">{mlabels}</div>'
            f'<div class="yh">{"".join(cols)}</div>')


def month_grid(data):
    start = dt.date(2026, 10, 26)
    cells = []
    for i in range(42):
        d = start + dt.timedelta(days=i)
        if d.month != 11 and d > dt.date(2026, 11, 30):
            break
        other = d.month != 11
        sel = d == dt.date(2026, 11, 3)
        style, ncol = "background:#E3DBC9", "#77736A"
        if d > TODAY:
            style = "background:transparent;border:1px solid #CFC6B2"
        elif d in data:
            cats, a = data[d]
            style = cell_bg(cats, a)
            ncol = "#141414" if (a < 0.6 and cats[0] != "run") else "#EFE9DC"
        if d == TODAY:
            style = "background:repeating-linear-gradient(45deg,transparent 0 4px,rgba(20,20,20,.12) 4px 5px);border:2px solid #FF4F00"
            ncol = "#141414"
        op = "opacity:.45;" if other else ""
        ring = "box-shadow:0 0 0 2px #EFE9DC,0 0 0 4px #141414;" if sel else ""
        cells.append(f'<div style="height:32px;{style};{op}{ring}position:relative"><span class="mono" style="position:absolute;left:4px;top:2px;font-size:9.5px;font-weight:700;color:{ncol}">{d.day}</span></div>')
    head = "".join(f'<div class="lbl" style="text-align:center;font-size:8.5px">{x}</div>' for x in ["SEN", "SEL", "RAB", "KAM", "JUM", "SAB", "MIN"])
    return (f'<div style="display:grid;grid-template-columns:repeat(7,1fr);gap:4px;margin-bottom:5px">{head}</div>'
            f'<div style="display:grid;grid-template-columns:repeat(7,1fr);gap:4px">{"".join(cells)}</div>')


def chip_dot(k):
    return f'<i style="width:8px;height:8px;background:{C[k]};display:block"></i>' if k else ""


def build_kalender():
    data = activity_map()
    chips = [("SEMUA", None, True), ("SEPEDA", "bike", False), ("LARI", "run", False), ("JALAN", "walk", False), ("GYM", "gym", False)]
    ch = "".join(
        f'<span class="tag" style="font-size:9.5px;padding:5px 8px;display:flex;align-items:center;gap:5px;{"background:#141414;color:#EFE9DC" if on else "background:#EFE9DC"}">'
        f'{chip_dot(k)}{l}</span>'
        for l, k, on in chips)

    def stat(n, l, unit=""):
        return (f'<div style="flex:1;padding:7px 10px;border-right:1.5px solid #141414"><div class="anton" style="font-size:30px">{n}<span style="font-size:15px;margin-left:3px">{unit}</span></div>'
                f'<div class="lbl" style="font-size:8.5px;margin-top:3px">{l}</div></div>')

    detail_rows = [
        ("gym", "Gym · Pull day", "52 mnt · 6 gerakan · 8.420 kg", "07:05"),
        ("bike", "Gravel · Kaliurang", "34,2 km · 1:48 · ↑ 412 m", "15:30"),
        (None, "3 tugas selesai", "Bayar listrik, cuci bidon, +1", ""),
    ]
    dr = ""
    for k, t, sub, tm in detail_rows:
        sw = (f'<i style="width:12px;height:30px;background:{C[k]};display:block;flex:none"></i>' if k
              else f'<div class="cb on" style="width:14px;height:14px">{check(size=10)}</div>')
        dr += (f'<div class="row" style="padding:7px 10px">{sw}<div style="flex:1"><div class="sb" style="font-size:13.5px">{t}</div>'
               f'<div class="mute" style="font-size:11.5px">{sub}</div></div><span class="mono mute" style="font-size:10px">{tm}</span></div>')

    content = f"""
<div style="display:flex;justify-content:space-between;align-items:flex-end;margin:2px 0 10px">
  <div><div class="lbl">Konsistensi · 2026</div><div class="anton" style="font-size:36px;margin-top:5px">KALENDER</div></div>
  <div style="display:flex;border:2px solid #141414" class="mono"><span style="padding:5px 9px;font-size:10px;font-weight:700;letter-spacing:.1em">TAHUN</span><span style="padding:5px 9px;font-size:10px;font-weight:700;letter-spacing:.1em;background:#141414;color:#EFE9DC">BULAN</span></div>
</div>
<div style="display:flex;gap:5px;margin-bottom:10px">{ch}</div>
<div style="display:flex;border:2px solid #141414;margin-bottom:10px">{stat("12", "Streak · hari")}{stat("34", "Terpanjang")}<div style="flex:1;padding:7px 10px"><div class="anton" style="font-size:30px">68<span style="font-size:15px;margin-left:2px">%</span></div><div class="lbl" style="font-size:8.5px;margin-top:3px">Hari aktif</div></div></div>
<div style="margin-bottom:6px">{year_heatmap(data)}</div>
<div style="display:flex;justify-content:space-between;align-items:center;margin:6px 0 10px">{legend_inline(8)}</div>
<div style="display:flex;justify-content:space-between;align-items:center;border-top:2px solid #141414;padding-top:7px;margin-bottom:7px">
  <span>{svg(I_CHEVL, 16)}</span><span class="lbl b" style="font-size:11px">November 2026</span><span>{svg(I_CHEV, 16)}</span></div>
{month_grid(data)}
<div class="card" style="margin-top:12px"><div class="hd"><span>Selasa, 3 Nov</span><span class="r">2 aktivitas</span></div>{dr}</div>
"""
    css = (".yh{display:flex;gap:1.25px}.yh .wk{display:flex;flex-direction:column;gap:1.25px}"
           ".yh i{display:block;width:5.5px;height:5.5px}")
    inner = status_bar() + f'<div class="content">{content}</div>' + nav("kal")
    return page("kalender", f'<div class="stage">{device(inner)}</div>', 462, 916, css)


# ================================================================ 3. GYM SESI
def build_gym():
    def set_row(n, prev, kg, reps, state):
        if state == "done":
            return (f'<div class="sr" style="background:#E3DBC9"><span class="mono sb">{n}</span><span class="mono mute">sblm {prev}</span>'
                    f'<span class="mono sb">{kg}</span><span class="mono sb">{reps}</span><span class="ck" style="background:#2F7D4F;border-color:#141414">{check()}</span></div>')
        if state == "active":
            return (f'<div class="sr" style="background:#EFE9DC;box-shadow:inset 4px 0 0 #FF4F00"><span class="mono sb">{n}</span><span class="mono mute">sblm {prev}</span>'
                    f'<span class="inp" style="border-color:#FF4F00">{kg}</span><span class="inp mute">{reps}</span><span class="ck"></span></div>')
        return (f'<div class="sr"><span class="mono mute">{n}</span><span class="mono mute">sblm {prev}</span>'
                f'<span class="inp mute">{kg}</span><span class="inp mute">{reps}</span><span class="ck"></span></div>')

    head = f'<div class="sr sh"><span>SET</span><span>SEBELUMNYA</span><span>KG</span><span>REPS</span><span style="justify-self:center">{svg(I_CHECK, 11, "#3A3A36", 3)}</span></div>'
    ex1 = (f'<div class="card"><div style="display:flex;justify-content:space-between;align-items:flex-start;padding:8px 10px 6px">'
           f'<div><div class="sb" style="font-size:16px">Bench Press</div><div class="lbl" style="font-size:9px;margin-top:2px">Dada · barbel · PR 65 kg</div></div>'
           f'<span class="tag" style="background:#141414;color:#EFE9DC">3/4 SET</span></div>{head}'
           + set_row(1, "60×8", "60", "8", "done") + set_row(2, "60×8", "62,5", "8", "done")
           + set_row(3, "60×7", "62,5", "7", "done") + set_row(4, "60×6", "62,5", "6", "active") + '</div>')
    ex2 = (f'<div class="card"><div style="display:flex;justify-content:space-between;align-items:flex-start;padding:8px 10px 6px">'
           f'<div><div class="sb" style="font-size:16px">Overhead Press</div><div class="lbl" style="font-size:9px;margin-top:2px">Bahu · barbel</div></div>'
           f'<span class="tag">0/3 SET</span></div>{head}'
           + set_row(1, "35×8", "35", "8", "todo") + set_row(2, "35×8", "35", "8", "todo") + '</div>')
    rest = [("Incline Dumbbell Press", "Dada · 3 set"), ("Lateral Raise", "Bahu · 3 set"), ("Triceps Pushdown", "Lengan · 3 set")]
    ex3 = '<div class="card">' + "".join(
        f'<div class="row" style="padding:6px 10px"><span class="mono mute" style="font-size:11px;width:16px">{i+3}</span><span class="sb" style="flex:1;font-size:14px">{n}</span><span class="lbl" style="font-size:9px">{s}</span>{svg(I_CHEV, 14)}</div>'
        for i, (n, s) in enumerate(rest)) + '</div>'

    content = f"""
<div style="display:flex;justify-content:space-between;align-items:center;margin:2px 0 8px">
  <span style="display:flex;gap:8px;align-items:center">{svg(I_BACK, 18)}<span class="lbl b">Sesi gym</span>
  <span class="tag" style="display:flex;gap:5px;align-items:center;border-color:#FF4F00;color:#FF4F00"><i style="width:6px;height:6px;border-radius:50%;background:#FF4F00;display:block"></i>BERJALAN</span></span>
  {svg(I_MORE, 20)}</div>
<div style="display:flex;align-items:stretch;border:2px solid #141414;margin-bottom:10px">
  <div style="flex:1;padding:8px 10px"><div class="anton" style="font-size:36px">PUSH DAY</div>
    <div class="lbl" style="margin-top:5px;font-size:9px">Min, 8 Nov · 5 gerakan</div></div>
  <div style="background:#141414;color:#EFE9DC;padding:8px 12px;display:flex;flex-direction:column;justify-content:space-between;align-items:flex-end">
    <div class="lbl" style="color:#C6FF00;font-size:9px">Durasi</div><div class="anton" style="font-size:32px">00:42:10</div></div>
</div>
<div style="display:flex;gap:0;border:2px solid #141414;margin-bottom:10px" class="mono">
  <div style="flex:1;padding:5px 10px;border-right:1.5px solid #141414"><div class="lbl" style="font-size:8.5px">Volume</div><div class="sb" style="font-size:14px">1.427 kg</div></div>
  <div style="flex:1;padding:5px 10px;border-right:1.5px solid #141414"><div class="lbl" style="font-size:8.5px">Set</div><div class="sb" style="font-size:14px">3 / 16</div></div>
  <div style="flex:1;padding:5px 10px"><div class="lbl" style="font-size:8.5px">Gerakan</div><div class="sb" style="font-size:14px">1 / 5</div></div>
</div>
{ex1}{ex2}{ex3}
"""
    bottom = f"""
<div style="position:absolute;left:0;right:0;bottom:0;background:#EFE9DC;border-top:2px solid #141414;z-index:6">
  <div style="background:#141414;color:#EFE9DC;padding:9px 16px 10px">
    <div style="display:flex;align-items:center;gap:12px">
      <div style="flex:1"><div class="lbl" style="color:#C6FF00;font-size:9.5px">Istirahat · set 4 berikutnya</div>
        <div style="height:8px;background:#3A3A36;margin-top:7px;position:relative"><i style="position:absolute;left:0;top:0;bottom:0;width:62%;background:#C6FF00"></i></div></div>
      <div class="anton" style="font-size:34px;color:#EFE9DC">01:30</div>
    </div>
    <div style="display:flex;gap:6px;margin-top:8px" class="mono">
      <span class="btn" style="flex:1;height:26px;border-color:#EFE9DC;color:#EFE9DC;font-size:10px">−15 D</span>
      <span class="btn" style="flex:1;height:26px;border-color:#EFE9DC;color:#EFE9DC;font-size:10px">+15 D</span>
      <span class="btn" style="flex:1;height:26px;border-color:#C6FF00;color:#C6FF00;font-size:10px">LEWATI</span></div>
  </div>
  <div style="display:flex;gap:8px;padding:10px 16px 6px">
    <span class="btn" style="flex:1;height:46px;background:#EFE9DC">{svg(I_PLUS, 14, "#141414", 3)} GERAKAN</span>
    <span class="btn or" style="flex:1.3;height:46px">SELESAI LATIHAN</span></div>
  <div class="gest" style="height:18px;display:flex;align-items:center;justify-content:center"><i></i></div>
</div>"""
    css = (".sr{display:grid;grid-template-columns:34px 1fr 62px 52px 30px;gap:8px;align-items:center;padding:4px 10px;border-top:1px solid #CFC6B2;font-size:13px}"
           ".sr.sh{font-family:Mono;font-size:8.5px;font-weight:700;letter-spacing:.12em;color:#3A3A36;padding:4px 10px;border-top:1.5px solid #141414}"
           ".sr .mono.mute{font-size:11px}"
           ".inp{border:1.5px solid #141414;background:#EFE9DC;height:24px;display:flex;align-items:center;justify-content:center;font-family:Mono;font-weight:700;font-size:12.5px}"
           ".ck{width:22px;height:22px;border:2px solid #141414;display:flex;align-items:center;justify-content:center;justify-self:center}")
    inner = status_bar() + f'<div class="content full" style="padding-bottom:0">{content}</div>' + bottom
    return page("gym_sesi", f'<div class="stage">{device(inner)}</div>', 462, 916, css)


# ================================================================ 4. TUGAS
def task_row(title, meta="", pin=False, done=False, date=""):
    cb = f'<div class="cb on">{check()}</div>' if done else '<div class="cb"></div>'
    right = ""
    if date:
        right += f'<span class="mono" style="font-size:10px;font-weight:700;letter-spacing:.06em">{date}</span>'
    if meta:
        right += f'<span class="mono" style="font-size:10px;font-weight:500;color:#3A3A36;display:flex;gap:4px;align-items:center">{svg(I_CLOCK, 12, "#3A3A36", 2)}{meta}</span>'
    if pin:
        right += svg(I_PIN, 15, "#FF4F00", 2)
    return (f'<div class="row" style="padding:9px 10px">{cb}<span style="flex:1;font-size:14px" class="{"done" if done else ""}">{title}</span>'
            f'<span style="display:flex;gap:8px;align-items:center">{right}</span></div>')


def build_tugas():
    sec = lambda t, r: f'<div class="lbl b" style="display:flex;justify-content:space-between;margin:12px 0 5px"><span>{t}</span><span class="mute" style="font-weight:500">{r}</span></div>'
    content = f"""
<div style="display:flex;gap:8px;align-items:center;margin:2px 0 6px">{svg(I_BACK, 18)}<span class="lbl b">Hari ini</span></div>
<div style="display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:10px">
  <div class="anton" style="font-size:40px">TUGAS</div><div class="lbl" style="margin-bottom:4px">7 aktif · 3 berpin</div></div>
<div style="display:flex;border:2px solid #141414;background:#EFE9DC;height:48px">
  <div style="flex:1;display:flex;align-items:center;padding:0 12px;font-size:15px;color:#77736A">Tulis tugas…<i style="width:2px;height:20px;background:#FF4F00;display:block;margin-left:2px"></i></div>
  <div style="display:flex;align-items:center;gap:4px;padding:0 9px;border-left:1.5px solid #CFC6B2" class="mono"><span style="font-size:10px;font-weight:700;letter-spacing:.08em">HARI INI</span>{svg('<path d="M6 9l6 6 6-6"/>', 12)}</div>
  <div style="width:46px;background:#FF4F00;border-left:2px solid #141414;display:flex;align-items:center;justify-content:center">{svg(I_PLUS, 22, "#141414", 3)}</div>
</div>
{sec("Hari ini", "3")}
<div class="card" style="margin:0">{task_row("Servis rantai sepeda", pin=True)}{task_row("Kirim laporan mingguan", meta="16:00")}{task_row("Beli protein bar", pin=True)}</div>
{sec("Nanti", "4")}
<div class="card" style="margin:0">{task_row("Perpanjang SIM", date="SEL 10 NOV")}{task_row("Ganti ban belakang gravel", pin=True, date="JUM 13 NOV")}{task_row("Booking lapangan futsal", date="SAB 14 NOV")}{task_row("Cek tekanan ban", date="")}</div>
{sec("Selesai", "hari ini 2")}
<div class="card" style="margin:0">{task_row("Bayar listrik", done=True)}{task_row("Cuci bidon", done=True)}</div>
<div class="mono mute" style="font-size:10px;margin-top:10px;display:flex;gap:6px;align-items:center">{svg(I_PIN, 12, "#FF4F00", 2)}Berpin = tampil di widget layar utama</div>
"""
    phone = device(status_bar() + f'<div class="content">{content}</div>' + nav("hari"))

    v_icon = '<span style="width:20px;height:20px;border-radius:50%;background:#FF4F00;display:inline-flex;align-items:center;justify-content:center;font-family:Anton;font-size:12px;color:#141414">V</span>'

    def tile(label, sub, on=False, icon=""):
        bg = "#FF4F00" if on else "#2E2E2B"
        fg = "#141414" if on else "#EFE9DC"
        return (f'<div style="background:{bg};color:{fg};border-radius:18px;padding:10px 12px;display:flex;gap:9px;align-items:center;height:56px">'
                f'{icon}<div><div style="font-size:12.5px;font-weight:600">{label}</div><div style="font-size:10.5px;opacity:.75">{sub}</div></div></div>')

    notif_base = f"""<div style="display:flex;align-items:center;gap:7px;font-size:11px;color:#3A3A36">{v_icon}<span>Virya</span><span>·</span><span>sekarang</span>
      <span style="margin-left:auto">{svg('<path d="M6 15l6-6 6 6"/>', 14, "#3A3A36")}</span></div>
     <div style="font-weight:600;font-size:14px;margin-top:7px">Catat cepat Virya</div>
     <div style="font-size:12.5px;color:#3A3A36;margin-top:1px">Ketuk Balas untuk menambah tugas tanpa membuka aplikasi.</div>"""
    inset = f"""
<div style="width:340px;flex:none;padding-top:8px">
  <div class="lbl b" style="font-size:11px">Catat dari luar aplikasi</div>
  <div style="font-size:12.5px;color:#3A3A36;margin:5px 0 12px;line-height:1.4">Notifikasi permanen dengan kolom balas, plus ubin Quick Settings. Tugas masuk ke bagian <b>Hari ini</b>.</div>
  <div style="background:#1B1B19;border-radius:26px;padding:16px 12px 14px;box-shadow:0 14px 30px rgba(20,20,20,.25)">
    <div style="display:flex;justify-content:space-between;color:#EFE9DC;font-size:12px;padding:0 6px 10px"><span style="font-weight:600">09:41</span><span>Min, 8 Nov</span></div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px">
      {tile("Wi-Fi", "Rumah", False, svg('<path d="M2 9a15 15 0 0 1 20 0M5.5 12.5a10 10 0 0 1 13 0M9 16a5 5 0 0 1 6 0"/><circle cx="12" cy="19" r="1" fill="currentColor"/>', 18))}
      {tile("Senter", "Mati", False, svg('<path d="M8 3h8v5l-2 3v10h-4V11L8 8z"/>', 18))}
      {tile("Catat tugas", "Virya", True, svg(I_TASK, 18, "#141414"))}
      {tile("Jangan ganggu", "Mati", False, svg('<circle cx="12" cy="12" r="9"/><path d="M7 12h10"/>', 18))}
    </div>
    <div class="mono" style="color:#C6FF00;font-size:9px;letter-spacing:.14em;margin:8px 6px 10px">&uarr; UBIN QUICK SETTINGS</div>
    <div style="background:#F4F0E7;border-radius:18px;padding:12px 14px;color:#141414">{notif_base}
      <div style="display:flex;gap:18px;margin-top:10px;font-size:12.5px;font-weight:600;color:#C23C00"><span>Balas</span><span>Buka tugas</span></div></div>
    <div class="mono" style="color:#EFE9DC;opacity:.7;font-size:9px;letter-spacing:.14em;margin:12px 6px 8px">SETELAH KETUK "BALAS"</div>
    <div style="background:#F4F0E7;border-radius:18px;padding:12px 14px;color:#141414">{notif_base}
      <div style="display:flex;align-items:center;gap:8px;margin-top:10px;background:#E3DBC9;border-radius:22px;padding:6px 6px 6px 14px">
        <span style="flex:1;font-size:13.5px">Ganti oli motor<i style="display:inline-block;width:2px;height:15px;background:#FF4F00;vertical-align:-2px;margin-left:1px"></i></span>
        <span style="width:32px;height:32px;border-radius:50%;background:#FF4F00;display:flex;align-items:center;justify-content:center">{svg(I_SEND, 16, "#141414", 2)}</span></div>
      <div style="font-size:10.5px;color:#77736A;margin-top:6px;padding-left:4px">Masuk ke: Hari ini · Enter untuk simpan</div></div>
  </div>
</div>"""
    return page("tugas", f'<div class="stage">{phone}{inset}</div>', 846, 916)


# ================================================================ 5. WIDGET HOME
def build_widget():
    def app(label, bg, glyph):
        return (f'<div style="display:flex;flex-direction:column;align-items:center;gap:6px;width:72px">'
                f'<div style="width:54px;height:54px;border-radius:50%;background:{bg};display:flex;align-items:center;justify-content:center">{glyph}</div>'
                f'<span style="font-size:11.5px;color:#fff;text-shadow:0 1px 2px rgba(0,0,0,.4)">{label}</span></div>')
    g = lambda body: svg(body, 24, "#2A2A27", 2)
    virya = '<span style="font-family:Anton;font-size:26px;color:#141414">V</span>'
    apps1 = [("Kalender", "#E9E4D8", g('<rect x="3" y="5" width="18" height="16"/><path d="M3 10h18M8 3v4M16 3v4"/>')),
             ("Kamera", "#E9E4D8", g(I_CAM)), ("Galeri", "#E9E4D8", g('<rect x="3" y="4" width="18" height="16"/><path d="M3 17l5-5 4 4 3-3 6 6"/>')),
             ("Peta", "#E9E4D8", g('<path d="M3 6l6-2 6 2 6-2v14l-6 2-6-2-6 2z"/><path d="M9 4v14M15 6v14"/>'))]
    apps2 = [("Jam", "#E9E4D8", g(I_CLOCK)), ("Musik", "#E9E4D8", g('<path d="M9 18V5l11-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="17" cy="16" r="3"/>')),
             ("Pengaturan", "#E9E4D8", g('<circle cx="12" cy="12" r="3.5"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M5 5l2 2M17 17l2 2M5 19l2-2M17 7l2-2"/>')),
             ("Virya", "#FF4F00", virya)]
    dock = [("", "#E9E4D8", g('<path d="M5 3h4l2 5-3 2a11 11 0 0 0 6 6l2-3 5 2v4a2 2 0 0 1-2 2A17 17 0 0 1 3 5a2 2 0 0 1 2-2z"/>')),
            ("", "#E9E4D8", g('<path d="M3 5h18v12H8l-5 4z"/>')),
            ("", "#E9E4D8", g('<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>')),
            ("", "#E9E4D8", g(I_USER))]

    wtask = lambda t, done=False: (f'<div style="display:flex;align-items:center;gap:9px;padding:6px 12px;border-bottom:1px solid #CFC6B2">'
                                   f'{f"<div class=cb style=background:#141414>{check()}</div>" if done else "<div class=cb></div>"}'
                                   f'<span style="font-size:13.5px;flex:1" class="{"done" if done else ""}">{t}</span>{svg(I_PIN, 12, "#FF4F00", 2)}</div>')
    widget = f"""
<div style="background:#EFE9DC;border:2px solid #141414;margin:0 16px;box-shadow:0 10px 24px rgba(0,0,0,.25)">
  <div style="display:flex;align-items:center;gap:8px;padding:0 0 0 12px;border-bottom:2px solid #141414;height:38px">
    <span class="anton" style="font-size:18px">VIRYA</span><span class="lbl" style="font-size:9px;flex:1">· Tugas berpin</span>
    <span class="mono" style="font-size:10px;font-weight:700;margin-right:10px">1/3</span>
    <div style="width:44px;height:36px;background:#FF4F00;border-left:2px solid #141414;display:flex;align-items:center;justify-content:center">{svg(I_PLUS, 20, "#141414", 3)}</div>
  </div>
  {wtask("Servis rantai sepeda")}{wtask("Beli protein bar")}<div style="margin-bottom:-1px">{wtask("Bayar listrik", True)}</div>
  <div style="background:#141414;color:#EFE9DC;display:flex;align-items:center;gap:10px;padding:7px 12px" class="mono">
    <span style="color:#C6FF00;font-size:9.5px;font-weight:700;letter-spacing:.14em">FOKUS · SISA</span>
    <span style="font-size:11px;font-weight:500;flex:1;text-align:right">TIKTOK <b>7</b> · IG <b style="color:#E8B23A">4</b> · YT <b>50</b> MNT</span></div>
</div>"""
    wall = ("background:radial-gradient(120% 70% at 20% 10%,#A39E93 0%,#7D796F 45%,#55524C 100%);")
    content = f"""
<div style="position:absolute;inset:0;{wall}"></div>
<svg style="position:absolute;inset:0;opacity:.18" width="390" height="844" viewBox="0 0 390 844" fill="none" stroke="#fff" stroke-width="1">
 <path d="M-10 520 C 80 470 160 560 250 510 S 380 470 400 500"/><path d="M-10 545 C 80 497 160 585 250 537 S 380 497 400 527"/>
 <path d="M-10 570 C 80 524 160 610 250 564 S 380 524 400 554"/><path d="M-10 595 C 80 551 160 635 250 591 S 380 551 400 581"/></svg>
<div style="position:relative;z-index:2">
 {status_bar(dark=True)}
 <div style="padding:24px 22px 26px;color:#fff">
   <div style="font-family:Sans;font-size:64px;font-weight:400;line-height:1;letter-spacing:-.02em">09:41</div>
   <div style="font-size:14px;margin-top:6px;opacity:.9">Minggu, 8 November · 24°C</div></div>
 {widget}
 <div class="mono" style="font-size:9px;color:#fff;opacity:.8;letter-spacing:.14em;margin:7px 16px 0;text-align:right">WIDGET 4×2</div>
 <div style="display:flex;justify-content:space-around;padding:0 12px;margin-top:150px">{"".join(app(*a) for a in apps1)}</div>
 <div style="display:flex;justify-content:space-around;padding:0 12px;margin-top:18px">{"".join(app(*a) for a in apps2)}</div>
</div>
<div style="position:absolute;left:0;right:0;bottom:30px;z-index:2;padding:0 12px">
 <div style="display:flex;justify-content:space-around;margin-bottom:14px">{"".join(app(*a) for a in dock)}</div>
 <div style="margin:0 10px;height:46px;border-radius:23px;background:rgba(239,233,220,.92);display:flex;align-items:center;padding:0 16px;gap:10px;color:#3A3A36">{svg(I_SEARCH, 18, "#3A3A36")}<span style="font-size:14px">Cari</span></div>
</div>
<div class="gestfree"><i style="width:120px;height:4px;border-radius:2px;background:#fff;display:block"></i></div>
"""
    return page("widget_home", f'<div class="stage">{device(content)}</div>', 462, 916)


# ================================================================ 6. FOKUS
def toggle(on):
    if on:
        return '<span style="width:40px;height:22px;border:2px solid #141414;background:#141414;position:relative;display:block;flex:none"><i style="position:absolute;right:2px;top:2px;width:14px;height:14px;background:#FF4F00;display:block"></i></span>'
    return '<span style="width:40px;height:22px;border:2px solid #141414;background:#E3DBC9;position:relative;display:block;flex:none"><i style="position:absolute;left:2px;top:2px;width:14px;height:14px;background:#77736A;display:block"></i></span>'


def build_fokus():
    def app_row(name, letter, used, lim, on=True, warn=False):
        pct = min(used / lim * 100, 100)
        col = C["cau"] if warn else C["ink"]
        sisa = (f'<span class="tag" style="background:{C["cau"]}">SISA {lim-used} MNT</span>' if warn
                else f'<span class="mono mute" style="font-size:10px">SISA {lim-used} MNT</span>')
        if not on:
            sisa = '<span class="mono mute" style="font-size:10px">NONAKTIF</span>'
        op = "" if on else "opacity:.5;"
        return f"""<div style="padding:9px 10px;border-bottom:1px solid #CFC6B2">
 <div style="display:flex;align-items:center;gap:10px">
  <div style="width:36px;height:36px;background:#141414;color:#EFE9DC;display:flex;align-items:center;justify-content:center;font-family:Anton;font-size:18px;{op}">{letter}</div>
  <div style="flex:1;{op}"><div class="sb" style="font-size:15px">{name}</div><div class="mono mute" style="font-size:10.5px">BATAS {lim} MNT / HARI</div></div>
  {toggle(on)}</div>
 <div style="display:flex;align-items:center;gap:8px;margin-top:8px;{op}"><div class="bar" style="flex:1"><i style="width:{pct:.0f}%;background:{col if on else '#77736A'}"></i></div>
  <span class="mono" style="font-size:11px;font-weight:700;width:44px;text-align:right">{used}/{lim}</span><span style="width:92px;text-align:right">{sisa}</span></div></div>"""

    spark = [52, 70, 38, 61, 80, 44, 74]
    days = ["S", "S", "R", "K", "J", "S", "M"]
    sp = "".join(f'<div style="display:flex;flex-direction:column;align-items:center;gap:3px"><i style="width:12px;height:{v*0.42:.0f}px;background:{"#FF4F00" if i==6 else "#EFE9DC"};display:block"></i><span class="mono" style="font-size:8px;color:#EFE9DC;opacity:.7">{days[i]}</span></div>' for i, v in enumerate(spark))
    content = f"""
<div style="display:flex;gap:8px;align-items:center;margin:2px 0 6px">{svg(I_BACK, 18)}<span class="lbl b">Hari ini</span></div>
<div style="display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:10px">
  <div class="anton" style="font-size:40px">FOKUS</div><div class="lbl" style="margin-bottom:4px">Batas waktu aplikasi</div></div>
<div style="background:#141414;color:#EFE9DC;border:2px solid #141414;display:flex;align-items:flex-end;justify-content:space-between;padding:10px 12px;margin-bottom:10px">
  <div><div class="lbl" style="color:#C6FF00">Total hari ini</div><div class="anton" style="font-size:38px;margin-top:6px">1 J 14 MNT</div>
  <div class="mono" style="font-size:10px;opacity:.75;margin-top:4px">−18 MNT DARI RATA-RATA</div></div>
  <div style="display:flex;gap:5px;align-items:flex-end">{sp}</div></div>
<div class="card" style="margin-bottom:10px">
  <div class="hd"><span>Aplikasi dibatasi</span><span class="r">3 aktif</span></div>
  {app_row("TikTok", "T", 23, 30)}{app_row("Instagram", "I", 41, 45, warn=True)}{app_row("YouTube", "Y", 10, 60)}
  <div style="margin-bottom:-1px">{app_row("Reddit", "R", 0, 20, on=False)}</div>
</div>
<div class="btn" style="height:40px;margin-bottom:10px;background:#EFE9DC">{svg(I_PLUS, 14, "#141414", 3)} TAMBAH APLIKASI</div>
<div class="mono" style="font-size:10px;line-height:1.7;color:#3A3A36">
 <div style="display:flex;justify-content:space-between"><span>AKSES PEMAKAIAN</span><span style="color:#2F7D4F;font-weight:700;display:flex;gap:4px;align-items:center">{svg(I_CHECK, 11, "#2F7D4F", 3)}AKTIF</span></div>
 <div style="display:flex;justify-content:space-between"><span>LAYANAN AKSESIBILITAS</span><span style="color:#2F7D4F;font-weight:700;display:flex;gap:4px;align-items:center">{svg(I_CHECK, 11, "#2F7D4F", 3)}AKTIF</span></div>
</div>"""
    phone1 = device(status_bar() + f'<div class="content">{content}</div>' + nav("hari"))

    block = f"""{status_bar(dark=True)}
<div style="position:absolute;inset:34px 0 0 0;padding:28px 24px;display:flex;flex-direction:column">
  <div style="display:flex;align-items:center;gap:10px">
    <div style="width:44px;height:44px;background:#EFE9DC;color:#141414;display:flex;align-items:center;justify-content:center;font-family:Anton;font-size:22px">I</div>
    <div><div style="font-size:15px;font-weight:600;color:#EFE9DC">Instagram</div><div class="mono" style="font-size:10px;color:#EFE9DC;opacity:.7;letter-spacing:.1em">DITUTUP OLEH VIRYA</div></div></div>
  <div style="margin-top:110px"><div class="lbl" style="color:#C6FF00;font-size:11px">Batas tercapai</div>
   <div class="anton" style="font-size:96px;color:#EFE9DC;margin-top:12px;line-height:.92">WAKTU<br>HABIS</div>
   <div style="font-size:16px;color:#EFE9DC;margin-top:18px;line-height:1.45">Kamu sudah memakai Instagram <b>45 dari 45 menit</b> hari ini.</div>
   <div class="mono" style="font-size:11px;color:#EFE9DC;opacity:.7;margin-top:10px;letter-spacing:.06em">KUOTA TERISI LAGI BESOK 00:00</div></div>
  <div style="display:flex;border:1.5px solid #3A3A36;margin-top:26px">
   <div style="flex:1;padding:8px 12px;border-right:1.5px solid #3A3A36"><div class="lbl" style="color:#EFE9DC;opacity:.7;font-size:9px">Hari ini</div><div class="anton" style="font-size:26px;color:#EFE9DC;margin-top:4px">45 MNT</div></div>
   <div style="flex:1;padding:8px 12px"><div class="lbl" style="color:#EFE9DC;opacity:.7;font-size:9px">Minggu ini</div><div class="anton" style="font-size:26px;color:#EFE9DC;margin-top:4px">4 J 12 M</div></div></div>
  <div style="margin-top:auto;margin-bottom:22px">
   <div class="btn" style="height:54px;background:#EFE9DC;color:#141414;border-color:#EFE9DC;font-size:13px">TUTUP</div>
   <div class="btn" style="height:48px;margin-top:10px;border-color:#C6FF00;color:#C6FF00;font-size:12px">+5 MENIT (SEKALI)</div>
   <div class="mono" style="font-size:9.5px;color:#EFE9DC;opacity:.6;text-align:center;margin-top:8px;letter-spacing:.1em">SISA KESEMPATAN: 1 DARI 1</div></div>
</div>
<div class="gestfree"><i style="width:120px;height:4px;border-radius:2px;background:#EFE9DC;display:block"></i></div>"""
    phone2 = device(block, dark=True)
    small = f"""<div style="width:{414*0.72:.0f}px;flex:none;padding-top:20px">
  <div class="lbl b" style="font-size:11px">Saat kuota habis</div>
  <div style="font-size:12.5px;color:#3A3A36;margin:5px 0 14px;line-height:1.4">Aplikasi ditutup, layar ini tampil. +5 menit hanya sekali per aplikasi per hari.</div>
  <div style="width:{414*0.72:.0f}px;height:{868*0.72:.0f}px"><div style="transform:scale(.72);transform-origin:0 0">{phone2}</div></div></div>"""
    return page("fokus", f'<div class="stage">{phone1}{small}</div>', 806, 916)


# ================================================================ 7. TUBUH
def figure(w=1.0, fill="#9A958B", stroke="none", size=(100, 200)):
    # abstract neutral figure; w scales torso/waist width
    cx = 50
    sh = 30 * w if w < 1 else 30
    wa = 18 * w
    hip = 21 * w
    body = (f'<circle cx="{cx}" cy="22" r="13"/>'
            f'<rect x="{cx-5}" y="33" width="10" height="8"/>'
            f'<path d="M{cx-sh} 44 L{cx+sh} 44 L{cx+wa+2} 95 L{cx+hip} 112 L{cx-hip} 112 L{cx-wa-2} 95 Z"/>'
            f'<path d="M{cx-sh} 46 L{cx-sh-9} 50 L{cx-sh-11} 112 L{cx-sh-3} 112 L{cx-sh+1} 62 Z"/>'
            f'<path d="M{cx+sh} 46 L{cx+sh+9} 50 L{cx+sh+11} 112 L{cx+sh+3} 112 L{cx+sh-1} 62 Z"/>'
            f'<path d="M{cx-hip} 112 L{cx-1.5} 112 L{cx-4} 196 L{cx-hip+3} 196 Z"/>'
            f'<path d="M{cx+hip} 112 L{cx+1.5} 112 L{cx+4} 196 L{cx+hip-3} 196 Z"/>')
    return f'<svg viewBox="0 0 100 200" width="{size[0]}" height="{size[1]}" fill="{fill}" stroke="{stroke}">{body}</svg>'


def build_tubuh():
    seg = "".join(f'<span style="flex:1;text-align:center;padding:6px 0;font-size:10px;font-weight:700;letter-spacing:.12em;{"background:#141414;color:#EFE9DC" if i==0 else ""};{"border-left:1.5px solid #141414" if i else ""}">{t}</span>'
                  for i, t in enumerate(["DEPAN", "SAMPING", "BELAKANG"]))
    grid_lines = "".join(f'<i style="position:absolute;left:0;right:0;top:{y}%;height:1px;background:rgba(20,20,20,.08)"></i>' for y in (25, 50, 75))
    compare = f"""
<div style="position:relative;height:224px;border:2px solid #141414;overflow:hidden;margin-bottom:10px;background:#D9D0BC">
  <div style="position:absolute;inset:0;background:#E3DBC9;display:flex;justify-content:center;align-items:flex-end">{grid_lines}{figure(1.18, "#8F897D", size=(118, 212))}</div>
  <div style="position:absolute;top:0;bottom:0;left:50%;right:0;overflow:hidden;background:#D3C9B3">
    <div style="position:absolute;top:0;bottom:0;left:-177px;width:354px;display:flex;justify-content:center;align-items:flex-end">{grid_lines}{figure(0.98, "#6F6A60", size=(118, 212))}</div></div>
  <div style="position:absolute;top:0;bottom:0;left:50%;width:2px;margin-left:-1px;background:#141414"></div>
  <div style="position:absolute;top:50%;left:50%;width:32px;height:32px;margin:-16px 0 0 -16px;background:#141414;display:flex;align-items:center;justify-content:center;gap:2px">{svg(I_CHEVL, 12, "#EFE9DC", 2.5)}{svg(I_CHEV, 12, "#EFE9DC", 2.5)}</div>
  <div class="mono" style="position:absolute;left:0;top:0;background:#EFE9DC;border-right:1.5px solid #141414;border-bottom:1.5px solid #141414;padding:4px 7px;font-size:9.5px;font-weight:700;letter-spacing:.1em">SEBELUM · 12 JUL</div>
  <div class="mono" style="position:absolute;right:0;top:0;background:#141414;color:#EFE9DC;padding:5px 8px;font-size:9.5px;font-weight:700;letter-spacing:.1em">SESUDAH · 8 NOV</div>
  <div class="mono" style="position:absolute;left:8px;bottom:6px;font-size:10px;font-weight:700">78,4 KG</div>
  <div class="mono" style="position:absolute;right:8px;bottom:6px;font-size:10px;font-weight:700">72,1 KG</div>
</div>"""
    # weight chart
    vals = [78.4, 78.1, 77.6, 77.9, 77.2, 76.8, 76.5, 76.6, 75.9, 75.4, 75.1, 74.6, 74.2, 73.8, 73.1, 72.6, 72.1]
    W, H, pl, pr, pt, pb = 326, 96, 26, 10, 8, 16
    ymin, ymax = 71.5, 79
    def xy(i, v):
        x = pl + i * (W - pl - pr) / (len(vals) - 1)
        y = pt + (ymax - v) / (ymax - ymin) * (H - pt - pb)
        return x, y
    pts = " ".join(f"{xy(i, v)[0]:.1f},{xy(i, v)[1]:.1f}" for i, v in enumerate(vals))
    grid = ""
    for v in (72, 75, 78):
        y = xy(0, v)[1]
        grid += f'<line x1="{pl}" x2="{W-pr}" y1="{y:.1f}" y2="{y:.1f}" stroke="#CFC6B2" stroke-width="1"/><text x="{pl-5}" y="{y+3:.1f}" text-anchor="end" font-family="Mono" font-size="8.5" fill="#77736A">{v}</text>'
    marks = "".join(f'<rect x="{xy(i, v)[0]-2:.1f}" y="{xy(i, v)[1]-2:.1f}" width="4" height="4" fill="#141414"/>' for i, v in enumerate(vals[:-1]))
    lx, ly = xy(len(vals) - 1, vals[-1])
    months = "".join(f'<text x="{pl + k*(W-pl-pr)/4:.1f}" y="{H-3}" text-anchor="middle" font-family="Mono" font-size="8.5" fill="#77736A">{m}</text>' for k, m in enumerate(["JUL", "AGU", "SEP", "OKT", "NOV"]))
    chart = (f'<svg width="{W}" height="{H}" viewBox="0 0 {W} {H}">{grid}{months}<polyline points="{pts}" fill="none" stroke="#141414" stroke-width="2"/>'
             f'{marks}<rect x="{lx-4:.1f}" y="{ly-4:.1f}" width="8" height="8" fill="#FF4F00" stroke="#141414" stroke-width="1.5"/>'
             f'<rect x="{lx-40:.1f}" y="{ly-30:.1f}" width="32" height="15" fill="#141414"/><text x="{lx-24:.1f}" y="{ly-19:.1f}" text-anchor="middle" font-family="Mono" font-weight="700" font-size="10" fill="#EFE9DC">72,1</text></svg>')
    thumbs = [("12 JUL", 1.18), ("9 AGU", 1.12), ("6 SEP", 1.07), ("4 OKT", 1.02), ("1 NOV", 0.98)]
    th = "".join(f'<div style="flex:1"><div style="height:74px;border:1.5px solid #141414;background:{"#D3C9B3" if i==4 else "#E3DBC9"};display:flex;justify-content:center;align-items:flex-end;overflow:hidden">{figure(w, "#8F897D" if i<4 else "#6F6A60", size=(40, 70))}</div>'
                 f'<div class="mono" style="font-size:9px;font-weight:700;margin-top:4px;letter-spacing:.06em">{d}</div></div>'
                 for i, (d, w) in enumerate(thumbs))
    content = f"""
<div style="display:flex;gap:8px;align-items:center;margin:2px 0 6px">{svg(I_BACK, 18)}<span class="lbl b">Profil</span></div>
<div style="display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:9px">
  <div class="anton" style="font-size:36px">PROGRES TUBUH</div><div class="lbl" style="margin-bottom:3px;text-align:right">13 check-in</div></div>
<div class="mono" style="display:flex;border:2px solid #141414;margin-bottom:9px">{seg}</div>
{compare}
<div class="card" style="margin-bottom:10px"><div class="hd"><span>Berat · kg</span><span class="r"><b style="color:#2F7D4F">−6,3 KG</b> · 17 minggu</span></div>
 <div style="padding:6px 6px 2px">{chart}</div></div>
<div class="lbl b" style="display:flex;justify-content:space-between;margin-bottom:6px"><span>Check-in</span><span class="mute" style="font-weight:500">semua &rarr;</span></div>
<div style="display:flex;gap:6px;margin-bottom:12px">{th}</div>
<div class="btn or" style="height:46px">{svg(I_CAM, 18, "#141414", 2)} CHECK-IN BARU</div>
"""
    inner = status_bar() + f'<div class="content">{content}</div>' + nav("pro")
    return page("tubuh", f'<div class="stage">{device(inner)}</div>', 462, 916)


# ================================================================ 8. MULAI SHEET
def build_mulai():
    def opt(title, sub, icon, primary=False, note=""):
        bg = "background:#FF4F00" if primary else "background:#EFE9DC"
        n = f'<span class="tag" style="position:absolute;right:8px;top:8px;background:#141414;color:#EFE9DC;border-color:#141414">{note}</span>' if note else ""
        return (f'<div style="{bg};border:2px solid #141414;height:142px;padding:12px;display:flex;flex-direction:column;justify-content:space-between;position:relative">{n}'
                f'<div>{svg(icon, 30, "#141414", 2.2)}</div>'
                f'<div><div class="anton" style="font-size:28px">{title}</div><div class="lbl" style="font-size:8.5px;margin-top:5px;color:#141414">{sub}</div></div></div>')
    sheet = f"""
<div style="position:absolute;left:0;right:0;bottom:84px;background:#EFE9DC;border-top:2px solid #141414;z-index:8;padding:10px 16px 26px">
  <div style="display:flex;justify-content:center;margin-bottom:12px"><i style="width:44px;height:4px;background:#141414;display:block"></i></div>
  <div style="display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:12px">
    <div><div class="lbl">Mulai cepat</div><div class="anton" style="font-size:30px;margin-top:5px">MAU NGAPAIN?</div></div>
    <div class="mono mute" style="font-size:10px;margin-bottom:3px">MIN · 09:41</div></div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
    {opt("REKAM GPS", "Sepeda · lari · jalan", I_GPS, True)}
    {opt("MULAI GYM", "Template: Push day", I_DUMB)}
    {opt("TUGAS BARU", "Catat cepat", I_TASK)}
    {opt("FOTO TUBUH", "Check-in mingguan", I_CAM, note="JADWAL")}
  </div>
  <div style="display:flex;align-items:center;gap:10px;margin-top:12px;border-top:1.5px solid #CFC6B2;padding-top:10px">
    <i style="width:10px;height:24px;background:#FF4F00;display:block"></i>
    <div style="flex:1"><div class="lbl" style="font-size:8.5px">Ulangi terakhir</div><div class="sb" style="font-size:13.5px">Gravel · 34,2 km · Sel 3 Nov</div></div>{svg(I_CHEV, 16)}</div>
</div>"""
    inner = (status_bar() + f'<div class="content">{hari_ini_content()}</div>'
             + '<div style="position:absolute;inset:0;background:rgba(20,20,20,.58);z-index:7"></div>' + sheet + nav("hari", close=True))
    return page("mulai_sheet", f'<div class="stage">{device(inner)}</div>', 462, 916)


# ================================================================ OVERVIEW
SCREENS = [
    ("hari_ini", "01 · Hari Ini", "Tugas, fokus, latihan, minggu ini, pengingat"),
    ("kalender", "02 · Kalender", "Heatmap kategori, filter, streak, detail hari"),
    ("gym_sesi", "03 · Sesi Gym", "Set × kg × reps, nilai sebelumnya, timer istirahat"),
    ("tugas", "04 · Tugas", "Catat cepat, berpin, notifikasi balas + ubin QS"),
    ("widget_home", "05 · Widget", "Widget 4×2: tugas berpin + sisa fokus"),
    ("fokus", "06 · Fokus", "Batas per aplikasi + layar Waktu habis"),
    ("tubuh", "07 · Progres Tubuh", "Slider sebelum/sesudah, grafik berat, check-in"),
    ("mulai_sheet", "08 · Tombol Mulai", "Lembar cepat dari tombol tengah"),
]
SIZES = {"tugas": (846, 916), "fokus": (806, 916)}


def build_overview():
    H = 560
    def item(name, title, sub):
        w, h = SIZES.get(name, (462, 916))
        return (f'<div><img src="../{name}.png" style="height:{H}px;width:{w*H/h:.0f}px;display:block;border:1.5px solid #141414">'
                f'<div class="lbl b" style="font-size:12px;margin-top:10px">{title}</div><div style="font-size:13px;color:#3A3A36;margin-top:3px">{sub}</div></div>')
    r1 = "".join(item(*s) for s in SCREENS[:4])
    r2 = "".join(item(*s) for s in SCREENS[4:])
    body = f"""<div style="padding:40px 44px">
 <div style="display:flex;justify-content:space-between;align-items:flex-end;border-bottom:2px solid #141414;padding-bottom:14px;margin-bottom:30px">
  <div><div class="lbl">Virya · rancangan layar · fase 3–7</div><div class="anton" style="font-size:56px;margin-top:8px">GAMBARAN LAYAR</div></div>
  <div style="text-align:right">{legend_inline(11)}<div class="mono mute" style="font-size:11px;margin-top:8px">MOCKUP STATIS · 8 NOV 2026</div></div></div>
 <div style="display:flex;gap:26px;margin-bottom:34px">{r1}</div>
 <div style="display:flex;gap:26px">{r2}</div></div>"""
    w = 44 * 2 + 3 * (462 * H / 916) + (846 * H / 916) + 3 * 26
    w2 = 44 * 2 + 3 * (462 * H / 916) + (806 * H / 916) + 3 * 26
    W = int(max(w, w2)) + 4
    Ht = 40 + 110 + 30 + (H + 60) * 2 + 34 - 20
    html = f"""<!doctype html><html class="x2"><head><meta charset="utf-8"><link rel="stylesheet" href="common.css">
<style>body{{width:{W}px;height:{Ht}px;background:#EFE9DC}}</style></head><body>{body}</body></html>"""
    path = os.path.join(HERE, "overview_layar.html")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(html)
    return path, W, Ht


BUILDERS = dict(hari_ini=build_hari_ini, kalender=build_kalender, gym_sesi=build_gym, tugas=build_tugas,
                widget_home=build_widget, fokus=build_fokus, tubuh=build_tubuh, mulai_sheet=build_mulai)


def render(path, w, h, out, scale=2):
    subprocess.run([sys.executable, RENDER, path, "-o", out, "--width", str(w * scale), "--height", str(h * scale)], check=True)


if __name__ == "__main__":
    names = sys.argv[1:] or list(BUILDERS) + ["overview"]
    for n in names:
        if n == "overview":
            p, w, h = build_overview()
            render(p, w, h, os.path.join(OUT, "overview_layar.png"), scale=2)
        else:
            p, w, h = BUILDERS[n]()
            render(p, w, h, os.path.join(OUT, n + ".png"))
        print("ok", n)
