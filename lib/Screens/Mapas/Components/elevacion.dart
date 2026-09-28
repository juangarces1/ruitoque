import 'dart:convert';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// De dónde salen las alturas del terreno (metros sobre el nivel del mar).
abstract class FuenteElevacion {
  Future<List<double>> alturas(List<LatLng> puntos);
}

/// Open-Meteo: gratis y sin clave. Modelo Copernicus de ~90 m, así que las alturas
/// son aproximadas (±5-10 m).
class OpenMeteoElevacion implements FuenteElevacion {
  static const _maxPorLlamada = 100;
  final http.Client _cliente;

  OpenMeteoElevacion({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  @override
  Future<List<double>> alturas(List<LatLng> puntos) async {
    final resultado = <double>[];
    for (var i = 0; i < puntos.length; i += _maxPorLlamada) {
      final lote = puntos.sublist(i, min(i + _maxPorLlamada, puntos.length));
      final url = Uri.https('api.open-meteo.com', '/v1/elevation', {
        'latitude': lote.map((p) => p.latitude.toStringAsFixed(6)).join(','),
        'longitude': lote.map((p) => p.longitude.toStringAsFixed(6)).join(','),
      });
      final res = await _cliente.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw Exception('Open-Meteo respondió ${res.statusCode}');
      }
      final alturas = (jsonDecode(res.body)['elevation'] as List).map((e) => (e as num).toDouble());
      resultado.addAll(alturas);
    }
    return resultado;
  }
}

/// Alturas del terreno en una cuadrícula que cubre el hoyo. Se descarga una vez
/// y después cualquier punto se calcula interpolando, sin más consultas.
class MallaElevacion {
  final double _latMin, _latMax, _lngMin, _lngMax;
  final int _n;
  final List<double> _alturas; // fila = latitud, columna = longitud

  MallaElevacion._(this._latMin, this._latMax, this._lngMin, this._lngMax, this._n, this._alturas);

  static Future<MallaElevacion> cargar(
    List<LatLng> puntos,
    FuenteElevacion fuente, {
    double margenMetros = 80,
    int n = 10,
  }) async {
    final lats = puntos.map((p) => p.latitude);
    final lngs = puntos.map((p) => p.longitude);
    final dLat = margenMetros / 111320;
    final dLng = margenMetros / (111320 * cos(lats.first * pi / 180));
    final latMin = lats.reduce(min) - dLat, latMax = lats.reduce(max) + dLat;
    final lngMin = lngs.reduce(min) - dLng, lngMax = lngs.reduce(max) + dLng;

    final nodos = [
      for (var i = 0; i < n; i++)
        for (var j = 0; j < n; j++)
          LatLng(
            latMin + (latMax - latMin) * i / (n - 1),
            lngMin + (lngMax - lngMin) * j / (n - 1),
          ),
    ];
    final alturas = await fuente.alturas(nodos);
    return MallaElevacion._(latMin, latMax, lngMin, lngMax, n, alturas);
  }

  /// Altura interpolada en [p], o null si queda fuera de la malla.
  double? alturaEn(LatLng p) {
    final fi = (p.latitude - _latMin) / (_latMax - _latMin) * (_n - 1);
    final fj = (p.longitude - _lngMin) / (_lngMax - _lngMin) * (_n - 1);
    if (fi < 0 || fj < 0 || fi > _n - 1 || fj > _n - 1) return null;

    final i0 = min(fi.floor(), _n - 2), j0 = min(fj.floor(), _n - 2);
    final ti = fi - i0, tj = fj - j0;
    double h(int i, int j) => _alturas[i * _n + j];
    final sur = h(i0, j0) * (1 - tj) + h(i0, j0 + 1) * tj;
    final norte = h(i0 + 1, j0) * (1 - tj) + h(i0 + 1, j0 + 1) * tj;
    return sur * (1 - ti) + norte * ti;
  }
}

/// Distancia que "juega" un tiro de [yardas] con [desnivelMetros] entre la bola y
/// el objetivo (positivo = cuesta arriba). Regla práctica: 1 m de desnivel ≈ 1 m
/// de distancia. Devuelve null si el desnivel es menor a 2 m (dentro del error).
int? juegaComo(int yardas, double desnivelMetros) {
  if (desnivelMetros.abs() < 2) return null;
  return yardas + (desnivelMetros * 1.09361).round();
}
