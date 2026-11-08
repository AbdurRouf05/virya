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
