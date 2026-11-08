import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// `<app documents>/maps` — where imported PMTiles packs live.
Future<Directory> defaultMapsDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'maps'));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}
