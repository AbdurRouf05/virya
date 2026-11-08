import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/app/theme/field_notes.dart';
import 'package:virya/core/data/activity_repository.dart';
import 'package:virya/features/share/domain/share_data.dart';
import 'package:virya/features/share/presentation/widgets/studio_body.dart';

/// Share studio: swipe templates, pick format/stats/accent, export PNG,
/// or render the recap MP4 (Android).
class ShareStudioScreen extends ConsumerWidget {
  final String activityId;
  const ShareStudioScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activityBundleProvider(activityId));
    return Scaffold(
      backgroundColor: FN.night,
      appBar: AppBar(
        backgroundColor: FN.night,
        foregroundColor: FN.onNight,
        elevation: 0,
        title: Text('STUDIO BAGIKAN',
            style: FN.label(size: 13, color: FN.onNight)
                .copyWith(fontWeight: FontWeight.w700, letterSpacing: 2)),
      ),
      body: async.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: FN.signal)),
        error: (e, _) => _Message('Gagal memuat aktivitas\n$e'),
        data: (b) => b == null
            ? const _Message('Aktivitas tidak ditemukan')
            : ShareStudioBody(data: ShareData.fromBundle(b)),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  const _Message(this.text);
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text,
              textAlign: TextAlign.center,
              style: FN.label(size: 12, color: FN.onNight)),
        ),
      );
}
