// lib/Models/stableford_result.dart

import 'package:ruitoque/Models/jugador.dart';
import 'package:ruitoque/Models/stable_ford_hoyo.dart';

class StablefordResult {
  final List<StablefordHoyo> puntosPorHoyo;
  final Map<Jugador, int> puntosTotalesPorJugador;

  StablefordResult({
    required this.puntosPorHoyo,
    required this.puntosTotalesPorJugador,
  });
}
