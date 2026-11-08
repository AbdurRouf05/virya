// Virya map bridge: Dart → window.ViryaMap.*, JS → Virya.postMessage(JSON).
(function () {
  'use strict';
  var C = window.ViryaStyle.colors;
  var SIGNAL = '#FF4F00';
  var map = null, cfg = {}, loaded = false, is3d = false;
  var routeCoords = []; // [[lon,lat]]
  var liveCoords = [];
  var pending = [];

  function post(msg) {
    try { if (window.Virya) window.Virya.postMessage(JSON.stringify(msg)); } catch (e) { /* ignore */ }
  }
  window.onerror = function (m, s, l) { post({ type: 'error', msg: String(m) + ' @' + l }); };

  function fc(features) { return { type: 'FeatureCollection', features: features || [] }; }
  function line(coords, props) {
    return { type: 'Feature', properties: props || {}, geometry: { type: 'LineString', coordinates: coords } };
  }
  function pt(lon, lat, props) {
    return { type: 'Feature', properties: props || {}, geometry: { type: 'Point', coordinates: [lon, lat] } };
  }
  function src(id) { return map && map.getSource(id); }
  function whenLoaded(fn) { if (loaded) fn(); else pending.push(fn); }

  // ---------- icons drawn on canvas (no sprite / glyph files) ----------
  function iconImage(drawFn, size) {
    var c = document.createElement('canvas');
    c.width = c.height = size;
    var g = c.getContext('2d');
    drawFn(g, size);
    return g.getImageData(0, 0, size, size);
  }
  function addIcons() {
    map.addImage('arrow', iconImage(function (g, s) {
      g.translate(s / 2, s / 2);
      g.beginPath(); g.arc(0, 0, s * 0.30, 0, Math.PI * 2);
      g.fillStyle = SIGNAL; g.fill(); g.lineWidth = s * 0.08; g.strokeStyle = C.paper; g.stroke();
      g.beginPath(); g.moveTo(0, -s * 0.48); g.lineTo(s * 0.16, -s * 0.30); g.lineTo(-s * 0.16, -s * 0.30); g.closePath();
      g.fillStyle = C.ink; g.fill();
    }, 64), { pixelRatio: 2 });
    map.addImage('photo', iconImage(function (g, s) {
      g.fillStyle = C.paper; g.fillRect(s * 0.1, s * 0.1, s * 0.8, s * 0.8);
      g.lineWidth = s * 0.1; g.strokeStyle = C.ink; g.strokeRect(s * 0.1, s * 0.1, s * 0.8, s * 0.8);
      g.fillStyle = SIGNAL; g.beginPath(); g.arc(s / 2, s / 2, s * 0.17, 0, Math.PI * 2); g.fill();
    }, 40), { pixelRatio: 2 });
  }

  function addRouteLayers() {
    var e = fc();
    ['heat', 'route', 'live', 'trace', 'ends', 'pos', 'photos'].forEach(function (id) {
      map.addSource(id, { type: 'geojson', data: e });
    });
    map.addLayer({ id: 'heat', type: 'heatmap', source: 'heat',
      paint: { 'heatmap-weight': ['get', 'w'],
        'heatmap-intensity': ['interpolate', ['linear'], ['zoom'], 6, 0.4, 12, 1, 16, 1.8],
        'heatmap-radius': ['interpolate', ['linear'], ['zoom'], 6, 1.5, 10, 2.5, 14, 4, 16, 12, 18, 40],
        'heatmap-opacity': 0.92,
        'heatmap-color': ['interpolate', ['linear'], ['heatmap-density'],
          0, 'rgba(255,79,0,0)', 0.08, 'rgba(255,120,30,0.5)', 0.35, SIGNAL, 0.7, '#A3161B', 1, '#5B0E2D'] } });
    map.addLayer({ id: 'route-casing', type: 'line', source: 'route',
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': C.ink, 'line-width': ['interpolate', ['linear'], ['zoom'], 8, 4, 16, 9] } });
    map.addLayer({ id: 'route-line', type: 'line', source: 'route',
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': ['coalesce', ['get', 'c'], SIGNAL],
        'line-width': ['interpolate', ['linear'], ['zoom'], 8, 2.2, 16, 5.5] } });
    map.addLayer({ id: 'live-casing', type: 'line', source: 'live',
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': C.ink, 'line-width': 8 } });
    map.addLayer({ id: 'live-line', type: 'line', source: 'live',
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': SIGNAL, 'line-width': 4.5 } });
    map.addLayer({ id: 'trace-glow', type: 'line', source: 'trace',
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': '#FFFDF6', 'line-width': 11, 'line-opacity': 0.75, 'line-blur': 2 } });
    map.addLayer({ id: 'trace-line', type: 'line', source: 'trace',
      layout: { 'line-cap': 'round', 'line-join': 'round' },
      paint: { 'line-color': SIGNAL, 'line-width': 5.5 } });
    map.addLayer({ id: 'ends', type: 'circle', source: 'ends',
      paint: { 'circle-radius': 7,
        'circle-color': ['match', ['get', 'k'], 'start', SIGNAL, C.ink],
        'circle-stroke-color': ['match', ['get', 'k'], 'start', C.ink, C.paper],
        'circle-stroke-width': 3, 'circle-pitch-alignment': 'map' } });
    map.addLayer({ id: 'photos', type: 'symbol', source: 'photos',
      layout: { 'icon-image': 'photo', 'icon-allow-overlap': true, 'icon-ignore-placement': true } });
    map.addLayer({ id: 'pos', type: 'symbol', source: 'pos',
      layout: { 'icon-image': 'arrow', 'icon-allow-overlap': true, 'icon-ignore-placement': true,
        'icon-rotate': ['coalesce', ['get', 'b'], 0], 'icon-rotation-alignment': 'map',
        'icon-pitch-alignment': 'map' } });
  }

  function applyTerrain() {
    if (!map) return;
    try {
      if (is3d && cfg.demUrl) map.setTerrain({ source: 'dem', exaggeration: 1.4 });
      else map.setTerrain(null);
    } catch (e) { post({ type: 'error', msg: 'terrain: ' + e }); }
  }

  // ---------- public: init ----------
  function init(c) {
    cfg = c || {};
    is3d = !!cfg.enable3d;
    if (window.pmtiles && !window.__pmReg) {
      var protocol = new pmtiles.Protocol();
      maplibregl.addProtocol('pmtiles', protocol.tile);
      window.__pmReg = true;
    }
    var style = window.ViryaStyle.build(cfg);
    map = new maplibregl.Map({
      container: 'map',
      style: style,
      center: cfg.center || [107.62, -6.83],
      zoom: cfg.zoom || 11,
      pitch: is3d ? 55 : 0,
      maxPitch: 80,
      interactive: cfg.interactive !== false,
      attributionControl: { compact: true },
      preserveDrawingBuffer: true,
      fadeDuration: 0,
      canvasContextAttributes: { preserveDrawingBuffer: true, antialias: true }
    });
    map.on('error', function (e) { post({ type: 'error', msg: String(e && e.error && e.error.message || e) }); });
    map.on('load', function () {
      try { addIcons(); addRouteLayers(); } catch (e) { post({ type: 'error', msg: String(e) }); }
      try {
        map.setSky({ 'sky-color': C.paperDeep, 'horizon-color': C.paper, 'fog-color': C.paper,
          'sky-horizon-blend': 0.6, 'horizon-fog-blend': 0.6, 'fog-ground-blend': 0.4 });
      } catch (e) { /* older API */ }
      applyTerrain();
      loaded = true;
      var q = pending; pending = [];
      q.forEach(function (fn) { try { fn(); } catch (e) { post({ type: 'error', msg: String(e) }); } });
      post({ type: 'loaded' });
    });
    window.addEventListener('resize', function () { if (map) map.resize(); });
  }

  // ---------- route colouring ----------
  function colorFor(v, mode, lo, hi) {
    var pal = cfg.palette || {};
    if (v === null || v === undefined || isNaN(v)) return SIGNAL;
    if (mode === 'surface') {
      var s = pal.surface || [];
      return s[Math.max(0, Math.min(s.length - 1, Math.round(v)))] || SIGNAL;
    }
    if (mode === 'grade') {
      var g = pal.grade || { stops: [3, 5, 8, 11, 15], colors: [C.inkSoft, '#D8B23A', '#E8812A', '#D9481B', '#A3161B', '#5B0E2D'] };
      for (var i = 0; i < g.stops.length; i++) if (v < g.stops[i]) return g.colors[i];
      return g.colors[g.colors.length - 1];
    }
    if (mode === 'speed') {
      var r = pal.speed || [C.inkSoft, '#C9A227', '#E8812A', SIGNAL, '#A3161B'];
      var t = hi > lo ? (v - lo) / (hi - lo) : 0.5;
      t = Math.max(0, Math.min(0.9999, t));
      return r[Math.floor(t * r.length)];
    }
    return SIGNAL;
  }
  function pct(sorted, p) { return sorted.length ? sorted[Math.floor((sorted.length - 1) * p)] : 0; }

  function routeFeatures(coords, values, mode) {
    if (!values || !values.length || mode === 'plain' || !mode) return [line(coords, { c: SIGNAL })];
    var sorted = values.filter(function (v) { return v !== null && !isNaN(v); }).sort(function (a, b) { return a - b; });
    var lo = pct(sorted, 0.05), hi = pct(sorted, 0.95);
    var feats = [], cur = null, run = null;
    for (var i = 0; i < coords.length - 1; i++) {
      var c = colorFor(values[i], mode, lo, hi);
      if (c !== cur) {
        if (run) feats.push(line(run, { c: cur }));
        run = [coords[i]];
        cur = c;
      }
      run.push(coords[i + 1]);
    }
    if (run) feats.push(line(run, { c: cur }));
    return feats;
  }

  // coords: [[lat,lon],...] (Dart order)
  function setRoute(coords, values, mode, fit) {
    whenLoaded(function () {
      routeCoords = (coords || []).map(function (p) { return [p[1], p[0]]; });
      liveCoords = [];
      src('live').setData(fc());
      if (routeCoords.length < 2) {
        src('route').setData(fc()); src('ends').setData(fc());
        if (routeCoords.length === 1) map.jumpTo({ center: routeCoords[0], zoom: 15 });
        return;
      }
      src('route').setData(fc(routeFeatures(routeCoords, values, mode)));
      var a = routeCoords[0], b = routeCoords[routeCoords.length - 1];
      src('ends').setData(fc([pt(b[0], b[1], { k: 'finish' }), pt(a[0], a[1], { k: 'start' })]));
      if (fit !== false) fitRoute(false);
    });
  }

  function appendLivePoints(pts) {
    whenLoaded(function () {
      (pts || []).forEach(function (p) { liveCoords.push([p[1], p[0]]); });
      if (liveCoords.length >= 2) src('live').setData(fc([line(liveCoords)]));
      if (liveCoords.length) {
        var a = liveCoords[0];
        src('ends').setData(fc([pt(a[0], a[1], { k: 'start' })]));
      }
    });
  }
  function appendLivePoint(lat, lon) { appendLivePoints([[lat, lon]]); }

  function setPosition(lat, lon, bearing, follow) {
    whenLoaded(function () {
      if (lat === null || lat === undefined) { src('pos').setData(fc()); return; }
      src('pos').setData(fc([pt(lon, lat, { b: bearing || 0 })]));
      if (follow) map.easeTo({ center: [lon, lat], duration: 600 });
    });
  }

  function boundsOf(coords) {
    if (!coords.length) return null;
    var b = new maplibregl.LngLatBounds(coords[0], coords[0]);
    coords.forEach(function (c) { b.extend(c); });
    return b;
  }

  function fitRoute(animate) {
    whenLoaded(function () {
      var all = routeCoords.concat(liveCoords);
      var b = boundsOf(all);
      if (!b) return;
      var pad = cfg.padding || 36;
      map.fitBounds(b, { padding: pad, maxZoom: 16, duration: animate ? 800 : 0,
        bearing: map.getBearing(), pitch: map.getPitch() });
    });
  }

  function set3d(on) {
    is3d = !!on;
    whenLoaded(function () {
      applyTerrain();
      if (!fly.plan) map.easeTo({ pitch: is3d ? 55 : 0, duration: 600 });
      else applyFly(fly.u);
    });
  }

  // flat: [lat, lon, weight, lat, lon, weight, ...]
  function setHeat(flat, fit) {
    whenLoaded(function () {
      var f = [], s = 90, n = -90, w = 180, e = -180;
      for (var i = 0; i + 2 < (flat || []).length; i += 3) {
        var lat = flat[i], lon = flat[i + 1];
        f.push(pt(lon, lat, { w: flat[i + 2] }));
        if (lat < s) s = lat;
        if (lat > n) n = lat;
        if (lon < w) w = lon;
        if (lon > e) e = lon;
      }
      src('heat').setData(fc(f));
      if (f.length && fit !== false) {
        map.fitBounds([[w, s], [e, n]], { padding: cfg.padding || 36, maxZoom: 14, duration: 0 });
      }
    });
  }

  function setPhotos(list) {
    whenLoaded(function () {
      src('photos').setData(fc((list || []).map(function (p) { return pt(p.lon, p.lat, {}); })));
    });
  }

  // ---------- flyover ----------
  var fly = { plan: null, u: 0, playing: false, speed: 1, duration: 30, last: 0, lastPost: 0, cum: null, ov: null, traceKey: -1 };

  function flyLoad(plan) {
    whenLoaded(function () {
      fly.plan = plan;
      fly.u = 0;
      var r = plan.route || [];
      var cum = [0];
      for (var i = 1; i < r.length; i++) {
        var dx = (r[i][0] - r[i - 1][0]) * Math.cos(r[i][1] * Math.PI / 180), dy = r[i][1] - r[i - 1][1];
        cum.push(cum[i - 1] + Math.sqrt(dx * dx + dy * dy));
      }
      fly.cum = cum;
      routeCoords = r;
      // Faint full route under the tracer.
      map.setPaintProperty('route-casing', 'line-opacity', 0.25);
      map.setPaintProperty('route-line', 'line-opacity', 0.0);
      src('route').setData(r.length > 1 ? fc([line(r, { c: C.ink })]) : fc());
      if (r.length > 1) {
        var a = r[0], b = r[r.length - 1];
        src('ends').setData(fc([pt(b[0], b[1], { k: 'finish' }), pt(a[0], a[1], { k: 'start' })]));
      }
      computeOverview();
      applyFly(0);
      post({ type: 'flyLoaded' });
    });
  }

  function computeOverview() {
    var b = boundsOf(routeCoords);
    if (!b) { fly.ov = null; return; }
    var pad = Math.round(Math.min(map.getContainer().clientWidth, map.getContainer().clientHeight) * 0.12);
    var cam = map.cameraForBounds(b, { padding: pad, bearing: 0 });
    fly.ov = cam ? { lon: cam.center.lng, lat: cam.center.lat, z: cam.zoom } : null;
  }

  function kfAt(u) {
    var P = fly.plan, U = P.u, n = U.length;
    if (u <= U[0]) return idx(0, 0, 0);
    if (u >= U[n - 1]) return idx(n - 1, n - 1, 0);
    var lo = 0, hi = n - 1;
    while (hi - lo > 1) { var m = (lo + hi) >> 1; if (U[m] <= u) lo = m; else hi = m; }
    var span = U[hi] - U[lo];
    return idx(lo, hi, span > 0 ? (u - U[lo]) / span : 0);
    function idx(a, b, t) {
      var o = {};
      ['lat', 'lon', 'b', 'pt', 'z', 'ov', 'p', 'd', 'e', 's', 'g', 't'].forEach(function (k) {
        o[k] = P[k][a] + (P[k][b] - P[k][a]) * t;
      });
      return o;
    }
  }

  function traceUpTo(p, tip) {
    var r = routeCoords, cum = fly.cum;
    if (!r || r.length < 2) return fc();
    var target = p * cum[cum.length - 1];
    var out = [];
    for (var i = 0; i < r.length && cum[i] <= target; i++) out.push(r[i]);
    if (tip) out.push(tip);
    return out.length > 1 ? fc([line(out)]) : fc();
  }

  function applyFly(u, force) {
    if (!fly.plan || !fly.plan.u.length) return null;
    fly.u = u;
    var k = kfAt(u);
    var lon = k.lon, lat = k.lat, z = k.z, w = k.ov;
    if (fly.ov && w > 0) {
      lon += (fly.ov.lon - lon) * w; lat += (fly.ov.lat - lat) * w; z += (fly.ov.z - z) * w;
    }
    map.jumpTo({ center: [lon, lat], zoom: z, bearing: k.b, pitch: is3d ? k.pt : 0 });
    var key = Math.round(k.p * 2000);
    if (force || key !== fly.traceKey || k.p >= 0.999) {
      fly.traceKey = key;
      src('trace').setData(traceUpTo(k.p, k.p > 0 ? [k.lon, k.lat] : null));
    }
    src('pos').setData(fc([pt(k.lon, k.lat, { b: k.b })]));
    return k;
  }

  function postProgress(k, force) {
    var now = performance.now();
    if (!force && now - fly.lastPost < 100) return;
    fly.lastPost = now;
    post({ type: 'progress', u: fly.u, playing: fly.playing, d: k.d, e: k.e, s: k.s, g: k.g, t: k.t });
  }

  function tick(ts) {
    if (!fly.playing) return;
    var dt = fly.last ? Math.min(0.1, (ts - fly.last) / 1000) : 0;
    fly.last = ts;
    var u = Math.min(1, fly.u + dt * fly.speed / fly.duration);
    var k = applyFly(u);
    if (u >= 1) { fly.playing = false; if (k) postProgress(k, true); post({ type: 'ended' }); return; }
    if (k) postProgress(k);
    requestAnimationFrame(tick);
  }
  function flyPlay() {
    whenLoaded(function () {
      if (!fly.plan) return;
      if (fly.u >= 1) fly.u = 0;
      if (fly.playing) return;
      fly.playing = true; fly.last = 0;
      requestAnimationFrame(tick);
    });
  }
  function flyPause() { fly.playing = false; whenLoaded(function () { var k = fly.plan && applyFly(fly.u); if (k) postProgress(k, true); }); }
  function flySeek(u) {
    whenLoaded(function () { var k = applyFly(Math.max(0, Math.min(1, u)), true); if (k) postProgress(k, true); });
  }
  function flySetSpeed(x) { fly.speed = x || 1; }
  function flySetDuration(s) { fly.duration = s || 30; }

  // ---------- deterministic export ----------
  var exp = null;

  function exportBegin(o) {
    whenLoaded(function () {
      fly.playing = false;
      exp = o;
      var el = document.getElementById('map');
      var cssW = Math.max(200, window.innerWidth);
      var cssH = Math.round(cssW * o.h / o.w);
      el.style.width = cssW + 'px';
      el.style.height = cssH + 'px';
      exp.prevRatio = window.devicePixelRatio || 1;
      try { map.setPixelRatio(o.w / cssW); } catch (e) { /* fallback: scaled composite */ }
      map.resize();
      computeOverview();
      exp.canvas = document.createElement('canvas');
      exp.canvas.width = o.w; exp.canvas.height = o.h;
      var fonts = document.fonts ? Promise.all([
        document.fonts.load('80px Anton'), document.fonts.load('24px PlexMono')
      ]).catch(function () {}) : Promise.resolve();
      fonts.then(function () { post({ type: 'exportReady' }); });
    });
  }

  function exportEnd() {
    whenLoaded(function () {
      var el = document.getElementById('map');
      el.style.width = '100%'; el.style.height = '100%';
      try { map.setPixelRatio(window.devicePixelRatio || 1); } catch (e) { /* ignore */ }
      map.resize();
      computeOverview();
      exp = null;
      applyFly(fly.u, true);
    });
  }

  function waitRendered(ms) {
    return new Promise(function (res) {
      var done = false;
      var fin = function () { if (!done) { done = true; clearTimeout(to); res(); } };
      var to = setTimeout(fin, ms || 8000);
      map.once('idle', fin);
      map.triggerRepaint();
    });
  }

  function fmtTime(s) {
    s = Math.max(0, Math.round(s));
    var h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), x = s % 60;
    var mm = (m < 10 ? '0' : '') + m, xx = (x < 10 ? '0' : '') + x;
    return h > 0 ? h + ':' + mm + ':' + xx : m + ':' + xx;
  }
  function fmtPace(kmh) {
    if (!kmh || kmh < 1) return '--:--';
    var sec = 3600 / kmh, m = Math.floor(sec / 60), s = Math.round(sec % 60);
    if (s === 60) { m++; s = 0; }
    return m + ':' + (s < 10 ? '0' : '') + s;
  }
  function gradeColor(g) {
    var gr = (cfg.palette && cfg.palette.grade) || null;
    if (!gr) return SIGNAL;
    for (var i = 0; i < gr.stops.length; i++) if (g < gr.stops[i]) return i === 0 ? '#EFE9DC' : gr.colors[i];
    return gr.colors[gr.colors.length - 1];
  }

  function drawHud(g, W, H, k, u) {
    var s = W / 1080;
    // Top band.
    var top = g.createLinearGradient(0, 0, 0, 260 * s);
    top.addColorStop(0, 'rgba(14,14,12,0.85)'); top.addColorStop(1, 'rgba(14,14,12,0)');
    g.fillStyle = top; g.fillRect(0, 0, W, 260 * s);
    g.textBaseline = 'alphabetic';
    g.fillStyle = '#C6FF00';
    g.font = (26 * s) + 'px PlexMono, monospace';
    g.fillText('VIRYA // FLYOVER', 56 * s, 96 * s);
    g.fillStyle = '#EFE9DC';
    g.font = (64 * s) + 'px Anton, sans-serif';
    g.fillText(String(exp.title || '').toUpperCase().slice(0, 26), 56 * s, 176 * s);
    g.fillStyle = '#A9A49A';
    g.font = (24 * s) + 'px PlexMono, monospace';
    g.fillText(String(exp.subtitle || ''), 56 * s, 218 * s);
    // Bottom panel.
    var py = H - 470 * s;
    var bot = g.createLinearGradient(0, py - 120 * s, 0, H);
    bot.addColorStop(0, 'rgba(14,14,12,0)'); bot.addColorStop(0.25, 'rgba(14,14,12,0.88)'); bot.addColorStop(1, 'rgba(14,14,12,0.96)');
    g.fillStyle = bot; g.fillRect(0, py - 120 * s, W, H - py + 120 * s);
    var cells = [
      ['JARAK', (k.d / 1000).toFixed(k.d < 10000 ? 2 : 1), 'KM', '#EFE9DC'],
      ['ELEVASI', String(Math.round(k.e)), 'M', '#EFE9DC'],
      exp.pace ? ['TEMPO', fmtPace(k.s), '/KM', '#EFE9DC'] : ['KECEPATAN', k.s.toFixed(1), 'KM/J', '#EFE9DC'],
      ['TANJAKAN', (k.g >= 0 ? '+' : '') + k.g.toFixed(1), '%', gradeColor(k.g)]
    ];
    var colW = (W - 112 * s) / 2;
    cells.forEach(function (c, i) {
      var x = 56 * s + (i % 2) * colW, y = py + Math.floor(i / 2) * 170 * s;
      g.fillStyle = '#77736A'; g.font = (24 * s) + 'px PlexMono, monospace';
      g.fillText(c[0], x, y + 20 * s);
      g.fillStyle = c[3]; g.font = (104 * s) + 'px Anton, sans-serif';
      g.fillText(c[1], x, y + 130 * s);
      var vw = g.measureText(c[1]).width;
      g.fillStyle = '#A9A49A'; g.font = (28 * s) + 'px PlexMono, monospace';
      g.fillText(c[2], x + vw + 12 * s, y + 130 * s);
    });
    // Time + progress bar.
    var by = H - 96 * s;
    g.fillStyle = '#EFE9DC'; g.font = (30 * s) + 'px PlexMono, monospace';
    g.fillText('WAKTU ' + fmtTime(k.t), 56 * s, by - 24 * s);
    g.fillStyle = '#2E2E29'; g.fillRect(56 * s, by, W - 112 * s, 8 * s);
    g.fillStyle = SIGNAL; g.fillRect(56 * s, by, (W - 112 * s) * Math.max(0, Math.min(1, k.p)), 8 * s);
    if (cfg.basemapUrl || cfg.online) {
      g.fillStyle = 'rgba(169,164,154,0.8)'; g.font = (18 * s) + 'px PlexMono, monospace';
      g.fillText('© OpenStreetMap', W - 250 * s, H - 40 * s);
    }
  }

  function sendChunks(i, dataUrl) {
    var b64 = dataUrl.substring(dataUrl.indexOf(',') + 1);
    var size = 200000, n = Math.ceil(b64.length / size);
    for (var c = 0; c < n; c++) {
      post({ type: 'frameChunk', i: i, seq: c, n: n, data: b64.substr(c * size, size) });
    }
  }

  function exportWarmup(steps) {
    steps = steps || 24;
    whenLoaded(function () {
      var i = 0;
      function next() {
        if (i >= steps) {
          post({ type: 'warmupDone' });
          return;
        }
        var t = steps <= 1 ? 0 : i / (steps - 1);
        applyFly(t, true);
        i++;
        waitRendered(8000).then(next);
      }
      next();
    });
  }

  function renderFrame(t, i) {
    whenLoaded(function () {
      if (!exp) { post({ type: 'frameError', i: i, msg: 'export not started' }); return; }
      var k = applyFly(t, true);
      waitRendered(8000).then(function () {
        var g = exp.canvas.getContext('2d');
        var W = exp.w, H = exp.h;
        g.fillStyle = C.paper; g.fillRect(0, 0, W, H);
        var mc = map.getCanvas();
        // Cover-fit the map canvas into the output frame.
        var sc = Math.max(W / mc.width, H / mc.height);
        var dw = mc.width * sc, dh = mc.height * sc;
        g.drawImage(mc, (W - dw) / 2, (H - dh) / 2, dw, dh);
        if (k) drawHud(g, W, H, k, t);
        var q = exp.quality || 0.85;
        if (exp.captureUrl && exp.canvas.toBlob) {
          exp.canvas.toBlob(function (blob) {
            fetch(exp.captureUrl + '/' + i, { method: 'POST', body: blob })
              .then(function (r) {
                if (!r.ok) throw new Error('HTTP ' + r.status);
                post({ type: 'frameSent', i: i });
              })
              .catch(function () { sendChunks(i, exp.canvas.toDataURL('image/jpeg', q)); });
          }, 'image/jpeg', q);
        } else {
          sendChunks(i, exp.canvas.toDataURL('image/jpeg', q));
        }
      });
    });
  }

  window.ViryaMap = {
    init: init, setRoute: setRoute, appendLivePoint: appendLivePoint, appendLivePoints: appendLivePoints,
    setPosition: setPosition, fitRoute: fitRoute, set3d: set3d, setPhotos: setPhotos, setHeat: setHeat,
    flyLoad: flyLoad, flyPlay: flyPlay, flyPause: flyPause, flySeek: flySeek,
    flySetSpeed: flySetSpeed, flySetDuration: flySetDuration,
    exportBegin: exportBegin, exportWarmup: exportWarmup, renderFrame: renderFrame, exportEnd: exportEnd
  };
  post({ type: 'ready' });
})();
