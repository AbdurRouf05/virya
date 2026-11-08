# Virya

> *Virya* (Sanskerta): tenaga, kegigihan, usaha yang tekun.

Aplikasi pribadi untuk membangun konsistensi: olahraga, latihan, fokus, dan tugas harian dalam satu tempat. Semua data tersimpan di perangkat, tanpa akun dan tanpa server.

## Fitur saat ini

- **Rekam aktivitas GPS**: sepeda (gravel, road, MTB), lari, trail, hiking, jalan. GPS tetap bekerja tanpa internet.
- **Analitik**: GAP, tanjakan, sektor gravel, skor GRIT, estimasi power, kebugaran, best efforts.
- **Peta & flyover 3D**: MapLibre dengan paket peta offline PMTiles atau peta online cadangan.
- **Share studio**: kartu story, stiker PNG, video recap MP4 yang dirender di perangkat.
- **Impor / ekspor**: GPX, TCX, FIT, ZIP ekspor Strava, serta backup lokal.
- Layar **Hari Ini** sebagai pusat semua modul.
- **Gym**: gerakan, set, repetisi, beban, PR.
- **Kalender konsistensi** per kategori (sepeda / lari / jalan / gym).
- **Tugas**: catat cepat dari notifikasi dan widget layar utama.
- **Fokus**: batas waktu harian untuk aplikasi tertentu (Android).
- **Progres tubuh**: foto berkala, perbandingan, timelapse.
- **Mode tampilan**: Field Notes, Malam, Cetak Biru, Hutan.
- **Segmen live** dengan ghost pacer dan panduan suara.
- **Heatmap pribadi** dari semua jalur yang pernah direkam.
- **Sensor detak jantung** Bluetooth.

## Teknologi

Flutter · Riverpod · Drift (SQLite) · MapLibre GL · PMTiles · MediaCodec (encoder video native)

## Ikut mengerjakan

Mulai dari [docs/PANDUAN.md](docs/PANDUAN.md): status fase, cara menjalankan, alur kerja, dan aturan kode.

## Panduan Fitur Unggulan

### 1. Catat Cepat To-Do / Tugas (Quick Capture)
- **Notifikasi Permanen**: Aktifkan di layar **Tugas** atau **Pengaturan**. Notifikasi akan standby di status bar Android dengan kolom input langsung. Ketik tugas lalu tekan tombol kirim (panah) tanpa perlu membuka aplikasi.
- **Quick Settings Tile**: Buka panel notifikasi HP (geser 2x ke bawah), tap ikon pensil/edit tile, lalu tambahkan tile **"Catat Tugas"** (Virya). Cukup 1 klik dari mana saja untuk membuka popup pencatatan cepat.
- **Widget Layar Utama**: Tersedia widget daftar tugas yang interaktif (bisa langsung dicentang dari homescreen).

### 2. Fokus & Anti-Doom Scrolling (Android)
Membatasi waktu pemakaian aplikasi yang sering bikin kecanduan (misal: TikTok, Instagram, YouTube Shorts).
> **PENTING untuk Android 13, 14, dan 15:**
> Karena Virya di-install secara mandiri (sideload APK di luar Google Play Store), sistem keamanan Android secara otomatis mengunci izin dengan pesan **"Controlled by Restricted Setting"** (tombol izin abu-abu).
> 
> **Cara Mengaktifkannya:**
> 1. Buka **Pengaturan HP** ➜ **Aplikasi** ➜ pilih **Virya** (Layar Info Aplikasi).
> 2. Di pojok kanan atas, ketuk tombol **Menu Titik Tiga (⋮)**.
> 3. Pilih **"Izinkan setelan terbatas"** (*Allow restricted settings*).
> 4. Masukkan PIN / sidik jari HP.
> 5. Kembali ke menu **Fokus** di Virya, lalu nyalakan **Akses Penggunaan** dan **Aksesibilitas**.

### 3. Share Studio & Video Recap
- Ekspor kartu aktivitas berestetika *Field Notes* dalam 3 format: **Story (9:16)**, **Feed (4:5)**, dan **Kotak (1:1)**.
- Video Recap rute 3D MP4 dengan encoder native hemat baterai dan bebas memory leak.

## Menjalankan

```bash
flutter pub get
flutter run
```

Build rilis Android:

```bash
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

## Lisensi data peta

Data peta © kontributor OpenStreetMap (ODbL). Elevasi: Mapzen / AWS Terrain Tiles.
