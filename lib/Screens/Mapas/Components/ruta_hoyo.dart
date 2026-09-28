import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Ruta planeada de un hoyo: origen (tee o último golpe) → puntos intermedios → objetivo.
///
/// Par 3, par 4 y par 5 son la misma ruta con distinta cantidad de intermedios.
/// Los intermedios se arrastran en el mapa; si no hay intermedios, se arrastra el objetivo.
class RutaHoyo {
  final LatLng origen;
  final List<LatLng> intermedios;
  LatLng objetivo;

  RutaHoyo({
    required this.origen,
    required this.intermedios,
    required this.objetivo,
  });

  /// Golpes antes del golpe al green: par 3 → 0, par 4 → 1, par 5 → 2,
  /// y cada golpe ya dado resta uno.
  static int intermediosPara({required int par, required int golpesDados}) =>
      max(0, par - 3 - golpesDados);

  /// Ruta inicial hacia el centro del green. Con un solo intermedio usa [centroHoyo]
  /// si se conoce; si no, reparte los intermedios a partes iguales.
  factory RutaHoyo.planear({
    required LatLng origen,
    required LatLng green,
    required int cantidadIntermedios,
    LatLng? centroHoyo,
  }) {
    final intermedios = (cantidadIntermedios == 1 && centroHoyo != null)
        ? [centroHoyo]
        : [
            for (var i = 1; i <= cantidadIntermedios; i++)
              interpolar(origen, green, i / (cantidadIntermedios + 1)),
          ];
    return RutaHoyo(origen: origen, intermedios: intermedios, objetivo: green);
  }

  List<LatLng> get puntos => [origen, ...intermedios, objetivo];

  bool get objetivoMovible => intermedios.isEmpty;

  List<int> get tramosYardas {
    final p = puntos;
    return [for (var i = 0; i < p.length - 1; i++) yardasEntre(p[i], p[i + 1])];
  }

  int get totalYardas => tramosYardas.fold(0, (a, b) => a + b);

  /// Punto medio de cada tramo, donde se dibuja su distancia.
  List<LatLng> get centrosTramos {
    final p = puntos;
    return [for (var i = 0; i < p.length - 1; i++) interpolar(p[i], p[i + 1], 0.5)];
  }

  void moverIntermedio(int indice, LatLng posicion) => intermedios[indice] = posicion;

  void moverObjetivo(LatLng posicion) => objetivo = posicion;
}

int yardasEntre(LatLng a, LatLng b) {
  final metros = Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
  return (metros * 1.09361).round();
}

/// Interpolación lineal; a escala de un hoyo de golf la curvatura es despreciable.
LatLng interpolar(LatLng a, LatLng b, double t) => LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );

/// Rumbo de [desde] hacia [hasta] en grados (0 = norte), para orientar la cámara.
double rumbo(LatLng desde, LatLng hasta) {
  double rad(double g) => g * pi / 180;
  final lat1 = rad(desde.latitude);
  final lat2 = rad(hasta.latitude);
  var dLon = rad(hasta.longitude - desde.longitude);
  final dPhi = log(tan(lat2 / 2 + pi / 4) / tan(lat1 / 2 + pi / 4));
  if (dLon.abs() > pi) {
    dLon = dLon > 0 ? -(2 * pi - dLon) : (2 * pi + dLon);
  }
  return (atan2(dLon, dPhi) * 180 / pi + 360) % 360;
}

/// Zoom para que un recorrido de [metros] quepa en pantalla (orientado a lo largo).
double zoomParaDistancia(double metros) {
  final d = metros + 36; // margen
  if (d > 6000) return 13.5;
  if (d > 5000) return 14.0;
  if (d > 4000) return 14.5;
  if (d > 3000) return 15.0;
  if (d > 2000) return 15.5;
  if (d > 1500) return 16.0;
  if (d > 1000) return 16.5;
  if (d > 700) return 17.0;
  if (d > 500) return 17.5;
  if (d > 350) return 18.0;
  if (d > 200) return 18.5;
  if (d > 120) return 19.0;
  return 19.5;
}
