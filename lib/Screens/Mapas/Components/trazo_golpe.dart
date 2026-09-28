import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ruitoque/Screens/Mapas/Components/ruta_hoyo.dart';

/// Color de los golpes ya dados y de la trayectoria de la bola.
const colorGolpes = Color(0xFFFFC107);

/// Vuelo de la bola en un golpe: avisa unas 30 veces por segundo dónde va la bola,
/// frenando al final como una bola que aterriza.
class TrazoGolpe {
  static const duracion = Duration(milliseconds: 1200);
  static const _cuadro = Duration(milliseconds: 33);

  Timer? _timer;
  Completer<void>? _terminado;

  Future<void> animar(LatLng desde, LatLng hasta, void Function(LatLng bola) alAvanzar) {
    cancelar();
    final terminado = _terminado = Completer<void>();
    final cuadros = duracion.inMilliseconds / _cuadro.inMilliseconds;

    _timer = Timer.periodic(_cuadro, (timer) {
      final t = (timer.tick / cuadros).clamp(0.0, 1.0);
      alAvanzar(t >= 1 ? hasta : interpolar(desde, hasta, Curves.easeOutCubic.transform(t)));
      if (t >= 1) cancelar();
    });
    return terminado.future;
  }

  void cancelar() {
    _timer?.cancel();
    _timer = null;
    if (_terminado?.isCompleted == false) _terminado!.complete();
  }
}
