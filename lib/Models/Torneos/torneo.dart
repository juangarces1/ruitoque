import 'package:ruitoque/Models/Torneos/dia_torneo.dart';

class Torneo {
  int id;
  String nombre;
  DateTime fechaInicio;
  DateTime fechaFin;
  List<DiaTorneo> dias;

  Torneo({
    required this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.dias,
  });

  factory Torneo.fromJson(Map<String, dynamic> json) {
    return Torneo(
      id: json['id'],
      nombre: json['nombre'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      dias: (json['dias'] as List).map((d) => DiaTorneo.fromJson(d)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'dias': dias.map((d) => d.toJson()).toList(),
      };
}
