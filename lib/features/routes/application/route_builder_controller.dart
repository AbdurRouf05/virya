import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/maps/data/current_position.dart';
import 'package:virya/features/routes/application/route_generator.dart';
import 'package:virya/features/routes/data/route_providers.dart';
import 'package:virya/features/routes/data/routing_client.dart';
import 'package:virya/features/routes/domain/route_models.dart';
import 'package:virya/features/routes/domain/route_scoring.dart';
import 'package:virya/features/routes/domain/route_stats.dart';

/// Status layar "Buat rute" (Atur → pilihan).
class RouteBuilderState {
  final RoutePrefs prefs;
  final bool locating;
  final bool loading;
  final List<RouteCandidate> candidates;
  final int selected;
  final String? error;

  const RouteBuilderState({
    this.prefs = const RoutePrefs(),
    this.locating = false,
    this.loading = false,
    this.candidates = const [],
    this.selected = 0,
    this.error,
  });

  RouteCandidate? get current =>
      candidates.isEmpty ? null : candidates[selected.clamp(0, candidates.length - 1)];

  RouteBuilderState copyWith({
    RoutePrefs? prefs,
    bool? locating,
    bool? loading,
    List<RouteCandidate>? candidates,
    int? selected,
    String? error,
    bool clearError = false,
  }) =>
      RouteBuilderState(
        prefs: prefs ?? this.prefs,
        locating: locating ?? this.locating,
        loading: loading ?? this.loading,
        candidates: candidates ?? this.candidates,
        selected: selected ?? this.selected,
        error: clearError ? null : (error ?? this.error),
      );
}

class RouteBuilderController extends AutoDisposeNotifier<RouteBuilderState> {
  TrackGrid? _grid;
  LatLon? _gridCenter;
  int _run = 0;

  @override
  RouteBuilderState build() => const RouteBuilderState();

  void _prefs(RoutePrefs p) =>
      state = state.copyWith(prefs: p, clearError: true);

  /// Mengisi titik mulai dari lokasi sekarang (bila belum ada).
  Future<void> locate({bool force = false}) async {
    if (state.prefs.start != null && !force) return;
    state = state.copyWith(locating: true, clearError: true);
    try {
      final p = await currentLatLon();
      state = state.copyWith(
          locating: false, prefs: state.prefs.copyWith(start: p));
    } on PositionUnavailable catch (e) {
      state = state.copyWith(locating: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          locating: false, error: 'Lokasi belum didapat. Ketuk peta.');
    }
  }

  /// Ketukan peta: tujuan untuk A → B / pergi-pulang, selain itu titik mulai.
  void tapMap(LatLon p, {bool asDestination = false}) => _prefs(asDestination
      ? state.prefs.copyWith(destination: p)
      : state.prefs.copyWith(start: p));

  void clearDestination() =>
      _prefs(state.prefs.copyWith(clearDestination: true));

  void setSport(RouteSport s) {
    final km = (state.prefs.targetM / 1000).clamp(s.minKm, s.maxKm);
    _prefs(state.prefs.copyWith(
      sport: s,
      targetM: (s == state.prefs.sport ? km : s.defaultKm) * 1000,
    ));
  }

  void setTargetKm(double km) => _prefs(state.prefs.copyWith(
      targetM: km.clamp(state.prefs.sport.minKm, state.prefs.sport.maxKm) *
          1000));

  void setShape(RouteShape s) => _prefs(state.prefs.copyWith(shape: s));
  void setTerrain(RouteTerrain t) => _prefs(state.prefs.copyWith(terrain: t));
  void setPreferNew(bool v) => _prefs(state.prefs.copyWith(preferNew: v));
  void setAvoidMain(bool v) => _prefs(state.prefs.copyWith(avoidMain: v));
  void select(int i) => state = state.copyWith(selected: i);

  /// Membuat (atau mengacak ulang) tiga pilihan. Diabaikan bila sedang jalan.
  Future<bool> generate() async {
    if (state.loading) return false;
    final prefs = state.prefs;
    if (prefs.start == null) {
      state = state.copyWith(error: 'Titik mulai belum ada. Ketuk peta dulu.');
      return false;
    }
    final run = ++_run;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final grid = prefs.preferNew ? await _history(prefs) : null;
      final gen = RouteGenerator(ref.read(routingClientProvider));
      final list = await gen.generate(prefs, history: grid);
      if (run != _run) return false;
      state = state.copyWith(loading: false, candidates: list, selected: 0);
      return list.isNotEmpty;
    } on RoutingException catch (e) {
      if (run == _run) state = state.copyWith(loading: false, error: e.message);
    } catch (_) {
      if (run == _run) {
        state = state.copyWith(
            loading: false, error: 'Rute gagal dibuat. Coba lagi.');
      }
    }
    return false;
  }

  Future<TrackGrid?> _history(RoutePrefs p) async {
    final c = p.start!;
    if (_grid != null && _gridCenter == c) return _grid;
    try {
      _grid = await ref
          .read(routeRepositoryProvider)
          .trackGrid(c, p.targetM / 2 + 2000);
      _gridCenter = c;
      return _grid!.isEmpty ? null : _grid;
    } catch (_) {
      return null;
    }
  }
}

final routeBuilderProvider =
    AutoDisposeNotifierProvider<RouteBuilderController, RouteBuilderState>(
        RouteBuilderController.new);

/// Kecepatan pengguna per olahraga untuk perkiraan waktu.
final sportPaceProvider =
    FutureProvider.autoDispose.family<SportPace, RouteSport>(
  (ref, s) async {
    try {
      return await ref.read(routeRepositoryProvider).pace(s);
    } catch (_) {
      return SportPace.fallback(s);
    }
  },
);
