import 'package:xml/xml.dart';

String xmlEscape(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');

/// ISO-8601 UTC without fractional seconds, e.g. 2026-11-01T06:00:00Z.
String isoUtc(DateTime t) {
  final u = t.toUtc();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}'
      'T${two(u.hour)}:${two(u.minute)}:${two(u.second)}Z';
}

extension XmlElementX on XmlElement {
  String get localName => name.local;

  XmlElement? child(String local) {
    for (final c in childElements) {
      if (c.name.local == local) return c;
    }
    return null;
  }

  String? childText(String local) => child(local)?.innerText;
}
