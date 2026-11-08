# Panduan Mulai Virya

Kalau kamu baru bergabung, mulai dari sini. Dokumen ini menjelaskan aplikasinya, status pengerjaan,
cara menjalankan, dan cara ikut mengerjakan.

## 1. Virya itu apa

Virya adalah aplikasi pribadi untuk membangun konsistensi: olahraga GPS, gym, tugas harian, batas
waktu aplikasi, dan progres tubuh dalam satu tempat. **Semua data disimpan di HP. Tidak ada akun
dan tidak ada server.**

Dulu namanya Stravo, jadi kamu masih akan melihat nama itu di folder repo, log lama, dan file
database `stravo_local.sqlite`. Nama file database itu **jangan diubah**, karena dipakai backup.

Teknologi: Flutter, Riverpod (state), Drift (SQLite), Kotlin untuk fitur khusus Android.

## 2. Dokumen mana untuk apa

| Dokumen | Isi | Kapan dibaca |
|---|---|---|
| `docs/PANDUAN.md` | Dokumen ini | Pertama kali |
| [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) | **Aturan wajib** menulis kode | Sebelum mengedit apa pun |
| [`docs/ROADMAP.md`](ROADMAP.md) | Rancangan tiap modul dan relasi data | Sebelum mengerjakan modul |
| [`docs/PROGRESS.md`](PROGRESS.md) | Papan status dan log apa saja yang sudah dikerjakan | Untuk tahu detail pekerjaan lama |
| `docs/PRD_STRAVO_PRO_OFFLINE.md` | Dokumen kebutuhan awal (zaman Stravo) | Hanya sebagai latar belakang |

## 3. Status fase

Fase dikerjakan berurutan. Status terbaru selalu ada di papan status `docs/PROGRESS.md`.

| Fase | Isi | Status |
|---|---|---|
| Fondasi | Rekam GPS, analitik, impor/ekspor, UI dasar, kartu & video share, peta offline, flyover 3D | Selesai |
| 2 | Rename ke Virya, arsitektur modular, token tema | Selesai |
| 3 | Logo, layar Hari Ini, navigasi baru, kalender, peta gabungan | Selesai |
| 4 | Gym: gerakan, set, template, PR | Selesai |
| 5 | Tugas, widget layar utama, catat cepat dari notifikasi | Selesai |
| 6 | Fokus: batas waktu harian per aplikasi (khusus Android) | Selesai |
| 7 | Progres tubuh: foto berkala, perbandingan, timelapse | Selesai |
| 8 | Mode style: pilihan tampilan | Selesai |
| Wave 2 | Segmen live + ghost pacer, heatmap pribadi, sensor detak jantung BLE | Belum |

Di log lama ada kode seperti "Modul A–E", "v2.1", dan "T1–T8". Itu nama tahap pengerjaan Fondasi.

Fase 1–8 sudah lulus tes otomatis, tetapi **banyak fitur Android belum diuji di HP sungguhan**.
Daftarnya ada di bagian 8, dan ini tempat yang bagus untuk mulai membantu.

## 4. Menjalankan proyek

Yang dibutuhkan: Flutter 3.38 (stable), Android SDK, dan HP Android dengan USB debugging. GPS,
widget, notifikasi, dan encoder video tidak bisa diuji dengan baik tanpa HP sungguhan.

```bash
git clone https://github.com/AbdurRouf05/virya.git
cd virya
flutter pub get
flutter run
```

File `*.g.dart` sudah ikut di repo. Build ulang hanya kalau kamu mengubah tabel atau DAO database:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 5. Alur kerja

1. Ambil versi terbaru `main`, lalu buat branch sendiri: `git switch -c fitur/nama-singkat`.
2. Kerjakan, sambil mengikuti `docs/ARCHITECTURE.md`.
3. Sebelum commit, kedua perintah ini wajib bersih:

   ```bash
   flutter analyze   # harus: No issues found!
   flutter test      # harus: All tests passed!
   ```

4. Tambahkan catatan singkat di `docs/PROGRESS.md` (entri terbaru di atas).
5. Push branch-mu dan buka Pull Request ke `main`. Jangan push langsung ke `main`.

Format pesan commit: `feat: ...`, `fix: ...`, `refactor: ...`, `docs: ...`, dalam bahasa Indonesia.

## 6. Peta kode singkat

```
lib/
  app/        Perekat aplikasi: tema, pengaturan, Integrations
  core/       Kode bersama: database, analitik, widget dasar
  features/   Satu folder per modul: today, calendar, gym, tasks, recording, ...
  services/   Layanan tanpa UI: ekspor/impor, audio
android/app/src/main/kotlin/com/abdurrouf/virya/   Kode native
test/         Tes, foldernya mengikuti nama modul
```

Isi setiap folder modul selalu sama:

| Folder | Isi | Boleh tahu soal |
|---|---|---|
| `domain/` | Model dan logika murni | Dart saja |
| `data/` | Repository, provider, akses DB | `domain/`, `core/` |
| `application/` | Controller dan aksi | `data/`, `domain/` |
| `presentation/` | Layar dan widget | Semua di atas |

Modul tidak boleh mengimpor file internal modul lain. Kalau butuh layar dari modul lain, tambahkan
method di `lib/app/integrations.dart` (lihat `ARCHITECTURE.md` bagian 4).

**Contoh modul yang paling lengkap: `lib/features/tasks/`.** Tirulah strukturnya untuk modul baru.

## 7. Aturan yang paling sering terlewat

- Maksimal **300 baris per file**, dan satu widget publik per file.
- Warna dan font hanya dari `FN.*`. Jangan tulis `Color(0x...)` di fitur, dan jangan pakai `FN.*`
  di dalam ekspresi `const`.
- **Jangan pakai visual stempel atau label miring**, baik di UI maupun di video.
- Teks yang dilihat pengguna memakai bahasa Indonesia.
- Mengubah skema database berarti: naikkan `schemaVersion`, tambah langkah migrasi, jalankan
  `build_runner`, tambah tes migrasi.
- Jangan menjalankan dua `flutter test` bersamaan, karena DLL sqlite bentrok.

### Jebakan yang sudah pernah kejadian

- Versi `drift`, `permission_handler`, dan override `sqlite3` di `pubspec.yaml` sengaja dikunci.
  Jangan dinaikkan tanpa mengecek build Android.
- `build.yaml` membatasi `drift_dev` ke `lib/core/database/**`. Jangan dihapus.
- `kotlin.incremental=false` di `android/gradle.properties` sengaja dimatikan, karena cache Kotlin
  rusak bila pub cache dan proyek ada di drive berbeda.
- Kode native **tidak boleh menulis ke SQLite**. Native menaruh perubahan di antrean
  SharedPreferences, lalu Dart yang menerapkannya saat aplikasi aktif. Contohnya `TaskStore.kt` dan
  `task_inbox_sync.dart`.
- Tanggal tanpa jam (seperti jatuh tempo tugas) disimpan sebagai teks `YYYY-MM-DD`. Waktu lain
  disimpan UTC.

## 8. Daftar uji di HP

Centang di PR atau catat di `docs/PROGRESS.md` kalau sudah dicoba.

**Tugas**
- [ ] Pasang widget, lalu centang tugas saat aplikasi tertutup
- [ ] Balas lewat notifikasi catat cepat saat aplikasi tertutup, lalu buka aplikasi: tugas masuk sekali
- [ ] Ubin Quick Settings "Catat tugas" dan pintasan tekan lama ikon membuka lembar catat cepat
- [ ] Restart HP: notifikasi catat cepat muncul lagi

**Fokus**
- [ ] Izin Akses Penggunaan dan Aksesibilitas terdeteksi setelah kembali dari Pengaturan. APK di luar
  Play Store perlu "Izinkan setelan terbatas" di Info aplikasi (Android 13+)
- [ ] Aplikasi tertutup tepat saat kuota habis, baik saat sedang dipakai maupun saat baru dibuka
- [ ] Layar "Waktu habis" muncul di atas layar utama, termasuk di Xiaomi, Oppo, Infinix
- [ ] "Tambah 5 menit" hanya bisa sekali per aplikasi per hari
- [ ] Jumlah menit cocok dengan Digital Wellbeing, termasuk sesi yang melewati tengah malam

**Progres tubuh**
- [ ] Izin kamera diminta saat pertama, dan layar pesan muncul kalau izin ditolak
- [ ] Pratinjau tidak gepeng di kotak 3:4, dan foto hasil sama dengan pratinjau
- [ ] Bayangan foto lama sejajar dengan pratinjau; orientasi foto benar
- [ ] Ganti kamera depan/belakang; keluar dan masuk aplikasi saat kamera terbuka; HP dimiringkan
- [ ] Geser slider sebelum/sesudah terasa lancar
- [ ] Video timelapse jadi, bisa dibatalkan, dan bisa dibagikan
- [ ] Foto tidak muncul di galeri, dan kembali utuh setelah backup lalu restore

**Mode style**
- [ ] Ganti style di Pengaturan → Tampilan: seluruh aplikasi berubah dan pilihan tetap setelah aplikasi ditutup
- [ ] Style Malam: buka semua tab, layar rekam, gym, kalender, izin; tidak ada teks yang hilang
- [ ] Ikon status bar terang di Malam dan gelap di style terang
- [ ] Kartu dan video share tetap Field Notes di style apa pun
- [ ] Ganti style saat sesi gym berjalan: sesinya tidak hilang

**Gym**
- [ ] Sesi penuh sampai selesai, timer istirahat berjalan
- [ ] Tutup paksa aplikasi saat sesi berjalan, lalu sesi bisa dilanjutkan

**Rekam GPS**
- [ ] Merekam dengan layar mati, termasuk di HP yang agresif menutup aplikasi (Xiaomi, Oppo, Infinix)
- [ ] Elevasi barometer, deteksi permukaan, suara panduan bahasa Indonesia

**Peta dan share**
- [ ] Peta online, unduh wilayah, lalu pakai tanpa internet
- [ ] Flyover 3D dan ekspor video
- [ ] Video recap, bagikan ke WhatsApp dan Instagram
