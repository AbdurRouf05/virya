import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virya/features/social/data/social_repository.dart';
import 'package:virya/features/social/domain/circle_invite.dart';

Future<void> showIdentityDialog(
  BuildContext context,
  SocialRepository repo,
) async {
  final name = TextEditingController();
  await showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Buat identitas lari'),
          content: TextField(
            controller: name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Nama atau alias'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (await repo.ensureIdentity(name.text) != null &&
                    context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
  );
}

Future<void> showCreateCircleDialog(
  BuildContext context,
  SocialRepository repo,
) async {
  final name = TextEditingController();
  await showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Circle privat baru'),
          content: TextField(
            controller: name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Contoh: Night Runners',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (await repo.createCircle(name.text) != null &&
                    context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Buat'),
            ),
          ],
        ),
  );
}

Future<void> showAcceptInviteDialog(
  BuildContext context,
  SocialRepository repo,
) async {
  final payload = TextEditingController();
  await _textDialog(
    context,
    title: 'Simpan undangan',
    hint: 'Tempel kode undangan',
    controller: payload,
    confirm: 'Verifikasi',
    onConfirm: () => repo.acceptInvite(payload.text),
    showResult: false,
  );
}

Future<void> showIssueInviteDialog(
  BuildContext context,
  SocialRepository repo,
  String circleId,
) async {
  final request = TextEditingController();
  await _textDialog(
    context,
    title: 'Buat undangan',
    hint: 'Tempel kode permintaan teman',
    controller: request,
    confirm: 'Buat kode',
    onConfirm: () => repo.issueInvite(circleId, request.text),
  );
}

Future<void> _textDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required TextEditingController controller,
  required String confirm,
  required Future<String> Function() onConfirm,
  bool showResult = true,
}) async {
  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final code = await onConfirm();
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  if (showResult) {
                    await _showCodeDialog(dialogContext, code);
                  } else {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Undangan tersimpan di perangkat ini'),
                      ),
                    );
                  }
                } on InviteFormatException catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text(e.message)));
                  }
                } on StateError catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text(e.message)));
                  }
                }
              },
              child: Text(confirm),
            ),
          ],
        ),
  );
}

Future<void> _showCodeDialog(BuildContext context, String code) =>
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Kode siap dibagikan'),
            content: SelectableText(code),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Salin'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Selesai'),
              ),
            ],
          ),
    );

Future<void> showCode(BuildContext context, String title, String code) =>
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SelectableText(code),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Salin'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Selesai'),
              ),
            ],
          ),
    );
