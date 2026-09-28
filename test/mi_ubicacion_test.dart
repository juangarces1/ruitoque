import 'package:flutter_test/flutter_test.dart';
import 'package:ruitoque/Screens/Mapas/Components/mi_ubicacion.dart';

void main() {
  group('marcaCruzada', () {
    test('avisa al cruzar un múltiplo de 50 yardas, en cualquier dirección', () {
      expect(marcaCruzada(148, 152), 150);
      expect(marcaCruzada(152, 148), 150);
      expect(marcaCruzada(199, 200), 200);
    });

    test('no avisa si se mueve dentro del mismo tramo de 50', () {
      expect(marcaCruzada(151, 160), isNull);
      expect(marcaCruzada(160, 151), isNull);
      expect(marcaCruzada(150, 150), isNull);
    });

    test('no avisa por debajo de 50 yardas (el chip se mide a ojo)', () {
      expect(marcaCruzada(10, 30), isNull);
      expect(marcaCruzada(49, 51), 50);
    });

    test('un salto grande avisa la marca más cercana a donde quedó', () {
      expect(marcaCruzada(140, 260), 250);
      expect(marcaCruzada(260, 140), 150);
    });
  });

  group('pulso', () {
    test('arranca pequeño y visible y termina grande y transparente', () {
      final inicio = pulso(0);
      final fin = pulso(0.999);
      expect(inicio.radioMetros, lessThan(fin.radioMetros));
      expect(inicio.opacidad, greaterThan(0.5));
      expect(fin.opacidad, lessThan(0.05));
    });

    test('crece y se desvanece de forma continua', () {
      var anterior = pulso(0);
      for (var t = 0.05; t < 1; t += 0.05) {
        final actual = pulso(t);
        expect(actual.radioMetros, greaterThan(anterior.radioMetros));
        expect(actual.opacidad, lessThanOrEqualTo(anterior.opacidad));
        anterior = actual;
      }
    });
  });

  test('radioPrecision acota valores absurdos del GPS', () {
    expect(radioPrecision(0.5), 3);
    expect(radioPrecision(8), 8);
    expect(radioPrecision(500), 50);
  });
}
