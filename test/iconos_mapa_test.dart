import 'dart:typed_data';

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruitoque/Screens/Mapas/Components/iconos_mapa.dart';

int _anchoPng(Uint8List png) => ByteData.sublistView(png).getUint32(16);
int _altoPng(Uint8List png) => ByteData.sublistView(png).getUint32(20);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('genera un PNG', () async {
    final png = await dibujarEtiquetaPng('150y', pixelRatio: 2);
    expect(png.sublist(1, 4), 'PNG'.codeUnits);
  });

  test('un texto más largo produce una etiqueta más ancha', () async {
    final corta = await dibujarEtiquetaPng('9y', pixelRatio: 2);
    final larga = await dibujarEtiquetaPng('450y', pixelRatio: 2);
    expect(_anchoPng(larga), greaterThan(_anchoPng(corta)));
  });

  test('se dibuja a la densidad de la pantalla', () async {
    final x1 = await dibujarEtiquetaPng('150y', pixelRatio: 1);
    final x3 = await dibujarEtiquetaPng('150y', pixelRatio: 3);
    expect(_altoPng(x3), closeTo(_altoPng(x1) * 3, 3));
  });

  test('el punto es cuadrado y del tamaño pedido', () async {
    final png = await dibujarPuntoPng(
      relleno: const Color(0xFFFFFFFF),
      borde: const Color(0xFFFFC107),
      diametro: 14,
      pixelRatio: 2,
    );
    expect(_anchoPng(png), 28);
    expect(_altoPng(png), 28);
  });
}
