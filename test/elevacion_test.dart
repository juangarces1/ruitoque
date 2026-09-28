import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ruitoque/Screens/Mapas/Components/elevacion.dart';

/// Terreno de prueba: sube 1 m por cada 0.0001° de latitud hacia el norte.
class _RampaNorte implements FuenteElevacion {
  int consultas = 0;

  @override
  Future<List<double>> alturas(List<LatLng> puntos) async {
    consultas++;
    return [for (final p in puntos) (p.latitude - 7.0) * 10000];
  }
}

void main() {
  const tee = LatLng(7.0000, -73.0000);
  const green = LatLng(7.0030, -73.0010);

  group('MallaElevacion', () {
    test('se carga con una sola consulta de 100 puntos', () async {
      final fuente = _RampaNorte();
      await MallaElevacion.cargar([tee, green], fuente);
      expect(fuente.consultas, 1);
    });

    test('interpola la altura dentro del hoyo', () async {
      final malla = await MallaElevacion.cargar([tee, green], _RampaNorte());
      expect(malla.alturaEn(tee), closeTo(0, 0.01));
      expect(malla.alturaEn(green), closeTo(30, 0.01));
      expect(malla.alturaEn(const LatLng(7.0015, -73.0005)), closeTo(15, 0.01));
    });

    test('incluye un margen alrededor de los puntos del hoyo', () async {
      final malla = await MallaElevacion.cargar([tee, green], _RampaNorte(), margenMetros: 80);
      // 50 m al sur del tee sigue dentro de la malla.
      expect(malla.alturaEn(const LatLng(6.99955, -73.0000)), isNotNull);
    });

    test('fuera de la malla no inventa alturas', () async {
      final malla = await MallaElevacion.cargar([tee, green], _RampaNorte());
      expect(malla.alturaEn(const LatLng(7.02, -73.0)), isNull);
    });
  });

  group('juegaComo', () {
    test('cuesta arriba suma, cuesta abajo resta (1 m ≈ 1.09 yardas)', () {
      expect(juegaComo(150, 10), 161);
      expect(juegaComo(150, -10), 139);
    });

    test('desniveles menores a 2 m no se consideran', () {
      expect(juegaComo(150, 1.5), isNull);
      expect(juegaComo(150, -1.9), isNull);
    });
  });

  group('OpenMeteoElevacion', () {
    test('pide las coordenadas en una sola llamada y devuelve las alturas en orden', () async {
      late Uri pedida;
      final cliente = MockClient((req) async {
        pedida = req.url;
        return http.Response(jsonEncode({'elevation': [13.0, 47.0]}), 200);
      });
      final alturas = await OpenMeteoElevacion(cliente: cliente).alturas([tee, green]);

      expect(alturas, [13.0, 47.0]);
      expect(pedida.host, 'api.open-meteo.com');
      expect(pedida.queryParameters['latitude'], '7.000000,7.003000');
      expect(pedida.queryParameters['longitude'], '-73.000000,-73.001000');
    });

    test('divide en lotes de 100 coordenadas', () async {
      var llamadas = 0;
      final cliente = MockClient((req) async {
        llamadas++;
        final n = req.url.queryParameters['latitude']!.split(',').length;
        return http.Response(jsonEncode({'elevation': List.filled(n, 1.0)}), 200);
      });
      final puntos = List.generate(150, (i) => LatLng(7 + i * 0.0001, -73));
      final alturas = await OpenMeteoElevacion(cliente: cliente).alturas(puntos);
      expect(llamadas, 2);
      expect(alturas.length, 150);
    });

    test('un error del servidor se reporta como excepción', () async {
      final cliente = MockClient((_) async => http.Response('error', 500));
      expect(OpenMeteoElevacion(cliente: cliente).alturas([tee]), throwsException);
    });
  });
}
