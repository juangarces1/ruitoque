// lib/Models/fede_amigos_result.dart
import 'package:ruitoque/Models/jugador.dart';

class FedeAmigosResult {
  final Map<Jugador, double> puntosPorJugador;
  final List<FedeAmigosHoyoGanado> hoyosGanados;
  final List<PosicionCategoria> posicionesIda;
  final List<PosicionCategoria> posicionesVuelta;
  final List<PosicionCategoria> posicionesTotal;

  FedeAmigosResult({
    required this.puntosPorJugador,
    required this.hoyosGanados,
     required this.posicionesIda,
    required this.posicionesVuelta,
    required this.posicionesTotal,
  });
}

class FedeAmigosHoyoGanado {
  final int holeNumber;
  final Jugador ganador;

  FedeAmigosHoyoGanado({
    required this.holeNumber,
    required this.ganador,
  });
}

class PosicionCategoria {
  final int posicion;
  final List<Jugador> jugadores;

  PosicionCategoria({
    required this.posicion,
    required this.jugadores,
  });
}
