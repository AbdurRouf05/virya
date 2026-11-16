import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/features/routes/data/route_providers.dart';
import 'package:virya/features/routes/data/routing_client.dart';
import 'package:virya/features/routes/domain/route_legs.dart';
import 'package:virya/features/routes/domain/route_models.dart';

/// Status mode edit manual: titik-titik ketukan dan potongan jalan di antaranya.
class RouteEditorState {
  final SavedRoute? source;
  final RouteSport sport;
  final bool avoidMain;
  final List<LatLon> stops;
  final List<RoutePath> legs;
  final bool busy;
  final String? error;

  const RouteEditorState({
    this.source,
    this.sport = RouteSport.ride,
    this.avoidMain = false,
    this.stops = const [],
    this.legs = const [],
    this.busy = false,
    this.error,
  });

  RoutePath get path => legs.isEmpty ? RoutePath.empty : RoutePath.join(legs);
  bool get canUndo => stops.isNotEmpty && !busy;
  bool get canClose =>
      stops.length >= 2 && stops.last != stops.first && !busy;
  bool get canReverse => legs.isNotEmpty && !busy;

  RouteEditorState copyWith({
    RouteSport? sport,
    bool? avoidMain,
    List<LatLon>? stops,
    List<RoutePath>? legs,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      RouteEditorState(
        source: source,
        sport: sport ?? this.sport,
        avoidMain: avoidMain ?? this.avoidMain,
        stops: stops ?? this.stops,
        legs: legs ?? this.legs,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );
}

class RouteEditorController extends AutoDisposeNotifier<RouteEditorState> {
  @override
  RouteEditorState build() => const RouteEditorState();

  /// Mulai dari rute yang ada, atau kosong (dari nol).
  void load(SavedRoute? r, {RouteSport sport = RouteSport.ride}) {
    if (r == null || r.path.isEmpty) {
      state = RouteEditorState(sport: r?.sport ?? sport);
      return;
    }
    final stops = r.waypoints.length >= 2
        ? r.waypoints
        : [r.path.points.first, r.path.points.last];
    final legs = splitAtStops(r.path, stops);
    state = RouteEditorState(
      source: r,
      sport: r.sport,
      stops: legs.length == stops.length - 1
          ? stops
          : [r.path.points.first, r.path.points.last],
      legs: legs.length == stops.length - 1 ? legs : [r.path],
    );
  }

  void setSport(RouteSport s) => state = state.copyWith(sport: s);
  void setAvoidMain(bool v) => state = state.copyWith(avoidMain: v);

  /// Menambah titik; potongan baru mengikuti jalan lewat routing.
  Future<void> addPoint(LatLon p) async {
    if (state.busy) return;
    if (state.stops.isEmpty) {
      state = state.copyWith(stops: [p], clearError: true);
      return;
    }
    final from = state.stops.last;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final leg = await ref.read(routingClientProvider).route([from, p],
          sport: state.sport, avoidMain: state.avoidMain);
      state = state.copyWith(
        busy: false,
        stops: [...state.stops, p],
        legs: [...state.legs, leg],
      );
    } on RoutingException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          busy: false, error: 'Jalan ke titik itu tidak ditemukan.');
    }
  }

  void undo() {
    if (!state.canUndo) return;
    final stops = [...state.stops]..removeLast();
    final legs = [...state.legs];
    if (legs.isNotEmpty) legs.removeLast();
    state = state.copyWith(stops: stops, legs: legs, clearError: true);
  }

  /// Menyambung kembali ke titik awal (jadi rute keliling).
  Future<void> closeLoop() async {
    if (state.canClose) await addPoint(state.stops.first);
  }

  void reverse() {
    if (!state.canReverse) return;
    state = state.copyWith(
      stops: state.stops.reversed.toList(),
      legs: [for (final l in state.legs.reversed) l.reversed()],
      clearError: true,
    );
  }
}

final routeEditorProvider =
    AutoDisposeNotifierProvider<RouteEditorController, RouteEditorState>(
        RouteEditorController.new);
