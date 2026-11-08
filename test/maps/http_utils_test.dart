import 'package:flutter_test/flutter_test.dart';
import 'package:stravo/core/offline_maps/http_utils.dart';

void main() {
  group('parseRange', () {
    test('no header → full', () {
      expect(parseRange(null, 100), isA<FullRange>());
    });
    test('closed range', () {
      expect(parseRange('bytes=0-9', 100), const PartialRange(0, 9));
      expect(parseRange('bytes=10-19', 100), const PartialRange(10, 19));
    });
    test('open-ended range', () {
      expect(parseRange('bytes=90-', 100), const PartialRange(90, 99));
    });
    test('suffix range', () {
      expect(parseRange('bytes=-10', 100), const PartialRange(90, 99));
      expect(parseRange('bytes=-500', 100), const PartialRange(0, 99));
    });
    test('end clamped to size', () {
      expect(parseRange('bytes=50-1000', 100), const PartialRange(50, 99));
    });
    test('start beyond size → 416', () {
      expect(parseRange('bytes=100-200', 100), isA<UnsatisfiableRange>());
      expect(parseRange('bytes=-0', 100), isA<UnsatisfiableRange>());
    });
    test('malformed → full', () {
      expect(parseRange('bytes=abc', 100), isA<FullRange>());
      expect(parseRange('items=0-1', 100), isA<FullRange>());
      expect(parseRange('bytes=9-3', 100), isA<FullRange>());
    });
    test('multi-range uses first', () {
      expect(parseRange('bytes=0-1, 5-6', 100), const PartialRange(0, 1));
    });
    test('length', () {
      expect(const PartialRange(10, 19).length, 10);
    });
  });

  group('sanitizeRelativePath', () {
    test('accepts plain names', () {
      expect(sanitizeRelativePath('jawa.pmtiles'), 'jawa.pmtiles');
      expect(sanitizeRelativePath('sub/a.js'), 'sub/a.js');
      expect(sanitizeRelativePath('./a.js'), 'a.js');
      expect(sanitizeRelativePath('jawa%20baru.pmtiles'), 'jawa baru.pmtiles');
    });
    test('rejects traversal and absolute paths', () {
      for (final bad in [
        '../secret',
        'a/../../b',
        '%2e%2e/secret',
        '..%2fsecret',
        '/etc/passwd',
        r'..\win',
        'C:/x',
        '.hidden',
        '',
        'a%00b',
        '%zz',
      ]) {
        expect(sanitizeRelativePath(bad), isNull, reason: bad);
      }
    });
  });

  test('content types', () {
    expect(contentTypeFor('map.html'), startsWith('text/html'));
    expect(contentTypeFor('a.js'), startsWith('application/javascript'));
    expect(contentTypeFor('a.css'), startsWith('text/css'));
    expect(contentTypeFor('a.json'), startsWith('application/json'));
    expect(contentTypeFor('jawa.pmtiles'), 'application/octet-stream');
  });
}
