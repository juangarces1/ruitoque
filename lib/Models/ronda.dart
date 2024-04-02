import 'package:ruitoque/Models/campo.dart';
import 'package:ruitoque/Models/tarjeta.dart';

class Ronda {
  final int id;
  final DateTime fecha;
  final List<Tarjeta> tarjetas; // Asegúrate de que tienes una clase 'Tarjeta' definida en Dart.
  final Campo campo; // Asegúrate de que tienes una clase 'Campo' definida en Dart.
  final int? campoId;
  final bool isComplete;

  Ronda({
    required this.id,
    required this.fecha,
    required this.tarjetas,
    required this.campo,
    this.campoId,
    required this.isComplete,
  });

  factory Ronda.fromJson(Map<String, dynamic> json) {
    return Ronda(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      tarjetas: (json['tarjetas'] as List).map((item) => Tarjeta.fromJson(item)).toList(),
      campo: Campo.fromJson(json['campo']),
      campoId: json['campoId'],
      isComplete: json['isComplete'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'tarjetas': tarjetas.map((tarjeta) => tarjeta.toJson()).toList(),
        'campo': campo.toJson(),
        'campoId': campoId,
        'isComplete': isComplete,
      };
}
