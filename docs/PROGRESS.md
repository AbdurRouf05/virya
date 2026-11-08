# Virya — Progress Log

Newest entries on top. Baru bergabung? Mulai dari [PANDUAN.md](PANDUAN.md). Aturan kode: [ARCHITECTURE.md](ARCHITECTURE.md).

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

### 2026-11-08 — Wave 2 dan sisa kecil ✅
- **Segmen live + ghost** (`features/segments`): buat segmen dari rute di detail aktivitas, upaya lama langsung dicari, upaya baru dicocokkan tiap aktivitas selesai direkam, diimpor, atau dihitung ulang. HUD dan suara di layar rekam (mendekat, dimulai, selisih ghost tiap 30 detik, hasil akhir). Masuk dari ikon bendera di Jurnal dan bagian Segmen di detail aktivitas. HUD dan suara selalu memakai meter walau setelan imperial aktif.
- **Heatmap pribadi** (`features/heatmap`): layer `heat` di MapLibre, filter Semua/Sepeda/Lari/Jalan, dihitung di luar UI thread, maksimal 40.000 titik. Masuk dari tab Statistik. Hanya 2D; versi 3D dari PRD tidak dibuat.
- **Sensor detak jantung BLE** (`core/sensors`, `features/sensors`): pindai, sambung, simpan sensor terakhir, sambung ulang otomatis, bpm masuk ke track point. Pengaturan → Perekaman → Sensor detak jantung. Sensor speed/cadence belum dikerjakan. `flutter_blue_plus` memakai `License.nonprofit`, dan lisensinya menyebut "ping" saat build (nama paket, nama dan versi aplikasi, versi paket, tanggal), bukan saat aplikasi berjalan. Build rilis butuh `android/app/proguard-rules.pro`.
- **Sisa kecil:** judul kartu latihan di Hari Ini aman di layar sempit; jadwal pengingat foto tubuh 7/14/30 hari atau mati; warna zona detak jantung, layar "Waktu habis", dan widget tugas mengikuti style (channel `virya/style`).
- Audit ROADMAP bagian 2 dan 4: tidak ada butir besar yang hilang. Belum ada: gelembung mengambang (opsional). Beda dari rancangan: riwayat Fokus hanya di detail hari, bukan tanda di kotak kalender; widget juga menampilkan tugas jatuh tempo; intensitas kalender hanya dari durasi.
- Tes yang memompa `HomeShell`: macetnya artefak urutan penutupan. Urutan yang benar: `container.dispose()`, `tester.pump()`, lalu `tester.runAsync(db.close)`.
- Verifikasi: analyze bersih, 534 tes lulus, APK rilis arm64 dan armeabi-v7a berhasil. Belum diuji di HP; sensor BLE asli, GPS, dan WebView heatmap hanya teruji lewat tes dengan pengganti palsu. Daftarnya di `PANDUAN.md` bagian 8.

### 2026-11-08 — Fase 8: Mode style ✅
- Tiga style baru selain Field Notes: **Malam** (gelap), **Cetak Biru**, **Hutan**. Semuanya memakai font yang sudah ada di aplikasi. Daftarnya di `lib/app/theme/styles/styles.dart`; id yang tidak dikenal jatuh ke Field Notes.
- Token baru `FN.onNight`, `FN.onNightMuted`, `FN.onAccent`, `FN.isDark`, dan `FN.onInk(accent)`, supaya teks di atas foto, peta, dan warna aksen tetap terbaca di style gelap. Nilainya sama dengan warna lama di Field Notes, jadi tampilan Field Notes tidak berubah. Aturan pakainya di `ARCHITECTURE.md` bagian 5.
- `FNExport` selalu Field Notes. Dipakai oleh kartu share, video recap, timelapse, dan warna rute di peta dasar yang tetap krem.
- Pilihan ada di Pengaturan → Tampilan (`StylePicker`), tersimpan di setting `style_id`, dan dibaca sebelum `runApp` supaya tidak berkedip saat aplikasi dibuka.
- `MaterialApp` memakai `ValueKey(style.id)`, karena banyak widget `const` membaca `FN.*`. Akibatnya, setelah ganti style aplikasi kembali ke beranda; state Riverpod tetap ada.
- Splash native tidak mengikuti style, karena digambar sebelum kode aplikasi berjalan.
- Tes rebuild memakai `ViryaApp(home: Scaffold())`. Sisa pekerjaan dan penjelasan tes `HomeShell` ada di entri Wave 2 di atas.
- Verifikasi: analyze bersih, 445 tes lulus, APK debug berhasil. Belum diuji di HP; daftarnya di `PANDUAN.md` bagian 8.

### 2026-11-08 — Fase 7: Progres tubuh ✅
- **Skema DB v6**: tabel `body_checkins` (satu check-in per hari, `day` berupa `YYYY-MM-DD`) dan `body_photos` (cascade dari check-in, satu foto per pose), migrasi 5→6, `BodyDao`.
- `features/body`: layar PROGRES TUBUH (grafik berat, grid foto per tanggal), form check-in (3 pose, 5 ukuran, catatan), kamera dengan bayangan foto sebelumnya, slider sebelum/sesudah, dan video timelapse 720x960 yang bisa dibagikan.
- Foto disimpan di `photos/body/` dalam folder dokumen aplikasi, jadi tidak masuk galeri dan ikut backup. Database menyimpan path relatif supaya restore di HP lain tetap jalan. Video timelapse dibuat di folder sementara dan dihapus saat dialog ditutup.
- Pratinjau, bayangan, tampilan foto, dan timelapse semuanya memakai potongan tengah 3:4, supaya posisi tetap sejajar walau rasio kamera berbeda.
- Pengingat di Hari Ini muncul 7 hari setelah check-in terakhir (konstanta, belum ada pengaturan) dan hanya bila sudah pernah check-in.
- Titik masuk: tombol FOTO TUBUH di lembar "MAU NGAPAIN?", seksi Progres tubuh di Profil, kartu pengingat di Hari Ini, dan detail hari kalender.
- `video_encoder.dart` pindah dari `features/share/video/` ke `core/video/` karena dipakai dua modul. Paket baru: `camera`.
- Verifikasi: analyze bersih, 406 tes lulus, APK debug berhasil. Kamera dan encoder belum diuji di HP; daftarnya di `PANDUAN.md` bagian 8.

### 2026-11-08 — Fase 6: Fokus ✅
- **Skema DB v5**: tabel `app_limits` dan `app_usage_days`, migrasi 4→5, `FocusDao`. Riwayat ikut menyimpan nama dan batas yang berlaku saat itu, jadi tetap benar setelah batasnya diubah atau dihapus. Pemakaian sebelum batas dibuat tidak dicatat.
- `features/focus`: layar FOKUS (izin, daftar batas, pilih aplikasi, atur menit), kartu Fokus di Hari Ini setelah Tugas, pemakaian per aplikasi di detail hari kalender. `FocusHost` menyinkronkan saat aplikasi aktif dan tiap 60 detik.
- Native `android/.../focus/`, channel `virya/focus`: pemakaian dihitung dari event `UsageStatsManager` per hari lokal; `FocusAccessibilityService` menutup aplikasi saat kuota habis dan membuka layar "Waktu habis" dengan +5 menit (1× per aplikasi per hari). Native tidak menulis ke SQLite.
- Belum ada: titik penanda di sel grid kalender (indikator baru ada di detail hari).
- Verifikasi: analyze bersih, 346 tes lulus, APK debug berhasil. Belum diuji di HP; daftarnya di `PANDUAN.md` bagian 8.

### 2026-11-08 — Fase 5: Tugas ✅
- **Skema DB v4**: tabel `tasks` + indeks `done_at`, migrasi 3→4, `TasksDao`. Jatuh tempo disimpan sebagai teks `YYYY-MM-DD` agar tidak bergeser saat zona waktu berubah.
- `features/tasks`: layar TUGAS (kolom ketik di atas, seksi Hari ini · Nanti · Selesai), lembar catat cepat, lembar edit (catatan, tanggal, penting, pin, hapus), centang dengan BATAL. Tugas di-pin selalu tampil di Hari Ini dan widget; tugas terlambat tetap di Hari ini.
- Titik masuk: kartu tugas di atas LATIHAN HARI INI, tombol TUGAS BARU di lembar "MAU NGAPAIN?", dan tugas selesai di detail hari kalender. `TodayCard` pindah ke `core/widgets/`.
- Android (`kotlin/.../tasks/`, channel `virya/tasks`): widget layar utama yang bisa dicentang, notifikasi permanen dengan kolom balas (aktif lewat toggle, muncul lagi setelah reboot), ubin Quick Settings "Catat tugas", pintasan ikon aplikasi.
- **Sinkronisasi**: native tidak menulis ke SQLite. Perubahan masuk antrean SharedPreferences, lalu `TaskInboxSync` membaca → menerapkan → mengonfirmasi saat aplikasi aktif; penerapan idempoten sehingga tidak ada tugas ganda. Widget menampilkan snapshot − selesai tertunda + tangkapan tertunda.
- Belum dikerjakan dari rancangan: `task_reminders` (pengingat) dan gelembung mengambang (opsional).
- `flutter analyze` bersih, 305 tes lulus, `flutter build apk --debug` berhasil. Fitur Android belum diuji di perangkat: widget, balas notifikasi, ubin, pintasan, reboot.

### 2026-11-08 — Fase 4: Gym ✅
- **Skema DB v3**: tabel `exercises`, `workout_sets` (cascade dari `activities`), `workout_templates`, `workout_template_items` (cascade dari template) + indeks; migrasi 2→3 membuat tabel & men-seed 44 gerakan bawaan (`core/database/seed/exercise_library.dart`). `GymDao` di `core/database/daos/gym_dao.dart`. Backup tetap menyalin file sqlite utuh, jadi tabel baru ikut otomatis.
- Sesi gym = baris `activities` dengan `sportType: strength` (jarak 0, durasi = mulai→selesai). `SportType.strength` (label GYM, kategori kekuatan); `isGps` / `SportType.gps` memisahkan olahraga GPS. Pemulihan rekaman GPS & finalizer mengabaikan gym.
- `features/gym`: sesi berjalan (header durasi live, tabel set kg/reps/RPE opsional, "sblm 60×8", pemanasan, centang → timer istirahat 90 d −15/+15/lewati, SELESAI LATIHAN, buang sesi), draf tersimpan per perubahan sehingga selamat dari app ditutup paksa. Pemilih gerakan (cari + otot + gerakan kustom), template (buat/ubah/urutkan/hapus, simpan dari sesi selesai), riwayat & PR per gerakan (beban maks, e1RM Epley, set volume terbaik), volume mingguan, otot yang terlewat 7/14 hari.
- Titik masuk: lembar "MAU NGAPAIN?" → MULAI GYM; tab LATIHAN → GYM. Detail aktivitas gym (tanpa peta/ekspor) lewat `Integrations.gymSessionDetail`; jurnal punya filter GYM dan menampilkan durasi untuk gym.
- `build.yaml` baru: drift_dev hanya untuk `lib/core/database/**` (analyzer drift_dev 2.24 gagal membaca dot-shorthand di `win32 6.4.0`).
- Tes: `test/gym/` (matematika, DAO in-memory, migrasi 2→3) — 22/22 lulus.

### 2026-11-08 — Fase 3: logo, Hari Ini, kalender, navigasi ✅
- Logo **Streak Sel** (sel heatmap membentuk V, sel terakhir oranye). Kit di `assets/branding/`, generator `design/logo/build_kit.py`. Ikon Android adaptif + bulat + monokrom (Android 13), splash Android 12+/lama, ikon & launch screen iOS. Widget `ViryaMark` (`lib/core/widgets/virya_mark.dart`).
- Navigasi baru: HARI INI · KALENDER · [REKAM] · LATIHAN · PROFIL. Tombol tengah membuka lembar "MAU NGAPAIN?" (Rekam GPS aktif; Gym/Tugas/Foto tubuh menyusul). Tab PETA dihapus; peta offline pindah ke Pengaturan.
- `features/today`: tanggal, latihan hari ini + streak, strip 7 hari per kategori, aktivitas terakhir.
- `features/calendar`: heatmap tahun + grid bulan, warna per kategori, hari campuran terbelah, filter, streak, % hari aktif, detail hari. Provider publik `calendarDaysProvider`, `calendarStatsProvider(filter)`.
- `features/training`: tab LATIHAN = JURNAL · STATISTIK (layar tertanam tanpa judul ganda, `Masthead.title` kini opsional).
- Kategori olahraga bersama: `core/constants/sport_category.dart` + `FN.category(cat)` (warna di `Palette.category`).
- `core/time/current_day.dart`: `currentDayProvider` berganti saat tengah malam / app dibuka lagi.
- `Integrations.activityDetail(id)` untuk membuka detail aktivitas dari modul lain.
- **Peta gabungan**: peta online (OpenFreeMap) langsung jalan tanpa setup lewat server lokal `/tiles/` (urutan: wilayah terunduh → cache → internet). Cache tile 500 MB (LRU). "Unduh wilayah" di aplikasi: kotak 10–100 km di sekitar posisi GPS, zoom 5–14, estimasi ukuran, maks 30.000 tile, bisa dilanjutkan. Impor .pmtiles + panduan dipindah ke "Lanjutan". Layar bernama "PETA OFFLINE", dibuka dari Pengaturan.

### 2026-11-08 — Audit Kinerja, Pengamanan, & Fase 3 (Layar Hari Ini + Navigasi Baru) ✅
- **Optimasi & Bug Fix (Paket A-D)**:
  - Repository: `delete(activityId)` kini membersihkan file foto fisik di disk; profil atlet `ftpW` diteruskan ke `finalize()`; `activityBundleProvider` diubah ke `autoDispose` dengan keepAlive 30 detik.
  - Encoder Android: perbaikan memory churn di `Mp4Encoder.kt` (reused direct `ByteBuffer`, memotong ~5 GB alokasi heap selama 600 frame); pembatalan `enc.cancel()` saat thread pool gagal running.
  - Branding & Watermark: `'STRAVO // FLYOVER'` diubah menjadi `'VIRYA // FLYOVER'`.
  - Storage & share: pembersihan otomatis file ekspor dan video share lama (`_pruneOldFiles`, simpan maks 20 kartu / 10 video).
  - Keamanan: cegah ZipSlip saat backup restore menggunakan verifikasi path kanonikal (`isWithin`); nonaktifkan cleartext HTTP global di Android via `network_security_config.xml` (hanya loopback `127.0.0.1` dan `localhost` diizinkan); CSP ketat pada `map.html`; pembatasan CORS tile server lokal; sanitasi nama fungsi JavaScript di `virya_map_controller`; proteksi XML DTD/external entity di GPX/TCX codec; batas 100 MB impor file.
  - Database & Cache: SQLite index `idx_activities_status_start` untuk querying riwayat; caching rute di `recording_session.dart`; `autoDispose` 3 menit keepAlive pada `routeThumbProvider`.
  - Android release: `isMinifyEnabled = true`, `isShrinkResources = true`, dan ProGuard rules.
  - Dead code: pembersihan `cupertino_icons`, `flutter_foreground_task`, direktori asset kosong, enum tak terpakai, dan unused providers.
- **Fase 3: Layar Hari Ini + Navigasi Baru**:
  - `lib/features/today/presentation/today_screen.dart` & `widgets/today_cards.dart`: Sapaan harian dinamis, status kebugaran TSB, latihan hari ini / quick start, mini heatmap mingguan 7 hari, to-do list harian interaktif (persisten di `AppSettings`), dan limit waktu aplikasi.
  - `lib/features/calendar/presentation/calendar_screen.dart`: Kalender aktivitas multi-olahraga dengan 24-minggu `CalendarHeatStrip`, filter chip kategori, pemilih hari, dan daftar aktivitas harian.
  - `lib/features/training/presentation/training_screen.dart`: Hub Latihan terpadu yang menggabungkan Jurnal riwayat dan Statistik kebugaran dengan segmented control.
  - `lib/features/home/presentation/widgets/quick_action_sheet.dart`: Lembar aksi cepat Field Notes dengan 4 tombol: Rekam GPS, Mulai Gym, Catat Tugas Baru, dan Progres Tubuh.
  - `lib/features/home/presentation/home_shell.dart`: Navigasi 5-tab baru `[HARI INI] [KALENDER] (+) [LATIHAN] [PROFIL]`.
  - Profil: Ditambahkan akses langsung ke manajemen paket peta offline (.pmtiles).
  - Tests: Ditambahkan `test/ui/today_and_home_test.dart` menguji `HomeShell`, `TodayScreen`, `TrainingScreen`, dan `CalendarScreen`. Semua file Dart mematuhi batas <= 300 baris.

### 2026-11-08 — Fase 2: Virya, arsitektur modular ✅
- Rename Stravo → **Virya** (package `virya`, Android `com.abdurrouf.virya`, channel `virya/*`). Backup lama (`app: stravo`) tetap bisa di-restore.
- `docs/ARCHITECTURE.md` (aturan folder, maks 300 baris/file, arah dependensi) dan `docs/ROADMAP.md` (modul baru + relasi data).
- Token tema: `FN.*` kini dibaca dari `Palette` aktif (`lib/app/theme/palette.dart`, `styles/`). Tambah token `caution`.
- Semua file besar dipecah: recording, maps/flyover, share/video, activity detail, stats, gear. File terbesar kini 293 baris (sebelumnya 925).
- Tombol rekam baru: lingkaran oranye terangkat, titik putih, efek tekan + haptic.
- Ikon/label impor di Jurnal & Pengaturan diperjelas ("Impor riwayat"). Ekspor GPX/TCX diberi label jelas.
- `flutter analyze` bersih, 186 test lulus.

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
