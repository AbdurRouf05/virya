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
import 'package:virya/features/recording/domain/recording_state.dart';
import 'package:virya/features/recording/presentation/recording_format.dart';
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
    final s = ref.read(recordingControllerProvider);
    if (s.phase != RecordingPhase.idle || s.simulated) return;
    final ok = await TrackingPermissions.ensureForRecording(
      context,
      db: ref.read(databaseProvider),
    );
    if (ok && mounted) await _ctrl.warmUp();
  }

  @override
  void dispose() {
    _ctrl.coolDown();
    super.dispose();
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
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: FN.night,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    RecordingTopBar(
                      state: s,
                      onClose: () => Navigator.of(context).maybePop(),
                      onSport: () => _pickSport(s.sport),
                    ),
                    ref.watch(integrationsProvider).recordingSegmentHud(),
                    Expanded(flex: 5, child: RecordingMapPanel(state: s)),
                    RecordingPrimaryMetric(state: s, fmt: fmt),
                    RecordingMetricGrid(state: s, fmt: fmt),
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
