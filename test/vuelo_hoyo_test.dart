import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Screens/Mapas/Components/ruta_hoyo.dart';
import 'package:ruitoque/Screens/Mapas/Components/vuelo_hoyo.dart';

void main() {
  const tee = LatLng(7.0000, -73.0000);
  const green = LatLng(7.0036, -73.0000); // ~440 yardas al norte

  RutaHoyo ruta(int intermedios) =>
      RutaHoyo.planear(origen: tee, green: green, cantidadIntermedios: intermedios);

  test('la cámara del vuelo arranca en el origen, inclinada y mirando al primer punto', () {
    final r = ruta(1);
    final inicio = camaraInicioVuelo(r);
    expect(inicio.target, tee);
    expect(inicio.tilt, greaterThan(30));
    expect(inicio.bearing, closeTo(rumbo(tee, r.intermedios.first), 0.01));
  });

  test('el vuelo pasa por cada punto de la ruta y termina en la vista general', () {
    final r = ruta(2);
    final pasos = pasosVuelo(r);
    // 2 intermedios + green + vista general
    expect(pasos.length, 4);
    expect(pasos[0].camara.target, r.intermedios[0]);
    expect(pasos[1].camara.target, r.intermedios[1]);
    expect(pasos[2].camara.target, green);
    expect(pasos.last.camara, camaraGeneral(r));
    expect(pasos.last.camara.tilt, 0);
  });

  test('par 3: del tee directo al green y a la vista general', () {
    final pasos = pasosVuelo(ruta(0));
    expect(pasos.map((p) => p.camara.target).take(1), [green]);
    expect(pasos.length, 2);
  });

  test('los tramos largos tardan más, dentro de un límite', () {
    final corto = pasosVuelo(RutaHoyo.planear(
      origen: tee,
      green: const LatLng(7.0010, -73.0000),
      cantidadIntermedios: 0,
    )).first.duracion;
    final largo = pasosVuelo(ruta(0)).first.duracion;
    expect(largo, greaterThan(corto));
    expect(largo, lessThanOrEqualTo(const Duration(milliseconds: 3000)));
    expect(corto, greaterThanOrEqualTo(const Duration(milliseconds: 1200)));
  });

  test('la vista general mira del origen al objetivo', () {
    final r = ruta(1);
    expect(camaraGeneral(r).bearing, closeTo(rumbo(tee, green), 0.01));
    expect(camaraGeneral(r).target, interpolar(tee, green, 0.5));
  });
}
