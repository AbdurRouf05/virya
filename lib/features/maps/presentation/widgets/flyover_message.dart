import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

/// Centered status message (optionally with a spinner) + back button.
class FlyoverMessage extends StatelessWidget {
  const FlyoverMessage(this.message, {super.key, this.loading = false});
  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (loading) CircularProgressIndicator(color: FN.acid),
                  if (loading) const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: FN.label(size: 12, color: FN.paper),
                  ),
                ],
              ),
            ),
            Positioned(left: 4, top: 4, child: BackButton(color: FN.paper)),
          ],
        ),
      );
}
