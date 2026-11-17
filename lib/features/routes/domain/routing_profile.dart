import 'package:virya/features/routes/domain/route_models.dart';

/// Profil BRouter per olahraga. Medan (datar/tanjakan) diatur lewat pemilihan
/// kandidat, bukan profil, supaya hasilnya tetap lewat jalan yang wajar.
String brouterProfile(RouteSport sport, {required bool avoidMain}) =>
    switch (sport) {
      RouteSport.ride => avoidMain ? 'safety' : 'trekking',
      RouteSport.run || RouteSport.walk =>
        avoidMain ? 'hiking-mountain' : 'shortest',
    };

/// Profil OSRM cadangan (routing.openstreetmap.de).
String osrmProfile(RouteSport sport) => switch (sport) {
      RouteSport.ride => 'routed-bike',
      RouteSport.run || RouteSport.walk => 'routed-foot',
    };
