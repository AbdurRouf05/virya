# Rancangan Virya: Modul, Data, dan UX

Status: **rancangan**, untuk ditinjau sebelum fase 4–8 dikerjakan.

## 1. Prinsip

1. **Satu layar pusat: "Hari Ini".** Semua modul menyetor ringkasan ke sini. Pengguna jarang
   perlu masuk ke modul kecuali untuk detail.
2. **Satu kalender untuk semua.** Olahraga GPS, gym, foto tubuh, dan tugas selesai semuanya
   tampil di satu sumbu waktu.
3. **Modul mandiri.** Tiap modul punya tabel, layar, dan provider sendiri. Modul hanya saling
   terhubung lewat `Hari Ini`, kalender, dan `activities.id`.
4. **Cepat dicatat.** Hal yang paling sering dilakukan (catat tugas, mulai gym, rekam) maksimal
   2 ketukan dari mana saja (layar utama, notifikasi, widget).

## 2. Navigasi baru

```
[ HARI INI ]  [ KALENDER ]  ( + )  [ LATIHAN ]  [ PROFIL ]
```

- **( + )**: tombol tengah membuka lembar cepat: Rekam GPS · Mulai Gym · Tugas baru · Foto tubuh.
- **Latihan**: tab berisi Jurnal (riwayat), Statistik, dan Gym (template, gerakan, PR).
- **Profil**: profil, gear, progres tubuh, pengaturan, peta offline (Lanjutan), dan mode style.
- Fokus (batas aplikasi) dan Tugas terlihat di Hari Ini; layar lengkapnya dibuka dari sana.

## 3. Relasi data

```
activities ─┬─< track_points          (GPS, sudah ada)
            ├─< waypoint_photos       (sudah ada)
            ├─< workout_sets ──> exercises   (BARU: gym)
            └── gear                  (sudah ada)

exercises (library gerakan) ─< workout_template_items >─ workout_templates

body_checkins ─< body_photos          (BARU: progres tubuh)

tasks ─< task_reminders               (BARU: tugas)

app_limits                            (BARU: fokus, batas per aplikasi)
app_usage_days                        (BARU: catatan pemakaian harian)
```

### Kunci keputusan
- **Gym memakai tabel `activities` yang sama** dengan `sportType = strength` (kategori baru).
  Dengan begitu jurnal, kalender, statistik, streak, dan share studio otomatis ikut bekerja.
  Kolom GPS (jarak, kecepatan) dibiarkan 0; data gym ada di `workout_sets`.
- **Kategori olahraga** diturunkan dari `sportType`:
  `cycling` (gravel/road/mtb) · `running` (road/trail) · `walking` (hiking/walk) · `strength` (gym).
  Kategori dipakai untuk warna kalender, filter, dan streak.

### Tabel baru (ringkas)

| Tabel | Kolom penting |
|---|---|
| `exercises` | id, name, muscleGroup (dada/punggung/kaki/bahu/lengan/core), equipment, isCustom |
| `workout_sets` | id, activityId → activities, exerciseId → exercises, order, reps, weightKg, rpe?, isWarmup, completedAt |
| `workout_templates` | id, name, note |
| `workout_template_items` | templateId, exerciseId, order, targetSets, targetReps |
| `body_checkins` | id, date, weightKg?, bodyFatPct?, waistCm?, chestCm?, armCm?, note |
| `body_photos` | id, checkinId, pose (depan/samping/belakang), filePath |
| `tasks` | id, title, note?, dueDate?, priority, doneAt?, pinned (tampil di widget), createdAt |
| `app_limits` | packageName, label, dailyMinutes, enabled |
| `app_usage_days` | date, packageName, minutes |

## 4. Modul per modul

### Hari Ini (`features/today`)
Kartu dari atas ke bawah: sapaan + tanggal → **Tugas hari ini** (centang langsung) →
**Fokus** (sisa waktu TikTok/IG, bar per aplikasi) → **Latihan hari ini** (sudah/belum, streak) →
**Minggu ini** (mini-heatmap 7 hari) → pengingat foto tubuh bila jadwalnya tiba.

### Kalender (`features/calendar`)
- Heatmap tahunan + tampilan bulan. Tiap hari diwarnai sesuai **kategori**; hari dengan
  >1 kategori = kotak terbelah (2 atau 4 bagian). Intensitas = durasi/beban relatif.
- Chip filter: Semua · Sepeda · Lari · Jalan · Gym. Di bawahnya: streak sekarang, streak
  terpanjang, dan % hari aktif untuk filter yang dipilih.
- Ketuk hari → daftar isi hari itu (aktivitas, sesi gym, tugas selesai, foto tubuh).

### Gym (`features/gym`)
- Mulai dari template atau kosong → tambah gerakan → catat set (reps × kg, RPE opsional).
- Timer istirahat otomatis setelah set selesai, nilai set sebelumnya ditampilkan sebagai patokan.
- Statistik: volume per minggu, PR per gerakan (beban maks, perkiraan 1RM), otot yang
  jarang dilatih.

### Tugas (`features/tasks`)
- Daftar sederhana: Hari ini · Nanti · Selesai. Satu kolom ketik di atas untuk catat cepat.
- **Catat cepat dari luar aplikasi**: notifikasi permanen dengan kolom balas (RemoteInput),
  ubin Quick Settings, pintasan ikon aplikasi (tekan lama).
- **Widget layar utama**: daftar tugas yang di-pin, bisa dicentang langsung.
- Opsional: gelembung mengambang (butuh izin "tampil di atas aplikasi lain").

### Fokus (`features/focus`, khusus Android)
- Pilih aplikasi + batas menit per hari. Pemakaian dibaca lewat Usage Access.
- Saat kuota habis: Accessibility Service menutup aplikasi dan menampilkan layar "Waktu habis"
  dengan opsi +5 menit (maks 1×) agar tetap manusiawi.
- Riwayat pemakaian harian ikut tampil di kalender sebagai indikator kecil.
- Butuh kode native Kotlin (`android/.../focus/`) + MethodChannel `virya/focus`.

### Progres tubuh (`features/body`)
- Check-in berkala (misal tiap Minggu): foto depan/samping/belakang + berat + ukuran.
- Foto disimpan di folder privat aplikasi (tidak masuk galeri), ikut backup.
- Tampilan: grid foto per tanggal, slider sebelum/sesudah, grafik berat,
  video timelapse (memakai ulang mesin video recap).
- Kamera dengan garis bantu bayangan foto sebelumnya agar posisi konsisten.

## 5. Urutan pengerjaan

| Fase | Isi |
|---|---|
| 2 | Refactor modular, rename, token tema, tombol rekam baru |
| 3 | Logo + splash, layar Hari Ini, navigasi baru, peta gabungan (online + unduh wilayah) |
| 4 | Gym + kalender kategori |
| 5 | Tugas + widget + catat cepat dari notifikasi |
| 6 | Fokus (batas waktu aplikasi) |
| 7 | Progres tubuh |
| 8 | Mode style tambahan |
