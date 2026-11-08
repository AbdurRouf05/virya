import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Technical "how to get packs" guide (CLI commands for PMTiles/DEM).
class MapPacksGuide extends StatelessWidget {
  const MapPacksGuide({super.key});

  static const _basemapCmd =
      'pmtiles extract https://build.protomaps.com/20261101.pmtiles jawa.pmtiles '
      '--bbox=105.0,-8.9,114.7,-5.8 --maxzoom=15';
  static const _demCmd1 =
      'aws s3 sync --no-sign-request s3://elevation-tiles-prod/terrarium/ ./terrarium '
      '--exclude "*" --include "5/*" ... (z5–12 area Jawa)';
  static const _demCmd2 =
      'mb-util --image_format=png ./terrarium jawa.dem.mbtiles\n'
      'pmtiles convert jawa.dem.mbtiles jawa.dem.pmtiles';

  @override
  Widget build(BuildContext context) {
    final body = TextStyle(fontFamily: FN.sans, fontSize: 13, color: FN.inkSoft, height: 1.45);
    Widget h(String t) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(t, style: FN.label(size: 12, color: FN.ink)),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('CARA MENDAPATKAN PAKET', style: FN.label(size: 12, color: FN.ink)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: FN.ink, thickness: 1)),
      ]),
      const SizedBox(height: 6),
      Text(
        'Semua peta berjalan 100% offline dari file PMTiles di ponsel. Siapkan '
        'file di komputer, salin ke ponsel (USB / kabel data / Drive), lalu tekan '
        '"IMPOR FILE .PMTILES".',
        style: body,
      ),
      h('1 · BASEMAP VEKTOR (PROTOMAPS)'),
      Text(
        'Pasang CLI "pmtiles" (github.com/protomaps/go-pmtiles). Lihat tanggal '
        'build terbaru di maps.protomaps.com/builds, lalu potong area yang '
        'dibutuhkan (contoh: Pulau Jawa, ± 1–2 GB):',
        style: body,
      ),
      const _Code(_basemapCmd),
      Text(
        'Ganti tanggal 20261101 dengan build terbaru. Perkecil --bbox atau '
        '--maxzoom=14 agar file lebih kecil.',
        style: body,
      ),
      h('2 · TERRAIN 3D (OPSIONAL)'),
      Text(
        'Unduh ubin elevasi Terrarium gratis dari AWS Open Data '
        '(s3://elevation-tiles-prod/terrarium) untuk zoom ≤ 12 di area yang '
        'sama, kemudian kemas menjadi PMTiles. Nama file WAJIB berakhiran '
        '.dem.pmtiles:',
        style: body,
      ),
      const _Code(_demCmd1),
      const _Code(_demCmd2),
      Text(
        'Tanpa terrain, flyover tetap jalan dengan kamera miring di atas peta datar. '
        'Tanpa basemap, rute digambar di atas kertas polos.',
        style: body,
      ),
      h('3 · LISENSI'),
      Text('Data peta © kontributor OpenStreetMap (ODbL). Elevasi: Mapzen/AWS Terrain Tiles.',
          style: body),
    ]);
  }
}

class _Code extends StatelessWidget {
  const _Code(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: FN.ink,
            content: Text('Perintah disalin', style: FN.label(size: 12, color: FN.paper)),
          ));
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          color: FN.night,
          child: SelectableText(
            text,
            style: TextStyle(fontFamily: FN.mono, fontSize: 11.5, color: FN.acid, height: 1.4),
          ),
        ),
      );
}
