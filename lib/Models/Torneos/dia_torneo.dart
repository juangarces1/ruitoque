import 'package:ruitoque/Models/ronda.dart';

class DiaTorneo {
  DateTime fecha;
  List<Ronda> rondas;

  DiaTorneo({
    required this.fecha,
    required this.rondas,
  });

  factory DiaTorneo.fromJson(Map<String, dynamic> json) {
    return DiaTorneo(
      fecha: DateTime.parse(json['fecha']),
      rondas: (json['rondas'] as List).map((r) => Ronda.fromJson(r)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'fecha': fecha.toIso8601String(),
        'rondas': rondas.map((r) => r.toJson()).toList(),
      };
}
