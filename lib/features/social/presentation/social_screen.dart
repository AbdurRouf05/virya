import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/widgets/field_kit.dart';
import 'package:virya/features/social/data/social_providers.dart';
import 'package:virya/features/social/presentation/circle_qr_scanner_screen.dart';
import 'package:virya/features/social/presentation/widgets/circle_actions.dart';

class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(socialRepositoryProvider);
    final identity = ref.watch(socialIdentityProvider).valueOrNull;
    final circles = ref.watch(socialCirclesProvider).valueOrNull ?? const [];
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              Masthead(
                kicker: 'Offline Running Club',
                title: 'Circle',
                subtitle: 'Privat di perangkatmu',
                actions: [
                  InkIconButton(
                    icon: Icons.qr_code_scanner,
                    tooltip: 'Pindai QR Circle',
                    size: 36,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CircleQrScannerScreen(),
                        ),
                      );
                      ref.invalidate(socialCirclesProvider);
                    },
                  ),
                  InkIconButton(
                    icon: Icons.person_add_alt_1_outlined,
                    tooltip: 'Simpan undangan manual',
                    size: 36,
                    onPressed:
                        identity == null
                            ? null
                            : () async {
                              await showAcceptInviteDialog(context, repo);
                              ref.invalidate(socialCirclesProvider);
                            },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkBox(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'Undangan ditandatangani pemilik, tetapi belum terenkripsi. '
                      'Belum ada transfer antarperangkat atau sinkronisasi server.',
                      style: FN.body(size: 12, color: FN.inkMuted),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(number: '01', title: 'Identitas perangkat'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    identity == null
                        ? InkButton(
                          label: 'Buat identitas',
                          icon: Icons.badge_outlined,
                          expand: true,
                          onPressed: () async {
                            await showIdentityDialog(context, repo);
                            ref.invalidate(socialIdentityProvider);
                            ref.invalidate(socialCirclesProvider);
                          },
                        )
                        : _IdentityCard(
                          name: identity.displayName,
                          onCopy: () async {
                            final code = await repo.createPairingRequest();
                            if (!context.mounted) return;
                            await showCode(context, 'Kode permintaan', code);
                          },
                        ),
              ),
              SectionHeader(number: '02', title: 'Circle privat'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkButton(
                  label: 'Buat circle',
                  icon: Icons.group_add_outlined,
                  expand: true,
                  onPressed:
                      identity == null
                          ? null
                          : () async {
                            await showCreateCircleDialog(context, repo);
                            ref.invalidate(socialCirclesProvider);
                          },
                ),
              ),
              if (identity != null && circles.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada circle. Buat satu untuk run club-mu, atau simpan undangan dari teman.',
                    textAlign: TextAlign.center,
                    style: FN.body(size: 12, color: FN.inkMuted),
                  ),
                ),
              for (final circle in circles)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: InkBox(
                    child: ListTile(
                      leading: Icon(Icons.groups_outlined, color: FN.signal),
                      title: Text(
                        circle.name,
                        style: FN.heading(size: 15, color: FN.ink),
                      ),
                      subtitle: Text(
                        circle.ownerIdentityId == identity?.id
                            ? 'Kamu pemilik circle'
                            : 'Undangan tersimpan di perangkat ini',
                        style: FN.label(size: 10, color: FN.inkMuted),
                      ),
                      trailing:
                          circle.ownerIdentityId == identity?.id
                              ? IconButton(
                                icon: const Icon(Icons.qr_code_outlined),
                                tooltip: 'Buat undangan',
                                onPressed:
                                    () => showIssueInviteDialog(
                                      context,
                                      repo,
                                      circle.id,
                                    ),
                              )
                              : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final String name;
  final VoidCallback onCopy;

  const _IdentityCard({required this.name, required this.onCopy});

  @override
  Widget build(BuildContext context) => InkBox(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.badge_outlined, color: FN.signal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: FN.heading(size: 16, color: FN.ink)),
          ),
          TextButton.icon(
            icon: const Icon(Icons.qr_code, size: 16),
            label: const Text('Kode QR'),
            onPressed: onCopy,
          ),
        ],
      ),
    ),
  );
}
