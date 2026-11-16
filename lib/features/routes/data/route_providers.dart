import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/database/app_database.dart';
import 'package:virya/features/routes/data/brouter_client.dart';
import 'package:virya/features/routes/data/route_repository.dart';
import 'package:virya/features/routes/data/routing_client.dart';
import 'package:virya/features/routes/domain/route_models.dart';

final routingClientProvider =
    Provider<RoutingClient>((ref) => BrouterClient());

final routeRepositoryProvider = Provider<RouteRepository>(
  (ref) => RouteRepository(ref.watch(databaseProvider)),
);

final savedRoutesProvider = StreamProvider<List<SavedRoute>>(
  (ref) => ref.watch(routeRepositoryProvider).watchAll(),
);

/// Rute yang sedang diikuti saat merekam (publik untuk peta perekaman).
final activeRouteProvider = StateProvider<SavedRoute?>((ref) => null);

/// `true` bila layar rute dibuka dari layar perekaman, supaya "Mulai rekam"
/// cukup kembali ke perekaman yang sudah terbuka.
final routesFromRecordingProvider = StateProvider<bool>((ref) => false);
