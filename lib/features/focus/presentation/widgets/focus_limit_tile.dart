import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/focus/domain/focus_logic.dart';
import 'package:virya/features/focus/domain/focus_models.dart';

/// Satu baris batas aplikasi. [status] null berarti batasnya sedang mati.
class FocusLimitTile extends StatelessWidget {
  final FocusLimit limit;
  final FocusAppStatus? status;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FocusLimitTile({
    super.key,
    required this.limit,
    required this.status,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  String get _detail {
    final s = status;
    if (s == null) {
      return 'Mati, batas ${formatFocusMinutes(limit.dailyMinutes)} per hari';
    }
    return '${formatFocusMinutes(s.usedMinutes)} dari '
        '${formatFocusMinutes(s.allowedMinutes)} hari ini';
  }

  @override
  Widget build(BuildContext context) {
    final over = status?.isOver ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: Semantics(
                button: true,
                label: 'Ubah batas ${limit.label}',
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        limit.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FN.sans,
                          fontSize: 15,
                          color: FN.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _detail,
                        style: FN.label(
                          size: 11,
                          color: over ? FN.warn : FN.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Switch(value: limit.enabled, onChanged: onToggle),
          IconButton(
            tooltip: 'Hapus batas',
            onPressed: onDelete,
            icon: Icon(Icons.close, size: 20, color: FN.inkMuted),
          ),
        ],
      ),
    );
  }
}
