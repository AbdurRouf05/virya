# Virya

<div align="center">

> *Virya* (Sanskerta: वीर्य): Tenaga, kegigihan, semangat membara, dan usaha yang tekun.

**Aplikasi pelacak kebugaran dan pembangun konsistensi pribadi 100% *offline-first*.**  
Menggabungkan pelacakan GPS multi-sport, modul latihan beban (Gym), kalender konsistensi, pencatatan to-do cepat, batas layar anti-doom scrolling, dan progres tubuh — tanpa akun, tanpa cloud, dan tanpa langganan.

[![Flutter](https://img.shields.io/badge/Flutter-3.29.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.0-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-GPL--3.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20(API%2024%2B)-success?logo=android)](https://developer.android.com)
[![Offline First](https://img.shields.io/badge/Architecture-100%25%20Offline-orange)](#privasi--filosofi-offline-first)
[![Tests](https://img.shields.io/badge/Tests-534%20Passed-brightgreen)](#menjalankan-pengujian-tests)

</div>

---

## Daftar Isi
1. [Privasi & Filosofi Offline-First](#privasi--filosofi-offline-first)
2. [Cara Pasang (Install) APK di HP Android](#cara-pasang-install-apk-di-hp-android)
3. [Panduan Fitur & Cara Penggunaan](#panduan-fitur--cara-penggunaan)
   - [Layar Hari Ini & Navigasi](#1-layar-hari-ini--navigasi-utama)
   - [Rekam Aktivitas GPS & Sensor BLE](#2-rekam-aktivitas-gps--sensor-detak-jantung)
   - [Modul Gym & Latihan Beban](#3-modul-gym--latihan-beban)
   - [Peta Offline & Unduh Wilayah](#4-peta-offline--unduh-wilayah-pmtiles)
   - [Share Studio & Video Recap 3D](#5-share-studio--video-recap-3d)
   - [Kalender Konsistensi & Heatmap Pribadi](#6-kalender-konsistensi--heatmap-pribadi)
   - [Catat Cepat To-Do & Widget Layar Utama](#7-catat-cepat-to-do--widget-layar-utama)
   - [Fokus & Anti-Doom Scrolling](#8-fokus--anti-doom-scrolling)
   - [Progres Tubuh & Timelapse](#9-progres-tubuh--timelapse)
   - [Impor, Ekspor & Backup Lokal](#10-impor-ekspor--backup-lokal)
4. [Panduan Developer & Build dari Source Code](#panduan-developer--build-dari-source-code)
5. [Arsitektur & Struktur Proyek](#arsitektur--struktur-proyek)
6. [Troubleshooting & Solusi Masalah Umum](#troubleshooting--solusi-masalah-umum)
7. [Lisensi](#lisensi)

---

## Privasi & Filosofi Offline-First

* **Zero Server / Zero Cloud**: Tidak ada server pengumpul data, tidak ada registrasi akun, tidak ada analitik pihak ketiga.
* **Database di Perangkat**: Seluruh riwayat latihan, titik GPS, catatan to-do, dan foto progres tubuh disimpan di SQLite lokal (`virya.sqlite`) di memori internal HP Anda.
* **Desain Estetika *Field Notes***: Terinspirasi dari buku jurnal ekspedisi topografi klasik — garis kontur halus, tipografi monospaced Plex, warna *paper* krem, dan aksen *signal orange*.

---

## Cara Pasang (Install) APK di HP Android

### Langkah 1: Unduh File APK
Ambil file APK rilis sesuai arsitektur perangkat Anda dari folder `build/app/outputs/flutter-apk/` atau dari halaman **Releases**:
* **`app-arm64-v8a-release.apk`** (~24.4 MB) — **Rekomendasi Utama** untuk hampir semua smartphone Android modern (64-bit).
* **`app-armeabi-v7a-release.apk`** (~22.8 MB) — Untuk HP Android generasi lama (32-bit).

### Langkah 2: Izinkan Pemasangan dari Sumber Tidak Dikenal
1. Buka file APK yang sudah diunduh menggunakan File Manager atau browser.
2. Jika muncul peringatan *"Demi keamanan, ponsel Anda tidak diizinkan memasang aplikasi yang tidak dikenal dari sumber ini"*, ketuk **Setelan (Settings)**.
3. Aktifkan toggle **"Izinkan dari sumber ini"** (*Allow from this source*), lalu kembali dan ketuk **Instal**.

### Langkah 3: Pengaturan Penting untuk Android 13, 14, dan 15 (Wajib untuk Fitur Fokus)
Karena Virya dipasang di luar Play Store (*sideload*), Android secara otomatis mengunci izin sensitif dengan status **"Controlled by Restricted Setting"** (tombol izin abu-abu).
**Cara membuka kunci izin tersebut:**
1. Buka **Pengaturan HP** ➜ **Aplikasi** ➜ pilih **Virya** (masuk ke halaman Info Aplikasi).
2. Di pojok kanan atas, ketuk tombol **Menu Titik Tiga (⋮)**.
3. Pilih **"Izinkan setelan terbatas"** (*Allow restricted settings*).
4. Verifikasi dengan memasukkan PIN / pola / sidik jari HP Anda.
5. Selesai! Sekarang izin **Akses Penggunaan** dan **Aksesibilitas** di menu Fokus Virya sudah bisa dinyalakan.

### Langkah 4: Pengaturan Baterai Latar Belakang (Agar Rekaman GPS Tidak Mati)
Beberapa merk HP (Xiaomi/MIUI, Samsung, Oppo, Vivo, Infinix) memiliki manajemen baterai agresif yang dapat mematikan GPS saat layar mati.
* Buka **Info Aplikasi Virya** ➜ **Penghemat Baterai** ➜ Ubah menjadi **"Tidak Ada Pembatasan"** (*No restrictions* / *Unrestricted*).

---

## Panduan Fitur & Cara Penggunaan

### 1. Layar Hari Ini & Navigasi Utama
Layar **Hari Ini** adalah dasbor harian terpadu yang menampilkan:
* Sapaan waktu dinamis dan kalender hari ini.
* Kartu pintasan To-Do yang di-pin dan status batas waktu fokus aplikasi.
* Status kebugaran **TSB (*Training Stress Balance*)** dan streak aktivitas minggu ini.
* Tombol **(+) Aksi Cepat** di tengah bilah navigasi untuk meluncurkan:
  - 🚴 **Rekam GPS**
  - 🏋️ **Mulai Gym**
  - 📝 **Tugas Baru**
  - 📷 **Foto Tubuh**

---

### 2. Rekam Aktivitas GPS & Sensor Detak Jantung
* **Pilihan Olahraga**: Sepeda Gravel, Road, MTB, Lari Jalan, Trail Running, Hiking, dan Jalan Kaki.
* **Format Kecepatan Otomatis**: Olahraga lari dan jalan otomatis menggunakan satuan kecepatan **Pace (`/KM`)**, sedangkan bersepeda menggunakan **`KM/H`**.
* **Analitik Jalur Tingkat Lanjut**:
  - **GAP (*Grade Adjusted Pace*)** untuk lari tanjakan/turunan.
  - **Skor GRIT**: Mengukur tingkat kekasaran medan gravel (rute 100% aspal otomatis menghasilkan GRIT 0).
  - **Deteksi Tanjakan Otomatis**: Kategori 1–4, HC, elevasi total, dan VAM (*Vertical Ascent in Meters/hour*).
* **Sensor Detak Jantung BLE**:
  - Dukungan sensor dada/lengan Bluetooth Low Energy standar (Polar, Garmin, Magene, CooSpo).
  - Hubungkan melalui **Pengaturan ➜ Perekaman ➜ Sensor Detak Jantung**. Terhubung ulang secara otomatis.
* **Segmen Live & Ghost Pacer**:
  - Buat segmen dari rute rekaman sebelumnya.
  - Saat melintasi segmen, HUD live akan menampilkan selisih waktu secara *real-time* melawan catatan terbaik Anda (*Ghost Pacer*), disertai panduan suara audio cues bahasa Indonesia.

---

### 3. Modul Gym & Latihan Beban
* **44 Gerakan Bawaan**: Pustaka gerakan lengkap (Dada, Punggung, Kaki, Bahu, Lengan, Core) dengan estimasi otot target.
* **Pencatatan Sesi Fleksibel**: Catat beban (kg), repetisi (reps), RPE opsional, set pemanasan, dan catatan gerakan.
* **Timer Istirahat Cerdas**: Otomatis berhitung mundur setelah set dicentang (90 detik default, dengan tombol +15/-15 detik).
* **PR (*Personal Record*) Tracker**: Menghitung otomatis beban terberat, estimasi 1RM (formula Epley), dan rekor volume set tertinggi.
* **Template Latihan**: Buat template latihan favorit (Push, Pull, Legs, Upper, Lower) atau simpan langsung dari sesi yang baru selesai.
* **Pemulihan Sesi Otomatis**: Draf latihan disimpan tiap perubahan set; aman dari risiko aplikasi tertutup paksa.

---

### 4. Peta Offline & Unduh Wilayah (PMTiles)
* **Peta Online Langsung Aktif**: Menggunakan basemap OpenFreeMap tanpa perlu konfigurasi awal.
* **Unduh Wilayah (Offline Cache)**:
  - Masuk ke **Pengaturan ➜ Peta Offline ➜ Unduh Wilayah**.
  - Pilih radius kotak (10–100 km) di sekitar posisi GPS Anda dengan tingkat zoom 5–14.
  - Peta tersimpan di perangkat sehingga navigasi tetap menyala saat menjelajah area tanpa sinyal seluler.
* **Dukungan Format PMTiles**: Untuk pengguna tingkat lanjut, dapat mengimpor file peta `.pmtiles` vektor dan DEM elevasi 3D Terrarium sendiri.

---

### 5. Share Studio & Video Recap 3D
Bagikan pencapaian rute Anda ke media sosial dengan visual Field Notes tanpa stempel berputar norak:
* **3 Rasio Format**:
  - **Story (9:16)**: Format vertikal penuh untuk Instagram Story / WhatsApp Status.
  - **Feed (4:5)**: Format optimal feed Instagram dengan proporsi teks yang disesuaikan bebas tabrakan.
  - **Kotak (1:1)**: Format persegi ringkas.
* **6 Template Kartu**:
  - `FIELD NOTES`: Gaya lembar ekspedisi jurnal topografi resmi.
  - `SEKTOR`: Fokus pada analisis permukaan jalan dan sektor kerikil/gravel.
  - `PROFIL`: Diagram profil elevasi rute dan penanda puncak tanjakan.
  - `NIGHT INK`: Latar gelap dengan visualisasi kontur pita elevasi bercahaya.
  - `STICKER`: Format PNG transparan untuk ditempel di atas foto Anda di Instagram.
  - `FOTO`: Menggabungkan foto yang diambil saat rute dengan overlay data statistik.
* **Video Recap 3D (MP4)**:
  - Merender rute 3D bergerak dengan camera tracer, pop-up foto waypoint, dan HUD data.
  - Pilihan durasi: **Otomatis** (skala sebanding panjang rute), 15 detik, 30 detik, atau 60 detik.
  - Didukung encoder native hardware Android (MediaCodec H.264) hemat baterai dan bebas memory leak.

---

### 6. Kalender Konsistensi & Heatmap Pribadi
* **Heatmap Aktivitas Tahunan**: Grid visual 52 minggu ala GitHub commit history yang membedakan warna berdasarkan cabang olahraga:
  - 🟠 Oranye: Sepeda (Gravel, Road, MTB)
  - 🟢 Hijau: Lari & Trail
  - 🔵 Biru: Jalan & Hiking
  - 🟣 Ungu: Gym & Latihan Beban
* **Personal Heatmap (Peta Panas Pribadi)**:
  - Menampilkan akumulasi seluruh rute GPS yang pernah Anda lewati di atas peta MapLibre.
  - Mengidentifikasi jalan yang paling sering Anda lintasi (terang/tebal) tanpa mengirim data ke internet.

---

### 7. Catat Cepat To-Do & Widget Layar Utama
* **Input Langsung di Notifikasi Status Bar**:
  - Aktifkan toggle di layar Tugas. Notifikasi permanen minimalis akan hadir di status bar HP Anda.
  - Cukup tarik panel notifikasi, ketik ide tugas di kolom input, lalu tekan ikon kirim. Tugas langsung tersimpan tanpa membuka aplikasi!
* **Quick Settings Tile**:
  - Tambahkan tombol pintasan **"Catat Tugas"** di panel atas Android (Quick Settings).
  - Sekali ketuk dari aplikasi apa pun untuk membuka lembar catat cepat.
* **Widget Layar Utama (Homescreen Widget)**:
  - Pasang widget Virya di layar beranda HP untuk melihat daftar tugas hari ini dan langsung mencentangnya secara instan.

---

### 8. Fokus & Anti-Doom Scrolling
Bantu menjaga produktivitas dengan membatasi durasi pemakaian aplikasi tertentu (misal: media sosial):
* Pilih aplikasi yang ingin dibatasi dan tentukan kuota harian (misal: TikTok 30 menit/hari).
* Saat kuota harian habis, layanan aksesibilitas lokal akan otomatis menutup aplikasi tersebut dan menampilkan layar *"Waktu Habis"* dengan opsi darurat +5 menit (maksimal 1x sehari).
* Seluruh data pemakaian dibaca dari `UsageStatsManager` lokal dan tidak pernah meninggalkan HP Anda.

---

### 9. Progres Tubuh & Timelapse
* **Check-in Terjadwal**: Catat berat badan, lingkar pinggang/lengan/dada, persentase lemak tubuh, dan catatan perkembangan.
* **3 Pose Foto Standar**: Depan, Samping, dan Belakang.
* **Kamera dengan Bayangan Panduan (*Ghost Silhouette*)**: Menampilkan kontur tipis dari foto sebelumnya di jendela kamera agar posisi berdiri dan sudut foto selalu sejajar dan konsisten.
* **Video Timelapse Perkembangan**: Ekspor perubahan bentuk tubuh Anda menjadi video MP4 720×960. Foto disimpan di folder internal privat aplikasi (tidak tercampur ke galeri umum).

---

### 10. Impor, Ekspor & Backup Lokal
* **Impor File**: Mendukung format `.gpx`, `.tcx`, `.fit` (decoder binary native), dan file arsip `.zip` ekspor massal dari Strava.
* **Ekspor File**: Ekspor setiap aktivitas kapan saja ke format GPX 1.1 (dilengkapi ekstensi Garmin TPX untuk sensor detak jantung/irama) atau TCX.
* **Backup & Restore Penuh**: Cadangkan seluruh database SQLite dan foto ke dalam satu file ZIP terenkripsi kanonikal (dilindungi dari kerentanan ZipSlip) untuk dipindahkan antar perangkat.

---

## Panduan Developer & Build dari Source Code

### Prasyarat Lingkungan Pengembangan
* **Flutter SDK**: `^3.29.0`
* **Dart SDK**: `^3.7.0` (kompatibel dengan versi 3.7 hingga <4.0)
* **Android SDK**: `compileSdk = 36`, `minSdk = 24`, `targetSdk = 34`
* **Android NDK**: `27.0.12077973`
* **Java / JDK**: OpenJDK 17 atau 21

### 1. Kloning Repositori & Instal Dependensi
```bash
git clone https://github.com/AbdurRouf05/virya.git
cd virya
flutter pub get
```

### 2. Menjalankan Mode Pengembangan (Debug)
Pastikan perangkat Android atau emulator sudah terhubung dengan USB Debugging aktif:
```bash
flutter run
```

### 3. Menjalankan Pengujian (Tests)
Virya memiliki cakupan pengujian unit, database DAO, dan widget yang sangat ketat:
```bash
# Analisa kode statis (wajib 0 errors / 0 warnings)
dart analyze .

# Menjalankan seluruh test suite (534 tests)
flutter test
```

### 4. Build File APK Rilis (Split per ABI)
Sangat disarankan menggunakan flag `--split-per-abi` agar ukuran file APK ramping (~22–24 MB) dan teroptimasi untuk arsitektur prosesor pengguna:
```bash
flutter build apk --release --split-per-abi
```
File hasil kompilasi akan berada di:
* `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (HP 64-bit modern)
* `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (HP 32-bit lawas)
* `build/app/outputs/flutter-apk/app-x86_64-release.apk` (Emulator PC)

---

## Arsitektur & Struktur Proyek

Virya menerapkan arsitektur modular yang ketat untuk menjaga kemudahan pemeliharaan kode:
* **Aturan Maksimal 300 Baris per File**: Setiap file Dart dibatasi maksimal 300 baris kode. Logika yang kompleks dipecah menjadi komponen domain, presentasi, dan kalkulasi terpisah.
* **State Management**: [Riverpod 2.6](https://riverpod.dev) dengan pola reaktif.
* **Database Persisten**: [Drift 2.24](https://drift.simonbinder.eu) di atas SQLite lokal dengan migrasi skema terstruktur.
* **Akselerasi Native**: Kotlin MediaCodec untuk kompresi dan encoding video hardware.

```text
lib/
├── app/                  # Inisialisasi tema Field Notes, routing, dan integrasi modul
├── core/                 # Komponen inti bersama (Database Drift, Offline Maps, Audio Cues, GPS)
│   ├── database/         # Skema tabel SQLite, DAOs, dan seed data
│   ├── offline_maps/     # Local HTTP tile server (127.0.0.1) & parser PMTiles
│   └── video/            # Jembatan VideoEncoder native
└── features/             # Modul fitur independen
    ├── activity_history/ # Jurnal riwayat dan detail statistik aktivitas
    ├── body/             # Progres tubuh, kamera ghost silhouette, dan timelapse
    ├── calendar/         # Kalender tahunan/bulanan dan konsistensi multi-sport
    ├── dashboard/        # Grafik kebugaran ATL/CTL/TSB dan race predictor
    ├── focus/            # Pembatas waktu aplikasi dan service aksesibilitas
    ├── gym/              # Sesi latihan beban, PR tracker, dan template
    ├── heatmap/          # Personal heatmap visualizer rute GPS
    ├── home/             # Shell navigasi 5-tab dan lembar aksi cepat
    ├── maps/             # MapLibre controller, unduh wilayah, dan flyover 3D
    ├── profile/          # Profil atlet dan manajemen peta offline
    ├── recording/        # Perekaman GPS real-time, auto-pause, dan filter elevasi
    ├── sensors/          # Pemindaian dan pembacaan sensor detak jantung BLE
    ├── settings/         # Preferensi aplikasi, tema, dan manajemen data
    ├── share/            # Share Studio, 6 template kartu, dan MP4 video recap
    ├── tasks/            # Catat tugas cepat, widget Android, dan sinkronisasi inbox
    ├── today/            # Dasbor harian "Hari Ini"
    └── training/         # Hub latihan gabungan (Jurnal · Statistik · Gym)
```

---

## Troubleshooting & Solusi Masalah Umum

### 1. Izin Aksesibilitas / Penggunaan Terkunci (*"Controlled by Restricted Setting"*)
* **Penyebab**: Proteksi keamanan Android 13+ untuk aplikasi sideload.
* **Solusi**: Masuk ke **Info Aplikasi Virya** ➜ Ketuk menu titik tiga **(⋮)** di kanan atas ➜ Pilih **"Izinkan setelan terbatas"** (*Allow restricted settings*) ➜ Masukkan PIN HP. Kembali ke aplikasi dan nyalakan izin.

### 2. Rekaman GPS Berhenti Sendiri Saat Layar HP Mati
* **Penyebab**: Penghemat baterai bawaan HP mematikan *foreground service*.
* **Solusi**: Di Info Aplikasi Virya, matikan penghemat baterai (atur ke *"Tidak Ada Pembatasan"* / *"No Restrictions"*), dan pastikan izin lokasi diatur ke *"Izinkan sepanjang waktu"* atau *"Saat aplikasi digunakan"*.

### 3. Peta Tidak Menampilkan Gambar Saat Offline
* **Solusi**: Pastikan Anda sudah mengunduh area yang akan dikunjungi melalui menu **Pengaturan ➜ Peta Offline ➜ Unduh Wilayah** sebelum bepergian ke tempat tanpa sinyal.

---

## Lisensi

* Kode program Virya dirilis di bawah lisensi [GNU General Public License v3.0 (GPL-3.0)](LICENSE).
* Data peta dasar © kontributor [OpenStreetMap](https://www.openstreetmap.org/copyright) (ODbL).
* Data elevasi medan 3D: Mapzen / AWS Terrain Tiles.
