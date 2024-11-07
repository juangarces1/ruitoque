// lib/Models/stableford_hoyo.dart
import 'package:ruitoque/Models/jugador.dart';

class StablefordHoyo {
  final int holeNumber;
  final Jugador jugador;
  final int puntos;

  StablefordHoyo({
    required this.holeNumber,
    required this.jugador,
    required this.puntos,
  });

  factory StablefordHoyo.fromJson(Map<String, dynamic> json) {
    return StablefordHoyo(
      holeNumber: json['holeNumber'],
      jugador: Jugador.fromJson(json['jugador']),
      puntos: json['puntos'],
    );
  }

  Map<String, dynamic> toJson() => {
        'holeNumber': holeNumber,
        'jugador': jugador.toJson(),
        'puntos': puntos,
      };
}
