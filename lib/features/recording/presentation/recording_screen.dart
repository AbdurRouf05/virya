import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:virya/app/integrations.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/permissions/tracking_permissions.dart';
import 'package:virya/features/activity_history/presentation/activity_detail_screen.dart';
import 'package:virya/features/recording/application/recording_controller.dart';
import 'package:virya/features/recording/domain/recording_settings.dart';
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';
import 'package:virya/features/recording/presentation/widgets/amoled_hud_panel.dart';
import 'package:virya/features/recording/presentation/widgets/recording_controls.dart';
import 'package:virya/features/recording/presentation/widgets/recording_dialogs.dart';
import 'package:virya/features/recording/presentation/widgets/recording_map_panel.dart';
import 'package:virya/features/recording/presentation/widgets/recording_metric_grid.dart';
import 'package:virya/features/recording/presentation/widgets/recording_primary_metric.dart';
import 'package:virya/features/recording/presentation/widgets/recording_saving_overlay.dart';
import 'package:virya/features/recording/presentation/widgets/recording_sport_strip.dart';
import 'package:virya/features/recording/presentation/widgets/recording_top_bar.dart';

/// Live recording screen (night palette, glove-friendly controls).
class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  late final RecordingController _ctrl =
      ref.read(recordingControllerProvider.notifier);
  bool _busy = false;

  bool _amoledMode = false;
  bool _isPeeking = false;
  int _peekSecondsRemaining = 15;
  Timer? _peekTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    if (!ref.read(recordingControllerProvider).isActive) {
      await _ctrl.loadSettings();
    }
    if (!mounted) return;
    final db = ref.read(databaseProvider);
    final amoledSetting = await db.getSetting(RecordingSettings.keyAmoledHud);
    if (mounted && amoledSetting != null) {
      setState(() => _amoledMode = amoledSetting == 'true');
    }
    if (!mounted) return;
    final s = ref.read(recordingControllerProvider);
    if (s.phase != RecordingPhase.idle || s.simulated) return;
    final ok = await TrackingPermissions.ensureForRecording(
      context,
      db: db,
    );
    if (ok && mounted) await _ctrl.warmUp();
  }

  @override
  void dispose() {
    _peekTimer?.cancel();
    _ctrl.coolDown();
    super.dispose();
  }

  void _peekMap() {
    _peekTimer?.cancel();
    setState(() {
      _isPeeking = true;
      _peekSecondsRemaining = 15;
    });
    _peekTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_peekSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _isPeeking = false;
          _peekSecondsRemaining = 15;
        });
      } else {
        setState(() {
          _peekSecondsRemaining--;
        });
      }
    });
  }

  void _stopPeeking() {
    _peekTimer?.cancel();
    if (mounted) {
      setState(() {
        _isPeeking = false;
        _peekSecondsRemaining = 15;
      });
    }
  }

  void _toggleAmoled() {
    setState(() {
      _amoledMode = !_amoledMode;
      if (!_amoledMode) {
        _stopPeeking();
      }
    });
    final db = ref.read(databaseProvider);
    unawaited(db.setSetting(RecordingSettings.keyAmoledHud, _amoledMode.toString()));
    _snack(_amoledMode
        ? 'Mode Layar Hemat (AMOLED HUD) aktif. Sentuh layar untuk intip peta.'
        : 'Mode Peta normal aktif.');
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final s = ref.read(recordingControllerProvider);
      final ok = await TrackingPermissions.ensureForRecording(
        context,
        db: ref.read(databaseProvider),
        simulated: s.simulated,
      );
      if (!ok || !mounted) return;
      HapticFeedback.mediumImpact();
      await _ctrl.start();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop() async {
    final id = await _ctrl.stop();
    if (!mounted) return;
    if (id != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ActivityDetailScreen(activityId: id),
      ));
    }
  }

  Future<void> _discard() async {
    final yes = await showDiscardRecordingDialog(context);
    if (yes != true) return;
    await _ctrl.discard();
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _photo() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2560,
      );
      if (x == null) return;
      final ok = await _ctrl.addPhoto(x.path);
      if (ok && mounted) _snack('Foto tersimpan di rute');
    } catch (e) {
      if (mounted) _snack('Kamera tidak tersedia');
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text, style: TextStyle(fontFamily: FN.sans)),
        backgroundColor: FN.nightSurface,
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _pickSport(SportType current) async {
    final picked = await showRecordingSportPicker(context, current);
    if (picked != null) _ctrl.selectSport(picked);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(recordingControllerProvider);
    ref.listen<String?>(
      recordingControllerProvider.select((v) => v.message),
      (_, msg) {
        if (msg == null) return;
        _snack(msg);
        _ctrl.clearMessage();
      },
    );
    final fmt = RecFormat(imperial: s.imperial);

    return PopScope(
      canPop: !s.isActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && s.isActive) {
          _snack('Rekaman berjalan. Jeda lalu tahan SELESAI untuk menyimpan.');
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: _amoledMode ? Colors.black : Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: _amoledMode ? Colors.black : FN.night,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    RecordingTopBar(
                      state: s,
                      onClose: () => Navigator.of(context).maybePop(),
                      onSport: () => _pickSport(s.sport),
                      amoledMode: _amoledMode,
                      onToggleAmoled: _toggleAmoled,
                    ),
                    ref.watch(integrationsProvider).recordingSegmentHud(),
                    if (_amoledMode && !_isPeeking)
                      Expanded(
                        child: AmoledHudPanel(
                          state: s,
                          fmt: fmt,
                          onPeek: _peekMap,
                        ),
                      )
                    else ...[
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            RecordingMapPanel(state: s),
                            if (_amoledMode && _isPeeking)
                              Positioned(
                                top: 10,
                                left: 20,
                                right: 20,
                                child: _PeekCountdownBanner(
                                  secondsRemaining: _peekSecondsRemaining,
                                  onCancelPeek: _stopPeeking,
                                ),
                              ),
                          ],
                        ),
                      ),
                      RecordingPrimaryMetric(state: s, fmt: fmt),
                      RecordingMetricGrid(state: s, fmt: fmt),
                    ],
                    const SizedBox(height: 10),
                    if (s.phase == RecordingPhase.idle)
                      RecordingSportStrip(
                        selected: s.sport,
                        onSelect: _ctrl.selectSport,
                      ),
                    RecordingControls(
                      state: s,
                      busy: _busy,
                      onStart: _start,
                      onPause: _ctrl.pause,
                      onResume: _ctrl.resume,
                      onStop: _stop,
                      onDiscard: _discard,
                      onPhoto: _photo,
                      onToggleSim: (v) => _ctrl.setSimulated(v),
                    ),
                  ],
                ),
                if (s.phase == RecordingPhase.saving) const RecordingSavingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeekCountdownBanner extends StatelessWidget {
  final int secondsRemaining;
  final VoidCallback onCancelPeek;

  const _PeekCountdownBanner({
    required this.secondsRemaining,
    required this.onCancelPeek,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: FN.acid, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.visibility, size: 16, color: FN.acid),
            const SizedBox(width: 8),
            Text(
              'INTIP PETA: ${secondsRemaining}S',
              style: FN.label(size: 11, color: FN.acid).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onCancelPeek,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TUTUP',
                      style: FN.label(size: 10, color: Colors.white).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.close, size: 12, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
