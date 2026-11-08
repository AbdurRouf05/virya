import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/gym/application/gym_session_controller.dart';
import 'package:virya/features/gym/domain/gym_models.dart';
import 'package:virya/features/gym/presentation/gym_session_screen.dart';
import 'package:virya/features/gym/presentation/widgets/gym_template_picker_sheet.dart';

/// Buka layar sesi yang sedang berjalan.
Future<void> openGymSession(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute(builder: (_) => const GymSessionScreen()));

/// Titik masuk "MULAI GYM": lanjutkan sesi aktif, atau pilih template lalu
/// mulai sesi baru.
Future<void> startGymFlow(
  BuildContext context,
  WidgetRef ref, {
  GymTemplate? template,
  bool askTemplate = true,
}) async {
  final ctl = ref.read(gymSessionProvider.notifier);
  if (ref.read(gymSessionProvider) != null || await ctl.resume()) {
    if (context.mounted) await openGymSession(context);
    return;
  }
  if (!context.mounted) return;
  var picked = template;
  if (picked == null && askTemplate) {
    final choice = await showGymTemplatePicker(context);
    if (choice == null) return;
    picked = choice.template;
  }
  await ctl.start(template: picked);
  if (context.mounted) await openGymSession(context);
}
