# Stravo Pro — Progress Log

Newest entries on top. Contract & ownership: [BUILD_CONTRACT_V2.md](BUILD_CONTRACT_V2.md).

## Status board

| # | Module | Owner | Status |
|---|---|---|---|
| 0 | Foundation: deps, fonts, MapLibre assets, contracts, DB schema v2, finalizer | Integrator | ✅ Done |
| A | Tracking engine + recording screen + foreground service + TTS | Modul A | ✅ Done (43 tests) — device test pending |
| B | Analytics (GAP, climbs, gravel sectors, grit, power, fitness, best efforts) + GPX/TCX/FIT IO + backup | Modul B | ✅ Done (48 tests) |
| C | Field Notes UI shell, history, detail, dashboard, gear, settings | Modul C | ✅ Done (4 tests) |
| I | Integration: analyze clean, 179/179 tests, debug APK builds | Integrator | ✅ Done |
| D | Share studio: story cards, sticker PNG, Topo-Ink renderer, MP4 encoder | Modul D | ✅ Done (30 tests) — device test pending |
| E | Offline maps (PMTiles server), MapLibre WebView, 3D flyover + video | Modul E | ✅ Done (48 tests) — device test pending |
| 2.1 | Perbaikan v2.1 (stempel, video cepat, durasi, flyover, lari, analitik) | Antigravity | ✅ Done (186 tests) |
| 2 | Wave 2: live segments + ghost pacer, personal heatmap, BLE HR, polish | — | 🔜 Planned |

## Log

### 2026-11-07 — v2.1 T8 Penutup & verifikasi rilis v2.1 ✅
- `flutter analyze`: No issues found! (0 warnings, 0 infos).
- `flutter test`: 186/186 tes lolos.
- `flutter build apk --release`: sukses dibangun `build\app\outputs\flutter-apk\app-release.apk` (68.8 MB).
- Checklist verifikasi perbaikan v2.1:
  1. Statistik: Visual stempel miring dihapus; status form & PR diganti `MarkLabel` lurus; grafik kebugaran terisi dengan lead-in 7 hari (≥8 titik).
  2. Detail aktivitas: GRIT diubah jadi `StatBlock` datar di grid ringkasan; disembunyikan bila GRIT 0.
  3. Bagikan: Tidak ada stempel/segel rotasi; template `SEKTOR` otomatis disembunyikan untuk lari atau rute tanpa sektor kerikil.
  4. Video recap: Default 720P, cache layer statis `_bake()`, pipelining render-encode, multi-threaded RGBA→YUV Kotlin; outro 'FINIS' lurus; polaroid foto tegak tanpa pop scale.
  5. Pilihan durasi: `RecapLength` (OTOMATIS sebanding jarak rute, 15, 30, 60 dtk) dengan keterangan kecepatan rute.
  6. Flyover 3D: Pre-warming tile `exportWarmup`, pipelining frame, durasi dinamis, pilihan resolusi 720P/1080P, safety timeout 20 detik & error UI dengan tombol coba lagi.
  7. Mode REKAM: Strip horizontal 7 olahraga utama saat idle (`_SportStrip`), pilihan olahraga terakhir tersimpan ke database settings.
  8. Mode LARI: Format kecepatan pace `/KM` otomatis aktif untuk lari/trail/hiking/jalan di seluruh layar dan media.
  9. Analitik & Data: Formula `gritScore` mengalikan elevasi dengan porsi gravel (`25 * c * g`), menghasilkan GRIT 0 pada aspal 100%; kartu share menampilkan `—` saat GRIT 0; tombol "HITUNG ULANG SEMUA AKTIVITAS" tersedia di Pengaturan → Data dengan progress dialog.

### 2026-11-07 — v2.1 T7 Perbaikan analitik (GRIT aspal 0, tombol hitung ulang, lead-in grafik fitness) ✅
- `gravel.dart`: formula `gritScore` memperhitungkan komponen tanjakan sebanding porsi gravel (`25 * c * g`). Rute 100% aspal (`gravelPct = 0`) kini selalu menghasilkan GRIT 0 terlepas dari besarnya elevasi.
- `share_format.dart` & `sektor_card.dart`: kartu share menampilkan `—` saat `gritScore == 0` (dan label `/100` disembunyikan di kartu sektor bila 0).
- `data_actions.dart` & `settings_screen.dart`: ditambahkan tombol "HITUNG ULANG SEMUA AKTIVITAS" di Pengaturan → Data dengan dialog konfirmasi, progres `n/total`, dan pemanggilan `ActivityFinalizer(db).finalize(id)` untuk seluruh aktivitas berstatus `completed`.
- `stats_screen.dart`: `fitnessTimelineProvider` menambahkan titik awal 7 hari sebelum aktivitas pertama (`dayKey(first - 7d): 0`) sehingga grafik kebugaran selalu memiliki minimal 8 titik (mencegah grafik kosong saat baru 1 aktivitas).
- Ditambahkan unit test di `test/analytics/analyzer_test.dart` (validasi GRIT 0 pada aspal 100%) dan `test/analytics/fitness_and_helpers_test.dart` (validasi lead-in ≥8 hari).
- Analyze clean, 186/186 tes lolos.

### 2026-11-07 — v2.1 T6 Mode lari jelas, persistensi olahraga & sembunyikan sektor kosong ✅
- `recording_controller.dart`: `selectSport(sport)` menyimpan pilihan secara asinkron ke DB `settings` via `RecordingSettings.keyDefaultSport` sehingga pilihan olahraga terakhir diingat antar-sesi.
- `recording_screen.dart`: ditambahkan strip horizontal pilihan olahraga (`_SportStrip`) saat idle dengan 7 olahraga utama (GRAVEL, ROAD, MTB, LARI, TRAIL, HIKING, JALAN) menggunakan styling Field Notes (`FN.paper`, `FN.ink`, `FN.surface`).
- `recording_screen.dart`, `activity_detail_screen.dart`, & kartu share: diverifikasi penanganan format kecepatan/pace otomatis (`formatSpeedOrPace`, `pacePerKm`), lari menampilkan `/KM` bukan `KM/H`.
- `share_studio_screen.dart`: template `SEKTOR` disembunyikan otomatis jika aktivitas bukan bersepeda atau tidak memiliki sektor kerikil (`data.sport.isCycling && data.sectors.isNotEmpty`); tab dan navigasi PageView disinkronkan.
- Analyze clean, 184/184 tes lolos.

### 2026-11-07 — v2.1 T5 Ekspor video flyover lebih cepat & durasi dinamis ✅
- `flyover_screen.dart`: durasi ekspor terintegrasi dengan `RecapLength` (OTOMATIS sebanding jarak, 15, 30, 60 dtk) dan pilihan resolusi dinamis 720P (default) / 1080P.
- Pemanasan tile (`exportWarmup`): JS memanaskan ~24 titik kamera di jalur sebelum loop frame untuk memastikan tile PMTiles masuk cache; Dart menampilkan stage `MEMUAT PETA`.
- Pipelining frame: frame i+1 diminta ke MapLibre sebelum frame i selesai di-encode ke MP4 (maksimal 1 frame in-flight).
- Kualitas JPEG dioptimasi ke 0.85 (dari 0.92).
- Ditambahkan instrumentasi waktu `[flyover-perf]` per 60 frame dan total di akhir.
- UI panel flyover diperbarui dengan baris chip DURASI dan RESOLUSI, serta tombol ekspor berlabel resolusi dinamis.
- Analyze clean, 184/184 tes lolos.

### 2026-11-07 — v2.1 T4 Pilihan durasi video recap ✅
- Ditambahkan enum `RecapLength` di `share_options.dart` (OTOMATIS, 15 DTK, 30 DTK, 60 DTK) dengan formula sebanding jarak rute (`clamp(10, 55)` dtk + 4 dtk intro/outro).
- `share_studio_screen.dart`: ditambahkan row pilihan DURASI dan VIDEO (resolusi 720P/1080P), teks petunjuk kecepatan (mis. `14 DTK · 1 DTK ≈ 150 M`), dan integrasi ke `RecapTimeline`.
- Ditambahkan unit test baru di `test/share/recap_length_test.dart` (validasi skala OTOMATIS jarak 2–500km dan durasi frame timeline).
- Analyze clean, 184/184 tes lolos.

### 2026-11-07 — v2.1 T3 Render video recap lebih cepat ✅
- T3.1: Ditambahkan instrumentasi `[recap-perf]` mengukur paint+raster, bytes extraction, dan encode time per frame serta ringkasan total di `recap_video_renderer.dart`.
- T3.2: Cache layer statis via `_bake()`: latar kontur (`_bgPaper`, `_bgScene`) dan film grain (`_grainIntro`, `_grainRoute`, `_grainOutro`) dirender satu kali di `prepare()` dan digambar via `_drawCached()` tiap frame; di-dispose di `dispose()`.
- T3.3: Pipelining render & encode: frame berikutnya dirender paralel saat frame sebelumnya sedang di-encode (inFlight buffer maksimal 1 frame).
- T3.4: Optimasi Kotlin `Mp4Encoder.kt`: konversi RGBA→YUV multi-threaded (fixed thread pool per pita baris chroma), penulisan Y plane baris massal (`put(yArr, offset, w)`), dan `pool.shutdown()` di `release()`.
- T3.5: Default resolusi video diubah ke 720P (`_hd = false`) di `share_studio_screen.dart` (~2.25x lebih sedikit piksel).
- Analyze clean, 180/180 tes lolos.

### 2026-11-07 — v2.1 T2 Flyover safety & error handling ✅
- `flyover_screen.dart`: ditambahkan timeout 20 detik pada `_planInIsolate(samples)`, error ditangkap ke state `_planError`.
- Ditambahkan log `[flyover-perf] plan N titik: M ms`.
- Ditambahkan UI state error `_errorPlan` dengan judul 'GAGAL MENYIAPKAN FLYOVER', pesan detail, dan tombol `StampChip` 'COBA LAGI' untuk reset state.
- Ditampilkan pesan 'RUTE TERLALU PENDEK UNTUK FLYOVER' bila `plan.isEmpty` (< 2 titik).
- Ditambahkan unit test di `test/maps/flyover_plan_test.dart`: memastikan `buildFlyoverPlan(demoGravelRide())` selesai < 3s dan tidak kosong.
- Analyze clean, 180/180 tes lolos.

### 2026-11-07 — v2.1 T1 Hapus visual stempel ✅
- Dibuat `MarkLabel` (blok solid / garis kiri datar) di `lib/core/widgets/mark_label.dart` dan diekspor via `field_kit.dart`.
- Dihapus `RotatedStamp` dari `stamp_chip.dart`.
- `activity_detail_screen.dart`: GRIT diubah menjadi `StatBlock` di grid statistik ringkasan, `Stack` pembungkus diganti langsung dengan `StatGrid`.
- `stats_screen.dart`: status form (NETRAL, dsb.) dan badge `PR` diganti `MarkLabel`.
- `card_parts.dart`: dihapus `Stamp`, diganti `CardNote` datar dengan aksen garis vertikal kiri.
- `field_notes_card.dart` & `foto_card.dart`: semua `Stamp` diganti `CardNote` tanpa rotasi.
- `sektor_card.dart`: dihapus `_GritSeal`, diganti `Column` lurus berisi `MonoLabel('GRIT')` + nomor besar + `MonoLabel('/100')`.
- `recap_video_renderer.dart`: dihapus `_stamp` dan `_easeOutBack`, dibuat `_note` (rata kiri bergaris aksen), outro diubah dari "SELESAI." miring menjadi "FINIS" datar, polaroid foto tegak (angle 0, tanpa pop scale).
- Aturan visual stempel ditambahkan ke `docs/BUILD_CONTRACT_V2.md`.
- Analyze clean, 179/179 tes lolos.

### 2026-11-07 — v2.1 T0 baseline
- Lingkungan: Infinix X6853 (Android 16), build release `app-release.apk` (71.9 MB).
- Status awal: analyze clean, 179/179 test lolos.
- Baseline pencatatan awal (target optimasi di T3/T5):
  - Recap 1080P (540 frames, 18 dtk): render lama (RGBA->YUV single thread + unbaked static layers).
  - Recap 720P: belum default.
  - Flyover 3D: ekspor 1080P (600 frames, 20 dtk): tile loading bottleneck.

### 2026-11-07 — Integration ✅
- Detail-screen map colour toggle (KECEPATAN/TANJAKAN/PERMUKAAN) now reaches `RouteMapView` (`Integrations.routeMap(colorMode:)`).
- `ActivityFinalizer`: gear odometer is now recomputed from completed activities (`syncGearDistance`) instead of incremented → no double counting on re-finalize; edit sheet resyncs the previous gear when gear changes.
- `kotlin.incremental=false` in `android/gradle.properties` (pub cache on C:, project on D: broke Kotlin incremental caches — noisy but harmless).
- `flutter analyze` clean · `flutter test` 179/179 · `flutter build apk --debug` ✅.
- **Device checklist**: screen-off GPS + OEM battery killers, barometer elevation, surface-vibration thresholds, id-ID TTS, WebView MapLibre + 3D terrain with imported PMTiles, MP4 encoder speed, WA/IG share sheet.

### 2026-11-07 — Modul C: UI ✅
- Field Notes theme (paper/night), widget kit, home shell, journal, activity detail (map colour modes, splits, climbs, gravel sectors, best efforts), stats/fitness, profile, gear garage, settings, data actions (import/export/backup). Cross-module access via `Integrations` (live vs. placeholder for tests).

### 2026-11-07 — Integrator: Android build fix
- `permission_handler_android` 14.1.1 requires AGP 9 + compileSdk 37 → pinned `permission_handler: ^12.0.1` (android 13.0.1). Same API.

### 2026-11-07 — Modul D: Share & Video ✅
- 6 original templates × 3 formats (Story 1080×1920, Feed 1080×1350, Square 1080×1080): FIELD NOTES, SEKTOR, PROFIL, NIGHT INK, STICKER (transparent PNG for IG overlay), FOTO.
- Shared painters: cos(lat)-corrected route fitting, procedural contours, film grain, 2.5D Topo-Ink renderer (elevation ribbon + hatch curtain, rotating camera, tracer).
- `ShareStudioScreen`: template swipe, format/stat/accent/photo pickers, share PNG via share sheet (WA/IG), save, build video.
- Recap video: 540 frames (18 s @30fps) intro → animated route + HUD + photo pop-ups + sector stamps → outro; Kotlin `Mp4Encoder` (MediaCodec H.264, YUV420Flexible, BT.601, HandlerThread) via `stravo/video_encoder` channel.
- 30/30 tests pass. Needs device validation (encoder, share sheet).

### 2026-11-07 — Modul B: Analytics & IO ✅
- Full `ActivityAnalyzer`: smoothed elevation (median5+MA7, 3 m hysteresis), Minetti GAP, per-km splits, climb detection + category + VAM, cycling power (surface Crr, CdA .40) + NP, Banister TRIMP / IF²-based load, HR zones, gravel sectors with ★ and Indonesian names, Grit Score, best efforts, ≤600-pt series.
- Fitness timeline (CTL 42d / ATL 7d / TSB), Riegel race predictor, heatmap grid, segment matcher + live ghost tracker.
- Import GPX/TCX/FIT (own binary decoder)/.gz/Strava bulk-export ZIP with dedupe; export GPX 1.1 (+Garmin TPX) & TCX; zip backup + staged restore (`applyPendingRestore()` before DB open).
- Contract additions: `ActivityAnalysis.normalizedPowerW`, `AthleteParams.ftpW`.
- 48/48 tests pass.

### 2026-11-07 — Modul A: Tracking ✅
- GPS pipeline: accuracy/teleport gate, Kalman smoothing, haversine distance, barometer-fused elevation with hysteresis, grade, per-sport auto-pause; real (geolocator foreground service + wakelock) and simulated sources (`use_simulated_gps`, `sim_speedup`).
- Vibration surface classifier (handlebar/pocket mount, calibration, speed-normalised, majority smoothing).
- `RecordingController` + night-style `RecordingScreen` (hold-to-stop, camera waypoint photos, live map), crash-recovery prompt, permissions + OEM battery tips, Indonesian TTS split cues.
- **Bug fix**: `IncrementalFlushEngine` no longer overwrites description/gear/favorite on every flush; flushes serialised.
- Manifest: location FGS, notifications, camera, BLE, INTERNET + cleartext for localhost map server.
- 43/43 tests pass. Needs device validation (screen-off GPS, MIUI/ColorOS killers, barometer, surface thresholds, id-ID TTS).

### 2026-11-07 — Modul E: Maps ✅
- `LocalTileServer` on 127.0.0.1 (Range/HEAD/206/416, path sanitising, token-protected frame upload).
- Map packs: PMTiles v3 header parsing, basemap vs DEM detection, import/delete/activate, Indonesian how-to (Protomaps `pmtiles extract`, AWS Terrarium DEM).
- MapLibre Field Notes style (Protomaps v4 + OpenFreeMap fallback), dashed unpaved roads, hillshade + terrain, no labels.
- `RouteMapView` (plain/speed/grade/surface, live append throttled), painter fallback without WebView.
- 3D Flyover: camera plan in Dart (Catmull-Rom, smoothed bearing, adaptive zoom, summit orbit), HUD, 1–8× speed, scrub; MP4 export 1080×1920 @30fps via VideoEncoder.
- 48/48 tests pass. Needs real-device validation (WebView, terrain, export speed).

### 2026-11-07 — Foundation (integrator)
- Added plugins: geolocator, flutter_foreground_task, sensors_plus, flutter_tts, permission_handler, wakelock_plus, share_plus, webview_flutter, file_picker, xml, image_picker, flutter_blue_plus, archive, intl.
- Bundled fonts (Anton, IBM Plex Mono, IBM Plex Sans) and MapLibre GL JS 5.24 + pmtiles.js 4 into `assets/` for fully offline use.
- Shared contracts: `TrackSample`, `ActivityAnalysis` models, `ActivityAnalyzer` (stub), `ActivityRepository`/`activityBundleProvider`, `ActivityFinalizer`, `FN` design tokens.
- DB schema v2: analysis summary columns on `activities`, new `segments`, `segment_efforts`, `app_settings` tables + migration.
- `flutter analyze` clean, 7/7 tests pass.
