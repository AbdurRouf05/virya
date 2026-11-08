# Virya

> *Virya* (Sanskerta): tenaga, kegigihan, usaha yang tekun.

Aplikasi pribadi untuk membangun konsistensi: olahraga, latihan, fokus, dan tugas harian dalam satu tempat. Semua data tersimpan di perangkat, tanpa akun dan tanpa server.

## Fitur saat ini

- **Rekam aktivitas GPS**: sepeda (gravel, road, MTB), lari, trail, hiking, jalan. GPS tetap bekerja tanpa internet.
- **Analitik**: GAP, tanjakan, sektor gravel, skor GRIT, estimasi power, kebugaran, best efforts.
- **Peta & flyover 3D**: MapLibre dengan paket peta offline PMTiles atau peta online cadangan.
- **Share studio**: kartu story, stiker PNG, video recap MP4 yang dirender di perangkat.
- **Impor / ekspor**: GPX, TCX, FIT, ZIP ekspor Strava, serta backup lokal.

## Peta jalan

- Layar **Hari Ini** sebagai pusat semua modul
- **Gym**: gerakan, set, repetisi, beban, PR
- **Kalender konsistensi** per kategori (sepeda / lari / gym / campuran)
- **Tugas & catatan cepat** dari notifikasi dan widget layar utama
- **Fokus**: batas waktu harian untuk aplikasi tertentu (Android)
- **Progres tubuh**: foto berkala, perbandingan, timelapse
- **Mode tampilan** yang bisa dipilih

## Teknologi

Flutter · Riverpod · Drift (SQLite) · MapLibre GL · PMTiles · MediaCodec (encoder video native)

## Menjalankan

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Build rilis Android:

```bash
flutter build apk --release
```

## Lisensi data peta

Data peta © kontributor OpenStreetMap (ODbL). Elevasi: Mapzen / AWS Terrain Tiles.
