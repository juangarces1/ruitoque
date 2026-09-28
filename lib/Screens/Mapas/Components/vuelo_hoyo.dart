import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Screens/Mapas/Components/ruta_hoyo.dart';

/// Un tramo del recorrido aéreo: a dónde va la cámara, cuánto tarda en llegar
/// y cuánto se queda quieta al llegar.
class PasoCamara {
  final CameraPosition camara;
  final Duration duracion;
  final Duration pausa;

  const PasoCamara(this.camara, this.duracion, {this.pausa = Duration.zero});
}

const double _inclinacionVuelo = 55;

/// Vista de todo el hoyo, plana y orientada del origen al objetivo.
CameraPosition camaraGeneral(RutaHoyo ruta) => CameraPosition(
      target: interpolar(ruta.origen, ruta.objetivo, 0.5),
      bearing: rumbo(ruta.origen, ruta.objetivo),
      zoom: zoomParaDistancia(yardasEntre(ruta.origen, ruta.objetivo) / 1.09361),
    );

/// Cámara de arranque del vuelo: a ras del origen, mirando al primer punto.
CameraPosition camaraInicioVuelo(RutaHoyo ruta) => CameraPosition(
      target: ruta.origen,
      bearing: rumbo(ruta.origen, ruta.puntos[1]),
      tilt: _inclinacionVuelo,
      zoom: 18.5,
    );

/// Recorrido estilo transmisión de TV: sigue la ruta punto por punto hasta el
/// green, se detiene un momento y se abre a la vista general.
List<PasoCamara> pasosVuelo(RutaHoyo ruta) {
  final puntos = ruta.puntos;
  final pasos = <PasoCamara>[];
  var rumboActual = rumbo(puntos[0], puntos[1]);

  for (var i = 1; i < puntos.length; i++) {
    final esGreen = i == puntos.length - 1;
    // En cada punto la cámara ya gira hacia el siguiente, para anticipar los doglegs.
    if (!esGreen) rumboActual = rumbo(puntos[i], puntos[i + 1]);
    final ms = (yardasEntre(puntos[i - 1], puntos[i]) * 8).clamp(1200, 3000);
    pasos.add(PasoCamara(
      CameraPosition(
        target: puntos[i],
        bearing: rumboActual,
        tilt: esGreen ? 45 : _inclinacionVuelo,
        zoom: esGreen ? 19.5 : 18.5,
      ),
      Duration(milliseconds: ms.toInt()),
      pausa: Duration(milliseconds: esGreen ? 700 : 0),
    ));
  }

  pasos.add(PasoCamara(camaraGeneral(ruta), const Duration(milliseconds: 1500)));
  return pasos;
}
