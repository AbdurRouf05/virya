import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/body/data/body_providers.dart';
import 'package:virya/features/body/domain/body_logic.dart';
import 'package:virya/features/body/domain/body_models.dart';

/// Kamera check-in. Pratinjau, bayangan foto lama, dan foto hasilnya sama-sama
/// dipotong 3:4 dari tengah supaya posenya bisa disejajarkan.
class BodyCameraScreen extends ConsumerStatefulWidget {
  final BodyPose pose;
  final DateTime day;

  const BodyCameraScreen({super.key, required this.pose, required this.day});

  @override
  ConsumerState<BodyCameraScreen> createState() => _BodyCameraScreenState();
}

class _BodyCameraScreenState extends ConsumerState<BodyCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _lens = 0;
  String? _error;
  bool _capturing = false;
  bool _showGhost = true;

  /// Naik setiap kali kamera dibuka/ditutup; hasil pembukaan yang sudah basi
  /// dibuang.
  int _generation = 0;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _generation++;
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // Kontroler belum ada saat dialog izin terbuka; biarkan proses itu jalan.
      final c = _controller;
      if (c == null || _capturing) return;
      _generation++;
      setState(() => _controller = null);
      c.dispose();
    } else if (state == AppLifecycleState.resumed &&
        _controller == null &&
        _error == null &&
        !_opening) {
      _open();
    }
  }

  Future<void> _open() async {
    final generation = ++_generation;
    final old = _controller;
    _opening = true;
    // Pembukaan pertama datang dari initState, saat belum ada yang berubah.
    if (old != null || _error != null) {
      setState(() {
        _controller = null;
        _error = null;
      });
    }
    try {
      await old?.dispose();
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
        final back = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        _lens = back < 0 ? 0 : back;
      }
      if (!mounted || generation != _generation) return;
      if (_cameras.isEmpty) {
        setState(() => _error = 'Kamera tidak ditemukan di HP ini.');
        return;
      }
      final c = CameraController(
        _cameras[_lens],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await c.initialize();
      if (!mounted || generation != _generation) {
        await c.dispose();
        return;
      }
      await c.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted || generation != _generation) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
    } on CameraException catch (e) {
      debugPrint('Kamera gagal dibuka: ${e.code} ${e.description}');
      if (mounted && generation == _generation) {
        setState(() => _error = _messageOf(e));
      }
    } finally {
      if (generation == _generation) _opening = false;
    }
  }

  String _messageOf(CameraException e) {
    final code = e.code.toLowerCase();
    return code.contains('access') || code.contains('permission')
        ? 'Izin kamera belum diberikan. Aktifkan di Pengaturan HP, lalu coba lagi.'
        : 'Kamera tidak bisa dibuka.';
  }

  void _switchLens() {
    if (_cameras.length < 2 || _capturing) return;
    _lens = (_lens + 1) % _cameras.length;
    _open();
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _capturing) return;
    setState(() => _capturing = true);
    final repo = ref.read(bodyRepositoryProvider);
    try {
      final shot = await c.takePicture();
      final id = await repo.ensureCheckin(widget.day);
      await repo.savePhoto(
        checkinId: id,
        pose: widget.pose,
        sourcePath: shot.path,
      );
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (e) {
      debugPrint('Foto gagal disimpan: $e');
      if (!mounted) return;
      setState(() => _capturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto gagal disimpan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries =
        ref.watch(bodyEntriesProvider).valueOrNull ?? const <BodyEntry>[];
    final ghost = bodyPreviousShot(entries, widget.pose, widget.day);
    final c = _controller;
    return Scaffold(
      backgroundColor: FN.night,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context, ghost),
            Expanded(
              child: _error != null
                  ? _errorView(context)
                  : Center(
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(color: FN.nightSurface),
                            if (c != null) _Preview(controller: c),
                            if (ghost != null && _showGhost)
                              _Ghost(path: ghost.path),
                          ],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: InkButton(
                label: 'Ambil foto',
                icon: Icons.photo_camera,
                style: InkButtonStyle.primary,
                expand: true,
                busy: _capturing,
                onPressed: c == null ? null : _capture,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, BodyShot? ghost) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    child: Row(
      children: [
        InkIconButton(
          icon: Icons.close,
          tooltip: 'Tutup',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: Text(
            widget.pose.label,
            textAlign: TextAlign.center,
            style: FN.bigNumber(28, color: FN.onNight),
          ),
        ),
        if (ghost != null) ...[
          InkIconButton(
            icon: _showGhost ? Icons.layers : Icons.layers_clear,
            tooltip: _showGhost ? 'Sembunyikan bayangan' : 'Tampilkan bayangan',
            onPressed: () => setState(() => _showGhost = !_showGhost),
          ),
          const SizedBox(width: 8),
        ],
        if (_cameras.length > 1)
          InkIconButton(
            icon: Icons.cameraswitch,
            tooltip: 'Ganti kamera',
            onPressed: _controller == null ? null : _switchLens,
          ),
      ],
    ),
  );

  Widget _errorView(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: FN.sans, fontSize: 15, color: FN.onNight),
        ),
        const SizedBox(height: 18),
        InkButton(label: 'Coba lagi', expand: true, onPressed: _open),
        const SizedBox(height: 10),
        InkButton(
          label: 'Tutup',
          expand: true,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    ),
  );
}

/// Pratinjau yang mengisi kotaknya tanpa gepeng, sisa gambar terpotong.
class _Preview extends StatelessWidget {
  final CameraController controller;
  const _Preview({required this.controller});

  @override
  Widget build(BuildContext context) {
    // aspectRatio kamera selalu sisi panjang : sisi pendek.
    const width = 300.0;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: width,
          height: width * controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _Ghost extends StatelessWidget {
  final String path;
  const _Ghost({required this.path});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Image.file(
      File(path),
      fit: BoxFit.cover,
      cacheWidth: 720,
      gaplessPlayback: true,
      opacity: const AlwaysStoppedAnimation(0.35),
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    ),
  );
}
