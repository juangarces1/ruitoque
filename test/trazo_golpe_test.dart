import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Screens/Mapas/Components/trazo_golpe.dart';

void main() {
  const desde = LatLng(7.0000, -73.0000);
  const hasta = LatLng(7.0020, -73.0000);

  testWidgets('la bola avanza de desde a hasta y termina exactamente en hasta', (tester) async {
    final posiciones = <LatLng>[];
    var terminado = false;
    TrazoGolpe().animar(desde, hasta, posiciones.add).then((_) => terminado = true);

    await tester.pump(TrazoGolpe.duracion ~/ 2);
    expect(terminado, isFalse);
    final aMitad = posiciones.last.latitude;
    // Con easeOut a mitad de tiempo ya recorrió más de la mitad.
    expect(aMitad, greaterThan(7.0010));
    expect(aMitad, lessThan(7.0020));

    await tester.pump(TrazoGolpe.duracion);
    expect(terminado, isTrue);
    expect(posiciones.last, hasta);
    // Nunca retrocede.
    for (var i = 1; i < posiciones.length; i++) {
      expect(posiciones[i].latitude, greaterThanOrEqualTo(posiciones[i - 1].latitude));
    }
  });

  testWidgets('cancelar termina la animación y deja de avisar', (tester) async {
    final trazo = TrazoGolpe();
    final posiciones = <LatLng>[];
    var terminado = false;
    trazo.animar(desde, hasta, posiciones.add).then((_) => terminado = true);

    await tester.pump(const Duration(milliseconds: 200));
    trazo.cancelar();
    await tester.pump();
    final cantidad = posiciones.length;
    expect(terminado, isTrue);

    await tester.pump(TrazoGolpe.duracion);
    expect(posiciones.length, cantidad);
  });
}
