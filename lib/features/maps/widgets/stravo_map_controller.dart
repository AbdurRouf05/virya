import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stravo/app/theme/field_notes.dart';
import 'package:stravo/core/constants/enums.dart';
import 'package:stravo/core/offline_maps/map_pack_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// True when a platform WebView exists (Android/iOS app, not tests/desktop).
bool get mapWebViewSupported {
  if (kIsWeb) return false;
  if (!(Platform.isAndroid || Platform.isIOS)) return false;
  return WebViewPlatform.instance != null;
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Speed ramp (slow → fast), Field Notes.
const routeSpeedRamp = [
  FN.inkSoft,
  Color(0xFFC9A227),
  Color(0xFFE8812A),
  FN.signal,
  Color(0xFFA3161B),
];
const gradeStops = [3.0, 5.0, 8.0, 11.0, 15.0];

Map<String, Object> mapPalette() => {
      'speed': [for (final c in routeSpeedRamp) _hex(c)],
      'grade': {
        'stops': gradeStops,
        'colors': [
          _hex(FN.grade(0)),
          for (final s in gradeStops) _hex(FN.grade(s)),
        ],
      },
      'surface': [
        for (final s in SurfaceType.values) _hex(FN.surface[s] ?? FN.inkMuted)
      ],
    };

/// Thin wrapper over a [WebViewController] running `map.html`.
/// JS calls made before the page is ready are queued.
class StravoMapController {
  StravoMapController._(this.web, this._initConfig);

  final WebViewController web;
  final Map<String, Object?> _initConfig;
  final _ready = Completer<void>();
  final _loaded = Completer<void>();
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  bool _disposed = false;

  Stream<Map<String, dynamic>> get events => _events.stream;
  Future<void> get loaded => _loaded.future;
  bool get isLoaded => _loaded.isCompleted;

  static StravoMapController create({
    required MapConfig config,
    bool interactive = true,
    bool enable3d = false,
    Map<String, Object?> extra = const {},
  }) {
    final init = <String, Object?>{
      ...config.toJson(),
      'interactive': interactive,
      'enable3d': enable3d,
      'palette': mapPalette(),
      ...extra,
    };
    late final StravoMapController c;
    final web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(FN.paper)
      ..addJavaScriptChannel('Stravo', onMessageReceived: (m) => c._onMessage(m.message))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => c._sendInit(),
        onNavigationRequest: (r) => r.url.startsWith(config.pageUrl.origin)
            ? NavigationDecision.navigate
            : NavigationDecision.prevent,
      ));
    c = StravoMapController._(web, init);
    web.loadRequest(config.pageUrl);
    return c;
  }

  void _onMessage(String raw) {
    if (_disposed) return;
    Map<String, dynamic> msg;
    try {
      msg = (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return;
    }
    switch (msg['type']) {
      case 'ready':
        _sendInit();
      case 'loaded':
        if (!_loaded.isCompleted) _loaded.complete();
      case 'error':
        debugPrint('StravoMap JS: ${msg['msg']}');
    }
    _events.add(msg);
  }

  void _sendInit() {
    if (_ready.isCompleted || _disposed) return;
    _ready.complete();
    web
        .runJavaScript('StravoMap.init(${jsonEncode(_initConfig)})')
        .catchError((Object e) => debugPrint('StravoMap init: $e'));
  }

  /// Calls `StravoMap.<fn>(...args)` once the page is ready.
  Future<void> call(String fn, [List<Object?> args = const []]) async {
    await _ready.future;
    if (_disposed) return;
    final a = args.map(jsonEncode).join(',');
    try {
      await web.runJavaScript('StravoMap.$fn($a)');
    } catch (e) {
      debugPrint('StravoMap.$fn: $e');
    }
  }

  void dispose() {
    _disposed = true;
    _events.close();
  }
}

/// The platform view for a [StravoMapController].
class StravoMapWebView extends StatelessWidget {
  const StravoMapWebView({
    super.key,
    required this.controller,
    this.interactive = true,
  });

  final StravoMapController controller;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final view = WebViewWidget(
      controller: controller.web,
      gestureRecognizers: interactive
          ? {Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)}
          : const <Factory<OneSequenceGestureRecognizer>>{},
    );
    return interactive ? view : IgnorePointer(child: view);
  }
}
