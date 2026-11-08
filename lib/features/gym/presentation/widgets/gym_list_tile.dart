import 'package:flutter/material.dart';
import 'package:virya/core/widgets/field_kit.dart';

/// Baris daftar beranda gym: judul besar, keterangan mono, aksi kanan.
class GymListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData trailing;
  final VoidCallback onTap;
  final VoidCallback? onTrailing;

  const GymListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing = Icons.chevron_right,
    this.onTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FN.display,
                      fontSize: 20,
                      color: FN.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FN.label(size: 9.5),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(trailing, color: FN.ink),
              onPressed: onTrailing ?? onTap,
            ),
          ],
        ),
      ),
    );
  }
}
