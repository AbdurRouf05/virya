import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:virya/features/routes/domain/route_gpx.dart';
import 'package:virya/features/routes/domain/route_models.dart';

/// Menulis rute ke file GPX sementara lalu membuka lembar berbagi.
Future<void> shareRouteGpx(SavedRoute r) async {
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, gpxFileName(r.name)));
  await file.writeAsString(routeToGpx(r));
  await SharePlus.instance.share(ShareParams(
    files: [XFile(file.path, mimeType: 'application/gpx+xml')],
    subject: r.name,
  ));
}
