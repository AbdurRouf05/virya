# Arsitektur Virya

Dokumen ini adalah **aturan wajib** untuk siapa pun yang mengubah kode (manusia maupun AI).
Baca sampai habis sebelum mengedit. Kalau aturan bertentangan dengan kode lama, ikuti aturan
dan rapikan kode lama itu sekalian.

## 1. Peta folder

```
lib/
  main.dart                 Titik masuk. Hanya bootstrap + ProviderScope.
  app/                      Perekat aplikasi (tidak berisi logika fitur).
    virya_app.dart          MaterialApp.
    integrations*.dart      Jembatan antar-modul (lihat §4).
    settings.dart           Pengaturan global (Riverpod).
    format.dart             Format angka/satuan.
    sport_ui.dart           Ikon & label olahraga.
    theme/                  Token warna/huruf + ThemeData (lihat §5).
  core/                     Kode bersama, TIDAK BOLEH import dari features/.
    database/               Drift: tables/, daos/, app_database.dart (+ .g.dart).
    analytics/              Perhitungan murni (tanpa Flutter UI).
    location/ sensors/ permissions/ offline_maps/ backup/ ...
    widgets/                Widget dasar yang dipakai >1 modul.
  features/<modul>/         Satu folder per modul (recording, maps, share, ...).
    domain/                 Model & logika murni Dart. Tanpa import Flutter UI / DB.
    data/                   Repository, provider baca/tulis DB, akses file.
    application/            Controller / Notifier (state + aksi).
    presentation/
      <nama>_screen.dart    Satu layar = satu file.
      widgets/              Bagian-bagian layar (kartu, baris, sheet, painter).
  services/                 Layanan lintas modul tanpa UI (export_import, audio_cues, background).
```

Modul yang direncanakan: `today`, `gym`, `calendar`, `tasks`, `focus`, `body`. Strukturnya sama persis.

## 2. Aturan ukuran file

| Aturan | Batas |
|---|---|
| Panjang file (kecuali `*.g.dart`) | **maks 300 baris**, target ≤ 200 |
| Panjang satu fungsi/method `build` | target ≤ 60 baris; pecah jadi widget |
| Widget publik per file | **1** (widget privat kecil `_Xxx` boleh) |

Bila file melewati batas: pecah bagian visual ke `presentation/widgets/`, logika ke
`application/` atau `domain/`.

## 3. Arah dependensi

```
presentation  →  application  →  data  →  domain
      ↘──────────────↘─────────────↘──→  core/
```

- `domain/` tidak tahu soal Flutter widget, Riverpod, atau database.
- `core/` tidak pernah import `features/`.
- Modul A **tidak** import file internal modul B. Kalau perlu layar/servis modul lain,
  lewat `app/integrations.dart` (layar) atau provider publik di `data/` modul B.

## 4. Integrations (jembatan antar-modul)

`Integrations` (abstrak) dipakai UI untuk membuka layar/servis modul lain.
`LiveIntegrations` dipasang di `main.dart`; `PlaceholderIntegrations` untuk test.
Menambah layar lintas modul = tambah method di keduanya.

## 5. Tema & mode style

- Warna dan huruf **hanya** diambil dari `FN` (`lib/app/theme/field_notes.dart`).
  Dilarang `Color(0x...)` atau nama font langsung di widget fitur.
- Nilai `FN.*` berasal dari `Palette` aktif (`lib/app/theme/palette.dart`).
  Satu style = satu file di `lib/app/theme/styles/`. Menambah style baru = tambah satu file
  dan daftarkan di `styles/styles.dart`. Tidak ada widget yang perlu diubah.
- Karena token bisa berganti saat runtime, `FN.*` **bukan const**: jangan taruh `FN.*`
  di dalam ekspresi `const`.
- Ada style gelap, tempat `paper` menjadi gelap dan `ink` menjadi terang. Pilih token menurut
  apa yang ada **di belakangnya**:

| Di belakang | Teks/ikon |
|---|---|
| Halaman (`FN.paper`) | `FN.ink`, `FN.inkSoft`, `FN.inkMuted` |
| Blok `FN.ink` | `FN.paper`; aksen lewat `FN.onInk(FN.acid)` |
| `FN.night*`, foto, peta, gradasi gelap | `FN.onNight`, `FN.onNightMuted` |
| `FN.signal`, `FN.acid` | `FN.onAccent` (gelap) atau `FN.onNight` (terang) |
| Bayangan, scrim | `FN.onAccent` |

- Kartu, video recap, dan timelapse yang keluar dari aplikasi memakai `FNExport.*`
  (`lib/app/theme/export_tokens.dart`), selalu Field Notes. Rute di atas peta juga, karena
  dasar petanya tetap krem.

## 6. State (Riverpod)

- Provider ditaruh di `data/` (sumber data) atau `application/` (controller).
- Nama: `xxxProvider`. Controller: `XxxController`.
- Widget membaca dengan `ref.watch`, aksi dengan `ref.read(...notifier)`.

## 7. Database (Drift)

- Tabel di `core/database/tables/<nama>_table.dart`, DAO di `core/database/daos/`.
- Setiap perubahan skema: naikkan `schemaVersion`, tambah langkah di `migration`,
  jalankan `dart run build_runner build --delete-conflicting-outputs`, tambah test migrasi.
- ID memakai string (UUID). Waktu disimpan UTC.

## 8. Penamaan

| Jenis | Pola | Contoh |
|---|---|---|
| File | `snake_case.dart` | `journal_screen.dart` |
| Layar | `XxxScreen` di `xxx_screen.dart` | `JournalScreen` |
| Bagian layar | `presentation/widgets/<layar>_<bagian>.dart` | `journal_empty_state.dart` |
| Teks UI | Bahasa Indonesia | `'Rekam aktivitas'` |

## 9. Checklist setelah mengubah kode

```bash
flutter analyze      # wajib: No issues found!
flutter test         # wajib: All tests passed!
```

- Jangan menjalankan dua `flutter test` bersamaan (DLL sqlite bentrok).
- Tambah catatan singkat di `docs/PROGRESS.md`.
