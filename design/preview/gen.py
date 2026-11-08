F="file:///D:/coding/flutter/stravo/assets/fonts/"
A_P='<path d="M60 116 L108 180 L192 70" fill="none" stroke="{ink}" stroke-width="30" stroke-linecap="round" stroke-linejoin="round"/><circle cx="192" cy="70" r="24" fill="{acc}"/>'
B_P='<g fill="none" stroke="{ink}" stroke-width="16"><path d="M180 45.9 A104 104 0 1 1 76 45.9"/><path d="M164 73.6 A72 72 0 1 1 92 73.6"/><path d="M148 101.4 A40 40 0 1 1 108 101.4"/></g><circle cx="128" cy="136" r="14" fill="{acc}"/>'
C_P='<g fill="{ink}"><rect x="28" y="64" width="36" height="36"/><rect x="69" y="105" width="36" height="36"/><rect x="151" y="105" width="36" height="36"/><rect x="110" y="146" width="36" height="36"/></g><rect x="192" y="64" width="36" height="36" fill="{acc}"/>'
C=[("A","Rute Centang",A_P),("B","Kontur Puncak",B_P),("C","Streak Sel",C_P)]
def svg(p,ink,acc,size,vb="0 0 256 256"):
    return f'<svg viewBox="{vb}" width="{size}" height="{size}">'+p.format(ink=ink,acc=acc)+'</svg>'
def icon(p,bg,ink,acc,s=96):
    return f'<div class="ic" style="background:{bg};width:{s}px;height:{s}px">{svg(p,ink,acc,int(s*0.66))}</div>'
rows=""
for k,n,p in C:
    home=f'''<div class="home">
      <div class="grid">
        <div class="app"><div class="ic" style="background:#4a6;width:58px;height:58px"></div><span>Kamera</span></div>
        <div class="app"><div class="ic" style="background:#57c;width:58px;height:58px"></div><span>Pesan</span></div>
        <div class="app">{icon(p,"#EFE9DC","#141414","#FF4F00",58)}<span>Virya</span></div>
        <div class="app"><div class="ic" style="background:#d84;width:58px;height:58px"></div><span>Galeri</span></div>
      </div></div>'''
    splash=f'''<div class="phone" style="background:#EFE9DC">
        <div class="contour"></div>
        <div class="sp">{svg(p,"#141414","#FF4F00",120)}<div class="wm">VIRYA</div><div class="tag">TENAGA · KEGIGIHAN · USAHA</div></div></div>'''
    rows+=f'''<section><h2>{k} · {n}</h2><div class="row">
      <div class="col"><div class="cap">IKON (TERANG / GELAP / MONOKROM)</div>
        <div class="icons">{icon(p,"#EFE9DC","#141414","#FF4F00")}{icon(p,"#141414","#EFE9DC","#FF4F00")}{icon(p,"#FF4F00","#141414","#EFE9DC")}{icon(p,"#ffffff","#141414","#141414")}</div>
        <div class="cap">UKURAN KECIL</div><div class="icons small">{icon(p,"#EFE9DC","#141414","#FF4F00",48)}{icon(p,"#EFE9DC","#141414","#FF4F00",32)}{icon(p,"#EFE9DC","#141414","#FF4F00",20)}</div>
        <div class="cap">WORDMARK</div><div class="lock">{svg(p,"#141414","#FF4F00",64)}<span>VIRYA</span></div>
      </div>
      <div class="col"><div class="cap">DI LAYAR HP</div>{home}</div>
      <div class="col"><div class="cap">SPLASH SCREEN</div>{splash}</div>
    </div></section>'''
html=f'''<html><head><style>
@font-face{{font-family:Anton;src:url({F}Anton-Regular.ttf)}}
@font-face{{font-family:Mono;src:url({F}IBMPlexMono-Medium.ttf)}}
body{{margin:0;padding:40px;background:#E3DBC9;font-family:Mono;color:#141414;width:1320px}}
h1{{font-family:Anton;font-size:56px;margin:0 0 4px;letter-spacing:1px}}
h2{{font-family:Anton;font-size:34px;margin:0 0 14px;letter-spacing:1px}}
section{{background:#EFE9DC;border:2px solid #141414;padding:24px;margin:24px 0}}
.row{{display:flex;gap:36px;align-items:flex-start}} .col{{flex:0 0 auto}}
.cap{{font-size:11px;letter-spacing:1.5px;color:#77736A;margin:10px 0 8px}}
.icons{{display:flex;gap:14px;align-items:center}}
.ic{{border-radius:24%;display:flex;align-items:center;justify-content:center;box-shadow:0 1px 3px rgba(0,0,0,.25)}}
.lock{{display:flex;align-items:center;gap:10px}} .lock span{{font-family:Anton;font-size:60px;letter-spacing:3px}}
.home{{width:330px;height:300px;background:linear-gradient(160deg,#5b6b7a,#2d3640);border-radius:22px;padding:30px 18px;box-sizing:border-box}}
.grid{{display:grid;grid-template-columns:repeat(4,1fr);gap:16px}} .app{{display:flex;flex-direction:column;align-items:center;gap:6px}}
.app span{{color:#fff;font-family:sans-serif;font-size:12px}}
.phone{{width:200px;height:420px;border:8px solid #141414;border-radius:26px;position:relative;overflow:hidden}}
.contour{{position:absolute;inset:0;opacity:.35;background:repeating-radial-gradient(circle at 70% 85%,transparent 0 22px,#CFC6B2 22px 23px)}}
.sp{{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center}}
.wm{{font-family:Anton;font-size:44px;letter-spacing:4px;margin-top:6px}} .tag{{font-size:8px;letter-spacing:1.5px;color:#77736A;margin-top:4px}}
</style></head><body><h1>PRATINJAU LOGO VIRYA</h1><div class="cap">Warna: kertas #EFE9DC · tinta #141414 · aksen oranye #FF4F00</div>{rows}</body></html>'''
open("logo_preview.html","w",encoding="utf-8").write(html)
