import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/social/data/social_repository.dart';

final socialRepositoryProvider = Provider<SocialRepository>(
  (ref) => SocialRepository(ref.watch(socialDaoProvider)),
);

final socialIdentityProvider = FutureProvider((ref) {
  return ref.watch(socialRepositoryProvider).localIdentity();
});

final socialCirclesProvider = StreamProvider((ref) async* {
  final identity = await ref.watch(socialIdentityProvider.future);
  if (identity == null) {
    yield const [];
    return;
  }
  yield* ref.watch(socialDaoProvider).watchCircles(identity.id);
});
