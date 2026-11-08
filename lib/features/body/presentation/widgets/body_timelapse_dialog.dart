import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/body/application/body_timelapse_renderer.dart';
import 'package:virya/features/body/data/body_providers.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Buat video timelapse dari foto satu pose lalu bagikan.
Future<void> showBodyTimelapseDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const _TimelapseDialog(),
);

enum _Stage { idle, rendering, done }

class _TimelapseDialog extends ConsumerStatefulWidget {
  const _TimelapseDialog();

  @override
  ConsumerState<_TimelapseDialog> createState() => _TimelapseDialogState();
}

class _TimelapseDialogState extends ConsumerState<_TimelapseDialog> {
  _Stage _stage = _Stage.idle;
  BodyPose _pose = BodyPose.front;
  double _progress = 0;
  bool _cancel = false;
  bool _sharing = false;
  String? _error;
  String? _output;

  bool get _supported => defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _cancel = true;
    // Video berisi foto pribadi, jadi tidak ditinggal di folder sementara.
    final output = _output;
    if (output != null) _deleteQuietly(output);
    super.dispose();
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } on FileSystemException catch (e) {
      debugPrint('Video sementara gagal dihapus: $e');
    }
  }

  Future<void> _start(List<BodyEntry> entries) async {
    setState(() {
      _stage = _Stage.rendering;
      _progress = 0;
      _cancel = false;
      _error = null;
    });
    WakelockPlus.enable().catchError((_) {});
    try {
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final output = await BodyTimelapseRenderer().render(
        entries: entries,
        pose: _pose,
        outputPath: p.join(dir.path, 'virya_timelapse_$stamp.mp4'),
        isCancelled: () => _cancel,
        onProgress: (v) {
          if (mounted) setState(() => _progress = v);
        },
      );
      if (!mounted) {
        await _deleteQuietly(output);
        return;
      }
      setState(() {
        _output = output;
        _stage = _Stage.done;
      });
    } on BodyTimelapseCancelled {
      if (mounted) setState(() => _stage = _Stage.idle);
    } on StateError catch (e) {
      _fail(e.message);
    } catch (e) {
      debugPrint('Timelapse gagal: $e');
      _fail('Video gagal dibuat. Coba lagi.');
    } finally {
      WakelockPlus.disable().catchError((_) {});
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _stage = _Stage.idle;
    });
  }

  Future<void> _share() async {
    final output = _output;
    if (output == null) return;
    setState(() {
      _sharing = true;
      _error = null;
    });
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(output, mimeType: 'video/mp4')]),
      );
    } catch (e) {
      debugPrint('Video gagal dibagikan: $e');
      if (mounted) setState(() => _error = 'Video gagal dibagikan.');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage != _Stage.rendering,
      child: Dialog(
        backgroundColor: FN.paper,
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Timelapse', style: FN.bigNumber(26)),
              const SizedBox(height: 14),
              ...switch (_stage) {
                _Stage.idle => _idle(),
                _Stage.rendering => _rendering(),
                _Stage.done => _done(),
              },
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _body =>
      TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.inkMuted);

  Widget get _errorText => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      _error!,
      style: TextStyle(fontFamily: FN.sans, fontSize: 14, color: FN.warn),
    ),
  );

  Widget get _close => InkButton(
    label: 'TUTUP',
    expand: true,
    onPressed: () => Navigator.pop(context),
  );

  List<Widget> _idle() {
    final entries =
        ref.watch(bodyEntriesProvider).valueOrNull ?? const <BodyEntry>[];
    final count = bodyEntriesWithPose(entries, _pose).length;
    final enough = count >= 2;
    final note = !_supported
        ? 'Pembuatan video hanya tersedia di Android.'
        : enough
        ? '$count foto ${_pose.label.toLowerCase()} akan dirangkai.'
        : 'Butuh minimal 2 foto ${_pose.label.toLowerCase()}. '
              'Saat ini ada $count.';
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final pose in BodyPose.values)
            Semantics(
              selected: pose == _pose,
              child: InkButton(
                label: pose.label,
                height: 40,
                style: pose == _pose
                    ? InkButtonStyle.ink
                    : InkButtonStyle.outline,
                onPressed: () => setState(() {
                  _pose = pose;
                  _error = null;
                }),
              ),
            ),
        ],
      ),
      const SizedBox(height: 14),
      Text(note, style: _body),
      const SizedBox(height: 14),
      if (_error != null) _errorText,
      InkButton(
        label: 'BUAT VIDEO',
        style: InkButtonStyle.primary,
        expand: true,
        onPressed: enough && _supported ? () => _start(entries) : null,
      ),
      const SizedBox(height: 10),
      _close,
    ];
  }

  List<Widget> _rendering() => [
    Text('Merangkai foto. Biarkan layar tetap terbuka.', style: _body),
    const SizedBox(height: 14),
    LinearProgressIndicator(
      value: _progress,
      minHeight: 6,
      color: FN.ink,
      backgroundColor: FN.paperLine,
      semanticsLabel: 'Kemajuan pembuatan video',
      semanticsValue: '${(_progress * 100).round()} persen',
    ),
    const SizedBox(height: 16),
    InkButton(
      label: _cancel ? 'MEMBATALKAN' : 'BATAL',
      expand: true,
      onPressed: _cancel ? null : () => setState(() => _cancel = true),
    ),
  ];

  List<Widget> _done() => [
    Text(
      'Video siap. Bagikan untuk menyimpannya, karena video ini dihapus '
      'saat kamu menutup jendela ini.',
      style: _body,
    ),
    const SizedBox(height: 14),
    if (_error != null) _errorText,
    InkButton(
      label: 'BAGIKAN',
      icon: Icons.ios_share,
      style: InkButtonStyle.primary,
      expand: true,
      busy: _sharing,
      onPressed: _sharing ? null : _share,
    ),
    const SizedBox(height: 10),
    _close,
  ];
}
