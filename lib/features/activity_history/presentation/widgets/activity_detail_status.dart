import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Loading placeholder or a full-page message (error / not found).
class ActivityDetailStatus extends StatelessWidget {
  final String? title;
  final String? body;

  const ActivityDetailStatus.loading({super.key}) : title = null, body = null;

  const ActivityDetailStatus.message(
    String this.title,
    String this.body, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = title;
    if (t == null) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MEMBACA CATATAN…',
                style: FN.label(size: 12, color: FN.ink),
              ),
              const SizedBox(height: 12),
              const SizedBox(width: 160, child: LinearProgressIndicator()),
              const SizedBox(height: 8),
              Text(
                'menganalisis tanjakan, sektor & split',
                style: FN.label(size: 9.5),
              ),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 24),
            Text(
              t.toUpperCase(),
              style: TextStyle(
                fontFamily: FN.display,
                fontSize: 40,
                color: FN.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(body ?? ''),
          ],
        ),
      ),
    );
  }
}
