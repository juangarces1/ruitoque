import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Screens/Mapas/Components/ruta_hoyo.dart';

void main() {
  // Tee y green separados ~300 yardas hacia el norte.
  const tee = LatLng(7.0000, -73.0000);
  const green = LatLng(7.0025, -73.0000);

  group('intermediosPara', () {
    test('desde el tee: par 3 → 0, par 4 → 1, par 5 → 2', () {
      expect(RutaHoyo.intermediosPara(par: 3, golpesDados: 0), 0);
      expect(RutaHoyo.intermediosPara(par: 4, golpesDados: 0), 1);
      expect(RutaHoyo.intermediosPara(par: 5, golpesDados: 0), 2);
    });

    test('cada golpe dado resta un punto intermedio, nunca menos de 0', () {
      expect(RutaHoyo.intermediosPara(par: 4, golpesDados: 1), 0);
      expect(RutaHoyo.intermediosPara(par: 5, golpesDados: 1), 1);
      expect(RutaHoyo.intermediosPara(par: 5, golpesDados: 4), 0);
      expect(RutaHoyo.intermediosPara(par: 3, golpesDados: 2), 0);
    });
  });

  group('planear', () {
    test('sin intermedios la ruta es origen → objetivo', () {
      final ruta = RutaHoyo.planear(origen: tee, green: green, cantidadIntermedios: 0);
      expect(ruta.puntos, [tee, green]);
      expect(ruta.objetivoMovible, isTrue);
    });

    test('con un intermedio usa el centro del hoyo si existe', () {
      const centroHoyo = LatLng(7.0015, -73.0005);
      final ruta = RutaHoyo.planear(
        origen: tee,
        green: green,
        cantidadIntermedios: 1,
        centroHoyo: centroHoyo,
      );
      expect(ruta.intermedios, [centroHoyo]);
      expect(ruta.objetivoMovible, isFalse);
    });

    test('dos intermedios se reparten a 1/3 y 2/3 del recorrido', () {
      final ruta = RutaHoyo.planear(origen: tee, green: green, cantidadIntermedios: 2);
      expect(ruta.intermedios.length, 2);
      expect(ruta.intermedios[0].latitude, closeTo(7.0025 / 3 + 7.0 * 2 / 3, 1e-9));
      expect(ruta.intermedios[1].latitude, closeTo(7.0025 * 2 / 3 + 7.0 / 3, 1e-9));
      // Tramos iguales
      final tramos = ruta.tramosYardas;
      expect(tramos.length, 3);
      expect((tramos[0] - tramos[1]).abs(), lessThanOrEqualTo(1));
      expect((tramos[1] - tramos[2]).abs(), lessThanOrEqualTo(1));
    });
  });

  group('distancias', () {
    test('yardasEntre ~ 304 yardas para 0.0025° de latitud', () {
      expect(yardasEntre(tee, green), inInclusiveRange(300, 308));
    });

    test('la suma de tramos es el total de la ruta', () {
      final ruta = RutaHoyo.planear(origen: tee, green: green, cantidadIntermedios: 2);
      expect(ruta.totalYardas, ruta.tramosYardas.reduce((a, b) => a + b));
    });

    test('centrosTramos devuelve un punto medio por tramo', () {
      final ruta = RutaHoyo.planear(origen: tee, green: green, cantidadIntermedios: 1);
      expect(ruta.centrosTramos.length, 2);
    });
  });

  group('mover puntos', () {
    test('mover un intermedio cambia los tramos', () {
      final ruta = RutaHoyo.planear(origen: tee, green: green, cantidadIntermedios: 1);
      const nuevo = LatLng(7.0020, -73.0010);
      ruta.moverIntermedio(0, nuevo);
      expect(ruta.intermedios.single, nuevo);
      expect(ruta.tramosYardas[0], yardasEntre(tee, nuevo));
    });

    test('mover el objetivo solo cuando no hay intermedios', () {
      final ruta = RutaHoyo.planear(origen: tee, green: green, cantidadIntermedios: 0);
      const nuevo = LatLng(7.0010, -73.0000);
      ruta.moverObjetivo(nuevo);
      expect(ruta.objetivo, nuevo);
      expect(ruta.tramosYardas.single, yardasEntre(tee, nuevo));
    });
  });

  test('rumbo hacia el norte es ~0° y hacia el este ~90°', () {
    expect(rumbo(tee, green), closeTo(0, 0.01));
    expect(rumbo(tee, const LatLng(7.0, -72.9975)), closeTo(90, 0.1));
  });

  test('zoomParaDistancia acerca más en hoyos cortos', () {
    expect(zoomParaDistancia(150), greaterThan(zoomParaDistancia(450)));
  });
}
