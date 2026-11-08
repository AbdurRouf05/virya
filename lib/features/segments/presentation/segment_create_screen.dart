import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/data/activity_repository.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/segments/presentation/widgets/segment_create_form.dart';

/// Membuat segmen dari potongan rute sebuah aktivitas.
class SegmentCreateScreen extends ConsumerWidget {
  final String activityId;
  const SegmentCreateScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundle = ref.watch(activityBundleProvider(activityId));
    return Scaffold(
      appBar: AppBar(title: const Text('Buat segmen')),
      body: PaperBackground(
        child: bundle.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text('Gagal membaca rute.')),
          data: (b) => b == null
              ? const Center(child: Text('Aktivitas sudah dihapus.'))
              : SegmentCreateForm(
                  samples: b.samples,
                  sportType: b.activity.sportType,
                ),
        ),
      ),
    );
  }
}
