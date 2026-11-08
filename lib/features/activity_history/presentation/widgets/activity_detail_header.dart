import 'package:flutter/material.dart';
import 'package:virya/app/sport_ui.dart';
import 'package:virya/core/constants/enums.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Sport/gear chips, big title (tap to edit) and description.
class ActivityDetailHeader extends StatelessWidget {
  final Activity activity;
  final SportType sport;
  final Gear? gear;
  final VoidCallback onEdit;
  const ActivityDetailHeader({
    super.key,
    required this.activity,
    required this.sport,
    required this.gear,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final act = activity;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StampChip(text: sport.label, icon: sport.icon, selected: true),
              if (gear != null) StampChip(text: gear!.name),
              if (act.source == 'imported') const StampChip(text: 'IMPOR'),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onEdit,
            child: Text(
              act.title.toUpperCase(),
              style: TextStyle(
                fontFamily: FN.display,
                fontSize: 38,
                height: 1.0,
                color: FN.ink,
              ),
            ),
          ),
          if ((act.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              act.description!,
              style: TextStyle(
                fontFamily: FN.sans,
                fontSize: 14.5,
                height: 1.45,
                color: FN.inkSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
